# Error Handling System for MLSampling
# Defines standardized error classes and handling mechanisms

#' Standardized Error Classes
#'
#' @description
#' Defines a hierarchy of error classes for MLSampling to ensure consistent
#' error reporting and handling across all modules.
#'
#' @examples
#' \dontrun{
#' stop(MLSamplingError("General error"))
#' stop(BDLError("Model failed to converge"))
#' }
#' @name MLSamplingErrors
NULL

#' Create a custom error condition
#' 
#' @param message Error message
#' @param class Error class name
#' @param call Call expression
#' @return error condition object
create_error <- function(message, class, call = sys.call(-1), ...) {
  structure(
    class = c(class, "error", "condition"),
    c(list(message = message, call = call), list(...))
  )
}

#' Raise a specific error
#'
#' @param message Error message
#' @param type Error type (e.g., "MLSamplingError", "BDLError")
#' @export
raise_error <- function(message, type = "MLSamplingError", ...) {
  stop(create_error(message, type, ...))
}

#' Base MLSampling Error
#' @export
MLSamplingError <- function(message, ...) create_error(message, "MLSamplingError", ...)

#' Bayesian Deep Learning Error
#' @export
BDLError <- function(message, ...) create_error(message, c("BDLError", "MLSamplingError"), ...)

#' Random Forest Optimization Error
#' @export
RFError <- function(message, ...) create_error(message, c("RFError", "MLSamplingError"), ...)

#' Spatial Analysis Error
#' @export
SpatialError <- function(message, ...) create_error(message, c("SpatialError", "MLSamplingError"), ...)

SpatialDataError <- function(message, ...) create_error(message, c("SpatialDataError", "SpatialError", "MLSamplingError"), ...)

#' Resource/Memory Error
#' @export
ResourceError <- function(message, ...) create_error(message, c("ResourceError", "MLSamplingError"), ...)

#' Configuration Error
#' @export
ConfigError <- function(message, ...) create_error(message, c("ConfigError", "MLSamplingError"), ...)

ConfigurationError <- function(message, ...) create_error(message, c("ConfigurationError", "ConfigError", "MLSamplingError"), ...)

#' Data Validation Error
#' @export
ValidationError <- function(message, ...) create_error(message, c("ValidationError", "MLSamplingError"), ...)

SoilSamplingError <- function(message, ...) {
  .Deprecated("MLSamplingError", package = "MLSampling", msg = "SoilSamplingError() is deprecated. Use MLSamplingError() instead.")
  MLSamplingError(message, ...)
}

OptimizationError <- function(message, ...) create_error(message, c("OptimizationError", "MLSamplingError"), ...)

PerformanceError <- function(message, ...) create_error(message, c("PerformanceError", "ResourceError", "MLSamplingError"), ...)

with_enhanced_error_handling <- function(expr, context = "Operation", config_manager = NULL, error_type = "MLSamplingError") {
  expr_sub <- substitute(expr)
  tryCatch(
    eval(expr_sub, envir = parent.frame()),
    error = function(e) {
      if (!is.null(config_manager) && "log" %in% names(config_manager)) {
        try(config_manager$log("ERROR", "%s failed: %s", context, conditionMessage(e)), silent = TRUE)
      }
      if (inherits(e, c("MLSamplingError", "BDLError", "RFError", "SpatialError", "SpatialDataError", "ResourceError", "ConfigError", "ConfigurationError", "ValidationError"))) {
        stop(e)
      }
      stop(create_error(paste0(context, ": ", conditionMessage(e)), error_type))
    }
  )
}

#' Safe execution wrapper
#'
#' @description
#' Executes an expression and wraps any errors in MLSampling-specific error types.
#'
#' @param expr Expression to evaluate
#' @param error_type Type of error to wrap (default "MLSamplingError")
#' @param fallback Optional fallback value to return on error
#' 
#' @return Result of expr or fallback
#' @export
with_error_handling <- function(expr, error_type = "MLSamplingError", fallback = NULL) {
  tryCatch(
    expr,
    error = function(e) {
      # If it's already a custom error, re-throw it
      if (inherits(e, "MLSamplingError") || inherits(e, "BDLError") || 
          inherits(e, "RFError") || inherits(e, "SpatialError") || 
          inherits(e, "ResourceError") || inherits(e, "ConfigError")) {
        stop(e)
      }
      
      # Log the original error if logging is available (simplified here)
      # message(sprintf("Original error: %s", e$message))
      
      if (!is.null(fallback)) {
        return(fallback)
      }
      
      # Wrap and throw
      stop(create_error(paste0(error_type, ": ", e$message), error_type))
    }
  )
}

analyze_error_recovery <- function(error) {
  classes <- class(error)
  if (inherits(error, "ResourceError") || inherits(error, "PerformanceError")) {
    return(list(recoverable = TRUE, recommended_action = "Reduce dataset size, enable batching, or increase memory_limit.", error_class = classes))
  }
  if (inherits(error, "SpatialDataError") || inherits(error, "SpatialError")) {
    return(list(recoverable = TRUE, recommended_action = "Validate CRS and spatial alignment for boundary/covariates/samples.", error_class = classes))
  }
  if (inherits(error, "ValidationError")) {
    return(list(recoverable = TRUE, recommended_action = "Fix input data quality issues and rerun validation.", error_class = classes))
  }
  if (inherits(error, "ConfigError") || inherits(error, "ConfigurationError")) {
    return(list(recoverable = TRUE, recommended_action = "Review configuration keys/values and retry.", error_class = classes))
  }
  list(recoverable = FALSE, recommended_action = "Inspect error details and stack trace.", error_class = classes)
}
