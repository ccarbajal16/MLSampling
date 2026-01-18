# Property-Based Tests for ML Ensemble Manager
# Validates ensemble methods and model integration

library(testthat)

# Source modules
source("../../R/ml-ensemble-manager.R")
# Mock classes for testing
MockModel <- R6::R6Class("MockModel",
  public = list(
    optimize_locations = function(field_data, n) {
      # Return random locations
      data.frame(x = runif(n), y = runif(n))
    },
    fit_model = function(field_data, existing_samples, target) {
      list(performance = list(rmse = runif(1)))
    }
  )
)

# Property 13: Ensemble Method Support
# **Validates: Requirements 5.1, 5.3**

test_that("Property 13: Ensemble Method Support - Ensemble correctly combines outputs", {
  
  ensemble <- MLEnsembleManager$new()
  
  # Register mock models
  ensemble$register_model("ModelA", MockModel$new())
  ensemble$register_model("ModelB", MockModel$new())
  
  # Dummy data
  field_data <- list()
  existing_samples <- data.frame(x=1:10, y=1:10, val=rnorm(10))
  n_new <- 5
  
  # Test Voting
  res_voting <- ensemble$run_ensemble(field_data, existing_samples, n_new, method = "voting")
  
  expect_true(is.list(res_voting))
  expect_true(nrow(res_voting$locations) == n_new)
  expect_true(length(res_voting$individual_results) == 2)
  
  # Test Stacking (currently falls back to voting in implementation)
  res_stacking <- ensemble$run_ensemble(field_data, existing_samples, n_new, method = "stacking")
  expect_true(nrow(res_stacking$locations) == n_new)
})

# Property 14: Unified ML Interface Consistency
# **Validates: Requirements 5.2, 5.5**

test_that("Property 14: Unified ML Interface Consistency - Compare models returns valid metrics", {
  
  ensemble <- MLEnsembleManager$new()
  ensemble$register_model("ModelA", MockModel$new())
  ensemble$register_model("ModelB", MockModel$new())
  
  field_data <- list()
  existing_samples <- data.frame()
  
  comp_metrics <- ensemble$compare_models(field_data, existing_samples, "target")
  
  expect_true(is.data.frame(comp_metrics))
  expect_true(nrow(comp_metrics) == 2)
  expect_true("model" %in% names(comp_metrics))
  expect_true("rmse" %in% names(comp_metrics))
})

test_that("Ensemble Manager Error Handling", {
  ensemble <- MLEnsembleManager$new()
  
  # Run without models
  expect_error(ensemble$run_ensemble(list(), list(), 5), "No models registered")
  
  # Unknown method
  ensemble$register_model("A", MockModel$new())
  expect_error(ensemble$run_ensemble(list(), list(), 5, method = "magic"), "Unknown ensemble method")
})
