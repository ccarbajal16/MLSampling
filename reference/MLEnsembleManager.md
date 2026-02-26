# MLEnsembleManager

Manages ensemble strategies for spatial sampling optimization, combining
results from different ML models (BDL, RF, UDL, UFN).

## Details

The MLEnsembleManager class provides:

- Unified interface for running multiple ML models

- Ensemble methods: Stacking, Blending, Voting

- Comparative analysis of model performance

## Methods

### Public methods

- [`MLEnsembleManager$new()`](#method-MLEnsembleManager-new)

- [`MLEnsembleManager$register_model()`](#method-MLEnsembleManager-register_model)

- [`MLEnsembleManager$run_ensemble()`](#method-MLEnsembleManager-run_ensemble)

- [`MLEnsembleManager$compare_models()`](#method-MLEnsembleManager-compare_models)

- [`MLEnsembleManager$clone()`](#method-MLEnsembleManager-clone)

------------------------------------------------------------------------

### Method `new()`

#### Usage

    MLEnsembleManager$new(config = list())

#### Arguments

- `config`:

  Optional configuration list Register an ML Model

------------------------------------------------------------------------

### Method `register_model()`

#### Usage

    MLEnsembleManager$register_model(name, model_instance)

#### Arguments

- `name`:

  Name of the model (e.g., "BDL", "RF")

- `model_instance`:

  Instance of the ML model class Run Ensemble Optimization

------------------------------------------------------------------------

### Method `run_ensemble()`

#### Usage

    MLEnsembleManager$run_ensemble(
      field_data,
      existing_samples,
      n_new_samples,
      method = "voting"
    )

#### Arguments

- `field_data`:

  Field data

- `existing_samples`:

  Existing samples

- `n_new_samples`:

  Number of new samples

- `method`:

  Ensemble method ("voting", "stacking")

#### Returns

Ensemble result Compare Registered Models

------------------------------------------------------------------------

### Method `compare_models()`

#### Usage

    MLEnsembleManager$compare_models(field_data, existing_samples, target_variable)

#### Arguments

- `field_data`:

  Field data

- `existing_samples`:

  Existing samples

- `target_variable`:

  Target variable name

#### Returns

Comparison metrics

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    MLEnsembleManager$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
