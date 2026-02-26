# Uncertainty Quantification Model

Provides standardized data structure and validation for uncertainty
quantification in ML-enhanced spatial sampling following constitutional
principles. Supports epistemic, aleatoric, and total uncertainty types
with proper validation and spatial consistency checks.

## Usage

``` r
create_uncertainty_results(
  epistemic = NULL,
  aleatoric = NULL,
  total = NULL,
  uncertainty_rasters = NULL,
  confidence_intervals = NULL,
  mc_samples = NULL,
  n_samples = NULL,
  validation_metrics = NULL,
  method = "unknown",
  field_data = NULL
)
```

## Arguments

- epistemic:

  Epistemic (model) uncertainty estimates

- aleatoric:

  Aleatoric (data) uncertainty estimates

- total:

  Total uncertainty estimates (combined)

- uncertainty_rasters:

  List of SpatRaster objects with uncertainty maps

- confidence_intervals:

  List with confidence interval bounds

- mc_samples:

  Monte Carlo samples for uncertainty estimation

- n_samples:

  Number of Monte Carlo iterations used

- validation_metrics:

  Uncertainty validation and calibration metrics

- method:

  ML method used for uncertainty quantification

- field_data:

  Reference field data for spatial consistency

## Value

Standardized UncertaintyResults object

## Details

UncertaintyResults ensures consistent representation of uncertainty
estimates across all ML methods (BDL, RF, Ensemble) with constitutional
compliance for spatial analysis excellence and performance requirements.
Create standardized uncertainty quantification results

## Examples

``` r
if (FALSE) { # \dontrun{
# Create uncertainty results
uncertainty_results <- create_uncertainty_results(
  epistemic = epistemic_uncertainty_raster,
  aleatoric = aleatoric_uncertainty_raster,
  total = total_uncertainty_raster,
  confidence_intervals = list(
    lower_bound = lower_ci_raster,
    upper_bound = upper_ci_raster,
    confidence_level = 0.95
  ),
  mc_samples = mc_sample_array,
  n_samples = 100,
  method = "BDL"
)
} # }
```
