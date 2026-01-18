# Contract Test for MLSampling$save_coordinates_to_csv() method
# Constitutional Compliance: Testing Standards Excellence

test_that("MLSampling$save_coordinates_to_csv() method contract", {
  tool <- suppressWarnings(MLSampling$new())
  
  # Mock result
  result <- list(
      selected_locations = data.frame(x = 1:5, y = 1:5, location_id = 1:5),
      coordinate_system = 32633,
      algorithm_used = "greedy",
      constitutional_compliance = list(overall_compliant = TRUE)
  )
  class(result) <- "OptimizationResult"
  
  tmp <- tempfile(fileext = ".csv")
  
  expect_true({
      res <- tool$save_coordinates_to_csv(result, file_path = tmp)
      res$export_successful && file.exists(tmp)
  })
  
  # Check file content
  expect_true({
      df <- read.csv(tmp)
      nrow(df) == 5 && all(c("x", "y", "location_id") %in% names(df))
  })
})
