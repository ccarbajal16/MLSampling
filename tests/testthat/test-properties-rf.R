# Property-Based Tests for Random Forest Optimization Module
# Tests properties of RF optimization and feature importance

library(testthat)

# Source the RF module directly for testing
source("../../R/random-forest-optimization.R")

# Check if quickcheck is available
quickcheck_available <- FALSE # Disable for now to test basic functionality

# Test generators for RF property tests
create_spatial_raster_generator <- function() {
  function() {
    nrows <- sample(20:50, 1)
    ncols <- sample(20:50, 1)
    nlayers <- sample(2:4, 1)
    
    r <- terra::rast(nrows = nrows, ncols = ncols, nlyr = nlayers)
    terra::values(r) <- matrix(rnorm(nrows * ncols * nlayers), ncol = nlayers)
    terra::crs(r) <- "EPSG:4326"
    terra::ext(r) <- c(0, 1, 0, 1)
    names(r) <- paste0("feature_", 1:nlayers)
    
    return(r)
  }
}

create_sample_locations_generator <- function(field_data) {
  function() {
    n_samples <- sample(10:20, 1)
    ext <- terra::ext(field_data$covariates)
    
    x_coords <- runif(n_samples, ext[1], ext[2])
    y_coords <- runif(n_samples, ext[3], ext[4])
    
    # Add target variable
    samples <- data.frame(
      x = x_coords, 
      y = y_coords, 
      soil_property = rnorm(n_samples, mean = 10, sd = 2),
      class_property = sample(c("A", "B"), n_samples, replace = TRUE),
      id = 1:n_samples
    )
    
    return(sf::st_as_sf(samples, coords = c("x", "y"), crs = terra::crs(field_data$covariates)))
  }
}

create_field_data_generator <- function() {
  function() {
    covariates <- create_spatial_raster_generator()()
    
    field_data <- list(
      covariates = covariates,
      boundary = terra::as.polygons(terra::ext(covariates)),
      metadata = list(
        crs = terra::crs(covariates),
        extent = terra::ext(covariates)
      )
    )
    
    return(field_data)
  }
}

# Property Test 5: RF Feature Importance Optimization
# **Validates: Requirements 3.1, 3.2**

test_that("Property 5: RF Feature Importance Optimization - RF must calculate feature importance", {
  
  if (quickcheck_available) {
    # Quickcheck implementation would go here
  } else {
    # Manual property test
    test_cases <- 5
    
    for (i in 1:test_cases) {
      
      # Generate test data
      field_data <- create_field_data_generator()()
      existing_samples <- create_sample_locations_generator(field_data)()
      
      # Initialize RF module
      rf_opt <- RandomForestOptimization$new()

      # Fit model
      model_result <- rf_opt$fit_model(field_data, existing_samples, target_variable = "soil_property")

      # Property: Feature importance must be calculated and returned
      importance <- rf_opt$get_feature_importance()

      expect_true(is.data.frame(importance),
                 info = paste("Test case", i, ": Importance is not a data frame"))
      expect_true(nrow(importance) > 0,
                 info = paste("Test case", i, ": Importance table is empty"))
      expect_true(all(c("feature", "importance") %in% names(importance)),
                 info = paste("Test case", i, ": Importance table missing columns"))

      # Property: Importance scores should be numeric
      expect_true(is.numeric(importance$importance),
                 info = paste("Test case", i, ": Importance scores are not numeric"))

      # Property: Feature names should match covariates
      covariate_names <- names(field_data$covariates)
      # Note: Depending on spatial autocorr, there might be extra features
      expect_true(any(importance$feature %in% covariate_names),
                 info = paste("Test case", i, ": No original covariates in importance list"))
    }
  }
})

# Property Test 6: RF Task Type Support
# **Validates: Requirements 3.3**

test_that("Property 6: RF Task Type Support - RF must support both regression and classification", {
  
  test_cases <- 3
  
  for (i in 1:test_cases) {
    
    field_data <- create_field_data_generator()()
    existing_samples <- create_sample_locations_generator(field_data)()
    
    rf_opt <- RandomForestOptimization$new()
    
    # Test Regression
    reg_result <- rf_opt$fit_model(field_data, existing_samples, target_variable = "soil_property")
    expect_true(reg_result$model$type == "regression",
               info = paste("Test case", i, ": Model type should be regression"))

    # Test Classification
    # Convert factor column explicitly for randomForest
    existing_samples$class_property <- as.factor(existing_samples$class_property)

    class_result <- rf_opt$fit_model(field_data, existing_samples, target_variable = "class_property")
    expect_true(class_result$model$type == "classification",
               info = paste("Test case", i, ": Model type should be classification"))
  }
})

# Property Test 7: Spatial Autocorrelation Integration
# **Validates: Requirements 3.4**

test_that("Property 7: Spatial Autocorrelation Integration - Spatial features should be added when enabled", {
  
  field_data <- create_field_data_generator()()
  existing_samples <- create_sample_locations_generator(field_data)()
  
  # With Spatial Autocorrelation
  rf_spatial <- RandomForestOptimization$new(config = list(spatial_autocorr = TRUE))
  res_spatial <- rf_spatial$fit_model(field_data, existing_samples, target_variable = "soil_property")
  
  # Without Spatial Autocorrelation
  rf_no_spatial <- RandomForestOptimization$new(config = list(spatial_autocorr = FALSE))
  res_no_spatial <- rf_no_spatial$fit_model(field_data, existing_samples, target_variable = "soil_property")
  
  # Check importance tables
  imp_spatial <- rf_spatial$get_feature_importance()
  imp_no_spatial <- rf_no_spatial$get_feature_importance()
  
  # Property: Spatial model should have more features (or at least the spatial ones)
  # In our implementation, we added 'spatial_lag'
  expect_true("spatial_lag" %in% imp_spatial$feature,
              info = "Spatial lag feature missing in spatial model")
  expect_false("spatial_lag" %in% imp_no_spatial$feature,
               info = "Spatial lag feature present in non-spatial model")
})

test_that("RF Optimization generates valid locations", {
  
  field_data <- create_field_data_generator()()
  existing_samples <- create_sample_locations_generator(field_data)()
  
  rf_opt <- RandomForestOptimization$new()
  rf_opt$fit_model(field_data, existing_samples, target_variable = "soil_property")
  
  n_new <- 5
  new_locs <- rf_opt$optimize_locations(field_data, n_new_samples = n_new)
  
  expect_equal(nrow(new_locs), n_new)
  expect_true(all(c("x", "y") %in% names(new_locs)))
})
