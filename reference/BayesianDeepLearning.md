# BayesianDeepLearning

Implements Bayesian Deep Learning techniques for spatial uncertainty
quantification in sampling optimization. Provides Monte Carlo dropout,
variational inference, and comprehensive uncertainty estimation
capabilities.

## Details

The BayesianDeepLearning class integrates with the torch framework to
provide:

- Monte Carlo dropout for epistemic uncertainty estimation

- Variational inference for parameter uncertainty quantification

- Epistemic, aleatoric, and total uncertainty calculation

- Spatial-aware neural network architectures

## Public fields

- `model`:

  Trained torch neural network model

- `config`:

  Configuration parameters for BDL

- `torch_available`:

  Boolean indicating torch availability

- `uncertainty_cache`:

  Cached uncertainty calculations

## Active bindings

- `model`:

  Trained torch neural network model

- `config`:

  Configuration parameters for BDL

- `torch_available`:

  Boolean indicating torch availability

- `uncertainty_cache`:

  Cached uncertainty calculations

## Methods

### Public methods

- [`BayesianDeepLearning$new()`](#method-BayesianDeepLearning-new)

- [`BayesianDeepLearning$fit_model()`](#method-BayesianDeepLearning-fit_model)

- [`BayesianDeepLearning$predict_with_uncertainty()`](#method-BayesianDeepLearning-predict_with_uncertainty)

- [`BayesianDeepLearning$mc_dropout_predict()`](#method-BayesianDeepLearning-mc_dropout_predict)

- [`BayesianDeepLearning$variational_inference()`](#method-BayesianDeepLearning-variational_inference)

- [`BayesianDeepLearning$epistemic_uncertainty()`](#method-BayesianDeepLearning-epistemic_uncertainty)

- [`BayesianDeepLearning$aleatoric_uncertainty()`](#method-BayesianDeepLearning-aleatoric_uncertainty)

- [`BayesianDeepLearning$total_uncertainty()`](#method-BayesianDeepLearning-total_uncertainty)

- [`BayesianDeepLearning$clone()`](#method-BayesianDeepLearning-clone)

------------------------------------------------------------------------

### Method `new()`

#### Usage

    BayesianDeepLearning$new(config = list())

#### Arguments

- `config`:

  Optional configuration list for BDL parameters

#### Examples

    \dontrun{
    bdl <- BayesianDeepLearning$new()
    bdl_custom <- BayesianDeepLearning$new(config = list(dropout_rate = 0.2))
    }

------------------------------------------------------------------------

### Method `fit_model()`

#### Usage

    BayesianDeepLearning$fit_model(
      field_data,
      existing_samples,
      target_variable = NULL,
      validation_split = 0.2,
      epochs = 100,
      batch_size = 32
    )

#### Arguments

- `field_data`:

  List containing boundary, covariates, and metadata

- `existing_samples`:

  Data frame with existing sample locations and values

- `target_variable`:

  Name of target variable to predict

- `validation_split`:

  Proportion of data for validation

- `epochs`:

  Number of training epochs

- `batch_size`:

  Training batch size

#### Returns

Fitted BDL model with training metrics

#### Examples

    \dontrun{
    model <- bdl$fit_model(
      field_data = field_data,
      existing_samples = samples,
      target_variable = "soil_property",
      epochs = 100
    )
    }

------------------------------------------------------------------------

### Method `predict_with_uncertainty()`

#### Usage

    BayesianDeepLearning$predict_with_uncertainty(
      locations,
      n_samples = 100,
      return_samples = FALSE,
      progress_manager = NULL,
      resource_manager = NULL
    )

#### Arguments

- `locations`:

  Spatial locations for prediction (sf object or data.frame with x,y)

- `n_samples`:

  Number of Monte Carlo samples for uncertainty estimation

- `return_samples`:

  Whether to return individual MC samples

- `progress_manager`:

  Optional ProgressManager instance

- `resource_manager`:

  Optional ResourceManager instance

#### Returns

List with predictions and uncertainty estimates

#### Examples

    \dontrun{
    predictions <- bdl$predict_with_uncertainty(
      locations = new_locations,
      n_samples = 100
    )
    }

------------------------------------------------------------------------

### Method `mc_dropout_predict()`

#### Usage

    BayesianDeepLearning$mc_dropout_predict(
      model,
      data,
      n_iterations = 100,
      dropout_rate = 0.1
    )

#### Arguments

- `model`:

  Trained neural network model

- `data`:

  Input data for prediction

- `n_iterations`:

  Number of MC dropout iterations

- `dropout_rate`:

  Dropout rate for MC sampling

#### Returns

Matrix of MC dropout predictions

#### Examples

    \dontrun{
    mc_predictions <- bdl$mc_dropout_predict(
      model = fitted_model,
      data = prediction_data,
      n_iterations = 100,
      dropout_rate = 0.1
    )
    }

------------------------------------------------------------------------

### Method `variational_inference()`

#### Usage

    BayesianDeepLearning$variational_inference(
      data,
      prior_params = list(),
      n_samples = 1000,
      learning_rate = 0.01
    )

#### Arguments

- `data`:

  Training data for variational inference

- `prior_params`:

  Prior parameter specifications

- `n_samples`:

  Number of variational samples

- `learning_rate`:

  Learning rate for variational optimization

#### Returns

Variational inference results with parameter distributions

#### Examples

    \dontrun{
    vi_result <- bdl$variational_inference(
      data = training_data,
      prior_params = list(mean = 0, std = 1),
      n_samples = 1000
    )
    }

------------------------------------------------------------------------

### Method `epistemic_uncertainty()`

#### Usage

    BayesianDeepLearning$epistemic_uncertainty(predictions)

#### Arguments

- `predictions`:

  Prediction results from BDL model

#### Returns

Vector of epistemic uncertainty estimates

#### Examples

    \dontrun{
    epistemic <- bdl$epistemic_uncertainty(predictions)
    }

------------------------------------------------------------------------

### Method `aleatoric_uncertainty()`

#### Usage

    BayesianDeepLearning$aleatoric_uncertainty(predictions)

#### Arguments

- `predictions`:

  Prediction results from BDL model

#### Returns

Vector of aleatoric uncertainty estimates

#### Examples

    \dontrun{
    aleatoric <- bdl$aleatoric_uncertainty(predictions)
    }

------------------------------------------------------------------------

### Method `total_uncertainty()`

#### Usage

    BayesianDeepLearning$total_uncertainty(predictions)

#### Arguments

- `predictions`:

  Prediction results from BDL model

#### Returns

Vector of total uncertainty estimates

#### Examples

    \dontrun{
    total <- bdl$total_uncertainty(predictions)
    }

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    BayesianDeepLearning$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
# Initialize BDL module
bdl <- BayesianDeepLearning$new()

# Fit model with spatial data
bdl$fit_model(field_data, existing_samples)

# Predict with uncertainty
predictions <- bdl$predict_with_uncertainty(new_locations)

# Calculate specific uncertainty types
epistemic <- bdl$epistemic_uncertainty(predictions)
} # }


## ------------------------------------------------
## Method `BayesianDeepLearning$new`
## ------------------------------------------------

if (FALSE) { # \dontrun{
bdl <- BayesianDeepLearning$new()
bdl_custom <- BayesianDeepLearning$new(config = list(dropout_rate = 0.2))
} # }


## ------------------------------------------------
## Method `BayesianDeepLearning$fit_model`
## ------------------------------------------------

if (FALSE) { # \dontrun{
model <- bdl$fit_model(
  field_data = field_data,
  existing_samples = samples,
  target_variable = "soil_property",
  epochs = 100
)
} # }


## ------------------------------------------------
## Method `BayesianDeepLearning$predict_with_uncertainty`
## ------------------------------------------------

if (FALSE) { # \dontrun{
predictions <- bdl$predict_with_uncertainty(
  locations = new_locations,
  n_samples = 100
)
} # }


## ------------------------------------------------
## Method `BayesianDeepLearning$mc_dropout_predict`
## ------------------------------------------------

if (FALSE) { # \dontrun{
mc_predictions <- bdl$mc_dropout_predict(
  model = fitted_model,
  data = prediction_data,
  n_iterations = 100,
  dropout_rate = 0.1
)
} # }


## ------------------------------------------------
## Method `BayesianDeepLearning$variational_inference`
## ------------------------------------------------

if (FALSE) { # \dontrun{
vi_result <- bdl$variational_inference(
  data = training_data,
  prior_params = list(mean = 0, std = 1),
  n_samples = 1000
)
} # }


## ------------------------------------------------
## Method `BayesianDeepLearning$epistemic_uncertainty`
## ------------------------------------------------

if (FALSE) { # \dontrun{
epistemic <- bdl$epistemic_uncertainty(predictions)
} # }


## ------------------------------------------------
## Method `BayesianDeepLearning$aleatoric_uncertainty`
## ------------------------------------------------

if (FALSE) { # \dontrun{
aleatoric <- bdl$aleatoric_uncertainty(predictions)
} # }


## ------------------------------------------------
## Method `BayesianDeepLearning$total_uncertainty`
## ------------------------------------------------

if (FALSE) { # \dontrun{
total <- bdl$total_uncertainty(predictions)
} # }
```
