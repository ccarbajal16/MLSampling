# Validate data for ML modeling

Validates that training data is suitable for ML algorithms. Checks for
target variable existence, feature alignment with covariates, and data
quality issues.

## Usage

``` r
validate_ml_data(data, target_col, field_data = NULL)
```

## Arguments

- data:

  Training data frame or sf object

- target_col:

  Name of target variable column

- field_data:

  Optional FieldData object to validate feature alignment

## Value

List with ML validation results
