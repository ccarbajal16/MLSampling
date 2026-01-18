# Integration Test for Basic UDL Workflow with Synthetic Data
# Constitutional Compliance: Spatial Analysis Excellence
# Tests UDL optimization with various synthetic datasets

library(testthat)

test_that("UDL workflow handles synthetic spatial data correctly", {
  tool <- SoilSamplingTool$new()
  
  # Create synthetic field data with known spatial patterns
  synthetic_data <- create_synthetic_field_data(
    pattern = "gradient",
    size = c(100, 100),
    crs = "EPSG:32633"
  )
  
  # Run UDL optimization
  result <- tool$run_udl(
    field_data = synthetic_data,
    n_new_samples = 20,
    optimization_method = "genetic",
    max_iter = 50
  )
  
  # Verify result structure and quality
  expect_s3_class(result$selected_locations, "data.frame")
  expect_equal(nrow(result$selected_locations), 20)
  expect_true(all(result$selected_locations$model == "UDL"))
  
  # Verify spatial distribution quality
  expect_true(result$metrics$coverage > 0.7)
  expect_true(result$metrics$spatial_balance > 0.6)
  expect_true(result$metrics$diversity > 0.5)
})

test_that("UDL workflow preserves CRS throughout processing", {
  tool <- SoilSamplingTool$new()
  
  # Test with projected CRS
  projected_data <- create_synthetic_field_data(
    pattern = "random",
    crs = "EPSG:32633"  # UTM Zone 33N
  )
  
  result <- tool$run_udl(
    field_data = projected_data,
    n_new_samples = 10
  )
  
  # Verify CRS consistency
  expect_equal(projected_data$crs, "EPSG:32633")
  expect_true("crs_validation" %in% names(result))
  expect_true(result$crs_validation$consistent)
})

test_that("UDL workflow handles different optimization methods", {
  tool <- SoilSamplingTool$new()
  field_data <- create_synthetic_field_data()
  
  # Test genetic algorithm
  result_genetic <- tool$run_udl(
    field_data = field_data,
    n_new_samples = 10,
    optimization_method = "genetic",
    max_iter = 20
  )
  
  # Test simulated annealing
  result_sa <- tool$run_udl(
    field_data = field_data,
    n_new_samples = 10,
    optimization_method = "simulated_annealing",
    max_iter = 20
  )
  
  # Test greedy algorithm
  result_greedy <- tool$run_udl(
    field_data = field_data,
    n_new_samples = 10,
    optimization_method = "greedy",
    max_iter = 20
  )
  
  # Verify all methods produce valid results
  for (result in list(result_genetic, result_sa, result_greedy)) {
    expect_s3_class(result$selected_locations, "data.frame")
    expect_equal(nrow(result$selected_locations), 10)
    expect_true(all(c("coverage", "efficiency", "diversity") %in% 
                    names(result$metrics)))
  }
  
  # Verify different methods produce different results
  genetic_coords <- paste(result_genetic$selected_locations$x, 
                         result_genetic$selected_locations$y)
  sa_coords <- paste(result_sa$selected_locations$x,
                    result_sa$selected_locations$y)
  
  expect_false(identical(genetic_coords, sa_coords))
})

test_that("UDL workflow integrates existing samples correctly", {
  tool <- SoilSamplingTool$new()
  field_data <- create_synthetic_field_data()
  
  # Create existing samples within field boundary
  existing_samples <- data.frame(
    x = c(250, 750),
    y = c(250, 750),
    sample_id = c("existing_1", "existing_2"),
    type = "existing",
    model = "manual"
  )
  
  result <- tool$run_udl(
    field_data = field_data,
    existing_samples = existing_samples,
    n_new_samples = 15
  )
  
  # Verify existing samples are preserved
  expect_true("existing_samples" %in% names(result))
  expect_equal(nrow(result$existing_samples), 2)
  expect_true(all(result$existing_samples$type == "existing"))
  
  # Verify new samples don't overlap with existing
  all_locations <- rbind(
    result$existing_samples[, c("x", "y")],
    result$selected_locations[, c("x", "y")]
  )
  
  distances <- as.matrix(dist(all_locations))
  min_distance <- min(distances[distances > 0])
  expect_gt(min_distance, field_data$resolution)
})

test_that("UDL workflow handles edge cases gracefully", {
  tool <- SoilSamplingTool$new()
  
  # Test with very small field
  small_field <- create_synthetic_field_data(size = c(10, 10))
  
  expect_warning(
    result <- tool$run_udl(
      field_data = small_field,
      n_new_samples = 5
    ),
    regexp = "small field.*limited locations"
  )
  
  # Test with many existing samples
  many_existing <- create_test_locations(n = 50, type = "existing")
  
  result_crowded <- tool$run_udl(
    field_data = create_synthetic_field_data(),
    existing_samples = many_existing,
    n_new_samples = 10
  )
  
  expect_true(nrow(result_crowded$selected_locations) <= 10)
})

# Helper function to create synthetic field data
create_synthetic_field_data <- function(pattern = "gradient", 
                                       size = c(100, 100), 
                                       crs = "EPSG:4326") {
  # Create extent based on CRS
  if (grepl("326", crs)) {
    # Geographic CRS - use decimal degrees
    extent <- c(-1, 1, -1, 1)
  } else {
    # Projected CRS - use meters
    extent <- c(0, 1000, 0, 1000)
  }
  
  # Create boundary
  boundary <- sf::st_polygon(list(matrix(c(
    extent[1], extent[3],
    extent[2], extent[3], 
    extent[2], extent[4],
    extent[1], extent[4],
    extent[1], extent[3]
  ), ncol = 2, byrow = TRUE))) %>%
    sf::st_sfc(crs = crs) %>%
    sf::st_sf()
  
  # Create raster with specified pattern
  r <- terra::rast(extent = terra::ext(extent), 
                   nrows = size[1], ncols = size[2], crs = crs)
  
  if (pattern == "gradient") {
    # Create east-west gradient
    x_coords <- terra::xFromCol(r, 1:terra::ncol(r))
    gradient_values <- (x_coords - min(x_coords)) / (max(x_coords) - min(x_coords))
    terra::values(r) <- rep(gradient_values, each = terra::nrow(r))
  } else if (pattern == "random") {
    terra::values(r) <- runif(terra::ncell(r))
  } else if (pattern == "hotspot") {
    # Create hotspot in center
    coords <- terra::xyFromCell(r, 1:terra::ncell(r))
    center_x <- mean(range(coords[,1]))
    center_y <- mean(range(coords[,2]))
    distances <- sqrt((coords[,1] - center_x)^2 + (coords[,2] - center_y)^2)
    terra::values(r) <- exp(-distances / max(distances) * 3)
  }
  
  list(
    boundary = boundary,
    covariates = r,
    crs = crs,
    extent = extent,
    resolution = terra::res(r)[1]
  )
}
