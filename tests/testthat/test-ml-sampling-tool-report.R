
# Contract Test for MLSampling$generate_ml_report() method
# Constitutional Compliance: Testing Standards Excellence

test_that("MLSampling$generate_ml_report() method contract", {
  tool <- suppressWarnings(MLSampling$new())
  
  # Mock result
  result <- list(
      selected_locations = data.frame(x = 1:5, y = 1:5),
      algorithm_used = "greedy",
      optimization_score = 0.8,
      execution_time = 0.1,  # Added top-level execution_time
      performance_metrics = list(execution_time = 0.1),
      constitutional_compliance = list(overall_compliant = TRUE)
  )
  class(result) <- "OptimizationResult"
  
  tmp_dir <- tempdir()
  
  expect_true({
      report <- tool$generate_ml_report(result, output_dir = tmp_dir)
      # Check if file was created
      file_exists <- file.exists(report$file_path)
      # Check if report object has expected status
      success <- isTRUE(report$success)
      
      file_exists && success
  })
  
  # Check if plots directory was created (default behavior)
  plots_dir <- file.path(tmp_dir, "plots")
  expect_true(dir.exists(plots_dir))
})

test_that("MLSampling uses ReportingService and VisualizationService", {
  tool <- suppressWarnings(MLSampling$new())
  
  expect_true(inherits(tool$reporting_service, "ReportingService"))
  expect_true(inherits(tool$visualization_service, "VisualizationService"))
})
