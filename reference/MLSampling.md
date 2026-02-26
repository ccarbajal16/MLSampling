# MLSampling

Main interface for the MLSampling package. Integrates multiple machine
learning models (BDL, RF, UDL, UFN) and ensemble strategies for
optimizing spatial sampling designs. Provides advanced spatial analysis,
design comparison, and uncertainty quantification.

## Details

The MLSampling class integrates all constitutional principles:

- Code Quality Excellence: Comprehensive error handling and validation

- Spatial Analysis Excellence: Modern terra/sf usage with CRS validation

- Testing Standards: 90%+ test coverage with TDD approach

- User Experience Consistency: Consistent APIs and progress feedback

- Performance Excellence: Memory efficiency and parallel support

It combines the core capabilities of the legacy SoilSamplingTool with
advanced ML modules:

- Bayesian Deep Learning (BDL) for uncertainty quantification

- Random Forest (RF) for feature importance-based optimization

- Ensemble methods (Voting, Stacking)

- Unified Deep Learning (UDL) & Unified Feature Network (UFN)

## Public fields

- `config_manager`:

  Configuration manager instance

- `validation_service`:

  Spatial data validation service

- `benchmarking_service`:

  Performance benchmarking service

- `progress_manager`:

  Progress tracking manager

- `resource_manager`:

  Resource management manager

- `supported_algorithms`:

  Supported optimization algorithms

- `constitutional_compliance`:

  Constitutional compliance tracker

- `bdl_module`:

  Bayesian Deep Learning module instance

- `rf_module`:

  Random Forest module instance

- `ensemble_manager`:

  Ensemble manager instance

- `spatial_engine`:

  Spatial analysis engine instance

- `comparison_engine`:

  Design comparison framework instance

- `reporting_service`:

  Reporting service instance

- `visualization_service`:

  Visualization service instance Initialize MLSampling Tool

## Methods

### Public methods

- [`MLSampling$new()`](#method-MLSampling-new)

- [`MLSampling$run_udl()`](#method-MLSampling-run_udl)

- [`MLSampling$run_ufn()`](#method-MLSampling-run_ufn)

- [`MLSampling$run_bdl()`](#method-MLSampling-run_bdl)

- [`MLSampling$run_rf_optimization()`](#method-MLSampling-run_rf_optimization)

- [`MLSampling$run_ensemble()`](#method-MLSampling-run_ensemble)

- [`MLSampling$compare_designs()`](#method-MLSampling-compare_designs)

- [`MLSampling$compare_models()`](#method-MLSampling-compare_models)

- [`MLSampling$quantify_uncertainty()`](#method-MLSampling-quantify_uncertainty)

- [`MLSampling$generate_ml_report()`](#method-MLSampling-generate_ml_report)

- [`MLSampling$generate_report()`](#method-MLSampling-generate_report)

- [`MLSampling$save_coordinates_to_csv()`](#method-MLSampling-save_coordinates_to_csv)

- [`MLSampling$get_supported_algorithms()`](#method-MLSampling-get_supported_algorithms)

- [`MLSampling$validate_report()`](#method-MLSampling-validate_report)

- [`MLSampling$clone()`](#method-MLSampling-clone)

------------------------------------------------------------------------

### Method `new()`

#### Usage

    MLSampling$new(config = NULL, config_manager = NULL, validate_system = FALSE)

#### Arguments

- `config`:

  Optional configuration list

- `config_manager`:

  Optional ConfigManager instance

- `validate_system`:

  Whether to validate system requirements Run Unified Deep Learning
  (UDL) optimization

------------------------------------------------------------------------

### Method `run_udl()`

#### Usage

    MLSampling$run_udl(
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

#### Arguments

- `field_data`:

  List containing boundary, covariates, and metadata

- `existing_samples`:

  Optional data frame with existing sample locations

- `n_new_samples`:

  Number of new samples to select

- `optimization_method`:

  Optimization algorithm to use

- `model_config`:

  Optional model configuration

- `parallel`:

  Whether to use parallel processing

#### Returns

OptimizationResult object with selected locations and performance
metrics Run Unified Feature Network (UFN) optimization

------------------------------------------------------------------------

### Method `run_ufn()`

#### Usage

    MLSampling$run_ufn(
      field_data = NULL,
      existing_samples = NULL,
      n_new_samples,
      model_config = NULL,
      force_neural_network = FALSE,
      force_statistical_fallback = FALSE,
      ...
    )

#### Arguments

- `field_data`:

  List containing boundary, covariates, and metadata

- `existing_samples`:

  Optional data frame with existing sample locations

- `n_new_samples`:

  Number of new samples to select

- `model_config`:

  UFN model configuration

- `force_neural_network`:

  Force use of neural network (requires torch)

- `force_statistical_fallback`:

  Force use of statistical fallback

#### Returns

OptimizationResult object with UFN-specific results Run Bayesian Deep
Learning Optimization

------------------------------------------------------------------------

### Method `run_bdl()`

#### Usage

    MLSampling$run_bdl(
      field_data,
      existing_samples,
      n_new_samples,
      uncertainty_type = "total",
      mc_iterations = 100,
      constitutional_compliance = TRUE,
      save_csv = FALSE
    )

#### Arguments

- `field_data`:

  Field data

- `existing_samples`:

  Existing samples

- `n_new_samples`:

  Number of new samples

- `uncertainty_type`:

  "epistemic", "aleatoric", or "total"

- `mc_iterations`:

  Number of Monte Carlo iterations

- `constitutional_compliance`:

  Boolean flag

- `save_csv`:

  Boolean flag

#### Returns

OptimizationResult with uncertainty data Run Random Forest Optimization

------------------------------------------------------------------------

### Method `run_rf_optimization()`

#### Usage

    MLSampling$run_rf_optimization(
      field_data,
      existing_samples,
      n_new_samples,
      feature_importance_method = "permutation",
      spatial_autocorr = TRUE,
      constitutional_compliance = TRUE,
      save_csv = FALSE
    )

#### Arguments

- `field_data`:

  Field data

- `existing_samples`:

  Existing samples

- `n_new_samples`:

  Number of new samples

- `feature_importance_method`:

  Method for importance

- `spatial_autocorr`:

  Boolean to use spatial features

- `constitutional_compliance`:

  Boolean flag

- `save_csv`:

  Boolean flag

#### Returns

OptimizationResult with feature importance Run Ensemble Optimization

------------------------------------------------------------------------

### Method `run_ensemble()`

#### Usage

    MLSampling$run_ensemble(
      field_data,
      existing_samples,
      n_new_samples,
      methods = c("BDL", "RF"),
      ensemble_method = "voting",
      constitutional_compliance = TRUE
    )

#### Arguments

- `field_data`:

  Field data

- `existing_samples`:

  Existing samples

- `n_new_samples`:

  Number of new samples

- `methods`:

  Vector of methods to combine

- `ensemble_method`:

  "voting" or "stacking"

- `constitutional_compliance`:

  Boolean flag

#### Returns

OptimizationResult Compare Sampling Designs (Advanced)

------------------------------------------------------------------------

### Method `compare_designs()`

#### Usage

    MLSampling$compare_designs(
      field_data,
      existing_samples,
      n_new_samples,
      methods = c("BDL", "RF"),
      comparison_metrics = c("coverage", "representativeness"),
      constitutional_compliance = TRUE,
      statistical_test = "wilcoxon",
      detailed_metrics = TRUE
    )

#### Arguments

- `field_data`:

  Field data

- `existing_samples`:

  Existing samples

- `n_new_samples`:

  Number of new samples

- `methods`:

  Vector of methods to compare

- `comparison_metrics`:

  Metrics to use

- `constitutional_compliance`:

  Boolean flag

- `statistical_test`:

  Test type

- `detailed_metrics`:

  Boolean flag

#### Returns

Comparison result Compare multiple optimization algorithms
(Legacy/Basic)

------------------------------------------------------------------------

### Method `compare_models()`

#### Usage

    MLSampling$compare_models(
      field_data = NULL,
      existing_samples = NULL,
      n_new_samples,
      algorithms = self$supported_algorithms[1:3],
      n_iterations = 5,
      parallel = FALSE,
      confidence_level = 0.95,
      ...
    )

#### Arguments

- `field_data`:

  List containing boundary, covariates, and metadata

- `existing_samples`:

  Optional data frame with existing sample locations

- `n_new_samples`:

  Number of new samples to select

- `algorithms`:

  Vector of algorithms to compare

- `n_iterations`:

  Number of iterations for statistical comparison

- `parallel`:

  Whether to use parallel processing

- `confidence_level`:

  Confidence level for statistical tests

#### Returns

ModelComparison object with detailed comparison results Quantify
Uncertainty

------------------------------------------------------------------------

### Method `quantify_uncertainty()`

#### Usage

    MLSampling$quantify_uncertainty(
      predictions,
      method = "ensemble",
      uncertainty_type = "total"
    )

#### Arguments

- `predictions`:

  Predictions to analyze

- `method`:

  Method used

- `uncertainty_type`:

  Type of uncertainty

#### Returns

Uncertainty analysis Generate ML Report

------------------------------------------------------------------------

### Method `generate_ml_report()`

#### Usage

    MLSampling$generate_ml_report(
      result,
      report_type = "comprehensive",
      include_uncertainty_analysis = TRUE,
      include_visualizations = TRUE,
      constitutional_compliance = TRUE,
      output_dir = getwd()
    )

#### Arguments

- `result`:

  Result object

- `report_type`:

  "comprehensive" or "standard"

- `include_uncertainty_analysis`:

  Boolean

- `include_visualizations`:

  Boolean

- `constitutional_compliance`:

  Boolean

- `output_dir`:

  Directory to save report

#### Returns

Report object Generate comprehensive optimization report (Base)

------------------------------------------------------------------------

### Method `generate_report()`

#### Usage

    MLSampling$generate_report(
      optimization_result = NULL,
      output_format = "html",
      report_config = NULL,
      export_path = NULL
    )

#### Arguments

- `optimization_result`:

  Result from run_udl, run_ufn, or compare_models

- `output_format`:

  Output format ("html", "pdf", "text")

- `report_config`:

  Report configuration options

- `export_path`:

  Optional path to export report

#### Returns

SamplingReport or ComparisonReport object Export optimization results to
CSV

------------------------------------------------------------------------

### Method `save_coordinates_to_csv()`

#### Usage

    MLSampling$save_coordinates_to_csv(
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

#### Arguments

- `optimization_result`:

  Result from optimization

- `file_path`:

  Path for CSV export

- `output_crs`:

  Target coordinate system for export

- `include_metadata`:

  Whether to include metadata

- `include_crs_info`:

  Whether to include CRS information

- `decimal_places`:

  Number of decimal places for coordinates

- `coordinate_format`:

  Coordinate format option

- `column_names`:

  Custom column names

- `include_fields`:

  Additional fields to include

- `include_covariate_values`:

  Whether to include covariate values

- `validate_export`:

  Whether to validate exported data

- `constitutional_compliance`:

  Whether to include constitutional compliance info

- `quality_assurance`:

  Whether to perform quality checks

- `standard_format`:

  Whether to use standardized format

#### Returns

Export result object with status and metadata Get supported optimization
algorithms

------------------------------------------------------------------------

### Method `get_supported_algorithms()`

#### Usage

    MLSampling$get_supported_algorithms()

#### Returns

Vector of supported algorithm names Validate report structure and
content

------------------------------------------------------------------------

### Method `validate_report()`

#### Usage

    MLSampling$validate_report(report)

#### Arguments

- `report`:

  Report object to validate

#### Returns

Validation result Execute Unified Deep Learning optimization Execute
Unified Feature Network optimization

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    MLSampling$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
