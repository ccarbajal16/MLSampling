
test_that("VisualizationService initialization", {
  viz_service <- VisualizationService$new()
  expect_true(inherits(viz_service, "VisualizationService"))
})

test_that("VisualizationService generates uncertainty map", {
  viz_service <- VisualizationService$new()
  
  # Mock data
  covariates <- terra::rast(matrix(runif(100), 10, 10), crs = "EPSG:32633")
  uncertainty <- terra::rast(matrix(runif(100), 10, 10), crs = "EPSG:32633")
  names(uncertainty) <- "uncertainty"
  
  field_data <- list(
    covariates = covariates,
    boundary = sf::st_as_sf(terra::as.polygons(terra::ext(covariates), crs = "EPSG:32633"))
  )
  
  output_file <- tempfile(fileext = ".png")
  
  result <- viz_service$plot_uncertainty_map(
    uncertainty_raster = uncertainty,
    field_data = field_data,
    output_path = output_file
  )
  
  expect_true(file.exists(output_file))
  expect_true(result$success)
})

test_that("VisualizationService generates feature importance plot", {
  viz_service <- VisualizationService$new()
  
  importance <- c(soil_ph = 0.5, elevation = 0.3, slope = 0.2)
  output_file <- tempfile(fileext = ".png")
  
  result <- viz_service$plot_feature_importance(
    importance_scores = importance,
    output_path = output_file
  )
  
  expect_true(file.exists(output_file))
  expect_true(result$success)
})

test_that("VisualizationService generates design comparison plot", {
  viz_service <- VisualizationService$new()
  
  comparison_data <- data.frame(
    algorithm = rep(c("A", "B"), each = 10),
    score = runif(20)
  )
  
  output_file <- tempfile(fileext = ".png")
  
  result <- viz_service$plot_design_comparison(
    comparison_data = comparison_data,
    metric = "score",
    output_path = output_file
  )
  
  expect_true(file.exists(output_file))
  expect_true(result$success)
})
