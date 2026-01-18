# Property-Based Tests for Design Comparison Framework
# Validates comparison metrics and statistical testing

library(testthat)

# Source the module directly
source("../../R/design-comparison.R")

# Generators
create_field_data_generator <- function() {
  function() {
    nrows <- 20
    ncols <- 20
    r <- terra::rast(nrows = nrows, ncols = ncols, nlyr = 2)
    
    # Generate random values
    vals <- matrix(rnorm(nrows * ncols * 2), ncol = 2)
    terra::values(r) <- vals
    terra::crs(r) <- "EPSG:4326"
    terra::ext(r) <- c(0, 1, 0, 1)
    names(r) <- c("f1", "f2")
    
    boundary <- terra::as.polygons(terra::ext(r))
    terra::crs(boundary) <- "EPSG:4326"
    
    return(list(
      covariates = r,
      boundary = boundary,
      metadata = list(crs = "EPSG:4326")
    ))
  }
}

create_design_generator <- function() {
  function() {
    n <- sample(10:20, 1)
    df <- data.frame(
      x = runif(n),
      y = runif(n),
      id = 1:n
    )
    return(sf::st_as_sf(df, coords = c("x", "y"), crs = "EPSG:4326"))
  }
}

# Property 10: Design Comparison Metrics
# **Validates: Requirements 4.1, 4.2**

test_that("Property 10: Design Comparison Metrics - Calculate valid metrics for designs", {
  
  test_cases <- 5
  comp <- DesignComparison$new()
  
  for (i in 1:test_cases) {
    field_data <- create_field_data_generator()()
    design1 <- create_design_generator()()
    design2 <- create_design_generator()()
    
    designs <- list(d1 = design1, d2 = design2)
    
    results <- comp$compare_designs(designs, field_data)
    
    # Check structure
    expect_true(is.list(results), info = "Results should be a list")
    expect_true(!is.null(results$metrics_summary), info = "Missing metrics summary")
    expect_true(!is.null(results$detailed_results), info = "Missing detailed results")
    
    # Check metrics
    summary <- results$metrics_summary
    expect_true("mssd" %in% names(summary), info = "Missing MSSD metric")
    expect_true("feature_ks_mean" %in% names(summary), info = "Missing KS metric")
    
    # Check validity
    expect_true(all(summary$mssd >= 0), info = "MSSD should be non-negative")
    expect_true(all(summary$feature_ks_mean >= 0 & summary$feature_ks_mean <= 1), 
                info = "KS statistic should be between 0 and 1")
  }
})

# Property 11: Statistical Significance Testing
# **Validates: Requirements 4.3**

test_that("Property 11: Statistical Significance Testing - Detect differences between designs", {
  
  comp <- DesignComparison$new()
  
  # Create two sets of metrics
  # Design 1: Good performance (low MSSD)
  metrics1 <- rnorm(10, mean = 0.1, sd = 0.01)
  
  # Design 2: Poor performance (high MSSD)
  metrics2 <- rnorm(10, mean = 0.5, sd = 0.05)
  
  # Test Wilcoxon
  res_wilcox <- comp$perform_statistical_test(metrics1, metrics2, test_type = "wilcoxon")
  expect_true(res_wilcox$p.value < 0.05, info = "Wilcoxon should detect difference")
  
  # Test T-test
  res_ttest <- comp$perform_statistical_test(metrics1, metrics2, test_type = "t-test")
  expect_true(res_ttest$p.value < 0.05, info = "T-test should detect difference")
})

test_that("Cross-validation for design assessment", {
  
  comp <- DesignComparison$new()
  field_data <- create_field_data_generator()()
  design <- create_design_generator()()
  
  cv_res <- comp$cross_validate_design(design, field_data, k = 5)
  
  expect_true(is.list(cv_res))
  expect_true(!is.null(cv_res$mean_metric))
  expect_true(!is.null(cv_res$fold_metrics))
  expect_equal(length(cv_res$fold_metrics), 5)
})
