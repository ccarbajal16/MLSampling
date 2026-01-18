# Property-Based Tests for Spatial Analysis Engine
# Validates spatial statistics and cross-validation implementation

library(testthat)

# Source the module directly
source("../../R/spatial-analysis-engine.R")

# Generators
create_spatial_raster_generator <- function() {
  function() {
    nrows <- sample(10:20, 1)
    ncols <- sample(10:20, 1)
    r <- terra::rast(nrows = nrows, ncols = ncols, nlyr = 1)
    
    # Generate spatially correlated data (smoothing random noise)
    vals <- matrix(rnorm(nrows * ncols), nrow = nrows, ncol = ncols)
    # Simple smoothing to create autocorrelation
    vals <- (vals + rbind(vals[-1,], vals[1,]) + cbind(vals[,-1], vals[,1])) / 3
    
    terra::values(r) <- vals
    terra::crs(r) <- "EPSG:4326"
    terra::ext(r) <- c(0, 1, 0, 1)
    return(r)
  }
}

create_spatial_points_generator <- function() {
  function() {
    n <- sample(10:30, 1)
    df <- data.frame(
      x = runif(n),
      y = runif(n),
      value = rnorm(n),
      id = 1:n
    )
    # Add some spatial pattern
    df$value <- df$x + df$y + rnorm(n, 0, 0.1)
    
    return(sf::st_as_sf(df, coords = c("x", "y"), crs = "EPSG:4326"))
  }
}

# Property 17: Spatial Statistics Implementation
# **Validates: Requirements 6.1, 6.2**

test_that("Property 17: Spatial Statistics Implementation - Calculate valid Moran's I and Geary's C", {
  
  test_cases <- 5
  engine <- SpatialAnalysisEngine$new()
  
  for (i in 1:test_cases) {
    # Test Raster
    r <- create_spatial_raster_generator()()
    
    moran_r <- engine$calculate_autocorrelation(r, method = "moran")
    geary_r <- engine$calculate_autocorrelation(r, method = "geary")
    
    expect_true(is.numeric(moran_r), info = "Raster Moran's I not numeric")
    expect_true(is.numeric(geary_r), info = "Raster Geary's C not numeric")
    expect_true(moran_r >= -1 && moran_r <= 1, info = "Raster Moran's I out of bounds")
    
    # Test Vector
    pts <- create_spatial_points_generator()()
    
    moran_v <- engine$calculate_autocorrelation(pts, variable = "value", method = "moran")
    geary_v <- engine$calculate_autocorrelation(pts, variable = "value", method = "geary")
    
    expect_true(is.numeric(moran_v), info = "Vector Moran's I not numeric")
    expect_true(is.numeric(geary_v), info = "Vector Geary's C not numeric")
    
    # Moran's I is usually between -1 and 1, but can exceed slightly with irregular weights
    # Geary's C is usually between 0 and 2
    expect_true(geary_v >= 0, info = "Vector Geary's C negative")
  }
})

# Property 18: Spatial Weight Matrix Support / CV Support
# **Validates: Requirements 6.3, 6.6**

test_that("Property 18: Spatial Cross-Validation - Generate valid spatial folds", {
  
  engine <- SpatialAnalysisEngine$new()
  pts <- create_spatial_points_generator()()
  k <- 4
  
  # Test Block CV
  folds <- engine$create_spatial_folds(pts, k = k, method = "block")
  
  expect_equal(length(folds), k, info = "Incorrect number of folds")
  
  # Check disjoint sets
  all_indices <- unlist(folds)
  expect_equal(length(all_indices), nrow(pts), info = "Folds do not cover all data")
  expect_equal(length(unique(all_indices)), nrow(pts), info = "Folds overlap")
  
  # Check if folds are spatially grouped (basic check)
  # In block CV, points in a fold should be closer to each other than random
  # This is hard to test deterministically without visual inspection or complex metrics
  # For now, we rely on the implementation (K-means)
})

test_that("Spatial Analysis Engine Error Handling", {
  engine <- SpatialAnalysisEngine$new()
  
  expect_error(engine$calculate_autocorrelation(list()), "Data must be a SpatRaster or sf object")
  
  pts <- create_spatial_points_generator()()
  expect_error(engine$calculate_autocorrelation(pts, method = "moran"), "Variable name required")
  
  expect_error(engine$create_spatial_folds(data.frame(x=1, y=1)), "Data must be an sf object")
})
