# Changelog

## MLSampling 0.0.3.9000 (development version)

Work towards a CRAN submission. `R CMD check --as-cran` went from 1
ERROR / 5 WARNINGs / 4 NOTEs to 1 ERROR / 1 WARNING / 2 NOTEs.

### Packaging

- `DESCRIPTION` now uses `Authors@R`. The maintainer had been recorded
  as “Carlos”, a first name only, which CRAN rejects.

- Removed the `Remotes` field. `pryr` is on CRAN, so the field was never
  needed and it was pushing `pryr` out of the mainstream repositories.

- Moved 14 never-referenced packages from `Imports` to `Suggests`,
  leaving 12. `ggplot2` and `viridis` stay in `Imports` because they are
  used through `import()` in `NAMESPACE`. Declared `units`, which is
  called in
  [`validate_field_boundary_geometry()`](https://ccarbajal16.github.io/MLSampling/reference/validate_field_boundary_geometry.md)
  but was missing.

- Dropped `quickcheck`, which is archived on CRAN, and the obsolete
  `Type` and `LazyData` fields.

### Bug fixes

- Escaped the non-ASCII characters in `benchmarking.R` and
  `data-validation.R`. Rendered output is unchanged.

- Declared [`dist()`](https://rdrr.io/r/stats/dist.html),
  [`na.omit()`](https://rspatial.github.io/terra/reference/na.omit.html),
  [`setNames()`](https://rdrr.io/r/stats/setNames.html),
  [`head()`](https://rspatial.github.io/terra/reference/headtail.html)
  and
  [`packageVersion()`](https://rdrr.io/r/utils/packageDescription.html),
  previously reported as undefined globals.

### Documentation

- Removed the Rd pages for `execute_udl_optimization` and
  `execute_ufn_optimization`, which documented private R6 methods as if
  they were exported functions, and the Rd page for `%||%`, whose
  `\name` contained a pipe character and which is not exported.

## MLSampling 0.0.3

### Bug fixes

- Random Forest classification works again.
  `calculate_spatial_features()` computed the spatial lag as
  `weights %*% values`, which fails for a factor target, and
  `spatial_autocorr` defaults to `TRUE`, so classification failed under
  the default configuration. A factor target now produces the
  neighbourhood class composition instead: one `spatial_lag_<level>`
  column per level holding the inverse distance weighted proportion of
  neighbours in that class. Numeric targets keep the single
  `spatial_lag` column and are unchanged.

### Testing

- The Random Forest property tests no longer wrap their assertions in
  [`tryCatch()`](https://rdrr.io/r/base/conditions.html), which was
  turning expectation failures into informational messages and reporting
  a passing suite. This had been masking both the classification failure
  above and the covariate assertion on the feature importance table.

## MLSampling 0.0.2

### Impact on existing results

Models fitted with version 0.0.1 were trained without any environmental
covariates, and when `target_variable` was left unset they were trained
against a spatial coordinate rather than the measured property. Any
result produced with 0.0.1 should be regenerated with this version.

### Bug fixes

- Covariate extraction no longer discards the first covariate.
  [`terra::extract()`](https://rspatial.github.io/terra/reference/extract.html)
  returns an `ID` column only for `SpatVector` input, but every call
  site passes a coordinate matrix, so the unconditional
  `[, -1, drop = FALSE]` removed a real covariate instead. With a
  single-layer raster the feature set was emptied entirely and the
  models trained on no covariates at all. Fixed in the Random Forest,
  Bayesian Deep Learning and design comparison modules.

- Random Forest no longer trains on the `x` coordinate. When
  `target_variable` was not supplied, `prepare_training_data()` kept the
  `x` and `y` columns in the sample data, so the automatic target
  detection selected `x` as the value to model.

- Bayesian Deep Learning carried the same defect in its own
  `prepare_training_data()` and is fixed the same way. Coordinates
  remain available as model features through `spatial_encoding`; only
  the target selection changed.

- Hyperparameter tuning no longer yields `mtry = 0` for a
  single-covariate feature set, which `randomForest` silently reset
  while `config_used` reported the unusable value.

### Behaviour changes

- Sample data whose only numeric columns are `x` and `y` now fails with
  “No numeric target variable found” instead of silently training
  against a coordinate. Supply a column holding the measured property,
  or pass `target_variable` explicitly.

### Documentation

- Added the `LICENSE` file required by the `MIT + file LICENSE`
  declaration in `DESCRIPTION`, which was previously missing.

- Added status badges to the README.

- The README sampling examples now include a numeric target column, so
  they run as written.

## MLSampling 0.0.1

- Initial release.
