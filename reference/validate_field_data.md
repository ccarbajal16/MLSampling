# Validate field data structure and spatial integrity

Comprehensive validation function that ensures field data meets
constitutional requirements for spatial analysis excellence. Validates
CRS consistency, geometry integrity, and data quality standards.

## Usage

``` r
validate_field_data(field_data, strict_validation = TRUE)
```

## Arguments

- field_data:

  List containing boundary, covariates, and metadata

- strict_validation:

  Logical, if TRUE applies strict constitutional standards

## Value

List with validation results and detailed diagnostic information

## Examples

``` r
if (FALSE) { # \dontrun{
# Create test field data
field_data <- list(
  boundary = sf::st_read("field_boundary.shp"),
  covariates = terra::rast("environmental_layers.tif")
)

# Validate with constitutional standards
validation_result <- validate_field_data(field_data, strict_validation = TRUE)
if (!validation_result$is_valid) {
  print(validation_result$issues)
}
} # }
```
