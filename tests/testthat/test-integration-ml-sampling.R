# Integration Tests for Main MLSampling Class
# Validates end-to-end functionality and module integration

library(testthat)

# Source all relevant modules
# In a package context, these would be loaded automatically
# For testing script, we might need to source them if not installed
# Note: The run script already sources all R files, so we can skip manual sourcing here
# or use a check.

if (!exists("MLSampling")) {
  # Fallback if run directly without helper
  r_files <- list.files("../../R", full.names = TRUE)
  for(f in r_files) try(source(f), silent = TRUE)
}

# Generators
create_test_data <- function() {
  # Small synthetic dataset
  r <- terra::rast(nrows = 10, ncols = 10, nlyr = 2)
  terra::values(r) <- matrix(rnorm(200), ncol = 2)
  terra::crs(r) <- "EPSG:4326"
  terra::ext(r) <- c(0, 1, 0, 1)
  names(r) <- c("feat1", "feat2")
  
  boundary <- terra::as.polygons(terra::ext(r))
  terra::crs(boundary) <- "EPSG:4326"
  
  existing <- data.frame(x = runif(5), y = runif(5), id = 1:5, target = rnorm(5))
  existing_sf <- sf::st_as_sf(existing, coords = c("x", "y"), crs = "EPSG:4326")
  
  return(list(
    field_data = list(
      covariates = r,
      boundary = boundary,
      metadata = list(crs = "EPSG:4326")
    ),
    existing_samples = existing_sf
  ))
}

test_that("MLSampling initialization works", {
  tool <- MLSampling$new()
  expect_true(inherits(tool, "MLSampling"))
  # Note: MLSampling does NOT inherit from SoilSamplingTool; 
  # SoilSamplingTool is now an alias for MLSampling
  expect_true(inherits(tool, "R6"))
  expect_true("BDL" %in% tool$supported_algorithms)
  expect_true("RF" %in% tool$supported_algorithms)
})

test_that("MLSampling runs BDL optimization", {
  data <- create_test_data()
  tool <- MLSampling$new()
  
  # Mock the BDL module to avoid torch dependency issues in test environment
  mock_bdl <- R6::R6Class("MockBDL",
    public = list(
      fit_model = function(...) TRUE,
      predict_with_uncertainty = function(locs, ...) {
        list(total_uncertainty = runif(nrow(locs)))
      }
    )
  )
  tool$bdl_module <- mock_bdl$new()
  
  result <- tool$run_bdl(data$field_data, data$existing_samples, n_new_samples = 5)
  
  expect_true(inherits(result, "OptimizationResult"))
  expect_equal(result$algorithm_used, "BDL")
  expect_equal(nrow(result$selected_locations), 5)
})

test_that("MLSampling runs RF optimization", {
  data <- create_test_data()
  tool <- MLSampling$new()
  
  # Mock RF module
  mock_rf <- R6::R6Class("MockRF",
    public = list(
      fit_model = function(...) TRUE,
      optimize_locations = function(data, n) {
        sf::st_as_sf(data.frame(x=runif(n), y=runif(n)), coords=c("x","y"), crs="EPSG:4326")
      },
      get_feature_importance = function() data.frame(feature="f1", importance=1)
    )
  )
  tool$rf_module <- mock_rf$new()
  
  result <- tool$run_rf_optimization(data$field_data, data$existing_samples, n_new_samples = 5)
  
  expect_true(inherits(result, "OptimizationResult"))
  expect_equal(result$algorithm_used, "RF")
  expect_equal(nrow(result$selected_locations), 5)
})

test_that("MLSampling runs Ensemble optimization", {
  data <- create_test_data()
  tool <- MLSampling$new()
  
  # Mock Ensemble Manager
  mock_ensemble <- R6::R6Class("MockEnsemble",
    public = list(
      register_model = function(...) TRUE,
      run_ensemble = function(data, samples, n, method) {
        list(
          locations = sf::st_as_sf(data.frame(x=runif(n), y=runif(n)), coords=c("x","y"), crs="EPSG:4326"),
          individual_results = list()
        )
      }
    )
  )
  tool$ensemble_manager <- mock_ensemble$new()
  
  result <- tool$run_ensemble(data$field_data, data$existing_samples, n_new_samples = 5)
  
  expect_true(inherits(result, "OptimizationResult"))
  expect_equal(result$algorithm_used, "Ensemble")
})

test_that("MLSampling compares designs", {
  data <- create_test_data()
  tool <- MLSampling$new()
  
  # Mock comparison engine
  mock_comp <- R6::R6Class("MockComp",
    public = list(
      compare_designs = function(...) {
        list(metrics_summary = data.frame(mssd = c(0.1, 0.2)))
      }
    )
  )
  tool$comparison_engine <- mock_comp$new()
  
  # We need to mock BDL/RF runs inside compare_designs too, or provide pre-computed designs
  # For this unit test, we'll override run_bdl/run_rf to return dummy results
  # Note: R6 methods are locked, so we cannot easily override them.
  # Instead, we will rely on the actual implementation since we have verified they work.
  # Or we can create a subclass for testing if needed.
  # For integration test, running actual methods is better.
  
  result <- tool$compare_designs(data$field_data, data$existing_samples, n_new_samples = 5)
  
  expect_true(inherits(result, "ModelComparison"))
  expect_true(!is.null(result$constitutional_compliance))
})

test_that("Backward compatibility works", {
  tool <- MLSampling$new()
  expect_true("run_udl" %in% names(tool))
  expect_true("run_ufn" %in% names(tool))
})
