# Enhanced ML Results Model

Provides standardized structure for ML-enhanced optimization algorithm
outputs following constitutional principles. Includes comprehensive
result validation, metadata management, performance tracking, and
ML-specific components for unified result handling across BDL, RF, UDL,
and UFN methods.

## Usage

``` r
create_ml_optimization_result(
  selected_locations,
  existing_samples = NULL,
  field_data = NULL,
  metrics = NULL,
  parameters = NULL,
  algorithm_specific = NULL,
  metadata = NULL,
  ml_components = NULL,
  method = "unknown"
)
```

## Arguments

- selected_locations:

  Data frame with new sampling locations

- existing_samples:

  Data frame with existing sampling locations

- field_data:

  Reference to input field data

- metrics:

  Performance metrics list

- parameters:

  Optimization parameters used

- algorithm_specific:

  List with algorithm-specific outputs

- metadata:

  Additional metadata

- ml_components:

  List with ML-specific components (predictions, uncertainties, etc.)

- method:

  Character string identifying ML method ("BDL", "RF", "UDL", "UFN",
  "Ensemble")

## Value

Standardized ML optimization result list

## Details

MLResults ensures consistent output structure across all ML optimization
algorithms with constitutional compliance for performance excellence and
spatial analysis standards. Supports multiple ML method outputs and
comparison data. Create standardized ML optimization result structure

## Examples

``` r
if (FALSE) { # \dontrun{
# Create ML optimization result
result <- create_ml_optimization_result(
  selected_locations = new_locations_df,
  existing_samples = existing_df,
  field_data = field_data,
  metrics = performance_metrics,
  parameters = optimization_params,
  ml_components = list(
    predictions = prediction_raster,
    uncertainties = uncertainty_raster,
    feature_importance = importance_scores
  ),
  method = "BDL"
)
} # }
```
