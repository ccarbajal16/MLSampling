# Contract Test for MLSampling$run_udl() method
# These tests MUST FAIL before implementation (TDD requirement)
# Constitutional Compliance: Testing Standards Excellence

test_that("MLSampling$run_udl() method contract", {
  tool <- suppressWarnings(MLSampling$new())

  field_data <- list(
    boundary = sf::st_sf(geometry = sf::st_sfc(sf::st_polygon(list(matrix(c(0,0,100,100,0,0,100,100,0,0), ncol=2))), crs = 32633)),
    covariates = terra::rast(matrix(runif(100), 10, 10), crs = "EPSG:32633"),
    metadata = list(n_locations = 100)
  )

  # Test basic execution
  expect_true({
    result <- tool$run_udl(field_data = field_data, n_new_samples = 10, optimization_method = "greedy")
    inherits(result, "OptimizationResult")
  })
  
  # Check structure
  expect_true({
      result <- tool$run_udl(field_data = field_data, n_new_samples = 5, optimization_method = "random")
      all(c("selected_locations", "optimization_score", "algorithm_used") %in% names(result))
  })
  
  # Test invalid method
  expect_error({
      tool$run_udl(field_data = field_data, n_new_samples = 5, optimization_method = "invalid_method")
  })
})
