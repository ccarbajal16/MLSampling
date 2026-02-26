# Package index

## Main Interface

Primary entry point for the MLSampling framework. Use
[`create_ml_sampling_tool()`](https://ccarbajal16.github.io/MLSampling/reference/create_ml_sampling_tool.md)
to create a fully configured `MLSampling` R6 instance that integrates
BDL, RF, UDL, UFN, and ensemble optimization methods.

- [`MLSampling`](https://ccarbajal16.github.io/MLSampling/reference/MLSampling.md)
  : MLSampling
- [`create_ml_sampling_tool()`](https://ccarbajal16.github.io/MLSampling/reference/create_ml_sampling_tool.md)
  : Create Enhanced ML Sampling Tool
- [`SoilSamplingTool`](https://ccarbajal16.github.io/MLSampling/reference/SoilSamplingTool.md)
  : Legacy SoilSamplingTool Class (Deprecated)
- [`create_soil_sampling_tool()`](https://ccarbajal16.github.io/MLSampling/reference/create_soil_sampling_tool.md)
  : Create default SoilSamplingTool instance (Deprecated)

## ML Model Classes

R6 classes implementing the individual ML models. These are instantiated
automatically by `MLSampling` but can also be used directly.

- [`BayesianDeepLearning`](https://ccarbajal16.github.io/MLSampling/reference/BayesianDeepLearning.md)
  : BayesianDeepLearning
- [`RandomForestOptimization`](https://ccarbajal16.github.io/MLSampling/reference/RandomForestOptimization.md)
  : RandomForestOptimization
- [`MLEnsembleManager`](https://ccarbajal16.github.io/MLSampling/reference/MLEnsembleManager.md)
  : MLEnsembleManager
- [`DesignComparison`](https://ccarbajal16.github.io/MLSampling/reference/DesignComparison.md)
  : DesignComparison
- [`SpatialAnalysisEngine`](https://ccarbajal16.github.io/MLSampling/reference/SpatialAnalysisEngine.md)
  : SpatialAnalysisEngine
- [`SpatialUncertainty`](https://ccarbajal16.github.io/MLSampling/reference/SpatialUncertainty.md)
  : SpatialUncertainty

## Service Classes

Supporting R6 service classes for configuration management,
benchmarking, progress tracking, resource management, visualization, and
reporting.

- [`BenchmarkingService`](https://ccarbajal16.github.io/MLSampling/reference/BenchmarkingService.md)
  : BenchmarkingService
- [`create_benchmarking_service()`](https://ccarbajal16.github.io/MLSampling/reference/create_benchmarking_service.md)
  : Create default benchmarking service
- [`ConfigManager`](https://ccarbajal16.github.io/MLSampling/reference/ConfigManager.md)
  : ConfigManager
- [`create_default_config_manager()`](https://ccarbajal16.github.io/MLSampling/reference/create_default_config_manager.md)
  : Create default configuration manager instance
- [`ProgressManager`](https://ccarbajal16.github.io/MLSampling/reference/ProgressManager.md)
  : ProgressManager
- [`create_progress_manager()`](https://ccarbajal16.github.io/MLSampling/reference/create_progress_manager.md)
  : Create default progress manager
- [`ReportingService`](https://ccarbajal16.github.io/MLSampling/reference/ReportingService.md)
  : ReportingService
- [`ResourceManager`](https://ccarbajal16.github.io/MLSampling/reference/ResourceManager.md)
  : ResourceManager
- [`create_resource_manager()`](https://ccarbajal16.github.io/MLSampling/reference/create_resource_manager.md)
  : Create default resource manager
- [`VisualizationService`](https://ccarbajal16.github.io/MLSampling/reference/VisualizationService.md)
  : VisualizationService

## Field Data Validation

Functions for validating system requirements, field data structures, CRS
consistency, and ML-related spatial data quality.

- [`validate_system_requirements()`](https://ccarbajal16.github.io/MLSampling/reference/validate_system_requirements.md)
  : Validate system requirements for constitutional compliance
- [`validate_field_data_structure()`](https://ccarbajal16.github.io/MLSampling/reference/validate_field_data_structure.md)
  : Enhanced Field Data Model with ML Metadata Support
- [`validate_field_data()`](https://ccarbajal16.github.io/MLSampling/reference/validate_field_data.md)
  : Validate field data structure and spatial integrity
- [`validate_crs_consistency()`](https://ccarbajal16.github.io/MLSampling/reference/validate_crs_consistency.md)
  : Validate CRS consistency between spatial objects
- [`validate_ml_data()`](https://ccarbajal16.github.io/MLSampling/reference/validate_ml_data.md)
  : Validate data for ML modeling

## Sampling & Result Validation

Validation functions for sampling location sets, optimization results,
and uncertainty quantification outputs.

- [`validate_sampling_locations()`](https://ccarbajal16.github.io/MLSampling/reference/validate_sampling_locations.md)
  : Validate sampling locations against field data
- [`validate_sampling_locations_model()`](https://ccarbajal16.github.io/MLSampling/reference/validate_sampling_locations_model.md)
  : Validate sampling locations data structure
- [`validate_optimization_result()`](https://ccarbajal16.github.io/MLSampling/reference/validate_optimization_result.md)
  : Validate optimization result (backward compatibility)
- [`validate_ml_optimization_result()`](https://ccarbajal16.github.io/MLSampling/reference/validate_ml_optimization_result.md)
  : Validate ML optimization result structure
- [`validate_uncertainty_results()`](https://ccarbajal16.github.io/MLSampling/reference/validate_uncertainty_results.md)
  : Validate uncertainty quantification results

## Data Structures

Factory functions for creating standardized result objects used
throughout the optimization pipeline.

- [`create_sampling_locations()`](https://ccarbajal16.github.io/MLSampling/reference/create_sampling_locations.md)
  : Sampling Locations Model
- [`create_uncertainty_results()`](https://ccarbajal16.github.io/MLSampling/reference/create_uncertainty_results.md)
  : Uncertainty Quantification Model
- [`create_spatial_uncertainty()`](https://ccarbajal16.github.io/MLSampling/reference/create_spatial_uncertainty.md)
  : Create Spatial Uncertainty instance
- [`create_ml_optimization_result()`](https://ccarbajal16.github.io/MLSampling/reference/create_ml_optimization_result.md)
  : Enhanced ML Results Model
- [`create_optimization_result()`](https://ccarbajal16.github.io/MLSampling/reference/create_optimization_result.md)
  : Create backward compatibility wrapper

## Error Handling

Structured error class hierarchy and handler utilities for robust
exception management. All domain errors inherit from `MLSamplingError`.

- [`MLSamplingErrors`](https://ccarbajal16.github.io/MLSampling/reference/MLSamplingErrors.md)
  : Standardized Error Classes
- [`MLSamplingError()`](https://ccarbajal16.github.io/MLSampling/reference/MLSamplingError.md)
  : Base MLSampling Error
- [`BDLError()`](https://ccarbajal16.github.io/MLSampling/reference/BDLError.md)
  : Bayesian Deep Learning Error
- [`RFError()`](https://ccarbajal16.github.io/MLSampling/reference/RFError.md)
  : Random Forest Optimization Error
- [`SpatialError()`](https://ccarbajal16.github.io/MLSampling/reference/SpatialError.md)
  : Spatial Analysis Error
- [`ResourceError()`](https://ccarbajal16.github.io/MLSampling/reference/ResourceError.md)
  : Resource/Memory Error
- [`ConfigError()`](https://ccarbajal16.github.io/MLSampling/reference/ConfigError.md)
  : Configuration Error
- [`ValidationError()`](https://ccarbajal16.github.io/MLSampling/reference/ValidationError.md)
  : Data Validation Error
- [`create_error()`](https://ccarbajal16.github.io/MLSampling/reference/create_error.md)
  : Create a custom error condition
- [`raise_error()`](https://ccarbajal16.github.io/MLSampling/reference/raise_error.md)
  : Raise a specific error
- [`with_error_handling()`](https://ccarbajal16.github.io/MLSampling/reference/with_error_handling.md)
  : Safe execution wrapper

## Internal Functions

Low-level helper functions used internally by the package. Documented
here for developer reference.

- [`BDLError()`](https://ccarbajal16.github.io/MLSampling/reference/BDLError.md)
  : Bayesian Deep Learning Error
- [`BayesianDeepLearning`](https://ccarbajal16.github.io/MLSampling/reference/BayesianDeepLearning.md)
  : BayesianDeepLearning
- [`BenchmarkingService`](https://ccarbajal16.github.io/MLSampling/reference/BenchmarkingService.md)
  : BenchmarkingService
- [`ConfigError()`](https://ccarbajal16.github.io/MLSampling/reference/ConfigError.md)
  : Configuration Error
- [`ConfigManager`](https://ccarbajal16.github.io/MLSampling/reference/ConfigManager.md)
  : ConfigManager
- [`DesignComparison`](https://ccarbajal16.github.io/MLSampling/reference/DesignComparison.md)
  : DesignComparison
- [`MLEnsembleManager`](https://ccarbajal16.github.io/MLSampling/reference/MLEnsembleManager.md)
  : MLEnsembleManager
- [`MLSampling`](https://ccarbajal16.github.io/MLSampling/reference/MLSampling.md)
  : MLSampling
- [`MLSamplingError()`](https://ccarbajal16.github.io/MLSampling/reference/MLSamplingError.md)
  : Base MLSampling Error
- [`MLSamplingErrors`](https://ccarbajal16.github.io/MLSampling/reference/MLSamplingErrors.md)
  : Standardized Error Classes
- [`ProgressManager`](https://ccarbajal16.github.io/MLSampling/reference/ProgressManager.md)
  : ProgressManager
- [`RFError()`](https://ccarbajal16.github.io/MLSampling/reference/RFError.md)
  : Random Forest Optimization Error
- [`RandomForestOptimization`](https://ccarbajal16.github.io/MLSampling/reference/RandomForestOptimization.md)
  : RandomForestOptimization
- [`ReportingService`](https://ccarbajal16.github.io/MLSampling/reference/ReportingService.md)
  : ReportingService
- [`ResourceError()`](https://ccarbajal16.github.io/MLSampling/reference/ResourceError.md)
  : Resource/Memory Error
- [`ResourceManager`](https://ccarbajal16.github.io/MLSampling/reference/ResourceManager.md)
  : ResourceManager
- [`SoilSamplingTool`](https://ccarbajal16.github.io/MLSampling/reference/SoilSamplingTool.md)
  : Legacy SoilSamplingTool Class (Deprecated)
- [`SpatialAnalysisEngine`](https://ccarbajal16.github.io/MLSampling/reference/SpatialAnalysisEngine.md)
  : SpatialAnalysisEngine
- [`SpatialError()`](https://ccarbajal16.github.io/MLSampling/reference/SpatialError.md)
  : Spatial Analysis Error
- [`SpatialUncertainty`](https://ccarbajal16.github.io/MLSampling/reference/SpatialUncertainty.md)
  : SpatialUncertainty
- [`ValidationError()`](https://ccarbajal16.github.io/MLSampling/reference/ValidationError.md)
  : Data Validation Error
- [`VisualizationService`](https://ccarbajal16.github.io/MLSampling/reference/VisualizationService.md)
  : VisualizationService
- [`calculate_derived_uncertainties()`](https://ccarbajal16.github.io/MLSampling/reference/calculate_derived_uncertainties.md)
  : Calculate derived uncertainty measures
- [`check_duplicate_coordinates()`](https://ccarbajal16.github.io/MLSampling/reference/check_duplicate_coordinates.md)
  : Check for duplicate coordinates
- [`create_benchmarking_service()`](https://ccarbajal16.github.io/MLSampling/reference/create_benchmarking_service.md)
  : Create default benchmarking service
- [`create_default_config_manager()`](https://ccarbajal16.github.io/MLSampling/reference/create_default_config_manager.md)
  : Create default configuration manager instance
- [`create_default_metrics()`](https://ccarbajal16.github.io/MLSampling/reference/create_default_metrics.md)
  : Create default performance metrics
- [`create_empty_ml_metadata()`](https://ccarbajal16.github.io/MLSampling/reference/create_empty_ml_metadata.md)
  : Create empty ML metadata structure for future use
- [`create_error()`](https://ccarbajal16.github.io/MLSampling/reference/create_error.md)
  : Create a custom error condition
- [`create_ml_optimization_result()`](https://ccarbajal16.github.io/MLSampling/reference/create_ml_optimization_result.md)
  : Enhanced ML Results Model
- [`create_ml_result_metadata()`](https://ccarbajal16.github.io/MLSampling/reference/create_ml_result_metadata.md)
  : Create ML result metadata
- [`create_ml_sampling_tool()`](https://ccarbajal16.github.io/MLSampling/reference/create_ml_sampling_tool.md)
  : Create Enhanced ML Sampling Tool
- [`create_optimization_result()`](https://ccarbajal16.github.io/MLSampling/reference/create_optimization_result.md)
  : Create backward compatibility wrapper
- [`create_progress_manager()`](https://ccarbajal16.github.io/MLSampling/reference/create_progress_manager.md)
  : Create default progress manager
- [`create_resource_manager()`](https://ccarbajal16.github.io/MLSampling/reference/create_resource_manager.md)
  : Create default resource manager
- [`create_result_metadata()`](https://ccarbajal16.github.io/MLSampling/reference/create_result_metadata.md)
  : Create result metadata
- [`create_sampling_locations()`](https://ccarbajal16.github.io/MLSampling/reference/create_sampling_locations.md)
  : Sampling Locations Model
- [`create_soil_sampling_tool()`](https://ccarbajal16.github.io/MLSampling/reference/create_soil_sampling_tool.md)
  : Create default SoilSamplingTool instance (Deprecated)
- [`create_spatial_uncertainty()`](https://ccarbajal16.github.io/MLSampling/reference/create_spatial_uncertainty.md)
  : Create Spatial Uncertainty instance
- [`create_uncertainty_results()`](https://ccarbajal16.github.io/MLSampling/reference/create_uncertainty_results.md)
  : Uncertainty Quantification Model
- [`determine_primary_crs()`](https://ccarbajal16.github.io/MLSampling/reference/determine_primary_crs.md)
  : Determine primary CRS from field data
- [`extract_metric_value()`](https://ccarbajal16.github.io/MLSampling/reference/extract_metric_value.md)
  : Extract metric value safely
- [`extract_ml_component()`](https://ccarbajal16.github.io/MLSampling/reference/extract_ml_component.md)
  : Extract ML component from ml_components list
- [`generate_sample_ids()`](https://ccarbajal16.github.io/MLSampling/reference/generate_sample_ids.md)
  : Generate automatic sample IDs
- [`` `%||%` ``](https://ccarbajal16.github.io/MLSampling/reference/grapes-or-or-grapes.md)
  : Helper function for NULL coalescing
- [`raise_error()`](https://ccarbajal16.github.io/MLSampling/reference/raise_error.md)
  : Raise a specific error
- [`standardize_confidence_intervals()`](https://ccarbajal16.github.io/MLSampling/reference/standardize_confidence_intervals.md)
  : Standardize confidence intervals
- [`standardize_existing_samples()`](https://ccarbajal16.github.io/MLSampling/reference/standardize_existing_samples.md)
  : Standardize existing samples format
- [`standardize_field_data_structure()`](https://ccarbajal16.github.io/MLSampling/reference/standardize_field_data_structure.md)
  : Standardize field data structure with ML enhancements
- [`standardize_location_output()`](https://ccarbajal16.github.io/MLSampling/reference/standardize_location_output.md)
  : Standardize location output format
- [`standardize_ml_metadata()`](https://ccarbajal16.github.io/MLSampling/reference/standardize_ml_metadata.md)
  : Standardize ML metadata structure
- [`standardize_ml_performance_metrics()`](https://ccarbajal16.github.io/MLSampling/reference/standardize_ml_performance_metrics.md)
  : Standardize ML performance metrics
- [`standardize_optimization_parameters()`](https://ccarbajal16.github.io/MLSampling/reference/standardize_optimization_parameters.md)
  : Standardize optimization parameters
- [`standardize_performance_metrics()`](https://ccarbajal16.github.io/MLSampling/reference/standardize_performance_metrics.md)
  : Standardize performance metrics structure
- [`standardize_uncertainty_component()`](https://ccarbajal16.github.io/MLSampling/reference/standardize_uncertainty_component.md)
  : Standardize uncertainty component
- [`standardize_uncertainty_rasters()`](https://ccarbajal16.github.io/MLSampling/reference/standardize_uncertainty_rasters.md)
  : Standardize uncertainty rasters
- [`standardize_uncertainty_validation_metrics()`](https://ccarbajal16.github.io/MLSampling/reference/standardize_uncertainty_validation_metrics.md)
  : Standardize uncertainty validation metrics
- [`validate_and_expand_vector()`](https://ccarbajal16.github.io/MLSampling/reference/validate_and_expand_vector.md)
  : Validate and expand vector to match required length
- [`validate_boundary_geometry()`](https://ccarbajal16.github.io/MLSampling/reference/validate_boundary_geometry.md)
  : Validate boundary geometry integrity
- [`validate_compliance_structure()`](https://ccarbajal16.github.io/MLSampling/reference/validate_compliance_structure.md)
  : Validate compliance structure
- [`validate_confidence_intervals_structure()`](https://ccarbajal16.github.io/MLSampling/reference/validate_confidence_intervals_structure.md)
  : Validate confidence intervals structure
- [`validate_constitutional_compliance()`](https://ccarbajal16.github.io/MLSampling/reference/validate_constitutional_compliance.md)
  : Validate constitutional compliance
- [`validate_constitutional_spatial_standards()`](https://ccarbajal16.github.io/MLSampling/reference/validate_constitutional_spatial_standards.md)
  : Validate constitutional spatial standards compliance
- [`validate_coordinates_input()`](https://ccarbajal16.github.io/MLSampling/reference/validate_coordinates_input.md)
  : Validate coordinate input format
- [`validate_covariate_rasters()`](https://ccarbajal16.github.io/MLSampling/reference/validate_covariate_rasters.md)
  : Validate covariate rasters
- [`validate_covariates_raster()`](https://ccarbajal16.github.io/MLSampling/reference/validate_covariates_raster.md)
  : Validate covariates raster integrity
- [`validate_crs_consistency()`](https://ccarbajal16.github.io/MLSampling/reference/validate_crs_consistency.md)
  : Validate CRS consistency between spatial objects
- [`validate_data_quality()`](https://ccarbajal16.github.io/MLSampling/reference/validate_data_quality.md)
  : Validate data quality standards
- [`validate_feature_importance()`](https://ccarbajal16.github.io/MLSampling/reference/validate_feature_importance.md)
  : Validate feature importance scores
- [`validate_field_boundary_geometry()`](https://ccarbajal16.github.io/MLSampling/reference/validate_field_boundary_geometry.md)
  : Validate boundary geometry
- [`validate_field_crs_consistency()`](https://ccarbajal16.github.io/MLSampling/reference/validate_field_crs_consistency.md)
  : Validate CRS consistency across spatial objects
- [`validate_field_data()`](https://ccarbajal16.github.io/MLSampling/reference/validate_field_data.md)
  : Validate field data structure and spatial integrity
- [`validate_field_data_structure()`](https://ccarbajal16.github.io/MLSampling/reference/validate_field_data_structure.md)
  : Enhanced Field Data Model with ML Metadata Support
- [`validate_location_types()`](https://ccarbajal16.github.io/MLSampling/reference/validate_location_types.md)
  : Validate location types
- [`validate_locations_in_boundary()`](https://ccarbajal16.github.io/MLSampling/reference/validate_locations_in_boundary.md)
  : Validate locations are within field boundary
- [`validate_mc_samples()`](https://ccarbajal16.github.io/MLSampling/reference/validate_mc_samples.md)
  : Validate Monte Carlo samples
- [`validate_mc_samples_consistency()`](https://ccarbajal16.github.io/MLSampling/reference/validate_mc_samples_consistency.md)
  : Validate Monte Carlo samples consistency
- [`validate_ml_components()`](https://ccarbajal16.github.io/MLSampling/reference/validate_ml_components.md)
  : Validate ML components structure
- [`validate_ml_components_consistency()`](https://ccarbajal16.github.io/MLSampling/reference/validate_ml_components_consistency.md)
  : Validate ML components consistency
- [`validate_ml_constitutional_compliance()`](https://ccarbajal16.github.io/MLSampling/reference/validate_ml_constitutional_compliance.md)
  : Validate ML constitutional compliance
- [`validate_ml_data()`](https://ccarbajal16.github.io/MLSampling/reference/validate_ml_data.md)
  : Validate data for ML modeling
- [`validate_ml_metadata()`](https://ccarbajal16.github.io/MLSampling/reference/validate_ml_metadata.md)
  : Validate ML metadata structure
- [`validate_ml_method()`](https://ccarbajal16.github.io/MLSampling/reference/validate_ml_method.md)
  : Validate ML method specification
- [`validate_ml_optimization_result()`](https://ccarbajal16.github.io/MLSampling/reference/validate_ml_optimization_result.md)
  : Validate ML optimization result structure
- [`validate_n_samples()`](https://ccarbajal16.github.io/MLSampling/reference/validate_n_samples.md)
  : Validate number of samples
- [`validate_numeric_coordinates()`](https://ccarbajal16.github.io/MLSampling/reference/validate_numeric_coordinates.md)
  : Validate numeric coordinates
- [`validate_optimization_result()`](https://ccarbajal16.github.io/MLSampling/reference/validate_optimization_result.md)
  : Validate optimization result (backward compatibility)
- [`validate_result_metrics()`](https://ccarbajal16.github.io/MLSampling/reference/validate_result_metrics.md)
  : Validate result metrics structure
- [`validate_sample_ids()`](https://ccarbajal16.github.io/MLSampling/reference/validate_sample_ids.md)
  : Validate sample IDs
- [`validate_sampling_locations()`](https://ccarbajal16.github.io/MLSampling/reference/validate_sampling_locations.md)
  : Validate sampling locations against field data
- [`validate_sampling_locations_model()`](https://ccarbajal16.github.io/MLSampling/reference/validate_sampling_locations_model.md)
  : Validate sampling locations data structure
- [`validate_selected_locations()`](https://ccarbajal16.github.io/MLSampling/reference/validate_selected_locations.md)
  : Validate selected locations structure
- [`validate_single_uncertainty_component()`](https://ccarbajal16.github.io/MLSampling/reference/validate_single_uncertainty_component.md)
  : Validate single uncertainty component
- [`validate_spatial_consistency()`](https://ccarbajal16.github.io/MLSampling/reference/validate_spatial_consistency.md)
  : Validate spatial consistency across uncertainty components
- [`validate_spatial_extent_alignment()`](https://ccarbajal16.github.io/MLSampling/reference/validate_spatial_extent_alignment.md)
  : Validate spatial extent alignment
- [`validate_spatial_weights()`](https://ccarbajal16.github.io/MLSampling/reference/validate_spatial_weights.md)
  : Validate spatial weights matrix
- [`validate_system_requirements()`](https://ccarbajal16.github.io/MLSampling/reference/validate_system_requirements.md)
  : Validate system requirements for constitutional compliance
- [`validate_uncertainty_components()`](https://ccarbajal16.github.io/MLSampling/reference/validate_uncertainty_components.md)
  : Validate uncertainty components
- [`validate_uncertainty_consistency()`](https://ccarbajal16.github.io/MLSampling/reference/validate_uncertainty_consistency.md)
  : Validate uncertainty consistency
- [`validate_uncertainty_maps()`](https://ccarbajal16.github.io/MLSampling/reference/validate_uncertainty_maps.md)
  : Validate uncertainty maps
- [`validate_uncertainty_method()`](https://ccarbajal16.github.io/MLSampling/reference/validate_uncertainty_method.md)
  : Validate uncertainty method
- [`validate_uncertainty_results()`](https://ccarbajal16.github.io/MLSampling/reference/validate_uncertainty_results.md)
  : Validate uncertainty quantification results
- [`with_error_handling()`](https://ccarbajal16.github.io/MLSampling/reference/with_error_handling.md)
  : Safe execution wrapper
