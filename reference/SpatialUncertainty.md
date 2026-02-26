# SpatialUncertainty

Provides comprehensive uncertainty quantification methods for spatial
predictions including epistemic, aleatoric, and total uncertainty
calculation, confidence interval generation, and uncertainty
visualization capabilities.

## Details

The SpatialUncertainty class provides:

- Multiple uncertainty types (epistemic, aleatoric, total)

- Confidence interval generation with various methods

- Spatial uncertainty mapping and visualization

- Uncertainty calibration and validation metrics

## Public fields

- `uncertainty_results`:

  Stored uncertainty calculation results

- `visualization_config`:

  Configuration for uncertainty visualizations

- `calibration_metrics`:

  Uncertainty calibration assessment results

## Active bindings

- `uncertainty_results`:

  Stored uncertainty calculation results

- `visualization_config`:

  Configuration for uncertainty visualizations

- `calibration_metrics`:

  Uncertainty calibration assessment results

## Methods

### Public methods

- [`SpatialUncertainty$new()`](#method-SpatialUncertainty-new)

- [`SpatialUncertainty$calculate_uncertainties()`](#method-SpatialUncertainty-calculate_uncertainties)

- [`SpatialUncertainty$generate_confidence_intervals()`](#method-SpatialUncertainty-generate_confidence_intervals)

- [`SpatialUncertainty$create_uncertainty_maps()`](#method-SpatialUncertainty-create_uncertainty_maps)

- [`SpatialUncertainty$visualize_uncertainty()`](#method-SpatialUncertainty-visualize_uncertainty)

- [`SpatialUncertainty$assess_calibration()`](#method-SpatialUncertainty-assess_calibration)

- [`SpatialUncertainty$calculate_coverage_probability()`](#method-SpatialUncertainty-calculate_coverage_probability)

- [`SpatialUncertainty$clone()`](#method-SpatialUncertainty-clone)

------------------------------------------------------------------------

### Method `new()`

#### Usage

    SpatialUncertainty$new(config = list())

#### Arguments

- `config`:

  Optional configuration list for uncertainty parameters

#### Examples

    \dontrun{
    uncertainty <- SpatialUncertainty$new()
    }

------------------------------------------------------------------------

### Method `calculate_uncertainties()`

#### Usage

    SpatialUncertainty$calculate_uncertainties(
      predictions,
      method = "bdl",
      uncertainty_types = c("epistemic", "aleatoric", "total")
    )

#### Arguments

- `predictions`:

  Prediction results from ML models (BDL, RF, etc.)

- `method`:

  Method used for predictions ("bdl", "rf", "ensemble")

- `uncertainty_types`:

  Types of uncertainty to calculate

#### Returns

UncertaintyResults object with all uncertainty estimates

#### Examples

    \dontrun{
    uncertainties <- uncertainty$calculate_uncertainties(
      predictions = bdl_result,
      method = "bdl",
      uncertainty_types = c("epistemic", "aleatoric", "total")
    )
    }

------------------------------------------------------------------------

### Method `generate_confidence_intervals()`

#### Usage

    SpatialUncertainty$generate_confidence_intervals(
      predictions,
      confidence_level = 0.95,
      method = "normal"
    )

#### Arguments

- `predictions`:

  Prediction results with uncertainty estimates

- `confidence_level`:

  Confidence level (e.g., 0.95 for 95% CI)

- `method`:

  Method for interval calculation ("normal", "bootstrap", "quantile")

#### Returns

List with lower and upper confidence bounds

#### Examples

    \dontrun{
    intervals <- uncertainty$generate_confidence_intervals(
      predictions = predictions,
      confidence_level = 0.95,
      method = "normal"
    )
    }

------------------------------------------------------------------------

### Method `create_uncertainty_maps()`

#### Usage

    SpatialUncertainty$create_uncertainty_maps(
      uncertainty_results,
      field_data,
      map_types = c("epistemic", "aleatoric", "total"),
      resolution = NULL
    )

#### Arguments

- `uncertainty_results`:

  Uncertainty calculation results

- `field_data`:

  Spatial field data for mapping

- `map_types`:

  Types of uncertainty maps to create

- `resolution`:

  Spatial resolution for mapping

#### Returns

List of uncertainty raster maps

#### Examples

    \dontrun{
    maps <- uncertainty$create_uncertainty_maps(
      uncertainty_results = uncertainties,
      field_data = field_data,
      map_types = c("epistemic", "total")
    )
    }

------------------------------------------------------------------------

### Method `visualize_uncertainty()`

#### Usage

    SpatialUncertainty$visualize_uncertainty(
      uncertainty_results,
      plot_type = "all",
      interactive = FALSE
    )

#### Arguments

- `uncertainty_results`:

  Uncertainty calculation results

- `plot_type`:

  Type of visualization ("maps", "histograms", "scatter", "all")

- `interactive`:

  Whether to create interactive plots

#### Returns

List of uncertainty visualization plots

#### Examples

    \dontrun{
    plots <- uncertainty$visualize_uncertainty(
      uncertainty_results = uncertainties,
      plot_type = "all",
      interactive = TRUE
    )
    }

------------------------------------------------------------------------

### Method `assess_calibration()`

#### Usage

    SpatialUncertainty$assess_calibration(
      predictions,
      observations,
      calibration_method = "reliability_diagram"
    )

#### Arguments

- `predictions`:

  Predictions with uncertainty estimates

- `observations`:

  True observed values for validation

- `calibration_method`:

  Method for calibration assessment

#### Returns

Calibration assessment results

#### Examples

    \dontrun{
    calibration <- uncertainty$assess_calibration(
      predictions = predictions,
      observations = true_values,
      calibration_method = "reliability_diagram"
    )
    }

------------------------------------------------------------------------

### Method `calculate_coverage_probability()`

#### Usage

    SpatialUncertainty$calculate_coverage_probability(
      predictions,
      observations,
      confidence_level = 0.95
    )

#### Arguments

- `predictions`:

  Predictions with confidence intervals

- `observations`:

  True observed values

- `confidence_level`:

  Expected confidence level

#### Returns

Coverage probability assessment

#### Examples

    \dontrun{
    coverage <- uncertainty$calculate_coverage_probability(
      predictions = predictions_with_ci,
      observations = true_values,
      confidence_level = 0.95
    )
    }

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    SpatialUncertainty$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
# Initialize uncertainty quantification
uncertainty <- SpatialUncertainty$new()

# Calculate uncertainties from BDL predictions
uncertainties <- uncertainty$calculate_uncertainties(bdl_predictions)

# Generate confidence intervals
intervals <- uncertainty$generate_confidence_intervals(predictions, level = 0.95)

# Create uncertainty maps
maps <- uncertainty$create_uncertainty_maps(uncertainties, field_data)
} # }


## ------------------------------------------------
## Method `SpatialUncertainty$new`
## ------------------------------------------------

if (FALSE) { # \dontrun{
uncertainty <- SpatialUncertainty$new()
} # }


## ------------------------------------------------
## Method `SpatialUncertainty$calculate_uncertainties`
## ------------------------------------------------

if (FALSE) { # \dontrun{
uncertainties <- uncertainty$calculate_uncertainties(
  predictions = bdl_result,
  method = "bdl",
  uncertainty_types = c("epistemic", "aleatoric", "total")
)
} # }


## ------------------------------------------------
## Method `SpatialUncertainty$generate_confidence_intervals`
## ------------------------------------------------

if (FALSE) { # \dontrun{
intervals <- uncertainty$generate_confidence_intervals(
  predictions = predictions,
  confidence_level = 0.95,
  method = "normal"
)
} # }


## ------------------------------------------------
## Method `SpatialUncertainty$create_uncertainty_maps`
## ------------------------------------------------

if (FALSE) { # \dontrun{
maps <- uncertainty$create_uncertainty_maps(
  uncertainty_results = uncertainties,
  field_data = field_data,
  map_types = c("epistemic", "total")
)
} # }


## ------------------------------------------------
## Method `SpatialUncertainty$visualize_uncertainty`
## ------------------------------------------------

if (FALSE) { # \dontrun{
plots <- uncertainty$visualize_uncertainty(
  uncertainty_results = uncertainties,
  plot_type = "all",
  interactive = TRUE
)
} # }


## ------------------------------------------------
## Method `SpatialUncertainty$assess_calibration`
## ------------------------------------------------

if (FALSE) { # \dontrun{
calibration <- uncertainty$assess_calibration(
  predictions = predictions,
  observations = true_values,
  calibration_method = "reliability_diagram"
)
} # }


## ------------------------------------------------
## Method `SpatialUncertainty$calculate_coverage_probability`
## ------------------------------------------------

if (FALSE) { # \dontrun{
coverage <- uncertainty$calculate_coverage_probability(
  predictions = predictions_with_ci,
  observations = true_values,
  confidence_level = 0.95
)
} # }
```
