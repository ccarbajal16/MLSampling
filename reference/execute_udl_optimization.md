# Execute Unified Deep Learning optimization

Internal helper used by `SoilSamplingTool` to perform Unified Deep
Learning (UDL) optimization. The routine selects an appropriate
heuristic algorithm, generates candidate locations when required, and
compiles performance diagnostics for the resulting sampling plan.

## Usage

``` r
execute_udl_optimization(field_data, existing_samples, n_new_samples,
  optimization_method, model_config, parallel)
```

## Arguments

- field_data:

  List containing boundary geometries, covariate rasters, and associated
  metadata for the field under analysis. Candidate locations are
  generated automatically if absent.

- existing_samples:

  Optional data frame or `sf` object describing existing sampling
  locations in the same coordinate reference system as `field_data`.

- n_new_samples:

  Positive integer giving the number of new sampling locations to
  select.

- optimization_method:

  Character scalar naming the heuristic algorithm to run, such as
  `"greedy"`, `"genetic"`, `"simulated_annealing"`, or `"random"`.

- model_config:

  Optional list of hyperparameters forwarded to the chosen optimization
  algorithm.

- parallel:

  Logical flag indicating whether the optimizer may use parallel
  processing when supported.

## Value

List summarising the optimization outcome, including selected sampling
locations, an optimization score, and performance metrics.

## See also

[`SoilSamplingTool`](https://ccarbajal16.github.io/MLSampling/reference/SoilSamplingTool.md)
for the public interface that invokes this helper.
