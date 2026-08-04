# MLSampling 0.0.2

## Impact on existing results

Models fitted with version 0.0.1 were trained without any environmental
covariates, and when `target_variable` was left unset they were trained against
a spatial coordinate rather than the measured property. Any result produced with
0.0.1 should be regenerated with this version.

## Bug fixes

* Covariate extraction no longer discards the first covariate.
  `terra::extract()` returns an `ID` column only for `SpatVector` input, but
  every call site passes a coordinate matrix, so the unconditional
  `[, -1, drop = FALSE]` removed a real covariate instead. With a single-layer
  raster the feature set was emptied entirely and the models trained on no
  covariates at all. Fixed in the Random Forest, Bayesian Deep Learning and
  design comparison modules.

* Random Forest no longer trains on the `x` coordinate. When `target_variable`
  was not supplied, `prepare_training_data()` kept the `x` and `y` columns in
  the sample data, so the automatic target detection selected `x` as the value
  to model.

* Bayesian Deep Learning carried the same defect in its own
  `prepare_training_data()` and is fixed the same way. Coordinates remain
  available as model features through `spatial_encoding`; only the target
  selection changed.

* Hyperparameter tuning no longer yields `mtry = 0` for a single-covariate
  feature set, which `randomForest` silently reset while `config_used` reported
  the unusable value.

## Behaviour changes

* Sample data whose only numeric columns are `x` and `y` now fails with
  "No numeric target variable found" instead of silently training against a
  coordinate. Supply a column holding the measured property, or pass
  `target_variable` explicitly.

## Documentation

* Added the `LICENSE` file required by the `MIT + file LICENSE` declaration in
  `DESCRIPTION`, which was previously missing.

* Added status badges to the README.

* The README sampling examples now include a numeric target column, so they run
  as written.

# MLSampling 0.0.1

* Initial release.
