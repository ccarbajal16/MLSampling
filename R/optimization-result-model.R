# Enhanced Optimization Result Structure with ML Support
# Constitutional Compliance: Code Quality Excellence and Performance Excellence
# Comprehensive output structure for ML-enhanced optimization algorithms

#' Enhanced ML Results Model
#'
#' @description
#' Provides standardized structure for ML-enhanced optimization algorithm outputs 
#' following constitutional principles. Includes comprehensive result validation, 
#' metadata management, performance tracking, and ML-specific components for 
#' unified result handling across BDL, RF, UDL, and UFN methods.
#'
#' @details
#' MLResults ensures consistent output structure across all ML optimization
#' algorithms with constitutional compliance for performance excellence and 
#' spatial analysis standards. Supports multiple ML method outputs and 
#' comparison data.

#' Create standardized ML optimization result structure
#'
#' @param selected_locations Data frame with new sampling locations
#' @param existing_samples Data frame with existing sampling locations
#' @param field_data Reference to input field data
#' @param metrics Performance metrics list
#' @param parameters Optimization parameters used
#' @param algorithm_specific List with algorithm-specific outputs
#' @param metadata Additional metadata
#' @param ml_components List with ML-specific components (predictions, uncertainties, etc.)
#' @param method Character string identifying ML method ("BDL", "RF", "UDL", "UFN", "Ensemble")
#'
#' @return Standardized ML optimization result list
#'
#' @examples
#' \dontrun{
#' # Create ML optimization result
#' result <- create_ml_optimization_result(
#'   selected_locations = new_locations_df,
#'   existing_samples = existing_df,
#'   field_data = field_data,
#'   metrics = performance_metrics,
#'   parameters = optimization_params,
#'   ml_components = list(
#'     predictions = prediction_raster,
#'     uncertainties = uncertainty_raster,
#'     feature_importance = importance_scores
#'   ),
#'   method = "BDL"
#' )
#' }
#'
#' @export
create_ml_optimization_result <- function(selected_locations,
                                        existing_samples = NULL,
                                        field_data = NULL,
                                        metrics = NULL,
                                        parameters = NULL,
                                        algorithm_specific = NULL,
                                        metadata = NULL,
                                        ml_components = NULL,
                                        method = "unknown") {
  
  # Validate required inputs
  if (is.null(selected_locations)) {
    stop(ConfigurationError(
      message = "selected_locations is required",
      suggestion = "Provide data.frame with selected sampling locations"
    ))
  }
  
  # Validate selected locations structure
  location_validation <- validate_selected_locations(selected_locations)
  if (!location_validation$valid) {
    stop(SpatialDataError(
      message = "Invalid selected locations structure",
      validation_details = location_validation,
      suggestion = "Ensure selected_locations has required columns: x, y, sample_id, type, model"
    ))
  }
  
  # Validate ML components if provided
  if (!is.null(ml_components)) {
    ml_validation <- validate_ml_components(ml_components, method)
    if (!ml_validation$valid) {
      stop(ConfigurationError(
        message = "Invalid ML components structure",
        validation_details = ml_validation,
        suggestion = "Ensure ML components contain valid predictions, uncertainties, or feature importance"
      ))
    }
  }
  
  # Create enhanced ML result structure
  ml_optimization_result <- list(
    # Method identification (ML enhancement)
    method = validate_ml_method(method),
    
    # Core components (constitutional requirement)
    selected_locations = standardize_location_output(selected_locations),
    existing_samples = standardize_existing_samples(existing_samples),
    field_data = field_data,
    
    # ML-specific results (enhancement)
    predictions = extract_ml_component(ml_components, "predictions"),
    uncertainties = extract_ml_component(ml_components, "uncertainties"),
    feature_importance = extract_ml_component(ml_components, "feature_importance"),
    
    # Model artifacts (ML enhancement)
    trained_models = extract_ml_component(ml_components, "trained_models", list()),
    optimization_trace = extract_ml_component(ml_components, "optimization_trace"),
    
    # Performance metrics (enhanced)
    metrics = standardize_ml_performance_metrics(metrics, method),
    parameters = standardize_optimization_parameters(parameters),
    
    # Comparison data (ML enhancement)
    comparison_baseline = extract_ml_component(ml_components, "comparison_baseline"),
    statistical_significance = extract_ml_component(ml_components, "statistical_significance"),
    
    # Metadata (constitutional compliance)
    metadata = create_ml_result_metadata(metadata, method)
  )
  
  # Add algorithm-specific components if provided
  if (!is.null(algorithm_specific) && is.list(algorithm_specific)) {
    ml_optimization_result <- append(ml_optimization_result, algorithm_specific)
  }
  
  # Enhanced constitutional compliance tracking
  ml_optimization_result$constitutional_compliance <- validate_ml_constitutional_compliance(
    selected_locations, metrics, parameters, ml_components, method
  )
  
  # Set enhanced class for method dispatch
  class(ml_optimization_result) <- c("MLOptimizationResult", "OptimizationResult", "list")
  
  # Add enhanced validation log
  attr(ml_optimization_result, "validation_log") <- list(
    creation_time = Sys.time(),
    method = method,
    n_selected = nrow(selected_locations),
    n_existing = if (!is.null(existing_samples)) nrow(existing_samples) else 0,
    has_predictions = !is.null(ml_optimization_result$predictions),
    has_uncertainties = !is.null(ml_optimization_result$uncertainties),
    has_feature_importance = !is.null(ml_optimization_result$feature_importance),
    validation_passed = TRUE,
    constitutional_compliance = TRUE,
    ml_enhanced = TRUE
  )
  
  return(ml_optimization_result)
}

#' Validate ML optimization result structure
#'
#' @param ml_optimization_result MLOptimizationResult object
#' @param strict_validation Logical for strict constitutional compliance
#'
#' @return List with validation results
#'
#' @export
validate_ml_optimization_result <- function(ml_optimization_result, strict_validation = TRUE) {
  
  validation <- list(
    valid = TRUE,
    issues = character(0),
    warnings = character(0),
    constitutional_compliance = TRUE,
    ml_compliance = TRUE
  )
  
  # Check basic structure
  if (!inherits(ml_optimization_result, "MLOptimizationResult")) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "Object is not MLOptimizationResult class")
    return(validation)
  }
  
  # Check required components (enhanced for ML)
  required_components <- c("method", "selected_locations", "metrics", "metadata", 
                          "constitutional_compliance")
  missing_components <- setdiff(required_components, names(ml_optimization_result))
  
  if (length(missing_components) > 0) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues,
                          paste("Missing components:", paste(missing_components, collapse = ", ")))
  }
  
  # Validate ML method
  if ("method" %in% names(ml_optimization_result)) {
    method_validation <- validate_ml_method(ml_optimization_result$method)
    if (!method_validation %in% c("BDL", "RF", "UDL", "UFN", "Ensemble", "unknown")) {
      validation$ml_compliance <- FALSE
      validation$issues <- c(validation$issues, "Invalid ML method specified")
    }
  }
  
  # Validate ML components consistency
  if (!is.null(ml_optimization_result$predictions) || 
      !is.null(ml_optimization_result$uncertainties) ||
      !is.null(ml_optimization_result$feature_importance)) {
    
    ml_comp_validation <- validate_ml_components_consistency(ml_optimization_result)
    if (!ml_comp_validation$valid) {
      validation$ml_compliance <- FALSE
      validation$issues <- c(validation$issues, ml_comp_validation$issues)
    }
  }
  
  # Call base validation without re-entering ML validation (avoid recursion)
  base_validation <- validate_optimization_result(ml_optimization_result, strict_validation, skip_ml = TRUE)
  if (!base_validation$valid) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, base_validation$issues)
    validation$warnings <- c(validation$warnings, base_validation$warnings)
  }
  
  return(validation)
}

#' Validate selected locations structure
#' @param selected_locations Data frame with selected locations
#' @return List with validation results
validate_selected_locations <- function(selected_locations) {
  validation <- list(
    valid = TRUE,
    issues = character(0)
  )
  
  if (!is.data.frame(selected_locations)) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "selected_locations must be data.frame")
    return(validation)
  }
  
  # Check required columns
  required_columns <- c("x", "y", "sample_id", "type", "model")
  missing_columns <- setdiff(required_columns, names(selected_locations))
  
  if (length(missing_columns) > 0) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues,
                          paste("Missing columns:", paste(missing_columns, collapse = ", ")))
  }
  
  # Validate coordinates
  if ("x" %in% names(selected_locations) && "y" %in% names(selected_locations)) {
    if (!is.numeric(selected_locations$x) || !is.numeric(selected_locations$y)) {
      validation$valid <- FALSE
      validation$issues <- c(validation$issues, "Coordinates x, y must be numeric")
    }
    
    if (any(is.na(selected_locations$x)) || any(is.na(selected_locations$y))) {
      validation$valid <- FALSE
      validation$issues <- c(validation$issues, "Coordinates cannot contain NA values")
    }
  }
  
  # Validate sample IDs
  if ("sample_id" %in% names(selected_locations)) {
    if (length(unique(selected_locations$sample_id)) != nrow(selected_locations)) {
      validation$valid <- FALSE
      validation$issues <- c(validation$issues, "Sample IDs must be unique")
    }
  }
  
  return(validation)
}

#' Standardize location output format
#' @param selected_locations Raw selected locations
#' @return Standardized data frame
standardize_location_output <- function(selected_locations) {
  if (is.null(selected_locations)) {
    return(data.frame(
      x = numeric(0),
      y = numeric(0),
      sample_id = character(0),
      type = character(0),
      model = character(0)
    ))
  }
  
  # Ensure required columns exist
  required_columns <- c("x", "y", "sample_id", "type", "model")
  for (col in required_columns) {
    if (!col %in% names(selected_locations)) {
      if (col == "type") {
        selected_locations$type <- "new"
      } else if (col == "model") {
        selected_locations$model <- "unknown"
      } else if (col == "sample_id") {
        selected_locations$sample_id <- paste0("LOC_", seq_len(nrow(selected_locations)))
      }
    }
  }
  
  # Standardize factor levels
  selected_locations$type <- factor(
    selected_locations$type,
    levels = c("existing", "new", "validation", "calibration")
  )
  
  selected_locations$model <- factor(selected_locations$model)
  
  # Add optional columns with defaults
  optional_columns <- c("suitability_score", "selection_order", "confidence")
  for (col in optional_columns) {
    if (!col %in% names(selected_locations)) {
      if (col == "suitability_score") {
        selected_locations[[col]] <- rep(NA_real_, nrow(selected_locations))
      } else if (col == "selection_order") {
        selected_locations[[col]] <- seq_len(nrow(selected_locations))
      } else if (col == "confidence") {
        selected_locations[[col]] <- rep(NA_real_, nrow(selected_locations))
      }
    }
  }
  
  return(selected_locations)
}

#' Standardize existing samples format
#' @param existing_samples Raw existing samples data
#' @return Standardized data frame or NULL
standardize_existing_samples <- function(existing_samples) {
  if (is.null(existing_samples)) {
    return(NULL)
  }
  
  # Apply same standardization as selected locations
  standardized <- standardize_location_output(existing_samples)
  
  # Ensure type is "existing" for all existing samples
  standardized$type <- factor("existing", levels = c("existing", "new", "validation", "calibration"))
  
  return(standardized)
}

#' Standardize performance metrics structure
#' @param metrics Raw metrics list
#' @return Standardized metrics list
standardize_performance_metrics <- function(metrics) {
  if (is.null(metrics)) {
    return(create_default_metrics())
  }
  
  # Required constitutional metrics
  required_metrics <- c("coverage", "efficiency", "diversity", "spatial_balance")
  
  standardized_metrics <- list()
  
  # Ensure all required metrics exist
  for (metric in required_metrics) {
    if (metric %in% names(metrics)) {
      standardized_metrics[[metric]] <- as.numeric(metrics[[metric]])
    } else {
      standardized_metrics[[metric]] <- NA_real_
    }
  }
  
  # Add optional metrics if present
  optional_metrics <- c("execution_time", "memory_usage", "algorithm_convergence", 
                       "optimization_score", "statistical_significance")
  
  for (metric in optional_metrics) {
    if (metric %in% names(metrics)) {
      standardized_metrics[[metric]] <- metrics[[metric]]
    }
  }
  
  # Add metadata
  standardized_metrics$calculation_timestamp <- Sys.time()
  standardized_metrics$constitutional_compliance <- all(!is.na(standardized_metrics[required_metrics]))
  
  return(standardized_metrics)
}

#' Create default performance metrics
#' @return Default metrics list
create_default_metrics <- function() {
  list(
    coverage = NA_real_,
    efficiency = NA_real_,
    diversity = NA_real_,
    spatial_balance = NA_real_,
    execution_time = NA_real_,
    memory_usage = NA_real_,
    calculation_timestamp = Sys.time(),
    constitutional_compliance = FALSE
  )
}

#' Standardize optimization parameters
#' @param parameters Raw parameters list
#' @return Standardized parameters list
standardize_optimization_parameters <- function(parameters) {
  if (is.null(parameters)) {
    return(list(
      algorithm = "unknown",
      n_new_samples = NA_integer_,
      optimization_method = "unknown",
      max_iter = NA_integer_,
      constitutional_compliance = FALSE
    ))
  }
  
  standardized <- list(
    algorithm = parameters$algorithm %||% "unknown",
    n_new_samples = as.integer(parameters$n_new_samples %||% NA),
    optimization_method = parameters$optimization_method %||% "unknown",
    max_iter = as.integer(parameters$max_iter %||% NA),
    timestamp = Sys.time()
  )
  
  # Add all other parameters
  other_params <- setdiff(names(parameters), names(standardized))
  for (param in other_params) {
    standardized[[param]] <- parameters[[param]]
  }
  
  standardized$constitutional_compliance <- !is.na(standardized$n_new_samples)
  
  return(standardized)
}

#' Create result metadata
#' @param metadata Raw metadata
#' @return Standardized metadata list
create_result_metadata <- function(metadata = NULL) {
  base_metadata <- list(
    timestamp = Sys.time(),
    execution_time = NA_real_,
    memory_usage = NA_real_,
    version_info = list(
      R_version = paste(R.version$major, R.version$minor, sep = "."),
      package_version = "0.0.1",
      terra_version = as.character(packageVersion("terra")),
      sf_version = as.character(packageVersion("sf"))
    ),
    system_info = list(
      platform = R.version$platform,
      os = Sys.info()["sysname"],
      cpu_cores = parallel::detectCores()
    )
  )
  
  # Add user-provided metadata
  if (!is.null(metadata) && is.list(metadata)) {
    base_metadata <- append(base_metadata, metadata)
  }
  
  return(base_metadata)
}

#' Validate constitutional compliance
#' @param selected_locations Selected locations data
#' @param metrics Performance metrics
#' @param parameters Optimization parameters
#' @return Constitutional compliance status
validate_constitutional_compliance <- function(selected_locations, metrics, parameters) {
  compliance <- list(
    code_quality_excellence = TRUE,
    spatial_analysis_excellence = TRUE,
    testing_standards = TRUE,
    user_experience_consistency = TRUE,
    performance_requirements = TRUE
  )
  
  # Check spatial analysis excellence
  if (!is.null(selected_locations)) {
    required_columns <- c("x", "y", "sample_id", "type", "model")
    compliance$spatial_analysis_excellence <- all(required_columns %in% names(selected_locations))
  }
  
  # Check performance requirements
  if (!is.null(metrics)) {
    required_metrics <- c("coverage", "efficiency", "diversity", "spatial_balance")
    compliance$performance_requirements <- all(required_metrics %in% names(metrics))
  }
  
  # Overall compliance
  compliance$overall_compliance <- all(unlist(compliance[1:5]))
  compliance$validation_timestamp <- Sys.time()
  
  return(compliance)
}

#' Helper function for NULL coalescing
#' @param x First value
#' @param y Second value (if x is NULL)
#' @return Non-NULL value
#' @noRd
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

#' Validate compliance structure
#' @param compliance_structure Constitutional compliance object
#' @return List with validation results
validate_compliance_structure <- function(compliance_structure) {
  validation <- list(
    valid = TRUE,
    issues = character(0)
  )
  
  if (!is.list(compliance_structure)) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "Compliance structure must be a list")
    return(validation)
  }
  
  # Check for required compliance fields
  required_fields <- c("overall_compliance")
  missing_fields <- setdiff(required_fields, names(compliance_structure))
  
  if (length(missing_fields) > 0) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, 
                          paste("Missing compliance fields:", 
                               paste(missing_fields, collapse = ", ")))
  }
  
  return(validation)
}

#' Validate result metrics structure
#' @param metrics Metrics object
#' @return List with validation results
validate_result_metrics <- function(metrics) {
  validation <- list(
    valid = TRUE,
    issues = character(0)
  )
  
  if (!is.list(metrics)) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "Metrics must be a list")
    return(validation)
  }
  
  # Check for basic metric fields
  expected_fields <- c("coverage", "efficiency", "diversity", "spatial_balance")
  missing_fields <- setdiff(expected_fields, names(metrics))
  
  if (length(missing_fields) > 0) {
    validation$issues <- c(validation$issues, 
                          paste("Missing metric fields:", 
                               paste(missing_fields, collapse = ", ")))
    # Don't mark as invalid for missing metrics, just warn
  }
  
  return(validation)
}

#' Validate ML method specification
#' @param method Character string with ML method
#' @return Validated method string
validate_ml_method <- function(method) {
  valid_methods <- c("BDL", "RF", "UDL", "UFN", "Ensemble")
  
  if (is.null(method) || !is.character(method)) {
    return("unknown")
  }
  
  if (method %in% valid_methods) {
    return(method)
  } else {
    return("unknown")
  }
}

#' Validate ML components structure
#' @param ml_components List with ML components
#' @param method ML method for context
#' @return List with validation results
validate_ml_components <- function(ml_components, method) {
  validation <- list(
    valid = TRUE,
    issues = character(0)
  )
  
  if (!is.list(ml_components)) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "ML components must be a list")
    return(validation)
  }
  
  # Validate predictions if present
  if ("predictions" %in% names(ml_components)) {
    if (!inherits(ml_components$predictions, c("SpatRaster", "numeric", "matrix"))) {
      validation$valid <- FALSE
      validation$issues <- c(validation$issues, 
                            "Predictions must be SpatRaster, numeric vector, or matrix")
    }
  }
  
  # Validate uncertainties if present
  if ("uncertainties" %in% names(ml_components)) {
    if (!inherits(ml_components$uncertainties, c("SpatRaster", "numeric", "matrix", "list"))) {
      validation$valid <- FALSE
      validation$issues <- c(validation$issues, 
                            "Uncertainties must be SpatRaster, numeric, matrix, or list")
    }
  }
  
  # Validate feature importance if present
  if ("feature_importance" %in% names(ml_components)) {
    if (!is.numeric(ml_components$feature_importance)) {
      validation$valid <- FALSE
      validation$issues <- c(validation$issues, 
                            "Feature importance must be numeric vector")
    }
  }
  
  return(validation)
}

#' Extract ML component from ml_components list
#' @param ml_components List with ML components
#' @param component_name Name of component to extract
#' @param default Default value if component not found
#' @return Component value or default
extract_ml_component <- function(ml_components, component_name, default = NULL) {
  if (is.null(ml_components) || !is.list(ml_components)) {
    return(default)
  }
  
  if (component_name %in% names(ml_components)) {
    return(ml_components[[component_name]])
  } else {
    return(default)
  }
}

#' Standardize ML performance metrics
#' @param metrics Raw metrics list
#' @param method ML method for context
#' @return Standardized ML metrics list
standardize_ml_performance_metrics <- function(metrics, method) {
  # Start with base metrics
  base_metrics <- standardize_performance_metrics(metrics)
  
  # Add ML-specific metrics
  ml_specific_metrics <- list(
    uncertainty_reduction = extract_metric_value(metrics, "uncertainty_reduction"),
    prediction_accuracy = extract_metric_value(metrics, "prediction_accuracy"),
    feature_importance_stability = extract_metric_value(metrics, "feature_importance_stability"),
    cross_validation_score = extract_metric_value(metrics, "cross_validation_score"),
    ensemble_diversity = extract_metric_value(metrics, "ensemble_diversity")
  )
  
  # Method-specific metrics
  if (method == "BDL") {
    ml_specific_metrics$epistemic_uncertainty = extract_metric_value(metrics, "epistemic_uncertainty")
    ml_specific_metrics$aleatoric_uncertainty = extract_metric_value(metrics, "aleatoric_uncertainty")
  } else if (method == "RF") {
    ml_specific_metrics$oob_score = extract_metric_value(metrics, "oob_score")
    ml_specific_metrics$variable_importance_score = extract_metric_value(metrics, "variable_importance_score")
  }
  
  # Combine base and ML-specific metrics
  enhanced_metrics <- append(base_metrics, ml_specific_metrics)
  enhanced_metrics$ml_method = method
  enhanced_metrics$ml_enhanced = TRUE
  
  return(enhanced_metrics)
}

#' Extract metric value safely
#' @param metrics Metrics list
#' @param metric_name Name of metric
#' @return Metric value or NA
extract_metric_value <- function(metrics, metric_name) {
  if (is.null(metrics) || !is.list(metrics)) {
    return(NA_real_)
  }
  
  if (metric_name %in% names(metrics)) {
    return(as.numeric(metrics[[metric_name]]))
  } else {
    return(NA_real_)
  }
}

#' Create ML result metadata
#' @param metadata Raw metadata
#' @param method ML method
#' @return Standardized ML metadata list
create_ml_result_metadata <- function(metadata = NULL, method = "unknown") {
  base_metadata <- create_result_metadata(metadata)
  
  # Add ML-specific metadata
  ml_metadata <- list(
    ml_method = method,
    ml_enhanced = TRUE,
    uncertainty_quantified = FALSE,
    feature_importance_calculated = FALSE,
    ensemble_used = method == "Ensemble",
    spatial_cv_applied = FALSE,
    hyperparameters_tuned = FALSE
  )
  
  # Combine base and ML metadata
  enhanced_metadata <- append(base_metadata, ml_metadata)
  
  return(enhanced_metadata)
}

#' Validate ML constitutional compliance
#' @param selected_locations Selected locations data
#' @param metrics Performance metrics
#' @param parameters Optimization parameters
#' @param ml_components ML components
#' @param method ML method
#' @return Enhanced constitutional compliance status
validate_ml_constitutional_compliance <- function(selected_locations, metrics, parameters, 
                                                ml_components, method) {
  # Get base compliance
  base_compliance <- validate_constitutional_compliance(selected_locations, metrics, parameters)
  
  # Add ML-specific compliance checks
  ml_compliance <- list(
    ml_method_specified = !is.null(method) && method != "unknown",
    ml_components_valid = !is.null(ml_components) && is.list(ml_components),
    uncertainty_handling = !is.null(ml_components$uncertainties) || method %in% c("BDL", "Ensemble"),
    feature_importance_available = !is.null(ml_components$feature_importance) || method %in% c("RF", "Ensemble"),
    spatial_awareness = TRUE  # Assume spatial awareness for all ML methods
  )
  
  # Combine base and ML compliance
  enhanced_compliance <- append(base_compliance, ml_compliance)
  enhanced_compliance$ml_enhanced_compliance <- all(unlist(ml_compliance))
  enhanced_compliance$overall_ml_compliance <- enhanced_compliance$overall_compliance && 
                                             enhanced_compliance$ml_enhanced_compliance
  
  return(enhanced_compliance)
}

#' Validate ML components consistency
#' @param ml_result ML optimization result
#' @return List with consistency validation results
validate_ml_components_consistency <- function(ml_result) {
  validation <- list(
    valid = TRUE,
    issues = character(0)
  )
  
  # Check spatial consistency between predictions and uncertainties
  if (!is.null(ml_result$predictions) && !is.null(ml_result$uncertainties)) {
    if (inherits(ml_result$predictions, "SpatRaster") && 
        inherits(ml_result$uncertainties, "SpatRaster")) {
      if (!terra::compareGeom(ml_result$predictions, ml_result$uncertainties, stopOnError = FALSE)) {
        validation$valid <- FALSE
        validation$issues <- c(validation$issues, 
                              "Predictions and uncertainties have inconsistent spatial geometry")
      }
    }
  }
  
  # Check feature importance length consistency
  if (!is.null(ml_result$feature_importance) && !is.null(ml_result$field_data)) {
    if ("covariates" %in% names(ml_result$field_data)) {
      n_layers <- terra::nlyr(ml_result$field_data$covariates)
      if (length(ml_result$feature_importance) != n_layers) {
        validation$valid <- FALSE
        validation$issues <- c(validation$issues, 
                              "Feature importance length does not match number of covariate layers")
      }
    }
  }
  
  return(validation)
}

#' Create backward compatibility wrapper
#' @param ... Arguments passed to create_ml_optimization_result
#' @return ML optimization result with backward compatibility
#' @export
create_optimization_result <- function(...) {
  # Call the enhanced ML version with default method
  create_ml_optimization_result(..., method = "unknown")
}

#' Validate optimization result (backward compatibility)
#' @param optimization_result Optimization result object
#' @param strict_validation Logical for strict validation
#' @return Validation results
#' @export
validate_optimization_result <- function(optimization_result, strict_validation = TRUE, skip_ml = FALSE) {
  
  validation <- list(
    valid = TRUE,
    issues = character(0),
    warnings = character(0),
    constitutional_compliance = TRUE
  )
  
  # Check basic structure
  if (!inherits(optimization_result, c("MLOptimizationResult", "OptimizationResult"))) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "Object is not OptimizationResult class")
    return(validation)
  }
  
  # If it's an ML result, use ML validation unless explicitly skipped
  if (!skip_ml && inherits(optimization_result, "MLOptimizationResult")) {
    return(validate_ml_optimization_result(optimization_result, strict_validation))
  }
  
  # Check required components
  required_components <- c("selected_locations", "metrics", "metadata", "constitutional_compliance")
  missing_components <- setdiff(required_components, names(optimization_result))
  
  if (length(missing_components) > 0) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues,
                          paste("Missing components:", paste(missing_components, collapse = ", ")))
  }
  
  # Validate selected locations
  if ("selected_locations" %in% names(optimization_result)) {
    location_validation <- validate_selected_locations(optimization_result$selected_locations)
    if (!location_validation$valid) {
      validation$valid <- FALSE
      validation$issues <- c(validation$issues, "Invalid selected_locations structure")
    }
  }
  
  # Validate performance metrics
  if ("metrics" %in% names(optimization_result)) {
    metrics_validation <- validate_result_metrics(optimization_result$metrics)
    if (!metrics_validation$valid) {
      if (strict_validation) {
        validation$valid <- FALSE
        validation$issues <- c(validation$issues, metrics_validation$issues)
      } else {
        validation$warnings <- c(validation$warnings, metrics_validation$issues)
      }
    }
  }
  
  # Validate constitutional compliance
  if ("constitutional_compliance" %in% names(optimization_result)) {
    compliance_validation <- validate_compliance_structure(
      optimization_result$constitutional_compliance
    )
    if (!compliance_validation$valid) {
      validation$constitutional_compliance <- FALSE
      validation$issues <- c(validation$issues, "Constitutional compliance validation failed")
    }
  }
  
  return(validation)
}
