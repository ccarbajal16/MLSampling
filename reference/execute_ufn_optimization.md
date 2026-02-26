# Execute Unified Feature Network optimization

Internal helper used by `SoilSamplingTool` to run Unified Feature
Network (UFN) optimizations via either the neural-network pipeline or
the statistical fallback implementation when neural execution is not
available.

## Usage

``` r
execute_ufn_optimization(field_data, existing_samples, n_new_samples,
  model_config, model_type)
```

## Arguments

- field_data:

  List containing boundary geometries, aligned covariate rasters, and
  metadata describing the field under analysis.

- existing_samples:

  Optional data frame or `sf` object of previously collected sampling
  locations expressed in the same CRS as `field_data`.

- n_new_samples:

  Positive integer specifying the number of additional sampling
  locations to generate.

- model_config:

  Optional list of hyperparameters forwarded to the neural network
  optimization pipeline. Ignored when
  `model_type = "statistical_fallback"`.

- model_type:

  Character scalar identifying the execution path, expected to be either
  `"neural_network"` or `"statistical_fallback"`.

## Value

List containing the selected sampling locations along with performance
diagnostics and flags describing which model path executed.

## See also

[`SoilSamplingTool`](https://ccarbajal16.github.io/MLSampling/reference/SoilSamplingTool.md)
for the public interface that calls this helper.
