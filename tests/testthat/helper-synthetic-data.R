create_synthetic_field_data <- function(size = c(100, 100), pattern = "random", crs = "EPSG:4326") {
  extent <- if (grepl("326", crs)) c(-1, 1, -1, 1) else c(0, 1000, 0, 1000)
  r <- terra::rast(extent = terra::ext(extent), nrows = size[1], ncols = size[2], nlyr = 2, crs = crs)

  n <- terra::ncell(r)
  xy <- terra::xyFromCell(r, seq_len(n))
  x <- xy[, 1]
  y <- xy[, 2]

  base1 <- switch(
    pattern,
    "hotspot" = exp(-((x - 0.7)^2 + (y - 0.7)^2) / 0.02),
    "gradient" = x + y,
    rnorm(n)
  )

  base2 <- switch(
    pattern,
    "hotspot" = exp(-((x - 0.3)^2 + (y - 0.3)^2) / 0.03),
    "gradient" = x - y,
    rnorm(n)
  )

  vals <- cbind(base1, base2) + matrix(rnorm(n * 2, sd = 0.05), ncol = 2)
  terra::values(r) <- vals
  names(r) <- c("feat1", "feat2")

  boundary <- sf::st_polygon(list(matrix(c(
    extent[1], extent[3],
    extent[2], extent[3],
    extent[2], extent[4],
    extent[1], extent[4],
    extent[1], extent[3]
  ), ncol = 2, byrow = TRUE))) |>
    sf::st_sfc(crs = crs) |>
    sf::st_sf()

  list(
    boundary = boundary,
    covariates = r,
    crs = crs,
    extent = extent,
    resolution = terra::res(r)[1],
    metadata = list(crs = crs)
  )
}

create_test_locations <- function(n = 10, type = "existing") {
  data.frame(
    x = runif(n, 0, 1000),
    y = runif(n, 0, 1000),
    sample_id = paste0(type, "_", seq_len(n)),
    type = type,
    model = if (type == "existing") "manual" else "UDL",
    stringsAsFactors = FALSE
  )
}

