# MLSampling Quickstart Workflow

## Overview

This vignette walks through a minimal end-to-end workflow using
`MLSampling`. The example creates synthetic spatial inputs, runs both
BDL (Bayesian Deep Learning) and RF (Random Forest) optimizations, and
exports results for reporting.

To execute the code, ensure the suggested dependencies listed in
`DESCRIPTION` (such as `sf`, `terra`, and `torch`) are installed.

## Load the package

``` r

library(MLSampling)
library(sf)
library(terra)
```

## Prepare synthetic field data

The tool expects a boundary geometry, associated covariate rasters, and
optional existing sampling locations. The helpers below construct these
objects using trivial synthetic data so the example can run without
external files.

``` r

# Create a simple square boundary in EPSG:32633 (UTM 33N)
boundary <- st_as_sf(st_sfc(st_polygon(list(rbind(
  c(0, 0), c(1000, 0), c(1000, 1000), c(0, 1000), c(0, 0)
))), crs = 32633))

# Generate two covariate rasters aligned with the boundary
grid_template <- rast(nrows = 50, ncols = 50, xmin = 0, xmax = 1000, ymin = 0, ymax = 1000, crs = "EPSG:32633")

covariates <- list(
  fertility = setValues(grid_template, runif(ncell(grid_template), min = 0.2, max = 0.9)),
  moisture = setValues(grid_template, runif(ncell(grid_template), min = 0.1, max = 0.8))
)

field_data <- list(
  boundary = boundary,
  covariates = covariates,
  metadata = list(field_id = "Synthetic-Field", season = "2025")
)

existing_samples <- data.frame(
  x = c(100, 350, 700, 880, 150),
  y = c(120, 780, 640, 210, 450)
)
```

## Initialize the tool

``` r

tool <- create_ml_sampling_tool(
  config = list(
    log_level = "INFO"
  ),
  interactive = FALSE
)
```

## Run BDL optimization with Uncertainty Quantification

``` r

bdl_result <- tool$run_bdl(
  field_data = field_data,
  existing_samples = existing_samples,
  n_new_samples = 25,
  uncertainty_type = "total",
  mc_iterations = 50
)

# Inspect uncertainty metrics
print(bdl_result$uncertainties$uncertainty_summary)
```

## Run Random Forest Optimization with Feature Importance

``` r

rf_result <- tool$run_rf_optimization(
  field_data = field_data,
  existing_samples = existing_samples,
  n_new_samples = 25,
  feature_importance_method = "permutation"
)

# Check feature importance
print(rf_result$feature_importance)
```

## Compare algorithms

``` r

comparison <- tool$compare_models(
  field_data = field_data,
  existing_samples = existing_samples,
  n_new_samples = 25,
  algorithms = c("BDL", "RF", "udl"),
  n_iterations = 3
)

# Generate comparison report
tool$generate_ml_report(
  result = comparison,
  report_type = "comprehensive",
  output_dir = tempdir()
)
```

## Next steps

- Explore
  [`vignette("advanced-ml-optimization")`](https://ccarbajal16.github.io/MLSampling/articles/advanced-ml-optimization.md)
  for deep dives into Bayesian Deep Learning and Ensemble methods.
- Check
  [`?MLSampling`](https://ccarbajal16.github.io/MLSampling/reference/MLSampling.md)
  for complete API documentation.
