# Legacy SoilSamplingTool Class (Deprecated)

Alias for MLSampling for backward compatibility.

## Methods

### Public methods

- [`SoilSamplingTool$new()`](#method-MLSampling-new)

- [`SoilSamplingTool$run_udl()`](#method-MLSampling-run_udl)

- [`SoilSamplingTool$run_ufn()`](#method-MLSampling-run_ufn)

- [`SoilSamplingTool$run_bdl()`](#method-MLSampling-run_bdl)

- [`SoilSamplingTool$run_rf_optimization()`](#method-MLSampling-run_rf_optimization)

- [`SoilSamplingTool$run_ensemble()`](#method-MLSampling-run_ensemble)

- [`SoilSamplingTool$compare_designs()`](#method-MLSampling-compare_designs)

- [`SoilSamplingTool$compare_models()`](#method-MLSampling-compare_models)

- [`SoilSamplingTool$quantify_uncertainty()`](#method-MLSampling-quantify_uncertainty)

- [`SoilSamplingTool$generate_ml_report()`](#method-MLSampling-generate_ml_report)

- [`SoilSamplingTool$generate_report()`](#method-MLSampling-generate_report)

- [`SoilSamplingTool$save_coordinates_to_csv()`](#method-MLSampling-save_coordinates_to_csv)

- [`SoilSamplingTool$get_supported_algorithms()`](#method-MLSampling-get_supported_algorithms)

- [`SoilSamplingTool$validate_report()`](#method-MLSampling-validate_report)

- [`SoilSamplingTool$clone()`](#method-MLSampling-clone)

------------------------------------------------------------------------

### Method `new()`

#### Usage

    SoilSamplingTool$new(
      config = NULL,
      config_manager = NULL,
      validate_system = FALSE
    )

------------------------------------------------------------------------

### Method `run_udl()`

#### Usage

    SoilSamplingTool$run_udl(
      field_data = NULL,
      existing_samples = NULL,
      n_new_samples,
      optimization_method = "greedy",
      model_config = NULL,
      parallel = FALSE,
      max_iter = NULL,
      save_csv = FALSE,
      ...
    )

------------------------------------------------------------------------

### Method `run_ufn()`

#### Usage

    SoilSamplingTool$run_ufn(
      field_data = NULL,
      existing_samples = NULL,
      n_new_samples,
      model_config = NULL,
      force_neural_network = FALSE,
      force_statistical_fallback = FALSE,
      ...
    )

------------------------------------------------------------------------

### Method `run_bdl()`

#### Usage

    SoilSamplingTool$run_bdl(
      field_data,
      existing_samples,
      n_new_samples,
      uncertainty_type = "total",
      mc_iterations = 100,
      constitutional_compliance = TRUE,
      save_csv = FALSE
    )

------------------------------------------------------------------------

### Method `run_rf_optimization()`

#### Usage

    SoilSamplingTool$run_rf_optimization(
      field_data,
      existing_samples,
      n_new_samples,
      feature_importance_method = "permutation",
      spatial_autocorr = TRUE,
      constitutional_compliance = TRUE,
      save_csv = FALSE
    )

------------------------------------------------------------------------

### Method `run_ensemble()`

#### Usage

    SoilSamplingTool$run_ensemble(
      field_data,
      existing_samples,
      n_new_samples,
      methods = c("BDL", "RF"),
      ensemble_method = "voting",
      constitutional_compliance = TRUE
    )

------------------------------------------------------------------------

### Method `compare_designs()`

#### Usage

    SoilSamplingTool$compare_designs(
      field_data,
      existing_samples,
      n_new_samples,
      methods = c("BDL", "RF"),
      comparison_metrics = c("coverage", "representativeness"),
      constitutional_compliance = TRUE,
      statistical_test = "wilcoxon",
      detailed_metrics = TRUE
    )

------------------------------------------------------------------------

### Method `compare_models()`

#### Usage

    SoilSamplingTool$compare_models(
      field_data = NULL,
      existing_samples = NULL,
      n_new_samples,
      algorithms = self$supported_algorithms[1:3],
      n_iterations = 5,
      parallel = FALSE,
      confidence_level = 0.95,
      ...
    )

------------------------------------------------------------------------

### Method `quantify_uncertainty()`

#### Usage

    SoilSamplingTool$quantify_uncertainty(
      predictions,
      method = "ensemble",
      uncertainty_type = "total"
    )

------------------------------------------------------------------------

### Method `generate_ml_report()`

#### Usage

    SoilSamplingTool$generate_ml_report(
      result,
      report_type = "comprehensive",
      include_uncertainty_analysis = TRUE,
      include_visualizations = TRUE,
      constitutional_compliance = TRUE,
      output_dir = getwd()
    )

------------------------------------------------------------------------

### Method `generate_report()`

#### Usage

    SoilSamplingTool$generate_report(
      optimization_result = NULL,
      output_format = "html",
      report_config = NULL,
      export_path = NULL
    )

------------------------------------------------------------------------

### Method `save_coordinates_to_csv()`

#### Usage

    SoilSamplingTool$save_coordinates_to_csv(
      optimization_result = NULL,
      file_path,
      output_crs = NULL,
      include_metadata = FALSE,
      include_crs_info = FALSE,
      decimal_places = 6,
      coordinate_format = "decimal",
      column_names = NULL,
      include_fields = NULL,
      include_covariate_values = FALSE,
      validate_export = TRUE,
      constitutional_compliance = FALSE,
      quality_assurance = FALSE,
      standard_format = TRUE
    )

------------------------------------------------------------------------

### Method `get_supported_algorithms()`

#### Usage

    SoilSamplingTool$get_supported_algorithms()

------------------------------------------------------------------------

### Method `validate_report()`

#### Usage

    SoilSamplingTool$validate_report(report)

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    SoilSamplingTool$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
