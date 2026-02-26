# Validate sampling locations against field data

Validates that sampling locations fall within the field boundary and
have valid coordinates according to constitutional standards.

## Usage

``` r
validate_sampling_locations(sampling_locations, field_data, tolerance = 1)
```

## Arguments

- sampling_locations:

  Data frame with x, y coordinates

- field_data:

  Field data list with boundary and covariates

- tolerance:

  Numeric tolerance for boundary checking in map units

## Value

List with sampling location validation results

## Examples

``` r
if (FALSE) { # \dontrun{
validation_result <- validate_sampling_locations(
  sampling_locations = data.frame(x = c(100, 200), y = c(150, 250)),
  field_data = field_data,
  tolerance = 1
)
} # }
```
