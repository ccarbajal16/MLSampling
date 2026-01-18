# Integration Test for Model Comparison Workflow
# Constitutional Compliance: Performance Excellence and Statistical Rigor
# Tests comparative analysis between UDL and UFN models

library(testthat)

source("../../R/soil-sampling-tool.R")
source("../../R/config-management.R")
source("../../R/benchmarking.R")

# Helper function to create synthetic field data
create_synthetic_field_data <- function(size = c(100, 100)) {
  r <- terra::rast(nrows = size[1], ncols = size[2], nlyr = 2)
  terra::values(r) <- matrix(rnorm(terra::ncell(r) * 2), ncol = 2)
  terra::crs(r) <- "EPSG:4326"
  terra::ext(r) <- c(0, 1, 0, 1)
  names(r) <- c("feat1", "feat2")

  boundary <- sf::st_as_sf(terra::as.polygons(terra::ext(r)))
  sf::st_crs(boundary) <- sf::st_crs("EPSG:4326")

  list(
    boundary = boundary,
    covariates = r,
    metadata = list(crs = "EPSG:4326")
  )
}

test_that("Model comparison runs both UDL and UFN algorithms", {
  skip_if_not_installed("torch")
  
  tool <- SoilSamplingTool$new()
  field_data <- create_synthetic_field_data()
  
  comparison_result <- tool$compare_models(
    field_data = field_data,
    n_new_samples = 15,
    algorithms = c("UDL", "UFN"),
    max_iter = 20,
    comparison_metrics = c("coverage", "efficiency", "diversity", "spatial_balance")
  )
  
  # Verify comparison structure
  expect_type(comparison_result, "list")
  expect_true("results" %in% names(comparison_result))
  expect_true("comparison_matrix" %in% names(comparison_result))
  expect_true("statistical_tests" %in% names(comparison_result))
  
  # Verify both models were run
  expect_true("UDL" %in% names(comparison_result$results))
  expect_true("UFN" %in% names(comparison_result$results))
  
  # Verify each result has proper structure
  for (model in c("UDL", "UFN")) {
    result <- comparison_result$results[[model]]
    expect_s3_class(result$selected_locations, "data.frame")
    expect_equal(nrow(result$selected_locations), 15)
    expect_true(all(result$selected_locations$model == model))
  }
})

test_that("Model comparison provides statistical significance testing", {
  skip_if_not_installed("torch")
  
  tool <- SoilSamplingTool$new()
  field_data <- create_synthetic_field_data()
  
  comparison_result <- tool$compare_models(
    field_data = field_data,
    n_new_samples = 10,
    algorithms = c("UDL", "UFN"),
    n_replicates = 5,  # Multiple runs for statistical testing
    statistical_test = "wilcoxon"
  )
  
  # Verify statistical analysis
  expect_true("statistical_tests" %in% names(comparison_result))
  stats <- comparison_result$statistical_tests
  
  expect_true("coverage_test" %in% names(stats))
  expect_true("efficiency_test" %in% names(stats))
  expect_true("p_values" %in% names(stats))
  expect_true("effect_sizes" %in% names(stats))
  
  # Verify p-values are valid
  expect_true(all(stats$p_values >= 0 & stats$p_values <= 1))
})

test_that("Model comparison handles algorithm failures gracefully", {
  tool <- SoilSamplingTool$new()
  field_data <- create_synthetic_field_data()
  
  # Mock UFN failure when torch is not available
  if (!requireNamespace("torch", quietly = TRUE) || !torch::torch_is_installed()) {
    comparison_result <- tool$compare_models(
      field_data = field_data,
      n_new_samples = 10,
      algorithms = c("UDL", "UFN"),
      handle_failures = TRUE
    )
    
    # Should still have UDL results
    expect_true("UDL" %in% names(comparison_result$results))
    expect_true("failure_summary" %in% names(comparison_result))
    expect_true("UFN" %in% comparison_result$failure_summary$failed_algorithms)
  }
})

test_that("Model comparison provides comprehensive performance metrics", {
  skip_if_not_installed("torch")
  tool <- SoilSamplingTool$new()
  field_data <- create_synthetic_field_data()
  
  comparison_result <- tool$compare_models(
    field_data = field_data,
    n_new_samples = 12,
    algorithms = c("UDL", "UFN"),
    detailed_metrics = TRUE
  )
  
  # Verify comprehensive metrics
  expect_true("performance_summary" %in% names(comparison_result))
  summary <- comparison_result$performance_summary
  
  expected_metrics <- c("execution_time", "memory_usage", "coverage", 
                       "efficiency", "diversity", "spatial_balance")
  
  for (metric in expected_metrics) {
    expect_true(metric %in% names(summary))
    expect_true("UDL" %in% names(summary[[metric]]))
    if ("UFN" %in% names(comparison_result$results)) {
      expect_true("UFN" %in% names(summary[[metric]]))
    }
  }
})

test_that("Model comparison supports different optimization scenarios", {
  skip_if_not_installed("torch")
  tool <- SoilSamplingTool$new()
  
  # Test scenario 1: Small field, high density sampling
  small_field <- create_synthetic_field_data(size = c(50, 50))
  
  comparison_small <- tool$compare_models(
    field_data = small_field,
    n_new_samples = 20,
    algorithms = c("UDL", "UFN"),
    scenario_name = "high_density"
  )
  
  # Test scenario 2: Large field, sparse sampling
  large_field <- create_synthetic_field_data(size = c(200, 200))
  
  comparison_large <- tool$compare_models(
    field_data = large_field,
    n_new_samples = 15,
    algorithms = c("UDL", "UFN"),
    scenario_name = "sparse_sampling"
  )
  
  # Verify scenarios are tracked
  expect_equal(comparison_small$scenario_info$name, "high_density")
  expect_equal(comparison_large$scenario_info$name, "sparse_sampling")
  
  # Verify different scenarios produce different optimization patterns
  expect_false(identical(
    comparison_small$performance_summary$spatial_balance,
    comparison_large$performance_summary$spatial_balance
  ))
})

test_that("Model comparison generates visualization-ready output", {
  skip_if_not_installed("torch")
  tool <- SoilSamplingTool$new()
  field_data <- create_synthetic_field_data()
  
  comparison_result <- tool$compare_models(
    field_data = field_data,
    n_new_samples = 10,
    algorithms = c("UDL", "UFN"),
    generate_plots = TRUE
  )
  
  # Verify visualization data
  expect_true("visualization_data" %in% names(comparison_result))
  viz_data <- comparison_result$visualization_data
  
  expect_true("comparison_plots" %in% names(viz_data))
  expect_true("performance_radar" %in% names(viz_data))
  expect_true("spatial_distribution" %in% names(viz_data))
  
  # Verify plot data structure
  expect_true("ggplot_data" %in% names(viz_data$comparison_plots))
  expect_true("plotly_config" %in% names(viz_data$comparison_plots))
})

test_that("Model comparison respects constitutional performance requirements", {
  skip_if_not_installed("torch")
  tool <- SoilSamplingTool$new()
  field_data <- create_synthetic_field_data()
  
  start_time <- Sys.time()
  
  comparison_result <- tool$compare_models(
    field_data = field_data,
    n_new_samples = 25,
    algorithms = c("UDL", "UFN"),
    max_iter = 50
  )
  
  end_time <- Sys.time()
  execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
  
  # Constitutional requirement: Should complete within reasonable time
  expect_lt(execution_time, 600,  # 10 minutes for comparison
           info = paste("Model comparison took", round(execution_time, 2), "seconds"))
  
  # Verify constitutional compliance tracking
  expect_true("constitutional_compliance" %in% names(comparison_result))
  compliance <- comparison_result$constitutional_compliance
  
  expect_true("performance_requirements_met" %in% names(compliance))
  expect_true("spatial_analysis_excellence" %in% names(compliance))
  expect_true("testing_standards_followed" %in% names(compliance))
})

test_that("Model comparison provides actionable recommendations", {
  skip_if_not_installed("torch")
  tool <- SoilSamplingTool$new()
  field_data <- create_synthetic_field_data()
  
  comparison_result <- tool$compare_models(
    field_data = field_data,
    n_new_samples = 15,
    algorithms = c("UDL", "UFN"),
    provide_recommendations = TRUE
  )
  
  # Verify recommendations
  expect_true("recommendations" %in% names(comparison_result))
  recommendations <- comparison_result$recommendations
  
  expect_true("best_algorithm" %in% names(recommendations))
  expect_true("rationale" %in% names(recommendations))
  expect_true("alternative_scenarios" %in% names(recommendations))
  
  # Verify rationale includes specific metrics
  expect_true(is.character(recommendations$rationale))
  expect_true(nchar(recommendations$rationale) > 50)
  
  # Verify best algorithm is valid
  expect_true(recommendations$best_algorithm %in% c("UDL", "UFN", "tie"))
})
