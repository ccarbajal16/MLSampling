# Enhanced Field Data Model with ML Metadata Support

Provides comprehensive validation for field data structures following
constitutional principles for spatial analysis excellence. Ensures CRS
consistency, geometry integrity, and data quality standards. Enhanced
with ML-specific metadata support for feature importance, uncertainty
maps, and spatial weights.

## Usage

``` r
validate_field_data_structure(field_data, strict_validation = TRUE)
```

## Arguments

- field_data:

  List containing boundary, covariates, and metadata

- strict_validation:

  Logical, apply strict constitutional standards

## Value

Validated field data list with standardized structure and ML metadata

## Examples

``` r
if (FALSE) { # \dontrun{
# Create enhanced field data with ML metadata
field_data <- list(
  boundary = sf::st_read("boundary.shp"),
  covariates = terra::rast("covariates.tif"),
  crs = "EPSG:32633",
  ml_metadata = list(
    feature_importance = c(0.3, 0.2, 0.5),
    uncertainty_maps = terra::rast("uncertainty.tif"),
    spatial_weights = matrix(c(1, 0.5, 0.5, 1), nrow = 2)
  )
)

# Validate and standardize
validated_data <- validate_field_data_structure(field_data)
} # }
```
