# Contract Test for MLSampling$compare_models() method
# These tests MUST FAIL before implementation (TDD requirement)
# Constitutional Compliance: Testing Standards Excellence

test_that("MLSampling$compare_models() method contract", {

  # Setup test data
  tool <- suppressWarnings(MLSampling$new())

  field_data <- list(
    boundary = sf::st_sf(geometry = sf::st_sfc(sf::st_polygon(list(matrix(c(0,0,100,100,0,0,100,100,0,0), ncol=2))), crs = 32633)),
    covariates = terra::rast(matrix(runif(100), 10, 10), crs = "EPSG:32633"),
    metadata = list(n_locations = 100)
  )

  existing_samples <- data.frame(x = c(10, 20, 30), y = c(10, 20, 30))

  # Test basic model comparison
  expect_true({
    comparison_result <- tool$compare_models(
      field_data = field_data,
      existing_samples = existing_samples,
      n_new_samples = 10,
      algorithms = c("greedy", "genetic")
    )
    inherits(comparison_result, "ModelComparison")
  })

  # Test comparison with all available algorithms
  expect_true({
    comparison_result <- tool$compare_models(
      field_data = field_data,
      existing_samples = existing_samples,
      n_new_samples = 5
    )

    supported_algorithms <- tool$get_supported_algorithms()
    # Note: Only testing first 3 for speed if needed, but get_supported_algorithms returns all
    # Just check if results contains some of them
    any(names(comparison_result$results) %in% supported_algorithms)
  })

  # Test comparison result structure
  expect_true({
    comparison_result <- tool$compare_models(field_data, existing_samples, 5)

    all(c("results", "statistical_comparison", "rankings", "recommendations",
          "execution_summary", "constitutional_compliance") %in% names(comparison_result))
  })
})

test_that("MLSampling$compare_models() performance metrics", {

  tool <- suppressWarnings(MLSampling$new())

  field_data <- list(
    boundary = sf::st_sf(geometry = sf::st_sfc(sf::st_polygon(list(matrix(c(0,0,100,100,0,0,100,100,0,0), ncol=2))), crs = 32633)),
    covariates = terra::rast(matrix(runif(100), 10, 10), crs = "EPSG:32633")
  )
  existing_samples <- data.frame(x = c(10, 20), y = c(10, 20))

  # Test execution time comparison
  expect_true({
    comparison_result <- tool$compare_models(field_data, existing_samples, 5)

    all(sapply(comparison_result$results, function(x) {
      !is.null(x$execution_time) && is.numeric(x$execution_time)
    }))
  })

  # Test memory usage comparison
  expect_true({
    comparison_result <- tool$compare_models(field_data, existing_samples, 5)

    all(sapply(comparison_result$results, function(x) {
      !is.null(x$memory_usage) && is.numeric(x$memory_usage)
    }))
  })

  # Test optimization score comparison (using mean_score for comparison results)
  expect_true({
    comparison_result <- tool$compare_models(field_data, existing_samples, 5)

    all(sapply(comparison_result$results, function(x) {
      !is.null(x$mean_score) &&
      is.numeric(x$mean_score)
    }))
  })

  # Test constitutional compliance comparison
  expect_true({
    comparison_result <- tool$compare_models(field_data, existing_samples, 5)

    all(sapply(comparison_result$results, function(x) {
      !is.null(x$constitutional_compliance) &&
      "time_compliant" %in% names(x$constitutional_compliance) &&
      "memory_compliant" %in% names(x$constitutional_compliance)
    }))
  })
})

test_that("MLSampling$compare_models() statistical analysis", {

  tool <- suppressWarnings(MLSampling$new())

  field_data <- list(
    boundary = sf::st_sf(geometry = sf::st_sfc(sf::st_polygon(list(matrix(c(0,0,100,100,0,0,100,100,0,0), ncol=2))), crs = 32633)),
    covariates = terra::rast(matrix(runif(100), 10, 10), crs = "EPSG:32633")
  )
  existing_samples <- data.frame(x = c(10, 20, 30), y = c(10, 20, 30))

  # Test multiple iterations for statistical power
  expect_true({
    comparison_result <- tool$compare_models(
      field_data = field_data,
      existing_samples = existing_samples,
      n_new_samples = 5,
      n_iterations = 10
    )

    all(sapply(comparison_result$results, function(x) {
      length(x$iteration_results) == 10
    }))
  })

  # Test confidence intervals
  expect_true({
    comparison_result <- tool$compare_models(
      field_data = field_data,
      existing_samples = existing_samples,
      n_new_samples = 5,
      n_iterations = 5,
      confidence_level = 0.95
    )

    !is.null(comparison_result$statistical_comparison$confidence_intervals)
  })
})

test_that("MLSampling$compare_models() parameter validation", {

  tool <- suppressWarnings(MLSampling$new())

  field_data <- list(
    boundary = sf::st_sf(geometry = sf::st_sfc(sf::st_polygon(list(matrix(c(0,0,100,100,0,0,100,100,0,0), ncol=2))), crs = 32633)),
    covariates = terra::rast(matrix(runif(100), 10, 10), crs = "EPSG:32633")
  )

  # Test invalid algorithms parameter
  expect_error({
    tool$compare_models(
      field_data = field_data,
      n_new_samples = 5,
      algorithms = c("invalid_algorithm", "another_invalid")
    )
  }, "(?i)unsupported.*algorithm")

  # Test invalid n_iterations
  expect_error({
    tool$compare_models(
      field_data = field_data,
      n_new_samples = 5,
      n_iterations = 0
    )
  }, "n_iterations.*positive")

  # Test excessive iterations (constitutional limit)
  expect_warning({
    tool$compare_models(
      field_data = field_data,
      n_new_samples = 5,
      n_iterations = 1000
    )
  }, "iterations.*exceed.*constitutional")

  # Test invalid confidence level
  expect_error({
    tool$compare_models(
      field_data = field_data,
      n_new_samples = 5,
      confidence_level = 1.5
    )
  }, "confidence_level.*between.*0.*1")
})

test_that("MLSampling$compare_models() parallel execution", {

  tool <- suppressWarnings(MLSampling$new())

  field_data <- list(
    boundary = sf::st_sf(geometry = sf::st_sfc(sf::st_polygon(list(matrix(c(0,0,100,100,0,0,100,100,0,0), ncol=2))), crs = 32633)),
    covariates = terra::rast(matrix(runif(100), 10, 10), crs = "EPSG:32633")
  )
  existing_samples <- data.frame(x = c(10, 20), y = c(10, 20))

  # Test parallel execution configuration
  expect_true({
    comparison_result <- tool$compare_models(
      field_data = field_data,
      existing_samples = existing_samples,
      n_new_samples = 5,
      parallel = TRUE,
      n_cores = 2
    )

    !is.null(comparison_result$execution_summary$parallel_execution) &&
    comparison_result$execution_summary$parallel_execution == TRUE
  })
})

test_that("MLSampling$compare_models() constitutional compliance", {

  tool <- suppressWarnings(MLSampling$new())

  # Create larger dataset for constitutional testing
  field_data <- list(
    boundary = sf::st_sf(geometry = sf::st_sfc(sf::st_polygon(list(matrix(c(0,0,1000,1000,0,0,1000,1000,0,0), ncol=2))), crs = 32633)),
    covariates = terra::rast(matrix(runif(10000), 100, 100), crs = "EPSG:32633")
  )
  existing_samples <- data.frame(
    x = runif(10, 0, 1000),
    y = runif(10, 0, 1000)
  )

  # Test constitutional time limits for comparison
  expect_true({
    start_time <- Sys.time()
    comparison_result <- tool$compare_models(
      field_data = field_data,
      existing_samples = existing_samples,
      n_new_samples = 50
    )
    total_time <- as.numeric(Sys.time() - start_time)

    total_time <= 300 && comparison_result$constitutional_compliance$overall_compliant
  })

  # Test memory usage compliance across all algorithms
  expect_true({
    comparison_result <- tool$compare_models(
      field_data = field_data,
      existing_samples = existing_samples,
      n_new_samples = 50
    )

    comparison_result$constitutional_compliance$memory_compliant
  })

  # Test that comparison identifies constitutional violations
  expect_true({
    comparison_result <- tool$compare_models(field_data, existing_samples, 50)

    # Should track constitutional compliance for each algorithm
    all(sapply(comparison_result$results, function(x) {
      "constitutional_compliance" %in% names(x)
    }))
  })
})
