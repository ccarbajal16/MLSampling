# Uncertainty Quantification Data Model
# Constitutional Compliance: Spatial Analysis Excellence and Code Quality Excellence
# Comprehensive uncertainty representation for ML-enhanced spatial sampling

#' Uncertainty Quantification Model
#'
#' @description
#' Provides standardized data structure and validation for uncertainty quantification
#' in ML-enhanced spatial sampling following constitutional principles. Supports
#' epistemic, aleatoric, and total uncertainty types with proper validation and
#' spatial consistency checks.
#'
#' @details
#' UncertaintyResults ensures consistent representation of uncertainty estimates
#' across all ML methods (BDL, RF, Ensemble) with constitutional compliance for
#' spatial analysis excellence and performance requirements.

#' Create standardized uncertainty quantification results
#'
#' @param epistemic Epistemic (model) uncertainty estimates
#' @param aleatoric Aleatoric (data) uncertainty estimates  
#' @param total Total uncertainty estimates (combined)
#' @param uncertainty_rasters List of SpatRaster objects with uncertainty maps
#' @param confidence_intervals List with confidence interval bounds
#' @param mc_samples Monte Carlo samples for uncertainty estimation
#' @param n_samples Number of Monte Carlo iterations used
#' @param validation_metrics Uncertainty validation and calibration metrics
#' @param method ML method used for uncertainty quantification
#' @param field_data Reference field data for spatial consistency
#'
#' @return Standardized UncertaintyResults object
#'
#' @examples
#' \dontrun{
#' # Create uncertainty results
#' uncertainty_results <- create_uncertainty_results(
#'   epistemic = epistemic_uncertainty_raster,
#'   aleatoric = aleatoric_uncertainty_raster,
#'   total = total_uncertainty_raster,
#'   confidence_intervals = list(
#'     lower_bound = lower_ci_raster,
#'     upper_bound = upper_ci_raster,
#'     confidence_level = 0.95
#'   ),
#'   mc_samples = mc_sample_array,
#'   n_samples = 100,
#'   method = "BDL"
#' )
#' }
#'
#' @export
create_uncertainty_results <- function(epistemic = NULL,
                                     aleatoric = NULL,
                                     total = NULL,
                                     uncertainty_rasters = NULL,
                                     confidence_intervals = NULL,
                                     mc_samples = NULL,
                                     n_samples = NULL,
                                     validation_metrics = NULL,
                                     method = "unknown",
                                     field_data = NULL) {
  
  # Validate at least one uncertainty type is provided
  if (is.null(epistemic) && is.null(aleatoric) && is.null(total)) {
    stop(ConfigurationError(
      message = "At least one uncertainty type must be provided",
      suggestion = "Provide epistemic, aleatoric, or total uncertainty estimates"
    ))
  }
  
  # Validate uncertainty components
  uncertainty_validation <- validate_uncertainty_components(
    epistemic, aleatoric, total, method
  )
  if (!uncertainty_validation$valid) {
    stop(SpatialDataError(
      message = "Invalid uncertainty components",
      validation_details = uncertainty_validation,
      suggestion = "Ensure uncertainty estimates are valid SpatRaster or numeric objects"
    ))
  }
  
  # Create standardized uncertainty structure
  uncertainty_results <- list(
    # Core uncertainty types
    epistemic = standardize_uncertainty_component(epistemic, "epistemic"),
    aleatoric = standardize_uncertainty_component(aleatoric, "aleatoric"), 
    total = standardize_uncertainty_component(total, "total"),
    
    # Spatial uncertainty maps
    uncertainty_rasters = standardize_uncertainty_rasters(uncertainty_rasters, 
                                                        epistemic, aleatoric, total),
    
    # Confidence intervals
    confidence_intervals = standardize_confidence_intervals(confidence_intervals),
    
    # Monte Carlo samples
    mc_samples = validate_mc_samples(mc_samples),
    n_samples = validate_n_samples(n_samples, mc_samples),
    
    # Validation and calibration metrics
    validation_metrics = standardize_uncertainty_validation_metrics(validation_metrics),
    
    # Method and metadata
    method = validate_uncertainty_method(method),
    creation_timestamp = Sys.time(),
    spatial_consistency = validate_spatial_consistency(epistemic, aleatoric, total, field_data)
  )
  
  # Calculate derived uncertainty measures if possible
  uncertainty_results <- calculate_derived_uncertainties(uncertainty_results)
  
  # Validate overall consistency
  consistency_validation <- validate_uncertainty_consistency(uncertainty_results)
  if (!consistency_validation$consistent) {
    warning(paste("Uncertainty consistency issues detected:", 
                 paste(consistency_validation$issues, collapse = ", ")))
  }
  
  # Set class for method dispatch
  class(uncertainty_results) <- c("UncertaintyResults", "list")
  
  # Add validation metadata
  attr(uncertainty_results, "validation_log") <- list(
    creation_time = Sys.time(),
    method = method,
    has_epistemic = !is.null(epistemic),
    has_aleatoric = !is.null(aleatoric),
    has_total = !is.null(total),
    has_confidence_intervals = !is.null(confidence_intervals),
    has_mc_samples = !is.null(mc_samples),
    n_mc_samples = n_samples %||% 0,
    spatial_consistency = consistency_validation$consistent,
    constitutional_compliance = TRUE
  )
  
  return(uncertainty_results)
}

#' Validate uncertainty quantification results
#'
#' @param uncertainty_results UncertaintyResults object
#' @param strict_validation Logical for strict constitutional compliance
#' @param field_data Optional field data for spatial validation
#'
#' @return List with validation results
#'
#' @export
validate_uncertainty_results <- function(uncertainty_results, 
                                       strict_validation = TRUE,
                                       field_data = NULL) {
  
  validation <- list(
    valid = TRUE,
    issues = character(0),
    warnings = character(0),
    constitutional_compliance = TRUE,
    spatial_consistency = TRUE
  )
  
  # Check basic structure
  if (!inherits(uncertainty_results, "UncertaintyResults")) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "Object is not UncertaintyResults class")
    return(validation)
  }
  
  # Check required components
  required_components <- c("method", "creation_timestamp", "spatial_consistency")
  missing_components <- setdiff(required_components, names(uncertainty_results))
  
  if (length(missing_components) > 0) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues,
                          paste("Missing components:", paste(missing_components, collapse = ", ")))
  }
  
  # Validate uncertainty types
  uncertainty_types <- c("epistemic", "aleatoric", "total")
  has_uncertainty <- any(sapply(uncertainty_types, function(type) {
    !is.null(uncertainty_results[[type]])
  }))
  
  if (!has_uncertainty) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "No uncertainty estimates found")
  }
  
  # Validate spatial consistency
  if ("spatial_consistency" %in% names(uncertainty_results)) {
    if (!uncertainty_results$spatial_consistency$consistent) {
      if (strict_validation) {
        validation$valid <- FALSE
        validation$issues <- c(validation$issues, "Spatial inconsistency detected")
      } else {
        validation$warnings <- c(validation$warnings, "Spatial inconsistency detected")
      }
      validation$spatial_consistency <- FALSE
    }
  }
  
  # Validate confidence intervals if present
  if (!is.null(uncertainty_results$confidence_intervals)) {
    ci_validation <- validate_confidence_intervals_structure(
      uncertainty_results$confidence_intervals
    )
    if (!ci_validation$valid) {
      validation$valid <- FALSE
      validation$issues <- c(validation$issues, ci_validation$issues)
    }
  }
  
  # Validate Monte Carlo samples consistency
  if (!is.null(uncertainty_results$mc_samples) && !is.null(uncertainty_results$n_samples)) {
    mc_validation <- validate_mc_samples_consistency(
      uncertainty_results$mc_samples, uncertainty_results$n_samples
    )
    if (!mc_validation$valid) {
      validation$warnings <- c(validation$warnings, mc_validation$issues)
    }
  }
  
  return(validation)
}

#' Validate uncertainty components
#' @param epistemic Epistemic uncertainty
#' @param aleatoric Aleatoric uncertainty  
#' @param total Total uncertainty
#' @param method ML method
#' @return List with validation results
validate_uncertainty_components <- function(epistemic, aleatoric, total, method) {
  validation <- list(
    valid = TRUE,
    issues = character(0)
  )
  
  # Validate individual components
  components <- list(epistemic = epistemic, aleatoric = aleatoric, total = total)
  
  for (comp_name in names(components)) {
    comp_value <- components[[comp_name]]
    if (!is.null(comp_value)) {
      comp_validation <- validate_single_uncertainty_component(comp_value, comp_name)
      if (!comp_validation$valid) {
        validation$valid <- FALSE
        validation$issues <- c(validation$issues, 
                              paste(comp_name, "uncertainty:", comp_validation$issues))
      }
    }
  }
  
  # Method-specific validation
  if (method == "BDL") {
    if (is.null(epistemic) && is.null(total)) {
      validation$issues <- c(validation$issues, 
                            "BDL method should provide epistemic or total uncertainty")
    }
  }
  
  return(validation)
}

#' Validate single uncertainty component
#' @param uncertainty_component Single uncertainty estimate
#' @param component_name Name for error messages
#' @return List with validation results
validate_single_uncertainty_component <- function(uncertainty_component, component_name) {
  validation <- list(
    valid = TRUE,
    issues = character(0)
  )
  
  # Check valid types
  valid_types <- c("SpatRaster", "numeric", "matrix", "array")
  if (!any(sapply(valid_types, function(type) inherits(uncertainty_component, type)))) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, 
                          paste("must be SpatRaster, numeric, matrix, or array"))
    return(validation)
  }
  
  # Check for negative values (uncertainty should be non-negative)
  if (inherits(uncertainty_component, "SpatRaster")) {
    values <- terra::values(uncertainty_component, na.rm = TRUE)
    if (any(values < 0, na.rm = TRUE)) {
      validation$valid <- FALSE
      validation$issues <- c(validation$issues, "contains negative uncertainty values")
    }
  } else if (is.numeric(uncertainty_component)) {
    if (any(uncertainty_component < 0, na.rm = TRUE)) {
      validation$valid <- FALSE
      validation$issues <- c(validation$issues, "contains negative uncertainty values")
    }
  }
  
  # Check for missing values
  if (inherits(uncertainty_component, "SpatRaster")) {
    if (all(is.na(terra::values(uncertainty_component)))) {
      validation$valid <- FALSE
      validation$issues <- c(validation$issues, "contains only NA values")
    }
  } else if (is.numeric(uncertainty_component)) {
    if (all(is.na(uncertainty_component))) {
      validation$valid <- FALSE
      validation$issues <- c(validation$issues, "contains only NA values")
    }
  }
  
  return(validation)
}

#' Standardize uncertainty component
#' @param uncertainty_component Raw uncertainty component
#' @param component_type Type of uncertainty component
#' @return Standardized uncertainty component
standardize_uncertainty_component <- function(uncertainty_component, component_type) {
  if (is.null(uncertainty_component)) {
    return(NULL)
  }
  
  if (inherits(uncertainty_component, "SpatRaster")) {
    if (is.null(names(uncertainty_component))) {
      names(uncertainty_component) <- paste0(component_type, "_uncertainty")
    }
    attr(uncertainty_component, "mlsampling_metadata") <- list(
      uncertainty_type = component_type,
      creation_timestamp = Sys.time(),
      constitutional_compliance = TRUE
    )
  }
  
  return(uncertainty_component)
}

#' Standardize uncertainty rasters
#' @param uncertainty_rasters Raw uncertainty rasters
#' @param epistemic Epistemic uncertainty for reference
#' @param aleatoric Aleatoric uncertainty for reference  
#' @param total Total uncertainty for reference
#' @return Standardized uncertainty rasters list
standardize_uncertainty_rasters <- function(uncertainty_rasters, epistemic, aleatoric, total) {
  if (is.null(uncertainty_rasters)) {
    # Create from individual components if available
    rasters <- list()
    
    if (!is.null(epistemic) && inherits(epistemic, "SpatRaster")) {
      rasters$epistemic <- epistemic
    }
    
    if (!is.null(aleatoric) && inherits(aleatoric, "SpatRaster")) {
      rasters$aleatoric <- aleatoric
    }
    
    if (!is.null(total) && inherits(total, "SpatRaster")) {
      rasters$total <- total
    }
    
    return(if (length(rasters) > 0) rasters else NULL)
  }
  
  # Validate existing rasters
  if (!is.list(uncertainty_rasters)) {
    return(NULL)
  }
  
  # Ensure all elements are SpatRaster objects
  valid_rasters <- list()
  for (name in names(uncertainty_rasters)) {
    if (inherits(uncertainty_rasters[[name]], "SpatRaster")) {
      valid_rasters[[name]] <- uncertainty_rasters[[name]]
    }
  }
  
  return(if (length(valid_rasters) > 0) valid_rasters else NULL)
}

#' Standardize confidence intervals
#' @param confidence_intervals Raw confidence intervals
#' @return Standardized confidence intervals list
standardize_confidence_intervals <- function(confidence_intervals) {
  if (is.null(confidence_intervals)) {
    return(list(
      lower_bound = NULL,
      upper_bound = NULL,
      confidence_level = 0.95,
      method = "unknown"
    ))
  }
  
  if (!is.list(confidence_intervals)) {
    return(NULL)
  }
  
  standardized <- list(
    lower_bound = confidence_intervals$lower_bound %||% NULL,
    upper_bound = confidence_intervals$upper_bound %||% NULL,
    confidence_level = confidence_intervals$confidence_level %||% 0.95,
    method = confidence_intervals$method %||% "unknown",
    creation_timestamp = Sys.time()
  )
  
  return(standardized)
}

#' Validate Monte Carlo samples
#' @param mc_samples Monte Carlo samples
#' @return Validated MC samples or NULL
validate_mc_samples <- function(mc_samples) {
  if (is.null(mc_samples)) {
    return(NULL)
  }
  
  # Check valid types
  if (!inherits(mc_samples, c("array", "matrix", "list"))) {
    warning("MC samples must be array, matrix, or list - setting to NULL")
    return(NULL)
  }
  
  return(mc_samples)
}

#' Validate number of samples
#' @param n_samples Number of samples
#' @param mc_samples MC samples for consistency check
#' @return Validated number of samples
validate_n_samples <- function(n_samples, mc_samples) {
  if (is.null(n_samples)) {
    if (!is.null(mc_samples)) {
      # Try to infer from mc_samples
      if (is.array(mc_samples)) {
        return(dim(mc_samples)[length(dim(mc_samples))])
      } else if (is.matrix(mc_samples)) {
        return(ncol(mc_samples))
      } else if (is.list(mc_samples)) {
        return(length(mc_samples))
      }
    }
    return(0)
  }
  
  return(as.integer(n_samples))
}

#' Standardize uncertainty validation metrics
#' @param validation_metrics Raw validation metrics
#' @return Standardized validation metrics list
standardize_uncertainty_validation_metrics <- function(validation_metrics) {
  if (is.null(validation_metrics)) {
    return(list(
      uncertainty_calibration = NA_real_,
      coverage_probability = NA_real_,
      sharpness = NA_real_,
      reliability = NA_real_,
      resolution = NA_real_,
      validation_timestamp = Sys.time()
    ))
  }
  
  if (!is.list(validation_metrics)) {
    return(NULL)
  }
  
  standardized <- list(
    uncertainty_calibration = validation_metrics$uncertainty_calibration %||% NA_real_,
    coverage_probability = validation_metrics$coverage_probability %||% NA_real_,
    sharpness = validation_metrics$sharpness %||% NA_real_,
    reliability = validation_metrics$reliability %||% NA_real_,
    resolution = validation_metrics$resolution %||% NA_real_,
    validation_timestamp = Sys.time()
  )
  
  return(standardized)
}

#' Validate uncertainty method
#' @param method ML method string
#' @return Validated method string
validate_uncertainty_method <- function(method) {
  valid_methods <- c("BDL", "RF", "Ensemble", "Bootstrap", "Quantile")
  
  if (is.null(method) || !is.character(method)) {
    return("unknown")
  }
  
  if (method %in% valid_methods) {
    return(method)
  } else {
    return("unknown")
  }
}

#' Validate spatial consistency across uncertainty components
#' @param epistemic Epistemic uncertainty
#' @param aleatoric Aleatoric uncertainty
#' @param total Total uncertainty  
#' @param field_data Reference field data
#' @return List with spatial consistency results
validate_spatial_consistency <- function(epistemic, aleatoric, total, field_data) {
  consistency <- list(
    consistent = TRUE,
    issues = character(0),
    reference_geometry = NULL
  )
  
  # Collect SpatRaster components
  raster_components <- list()
  if (inherits(epistemic, "SpatRaster")) raster_components$epistemic <- epistemic
  if (inherits(aleatoric, "SpatRaster")) raster_components$aleatoric <- aleatoric
  if (inherits(total, "SpatRaster")) raster_components$total <- total
  
  if (length(raster_components) == 0) {
    return(consistency)  # No spatial components to check
  }
  
  # Set reference geometry from first component
  reference <- raster_components[[1]]
  consistency$reference_geometry <- list(
    extent = as.vector(terra::ext(reference)),
    resolution = terra::res(reference),
    crs = terra::crs(reference)
  )
  
  # Check consistency across components
  for (i in seq_along(raster_components)) {
    comp_name <- names(raster_components)[i]
    comp_raster <- raster_components[[i]]
    
    if (!terra::compareGeom(reference, comp_raster, stopOnError = FALSE)) {
      consistency$consistent <- FALSE
      consistency$issues <- c(consistency$issues, 
                             paste("Geometry mismatch in", comp_name, "uncertainty"))
    }
  }
  
  # Check consistency with field data if provided
  if (!is.null(field_data) && "covariates" %in% names(field_data)) {
    if (inherits(field_data$covariates, "SpatRaster")) {
      if (!terra::compareGeom(reference, field_data$covariates, stopOnError = FALSE)) {
        consistency$consistent <- FALSE
        consistency$issues <- c(consistency$issues, 
                               "Uncertainty geometry does not match field data covariates")
      }
    }
  }
  
  return(consistency)
}

#' Calculate derived uncertainty measures
#' @param uncertainty_results Uncertainty results object
#' @return Enhanced uncertainty results with derived measures
calculate_derived_uncertainties <- function(uncertainty_results) {
  # Calculate total uncertainty if epistemic and aleatoric are available
  if (!is.null(uncertainty_results$epistemic) && 
      !is.null(uncertainty_results$aleatoric) && 
      is.null(uncertainty_results$total)) {
    
    if (inherits(uncertainty_results$epistemic, "SpatRaster") && 
        inherits(uncertainty_results$aleatoric, "SpatRaster")) {
      
      # Total uncertainty = sqrt(epistemic^2 + aleatoric^2)
      uncertainty_results$total <- sqrt(
        uncertainty_results$epistemic^2 + uncertainty_results$aleatoric^2
      )
      names(uncertainty_results$total) <- "total_uncertainty"
    }
  }
  
  # Calculate uncertainty ratios if multiple types available
  if (!is.null(uncertainty_results$epistemic) && !is.null(uncertainty_results$total)) {
    if (inherits(uncertainty_results$epistemic, "SpatRaster") && 
        inherits(uncertainty_results$total, "SpatRaster")) {
      
      uncertainty_results$epistemic_ratio <- uncertainty_results$epistemic / uncertainty_results$total
      names(uncertainty_results$epistemic_ratio) <- "epistemic_ratio"
    }
  }
  
  return(uncertainty_results)
}

#' Validate uncertainty consistency
#' @param uncertainty_results Uncertainty results object
#' @return List with consistency validation results
validate_uncertainty_consistency <- function(uncertainty_results) {
  consistency <- list(
    consistent = TRUE,
    issues = character(0)
  )
  
  # Check mathematical relationships
  if (!is.null(uncertainty_results$epistemic) && 
      !is.null(uncertainty_results$aleatoric) && 
      !is.null(uncertainty_results$total)) {
    
    if (inherits(uncertainty_results$epistemic, "SpatRaster") && 
        inherits(uncertainty_results$aleatoric, "SpatRaster") && 
        inherits(uncertainty_results$total, "SpatRaster")) {
      
      # Check if total >= epistemic and total >= aleatoric (approximately)
      epistemic_values <- terra::values(uncertainty_results$epistemic, na.rm = TRUE)
      aleatoric_values <- terra::values(uncertainty_results$aleatoric, na.rm = TRUE)
      total_values <- terra::values(uncertainty_results$total, na.rm = TRUE)
      
      if (any(total_values < epistemic_values - 1e-6, na.rm = TRUE)) {
        consistency$consistent <- FALSE
        consistency$issues <- c(consistency$issues, 
                               "Total uncertainty less than epistemic uncertainty")
      }
      
      if (any(total_values < aleatoric_values - 1e-6, na.rm = TRUE)) {
        consistency$consistent <- FALSE
        consistency$issues <- c(consistency$issues, 
                               "Total uncertainty less than aleatoric uncertainty")
      }
    }
  }
  
  # Check confidence interval consistency
  if (!is.null(uncertainty_results$confidence_intervals)) {
    ci <- uncertainty_results$confidence_intervals
    if (!is.null(ci$lower_bound) && !is.null(ci$upper_bound)) {
      
      if (inherits(ci$lower_bound, "SpatRaster") && inherits(ci$upper_bound, "SpatRaster")) {
        lower_values <- terra::values(ci$lower_bound, na.rm = TRUE)
        upper_values <- terra::values(ci$upper_bound, na.rm = TRUE)
        
        if (any(lower_values > upper_values, na.rm = TRUE)) {
          consistency$consistent <- FALSE
          consistency$issues <- c(consistency$issues, 
                                 "Lower confidence bound greater than upper bound")
        }
      }
    }
  }
  
  return(consistency)
}

#' Validate confidence intervals structure
#' @param confidence_intervals Confidence intervals object
#' @return List with validation results
validate_confidence_intervals_structure <- function(confidence_intervals) {
  validation <- list(
    valid = TRUE,
    issues = character(0)
  )
  
  if (!is.list(confidence_intervals)) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "Confidence intervals must be a list")
    return(validation)
  }
  
  # Check confidence level
  if ("confidence_level" %in% names(confidence_intervals)) {
    cl <- confidence_intervals$confidence_level
    if (!is.numeric(cl) || cl <= 0 || cl >= 1) {
      validation$valid <- FALSE
      validation$issues <- c(validation$issues, 
                            "Confidence level must be numeric between 0 and 1")
    }
  }
  
  return(validation)
}

#' Validate Monte Carlo samples consistency
#' @param mc_samples Monte Carlo samples
#' @param n_samples Number of samples
#' @return List with validation results
validate_mc_samples_consistency <- function(mc_samples, n_samples) {
  validation <- list(
    valid = TRUE,
    issues = character(0)
  )
  
  if (is.array(mc_samples)) {
    actual_samples <- dim(mc_samples)[length(dim(mc_samples))]
    if (actual_samples != n_samples) {
      validation$valid <- FALSE
      validation$issues <- c(validation$issues, 
                            paste("MC samples array dimension (", actual_samples, 
                                  ") does not match n_samples (", n_samples, ")"))
    }
  } else if (is.matrix(mc_samples)) {
    actual_samples <- ncol(mc_samples)
    if (actual_samples != n_samples) {
      validation$valid <- FALSE
      validation$issues <- c(validation$issues, 
                            paste("MC samples matrix columns (", actual_samples, 
                                  ") does not match n_samples (", n_samples, ")"))
    }
  } else if (is.list(mc_samples)) {
    actual_samples <- length(mc_samples)
    if (actual_samples != n_samples) {
      validation$valid <- FALSE
      validation$issues <- c(validation$issues, 
                            paste("MC samples list length (", actual_samples, 
                                  ") does not match n_samples (", n_samples, ")"))
    }
  }
  
  return(validation)
}

#' Helper function for NULL coalescing
#' @param x First value
#' @param y Second value (if x is NULL)
#' @return Non-NULL value
#' @noRd
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
