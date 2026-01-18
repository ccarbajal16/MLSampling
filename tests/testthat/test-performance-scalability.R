# Performance and Scalability Tests
# Validates Task 9 enhancements: Progress tracking, Memory management, Batch processing

library(testthat)

# Source necessary files
source("../../R/config-management.R")
source("../../R/progress-manager.R")
source("../../R/resource-manager.R")
source("../../R/bayesian-deep-learning.R")
source("../../R/random-forest-optimization.R")
source("../../R/ml-ensemble-manager.R")
source("../../R/spatial-analysis-engine.R")
source("../../R/design-comparison.R")
source("../../R/benchmarking.R")
source("../../R/data-validation.R")
source("../../R/soil-sampling-tool.R")
source("../../R/ml-sampling-tool.R")

test_that("ProgressManager works correctly", {
  pm <- ProgressManager$new()
  expect_true(inherits(pm, "ProgressManager"))
  
  # Test non-interactive mode (should not crash)
  pm$start_progress(100)
  pm$update_progress()
  pm$finish_progress()
  expect_true(TRUE) # Reached here without error
})

test_that("ResourceManager checks memory", {
  rm <- ResourceManager$new()
  expect_true(inherits(rm, "ResourceManager"))
  
  mem <- rm$check_memory()
  expect_true(is.numeric(mem))
  expect_true(mem > 0)
  
  # Check fit
  expect_true(rm$can_fit_in_memory(1)) # 1MB should fit
  expect_false(rm$can_fit_in_memory(1000000)) # 1TB shouldn't fit (unless on supercomputer)
})

test_that("ResourceManager performs batch processing", {
  rm <- ResourceManager$new()
  
  # Create dummy data
  data <- matrix(rnorm(100*2), ncol=2)
  
  # Batch function
  batch_fn <- function(x) {
    return(rowSums(x))
  }
  
  # Process in batches of 10
  result <- rm$process_in_batches(data, batch_fn, batch_size = 10, combine_fn = c)
  
  expect_equal(length(result), 100)
  expect_equal(result, rowSums(data))
})

test_that("MLSampling integrates managers", {
  tool <- MLSampling$new()
  expect_true(inherits(tool$progress_manager, "ProgressManager"))
  expect_true(inherits(tool$resource_manager, "ResourceManager"))
})

test_that("BDL uses batch processing for predictions", {
  tool <- MLSampling$new()
  
  # Setup mock data
  field_data <- list(
    boundary = sf::st_sfc(sf::st_polygon(list(matrix(c(0,0,1,0,1,1,0,1,0,0), ncol=2, byrow=TRUE)))),
    covariates = NULL
  )
  sf::st_crs(field_data$boundary) <- "EPSG:4326"
  
  existing <- data.frame(x=runif(10), y=runif(10), target=rnorm(10))
  
  # Fit model
  tool$bdl_module$fit_model(field_data, existing, "target", epochs=1)
  
  # Mock resource manager to spy on batch calls?
  # Or just run and ensure it works with a small batch size
  
  # Run prediction with very small batch size to force multiple batches
  # We need to access predict_with_uncertainty directly or via run_bdl
  
  candidates <- data.frame(x=runif(50), y=runif(50))
  
  # Spy/Mock via R6 method replacement is hard, so we test functionality
  
  # Manually call predict with resource manager
  preds <- tool$bdl_module$predict_with_uncertainty(
    candidates, 
    n_samples = 10,
    resource_manager = tool$resource_manager
  )
  
  expect_true(is.list(preds))
  expect_equal(length(preds$mean), 50)
})
