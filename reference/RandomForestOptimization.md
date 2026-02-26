# RandomForestOptimization

Implements Random Forest techniques for spatial sampling optimization,
focusing on feature importance analysis and spatial autocorrelation
handling.

## Details

The RandomForestOptimization class provides:

- Feature importance-based sampling location optimization

- Spatial Random Forest implementation with autocorrelation support

- Hyperparameter tuning for optimal model performance

- Support for both regression and classification tasks

## Public fields

- `model`:

  Trained Random Forest model

- `config`:

  Configuration parameters for RF optimization

- `importance_cache`:

  Cached feature importance results

## Active bindings

- `model`:

  Trained Random Forest model

- `config`:

  Configuration parameters for RF optimization

- `importance_cache`:

  Cached feature importance results

## Methods

### Public methods

- [`RandomForestOptimization$new()`](#method-RandomForestOptimization-new)

- [`RandomForestOptimization$fit_model()`](#method-RandomForestOptimization-fit_model)

- [`RandomForestOptimization$optimize_locations()`](#method-RandomForestOptimization-optimize_locations)

- [`RandomForestOptimization$get_feature_importance()`](#method-RandomForestOptimization-get_feature_importance)

- [`RandomForestOptimization$clone()`](#method-RandomForestOptimization-clone)

------------------------------------------------------------------------

### Method `new()`

#### Usage

    RandomForestOptimization$new(config = list())

#### Arguments

- `config`:

  Optional configuration list for RF parameters

#### Examples

    \dontrun{
    rf_opt <- RandomForestOptimization$new()
    rf_custom <- RandomForestOptimization$new(config = list(ntree = 1000))
    }

------------------------------------------------------------------------

### Method `fit_model()`

#### Usage

    RandomForestOptimization$fit_model(
      field_data,
      existing_samples,
      target_variable = NULL,
      perform_tuning = FALSE
    )

#### Arguments

- `field_data`:

  List containing boundary, covariates, and metadata

- `existing_samples`:

  Data frame or sf object with existing samples

- `target_variable`:

  Name of target variable to predict

- `perform_tuning`:

  Whether to perform hyperparameter tuning

#### Returns

Fitted RF model with performance metrics Optimize sampling locations
using Random Forest

------------------------------------------------------------------------

### Method `optimize_locations()`

#### Usage

    RandomForestOptimization$optimize_locations(
      field_data,
      n_new_samples,
      candidate_points = NULL,
      strategy = "importance"
    )

#### Arguments

- `field_data`:

  List containing boundary, covariates, and metadata

- `n_new_samples`:

  Number of new samples to select

- `candidate_points`:

  Optional set of candidate points

- `strategy`:

  Sampling strategy ("importance", "uncertainty", "hybrid")

#### Returns

Data frame of optimized sample locations Get Feature Importance

------------------------------------------------------------------------

### Method `get_feature_importance()`

#### Usage

    RandomForestOptimization$get_feature_importance()

#### Returns

Data frame of feature importance scores

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    RandomForestOptimization$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
# Initialize RF module
rf_opt <- RandomForestOptimization$new()

# Fit model and calculate importance
rf_opt$fit_model(field_data, existing_samples)

# Optimize new locations based on feature importance
new_locations <- rf_opt$optimize_locations(
  field_data = field_data,
  n_new_samples = 20
)
} # }


## ------------------------------------------------
## Method `RandomForestOptimization$new`
## ------------------------------------------------

if (FALSE) { # \dontrun{
rf_opt <- RandomForestOptimization$new()
rf_custom <- RandomForestOptimization$new(config = list(ntree = 1000))
} # }
```
