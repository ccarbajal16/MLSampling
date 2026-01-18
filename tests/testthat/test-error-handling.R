# Error Handling and Validation Tests
# Validates Task 10: Standardized error classes and ML data validation

library(testthat)

test_that("Standardized errors are created correctly", {
  err <- MLSamplingError("General error")
  expect_true(inherits(err, "MLSamplingError"))
  expect_true(inherits(err, "error"))
  expect_equal(err$message, "General error")
  
  bdl_err <- BDLError("BDL error")
  expect_true(inherits(bdl_err, "BDLError"))
  expect_true(inherits(bdl_err, "MLSamplingError")) # Should it inherit? The impl doesn't say so but structure allows multiple classes
  # Current impl: class = c("BDLError", "error", "condition")
  # It does NOT inherit from MLSamplingError by default unless I change it.
  # Let's check implementation again.
  # create_error creates c(class, "error", "condition")
  
  expect_true(inherits(bdl_err, "error"))
})

test_that("with_error_handling wraps errors", {
  
  # Function that throws standard error
  f_stop <- function() stop("Standard R error")
  
  # Wrapped execution
  expect_error(
    with_error_handling(f_stop()),
    "MLSamplingError: Standard R error",
    class = "MLSamplingError"
  )
  
  # Function that throws custom error (should pass through)
  f_custom <- function() stop(BDLError("Custom BDL error"))
  
  expect_error(
    with_error_handling(f_custom()),
    "Custom BDL error",
    class = "BDLError"
  )
})

test_that("validate_ml_data checks target and features", {
  
  # Mock data
  df <- data.frame(
    x = 1:10,
    y = 1:10,
    target = rnorm(10),
    feat1 = rnorm(10)
  )
  
  # Valid case
  res <- validate_ml_data(df, "target")
  expect_true(res$is_valid)
  expect_true(res$has_target)
  
  # Missing target
  res_missing <- validate_ml_data(df, "missing_target")
  expect_false(res_missing$is_valid)
  expect_false(res_missing$has_target)
  
  # NA in target
  df_na <- df
  df_na$target[1] <- NA
  res_na <- validate_ml_data(df_na, "target")
  expect_true(res_na$is_valid) # Still valid, but warns
  expect_length(res_na$warnings, 1)
  
  # Constant target
  df_const <- df
  df_const$target <- 1
  res_const <- validate_ml_data(df_const, "target")
  expect_length(res_const$warnings, 1)
})

test_that("validate_ml_data validates CRS for sf training data", {
  boundary <- sf::st_as_sf(terra::as.polygons(terra::ext(terra::rast(nrows = 10, ncols = 10))))
  sf::st_crs(boundary) <- sf::st_crs("EPSG:4326")
  r <- terra::rast(nrows = 10, ncols = 10)
  terra::crs(r) <- "EPSG:4326"

  training <- sf::st_as_sf(data.frame(x = 1, y = 1, target = 1), coords = c("x", "y"), crs = 3857)
  field_data <- list(boundary = boundary, covariates = r)
  res <- validate_ml_data(training, "target", field_data = field_data)
  expect_false(res$is_valid)
  expect_true(any(grepl("CRS mismatch", res$issues)))
})

test_that("BDL and RF modules throw typed errors", {
  bdl <- suppressWarnings(BayesianDeepLearning$new())
  expect_error(
    bdl$predict_with_uncertainty(data.frame(x = 1, y = 1)),
    class = "BDLError"
  )

  rf <- RandomForestOptimization$new()
  expect_error(
    rf$optimize_locations(field_data = list(), n_new_samples = 1),
    class = "RFError"
  )

  eng <- SpatialAnalysisEngine$new()
  expect_error(
    eng$calculate_autocorrelation(data.frame(x = 1)),
    class = "ValidationError"
  )
})
