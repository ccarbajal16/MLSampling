# Sampling Locations Model

Provides standardized data structure and validation for sampling point
coordinates following constitutional principles for spatial analysis
excellence and code quality.

## Usage

``` r
create_sampling_locations(
  coordinates,
  sample_ids = NULL,
  types = "new",
  models = "unknown",
  field_data = NULL,
  additional_columns = NULL
)
```

## Arguments

- coordinates:

  Matrix or data.frame with x, y coordinates

- sample_ids:

  Character vector of unique identifiers

- types:

  Character vector of location types (existing, new, validation)

- models:

  Character vector of model attribution (UDL, UFN, manual)

- field_data:

  Field data list for boundary validation

- additional_columns:

  Named list of additional columns to include

## Value

Standardized data.frame with validated sampling locations

## Details

SamplingLocations ensures consistent representation of sampling points
with proper validation, coordinate checking, and metadata management.
All locations are validated for spatial integrity and constitutional
compliance. Create standardized sampling locations data frame

## Examples

``` r
if (FALSE) { # \dontrun{
# Create sampling locations
coords <- data.frame(x = c(100, 200, 300), y = c(100, 200, 300))
locations <- create_sampling_locations(
  coordinates = coords,
  sample_ids = c("S001", "S002", "S003"),
  types = c("existing", "new", "new"),
  models = c("manual", "UDL", "UDL"),
  field_data = field_data
)
} # }
```
