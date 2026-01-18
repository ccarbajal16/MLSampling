# Integration Test for Quick Start Workflow (5-minute test)
# Constitutional Compliance: User Experience Consistency
# Tests complete user workflow from data loading to results export

library(testthat)

create_test_spatial_data <- function() {
  r <- terra::rast(nrows = 20, ncols = 20, nlyr = 2)
  terra::values(r) <- matrix(rnorm(terra::ncell(r) * 2), ncol = 2)
  terra::crs(r) <- "EPSG:4326"
  terra::ext(r) <- c(-1, 1, -1, 1)
  names(r) <- c("feat1", "feat2")

  boundary <- sf::st_as_sf(terra::as.polygons(terra::ext(r)))
  sf::st_crs(boundary) <- sf::st_crs("EPSG:4326")

  list(
    boundary = boundary,
    covariates = r,
    crs = "EPSG:4326",
    resolution = 0.1,
    extent = c(-1, 1, -1, 1)
  )
}

test_that("Quick Start workflow completes within 5 minutes", {
  skip_on_ci()  # Skip on CI as this is a long-running test
  
  start_time <- Sys.time()
  
  # Initialize tool
  tool <- SoilSamplingTool$new()
  
  # Generate test data
  field_data <- list(
    boundary = create_test_spatial_data()$boundary,
    covariates = create_test_spatial_data()$covariates,
    crs = "EPSG:4326",
    resolution = 0.1,
    extent = c(-1, 1, -1, 1)
  )
  
  # Generate small sample of existing samples
  existing_samples <- data.frame(
    x = c(-0.5, 0.5),
    y = c(-0.5, 0.5),
    sample_id = c("existing_1", "existing_2"),
    type = "existing",
    model = "manual"
  )
  
  # Run quick UDL optimization (small dataset)
  result <- tool$run_udl(
    field_data = field_data,
    existing_samples = existing_samples,
    n_new_samples = 10,
    optimization_method = "greedy",
    max_iter = 10,
    save_csv = TRUE
  )
  
  # Verify result structure
  expect_type(result, "list")
  expect_true("selected_locations" %in% names(result))
  expect_true("metrics" %in% names(result))
  expect_true("csv_file" %in% names(result))
  
  # Verify selected locations
  expect_s3_class(result$selected_locations, "data.frame")
  expect_equal(nrow(result$selected_locations), 10)
  expect_true(all(c("x", "y", "sample_id", "type", "model") %in% 
                  names(result$selected_locations)))
  
  # Verify CSV was created
  expect_true(file.exists(result$csv_file))
  
  # Verify execution time (constitutional requirement: < 5 minutes for quick start)
  end_time <- Sys.time()
  execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
  expect_lt(execution_time, 300)
  
  # Cleanup
  if (file.exists(result$csv_file)) {
    unlink(result$csv_file)
  }
})

test_that("Quick Start handles invalid input gracefully", {
  tool <- SoilSamplingTool$new()
  
  # Test with missing field data
  expect_error(
    tool$run_udl(field_data = NULL, n_new_samples = 1),
    regexp = "field_data.*required"
  )
  
  # Test with invalid existing samples
  invalid_samples <- data.frame(
    x = "invalid",
    y = "invalid",
    sample_id = "test"
  )
  
  expect_error(
    tool$run_udl(
      field_data = create_test_spatial_data(),
      existing_samples = invalid_samples,
      n_new_samples = 1
    ),
    regexp = "[Cc]oordinate.*numeric"
  )
})

test_that("Quick Start provides progress feedback", {
  tool <- SoilSamplingTool$new(config = list(progress_feedback = TRUE))
  
  # Capture output during execution
  output <- capture.output({
    result <- tool$run_udl(
      field_data = create_test_spatial_data(),
      n_new_samples = 5,
      optimization_method = "greedy",
      max_iter = 5
    )
  })
  
  # Verify progress messages were displayed
  expect_true(any(grepl("Validating", output, ignore.case = TRUE)))
  expect_true(any(grepl("Optimizing", output, ignore.case = TRUE)))
  expect_true(any(grepl("Complete", output, ignore.case = TRUE)))
})

test_that("Quick Start workflow integrates with benchmarking", {
  tool <- SoilSamplingTool$new()
  
  # Run optimization with benchmarking enabled
  result <- tool$run_udl(
    field_data = create_test_spatial_data(),
    n_new_samples = 5,
    optimization_method = "greedy",
    max_iter = 5
  )
  
  # Verify benchmarking data is available
  benchmark_results <- tool$benchmarking_service$get_latest_results()
  expect_type(benchmark_results, "list")
  expect_true("execution_time" %in% names(benchmark_results))
  expect_true("memory_usage" %in% names(benchmark_results))
})
