# Enhanced Data Models Tests for ML Metadata Support
# Constitutional Compliance: Code Quality Excellence and Spatial Analysis Excellence
# Tests for enhanced field data, ML results, and uncertainty quantification models

library(testthat)
library(terra)
library(sf)

# Source necessary files
source("../../R/error-handling.R")
source("../../R/field-data-model.R")
source("../../R/optimization-result-model.R")
source("../../R/uncertainty-quantification-model.R")
source("../../R/spatial-uncertainty.R")

# Test Enhanced Field Data Model with ML Metadata Support
test_that("Enhanced field data model with ML metadata validation", {
  
  # Create test data
  boundary <- sf::st_sfc(
    sf::st_polygon(list(matrix(c(0,0,100,100,0,0,100,100,0,0), ncol=2))),
    crs = 32633
  )
  covariates <- terra::rast(matrix(runif(100), 10, 10), crs = "EPSG:32633")
  names(covariates) <- "covariate1"
  
  # Test basic field data validation (existing functionality)
  basic_field_data <- list(
    boundary = boundary,
    covariates = covariates,
    crs = "EPSG:32633",
    resolution = 10,
    extent = c(0, 100, 0, 100)
  )
  
  expect_no_error({
    result <- validate_field_data_structure(basic_field_data, strict_validation = FALSE)
  })
  
  # Test enhanced field data with ML metadata
  enhanced_field_data <- list(
    boundary = boundary,
    covariates = covariates,
    crs = "EPSG:32633",
    resolution = 10,
    extent = c(0, 100, 0, 100),
    ml_metadata = list(
      feature_importance = c(0.8),
      uncertainty_maps = NULL,
      spatial_weights = matrix(c(1, 0.5, 0.5, 1), nrow = 2),
      preprocessing_steps = list("normalization"),
      ml_methods_applied = c("RF")
    )
  )
  
  expect_no_error({
    result <- validate_field_data_structure(enhanced_field_data, strict_validation = FALSE)
    expect_true(!is.null(result$ml_metadata))
    expect_equal(unname(result$ml_metadata$feature_importance), c(0.8))
    expect_equal(names(result$ml_metadata$feature_importance), "covariate1")
  })
})

test_that("ML metadata validation functions", {
  
  # Create test covariates
  covariates <- terra::rast(matrix(runif(100), 10, 10), crs = "EPSG:32633")
  names(covariates) <- c("covariate1")
  
  # Test valid feature importance
  valid_fi <- c(0.8)
  fi_validation <- validate_feature_importance(valid_fi, covariates)
  expect_true(fi_validation$valid)
  expect_length(fi_validation$issues, 0)
  
  # Test invalid feature importance (wrong length)
  invalid_fi <- c(0.8, 0.2)  # Too many values for 1 covariate
  fi_validation <- validate_feature_importance(invalid_fi, covariates)
  expect_false(fi_validation$valid)
  expect_true(length(fi_validation$issues) > 0)
  
  # Test invalid feature importance (negative values)
  negative_fi <- c(-0.2)
  fi_validation <- validate_feature_importance(negative_fi, covariates)
  expect_false(fi_validation$valid)
  expect_true(any(grepl("negative", fi_validation$issues)))
  
  # Test uncertainty maps validation
  uncertainty_raster <- terra::rast(matrix(runif(100, 0, 1), 10, 10), crs = "EPSG:32633")
  um_validation <- validate_uncertainty_maps(uncertainty_raster, covariates)
  expect_true(um_validation$valid)
  
  # Test spatial weights validation
  valid_weights <- matrix(c(1, 0.5, 0.5, 1), nrow = 2)
  sw_validation <- validate_spatial_weights(valid_weights)
  expect_true(sw_validation$valid)
  
  # Test invalid spatial weights (non-numeric)
  invalid_weights <- matrix(c("a", "b", "c", "d"), nrow = 2)
  sw_validation <- validate_spatial_weights(invalid_weights)
  expect_false(sw_validation$valid)
})

test_that("Empty ML metadata structure creation", {
  
  # Create test covariates with multiple layers
  covariates <- terra::rast(array(runif(300), dim = c(10, 10, 3)), crs = "EPSG:32633")
  names(covariates) <- c("elevation", "slope", "aspect")
  
  # Test empty ML metadata creation
  empty_ml <- create_empty_ml_metadata(covariates)
  
  expect_true(is.list(empty_ml))
  expect_equal(length(empty_ml$feature_importance), 3)
  expect_equal(names(empty_ml$feature_importance), c("elevation", "slope", "aspect"))
  expect_true(all(is.na(empty_ml$feature_importance)))
  expect_false(empty_ml$ready_for_ml)
  expect_equal(empty_ml$ml_methods_applied, character(0))
})

# Test ML Results Data Model
test_that("ML optimization result creation and validation", {
  
  # Create test data
  selected_locations <- data.frame(
    x = c(10, 20, 30),
    y = c(15, 25, 35),
    sample_id = c("ML001", "ML002", "ML003"),
    type = c("new", "new", "new"),
    model = c("BDL", "BDL", "BDL")
  )
  
  # Create ML components
  ml_components <- list(
    predictions = terra::rast(matrix(runif(100), 10, 10), crs = "EPSG:32633"),
    uncertainties = terra::rast(matrix(runif(100, 0, 0.5), 10, 10), crs = "EPSG:32633"),
    feature_importance = c(0.6, 0.4),
    trained_models = list(bdl_model = "mock_model_object")
  )
  
  # Test ML optimization result creation
  expect_no_error({
    ml_result <- create_ml_optimization_result(
      selected_locations = selected_locations,
      ml_components = ml_components,
      method = "BDL"
    )
  })
  
  # Validate ML result structure
  ml_result <- create_ml_optimization_result(
    selected_locations = selected_locations,
    ml_components = ml_components,
    method = "BDL"
  )
  
  expect_s3_class(ml_result, "MLOptimizationResult")
  expect_s3_class(ml_result, "OptimizationResult")
  expect_equal(ml_result$method, "BDL")
  expect_true(!is.null(ml_result$predictions))
  expect_true(!is.null(ml_result$uncertainties))
  expect_true(!is.null(ml_result$feature_importance))
  
  # Test validation
  validation <- validate_ml_optimization_result(ml_result)
  expect_true(validation$valid)
  expect_true(validation$ml_compliance)
})

test_that("ML components validation", {
  
  # Test valid ML components
  valid_components <- list(
    predictions = terra::rast(matrix(runif(100), 10, 10), crs = "EPSG:32633"),
    uncertainties = terra::rast(matrix(runif(100, 0, 1), 10, 10), crs = "EPSG:32633"),
    feature_importance = c(0.7, 0.3)
  )
  
  validation <- validate_ml_components(valid_components, "BDL")
  expect_true(validation$valid)
  expect_length(validation$issues, 0)
  
  # Test invalid predictions type
  invalid_components <- list(
    predictions = "not_a_raster",
    uncertainties = terra::rast(matrix(runif(100, 0, 1), 10, 10), crs = "EPSG:32633")
  )
  
  validation <- validate_ml_components(invalid_components, "BDL")
  expect_false(validation$valid)
  expect_true(any(grepl("Predictions", validation$issues)))
  
  # Test invalid feature importance type
  invalid_fi_components <- list(
    feature_importance = "not_numeric"
  )
  
  validation <- validate_ml_components(invalid_fi_components, "RF")
  expect_false(validation$valid)
  expect_true(any(grepl("Feature importance", validation$issues)))
})

test_that("ML method validation", {
  
  # Test valid methods
  expect_equal(validate_ml_method("BDL"), "BDL")
  expect_equal(validate_ml_method("RF"), "RF")
  expect_equal(validate_ml_method("UDL"), "UDL")
  expect_equal(validate_ml_method("UFN"), "UFN")
  expect_equal(validate_ml_method("Ensemble"), "Ensemble")
  
  # Test invalid methods
  expect_equal(validate_ml_method("InvalidMethod"), "unknown")
  expect_equal(validate_ml_method(NULL), "unknown")
  expect_equal(validate_ml_method(123), "unknown")
})

test_that("Backward compatibility for optimization results", {
  
  # Test that old create_optimization_result still works
  selected_locations <- data.frame(
    x = c(10, 20),
    y = c(15, 25),
    sample_id = c("OLD001", "OLD002"),
    type = c("new", "new"),
    model = c("UDL", "UDL")
  )
  
  expect_no_error({
    old_result <- create_optimization_result(selected_locations = selected_locations)
  })
  
  old_result <- create_optimization_result(selected_locations = selected_locations)
  expect_s3_class(old_result, "MLOptimizationResult")  # Should be enhanced version
  expect_equal(old_result$method, "unknown")  # Default method
})

# Test Uncertainty Quantification Data Model
test_that("Uncertainty results creation and validation", {
  
  # Create test uncertainty data
  epistemic_raster <- terra::rast(matrix(runif(100, 0, 0.3), 10, 10), crs = "EPSG:32633")
  aleatoric_raster <- terra::rast(matrix(runif(100, 0, 0.2), 10, 10), crs = "EPSG:32633")
  total_raster <- terra::rast(matrix(runif(100, 0, 0.4), 10, 10), crs = "EPSG:32633")
  
  # Test uncertainty results creation
  expect_no_error({
    uncertainty_results <- create_uncertainty_results(
      epistemic = epistemic_raster,
      aleatoric = aleatoric_raster,
      total = total_raster,
      method = "BDL"
    )
  })
  
  uncertainty_results <- create_uncertainty_results(
    epistemic = epistemic_raster,
    aleatoric = aleatoric_raster,
    total = total_raster,
    method = "BDL"
  )
  
  expect_s3_class(uncertainty_results, "UncertaintyResults")
  expect_equal(uncertainty_results$method, "BDL")
  expect_true(!is.null(uncertainty_results$epistemic))
  expect_true(!is.null(uncertainty_results$aleatoric))
  expect_true(!is.null(uncertainty_results$total))
  
  # Test validation
  validation <- validate_uncertainty_results(uncertainty_results)
  expect_true(validation$valid)
  expect_true(validation$constitutional_compliance)
})

test_that("Uncertainty component validation", {
  
  # Test valid uncertainty components
  valid_epistemic <- terra::rast(matrix(runif(100, 0, 1), 10, 10), crs = "EPSG:32633")
  validation <- validate_single_uncertainty_component(valid_epistemic, "epistemic")
  expect_true(validation$valid)
  
  # Test negative uncertainty values (should fail)
  invalid_epistemic <- terra::rast(matrix(runif(100, -0.5, 1), 10, 10), crs = "EPSG:32633")
  validation <- validate_single_uncertainty_component(invalid_epistemic, "epistemic")
  expect_false(validation$valid)
  expect_true(any(grepl("negative", validation$issues)))
  
  # Test all NA values (should fail)
  na_epistemic <- terra::rast(matrix(rep(NA, 100), 10, 10), crs = "EPSG:32633")
  validation <- validate_single_uncertainty_component(na_epistemic, "epistemic")
  expect_false(validation$valid)
  expect_true(any(grepl("NA values", validation$issues)))
  
  # Test numeric uncertainty
  numeric_uncertainty <- runif(10, 0, 1)
  validation <- validate_single_uncertainty_component(numeric_uncertainty, "total")
  expect_true(validation$valid)
  
  # Test invalid type
  invalid_type <- "not_valid_uncertainty"
  validation <- validate_single_uncertainty_component(invalid_type, "epistemic")
  expect_false(validation$valid)
})

test_that("Spatial consistency validation for uncertainties", {
  
  # Create spatially consistent uncertainty rasters
  epistemic <- terra::rast(matrix(runif(100, 0, 0.3), 10, 10), crs = "EPSG:32633")
  aleatoric <- terra::rast(matrix(runif(100, 0, 0.2), 10, 10), crs = "EPSG:32633")
  total <- terra::rast(matrix(runif(100, 0, 0.4), 10, 10), crs = "EPSG:32633")
  
  # Test spatial consistency
  consistency <- validate_spatial_consistency(epistemic, aleatoric, total, NULL)
  expect_true(consistency$consistent)
  expect_length(consistency$issues, 0)
  
  # Create spatially inconsistent rasters
  inconsistent_aleatoric <- terra::rast(matrix(runif(200, 0, 0.2), 20, 10), crs = "EPSG:32633")
  
  consistency <- validate_spatial_consistency(epistemic, inconsistent_aleatoric, total, NULL)
  expect_false(consistency$consistent)
  expect_true(length(consistency$issues) > 0)
})

test_that("Confidence intervals validation", {
  
  # Test valid confidence intervals
  lower_bound <- terra::rast(matrix(runif(100, 0, 0.3), 10, 10), crs = "EPSG:32633")
  upper_bound <- terra::rast(matrix(runif(100, 0.4, 0.8), 10, 10), crs = "EPSG:32633")
  
  ci <- list(
    lower_bound = lower_bound,
    upper_bound = upper_bound,
    confidence_level = 0.95
  )
  
  standardized_ci <- standardize_confidence_intervals(ci)
  expect_equal(standardized_ci$confidence_level, 0.95)
  expect_true(!is.null(standardized_ci$lower_bound))
  expect_true(!is.null(standardized_ci$upper_bound))
  
  # Test CI structure validation
  validation <- validate_confidence_intervals_structure(standardized_ci)
  expect_true(validation$valid)
  
  # Test invalid confidence level
  invalid_ci <- list(confidence_level = 1.5)  # > 1
  validation <- validate_confidence_intervals_structure(invalid_ci)
  expect_false(validation$valid)
  expect_true(any(grepl("Confidence level", validation$issues)))
})

test_that("Monte Carlo samples validation", {
  
  # Test valid MC samples (array)
  mc_array <- array(runif(1000), dim = c(10, 10, 10))
  validated_mc <- validate_mc_samples(mc_array)
  expect_identical(validated_mc, mc_array)
  
  # Test valid MC samples (matrix)
  mc_matrix <- matrix(runif(1000), nrow = 100, ncol = 10)
  validated_mc <- validate_mc_samples(mc_matrix)
  expect_identical(validated_mc, mc_matrix)
  
  # Test invalid MC samples type
  expect_warning({
    validated_mc <- validate_mc_samples("invalid_type")
  })
  
  # Test n_samples validation
  expect_equal(validate_n_samples(50, NULL), 50)
  expect_equal(validate_n_samples(NULL, mc_matrix), 10)  # Inferred from matrix
  expect_equal(validate_n_samples(NULL, mc_array), 10)   # Inferred from array
})

test_that("Derived uncertainty calculations", {
  
  # Create test uncertainties
  epistemic <- terra::rast(matrix(rep(0.3, 100), 10, 10), crs = "EPSG:32633")
  aleatoric <- terra::rast(matrix(rep(0.4, 100), 10, 10), crs = "EPSG:32633")
  
  uncertainty_results <- list(
    epistemic = epistemic,
    aleatoric = aleatoric,
    total = NULL
  )
  
  # Test derived uncertainty calculation
  enhanced_results <- calculate_derived_uncertainties(uncertainty_results)
  
  expect_true(!is.null(enhanced_results$total))
  expect_true(!is.null(enhanced_results$epistemic_ratio))
  
  # Check mathematical correctness (total = sqrt(epistemic^2 + aleatoric^2))
  expected_total <- sqrt(0.3^2 + 0.4^2)  # = 0.5
  actual_total <- terra::values(enhanced_results$total)[1]
  expect_equal(actual_total, expected_total, tolerance = 1e-6)
})

test_that("Uncertainty consistency validation", {
  
  # Create mathematically consistent uncertainties
  epistemic_vals <- rep(0.3, 100)
  aleatoric_vals <- rep(0.4, 100)
  total_vals <- sqrt(epistemic_vals^2 + aleatoric_vals^2)  # = 0.5
  
  epistemic <- terra::rast(matrix(epistemic_vals, 10, 10), crs = "EPSG:32633")
  aleatoric <- terra::rast(matrix(aleatoric_vals, 10, 10), crs = "EPSG:32633")
  total <- terra::rast(matrix(total_vals, 10, 10), crs = "EPSG:32633")
  
  uncertainty_results <- list(
    epistemic = epistemic,
    aleatoric = aleatoric,
    total = total
  )
  
  consistency <- validate_uncertainty_consistency(uncertainty_results)
  expect_true(consistency$consistent)
  expect_length(consistency$issues, 0)
  
  # Create mathematically inconsistent uncertainties (total < epistemic)
  inconsistent_total <- terra::rast(matrix(rep(0.1, 100), 10, 10), crs = "EPSG:32633")
  
  inconsistent_results <- list(
    epistemic = epistemic,
    aleatoric = aleatoric,
    total = inconsistent_total
  )
  
  consistency <- validate_uncertainty_consistency(inconsistent_results)
  expect_false(consistency$consistent)
  expect_true(length(consistency$issues) > 0)
})

test_that("Error handling for missing required inputs", {
  
  # Test field data validation with missing required fields
  expect_error({
    validate_field_data_structure(list(boundary = "test"))
  }, "Missing required fields")
  
  # Test uncertainty results with no uncertainty types
  expect_error({
    create_uncertainty_results()
  }, "At least one uncertainty type must be provided")
  
  # Test ML optimization result with missing locations
  expect_error({
    create_ml_optimization_result(selected_locations = NULL)
  }, "selected_locations is required")
})

# Helper functions for testing
create_test_field_data_with_ml <- function() {
  boundary <- sf::st_sfc(
    sf::st_polygon(list(matrix(c(0,0,100,100,0,0,100,100,0,0), ncol=2))),
    crs = 32633
  )
  covariates <- terra::rast(matrix(runif(100), 10, 10), crs = "EPSG:32633")
  names(covariates) <- "test_covariate"
  
  list(
    boundary = boundary,
    covariates = covariates,
    crs = "EPSG:32633",
    resolution = 10,
    extent = c(0, 100, 0, 100),
    ml_metadata = list(
      feature_importance = c(1.0),
      uncertainty_maps = NULL,
      spatial_weights = NULL,
      preprocessing_steps = list(),
      ml_methods_applied = character(0)
    )
  )
}

create_test_uncertainty_data <- function() {
  epistemic <- terra::rast(matrix(runif(100, 0, 0.3), 10, 10), crs = "EPSG:32633")
  aleatoric <- terra::rast(matrix(runif(100, 0, 0.2), 10, 10), crs = "EPSG:32633")
  total <- sqrt(epistemic^2 + aleatoric^2)
  
  list(
    epistemic = epistemic,
    aleatoric = aleatoric,
    total = total
  )
}
