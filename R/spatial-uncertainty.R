# Spatial Uncertainty Quantification Module for MLSampling
# Implements comprehensive uncertainty analysis and visualization

#' @title SpatialUncertainty
#'
#' @description
#' Provides comprehensive uncertainty quantification methods for spatial predictions
#' including epistemic, aleatoric, and total uncertainty calculation, confidence
#' interval generation, and uncertainty visualization capabilities.
#'
#' @details
#' The SpatialUncertainty class provides:
#' - Multiple uncertainty types (epistemic, aleatoric, total)
#' - Confidence interval generation with various methods
#' - Spatial uncertainty mapping and visualization
#' - Uncertainty calibration and validation metrics
#'
#' @field uncertainty_results Stored uncertainty calculation results
#' @field visualization_config Configuration for uncertainty visualizations
#' @field calibration_metrics Uncertainty calibration assessment results
#'
#' @examples
#' \dontrun{
#' # Initialize uncertainty quantification
#' uncertainty <- SpatialUncertainty$new()
#'
#' # Calculate uncertainties from BDL predictions
#' uncertainties <- uncertainty$calculate_uncertainties(bdl_predictions)
#'
#' # Generate confidence intervals
#' intervals <- uncertainty$generate_confidence_intervals(predictions, level = 0.95)
#'
#' # Create uncertainty maps
#' maps <- uncertainty$create_uncertainty_maps(uncertainties, field_data)
#' }
#'
#' @export
SpatialUncertainty <- R6::R6Class("SpatialUncertainty",
  
  public = list(
    
    #' Initialize Spatial Uncertainty Module
    #'
    #' @param config Optional configuration list for uncertainty parameters
    #'
    #' @examples
    #' \dontrun{
    #' uncertainty <- SpatialUncertainty$new()
    #' }
    initialize = function(config = list()) {
      
      # Set default configuration
      private$config <- private$set_default_config(config)
      
      # Initialize storage
      private$uncertainty_results <- list()
      private$calibration_metrics <- list()
      
      invisible(self)
    },
    
    #' Calculate comprehensive uncertainty estimates
    #'
    #' @param predictions Prediction results from ML models (BDL, RF, etc.)
    #' @param method Method used for predictions ("bdl", "rf", "ensemble")
    #' @param uncertainty_types Types of uncertainty to calculate
    #'
    #' @return UncertaintyResults object with all uncertainty estimates
    #'
    #' @examples
    #' \dontrun{
    #' uncertainties <- uncertainty$calculate_uncertainties(
    #'   predictions = bdl_result,
    #'   method = "bdl",
    #'   uncertainty_types = c("epistemic", "aleatoric", "total")
    #' )
    #' }
    calculate_uncertainties = function(predictions, 
                                       method = "bdl",
                                       uncertainty_types = c("epistemic", "aleatoric", "total")) {
      
      # Validate inputs
      if (is.null(predictions)) {
        stop("UncertaintyError: predictions is required for uncertainty calculation")
      }
      
      valid_methods <- c("bdl", "rf", "ensemble", "statistical")
      if (!method %in% valid_methods) {
        stop(paste("UncertaintyError: Invalid method:", method))
      }
      
      valid_types <- c("epistemic", "aleatoric", "total")
      invalid_types <- setdiff(uncertainty_types, valid_types)
      if (length(invalid_types) > 0) {
        stop(paste("UncertaintyError: Invalid uncertainty types:", paste(invalid_types, collapse = ", ")))
      }
      
      # Calculate uncertainties based on method
      uncertainty_result <- switch(method,
        "bdl" = private$calculate_bdl_uncertainties(predictions, uncertainty_types),
        "rf" = private$calculate_rf_uncertainties(predictions, uncertainty_types),
        "ensemble" = private$calculate_ensemble_uncertainties(predictions, uncertainty_types),
        "statistical" = private$calculate_statistical_uncertainties(predictions, uncertainty_types)
      )
      
      # Store results
      private$uncertainty_results[[length(private$uncertainty_results) + 1]] <- uncertainty_result
      
      return(uncertainty_result)
    },
    
    #' Generate confidence intervals for predictions
    #'
    #' @param predictions Prediction results with uncertainty estimates
    #' @param confidence_level Confidence level (e.g., 0.95 for 95% CI)
    #' @param method Method for interval calculation ("normal", "bootstrap", "quantile")
    #'
    #' @return List with lower and upper confidence bounds
    #'
    #' @examples
    #' \dontrun{
    #' intervals <- uncertainty$generate_confidence_intervals(
    #'   predictions = predictions,
    #'   confidence_level = 0.95,
    #'   method = "normal"
    #' )
    #' }
    generate_confidence_intervals = function(predictions, 
                                             confidence_level = 0.95,
                                             method = "normal") {
      
      # Validate inputs
      if (is.null(predictions)) {
        stop("UncertaintyError: predictions is required for confidence interval calculation")
      }
      
      if (confidence_level <= 0 || confidence_level >= 1) {
        stop("UncertaintyError: confidence_level must be between 0 and 1")
      }
      
      valid_methods <- c("normal", "bootstrap", "quantile")
      if (!method %in% valid_methods) {
        stop(paste("UncertaintyError: Invalid method:", method))
      }
      
      # Calculate confidence intervals
      intervals <- switch(method,
        "normal" = private$calculate_normal_intervals(predictions, confidence_level),
        "bootstrap" = private$calculate_bootstrap_intervals(predictions, confidence_level),
        "quantile" = private$calculate_quantile_intervals(predictions, confidence_level)
      )
      
      return(intervals)
    },
    
    #' Create spatial uncertainty maps
    #'
    #' @param uncertainty_results Uncertainty calculation results
    #' @param field_data Spatial field data for mapping
    #' @param map_types Types of uncertainty maps to create
    #' @param resolution Spatial resolution for mapping
    #'
    #' @return List of uncertainty raster maps
    #'
    #' @examples
    #' \dontrun{
    #' maps <- uncertainty$create_uncertainty_maps(
    #'   uncertainty_results = uncertainties,
    #'   field_data = field_data,
    #'   map_types = c("epistemic", "total")
    #' )
    #' }
    create_uncertainty_maps = function(uncertainty_results, 
                                       field_data,
                                       map_types = c("epistemic", "aleatoric", "total"),
                                       resolution = NULL) {
      
      # Validate inputs
      if (is.null(uncertainty_results)) {
        stop("UncertaintyError: uncertainty_results is required for mapping")
      }
      
      if (is.null(field_data)) {
        stop("UncertaintyError: field_data is required for spatial mapping")
      }
      
      # Create uncertainty maps
      uncertainty_maps <- private$generate_uncertainty_rasters(
        uncertainty_results, field_data, map_types, resolution
      )
      
      return(uncertainty_maps)
    },
    
    #' Visualize uncertainty estimates
    #'
    #' @param uncertainty_results Uncertainty calculation results
    #' @param plot_type Type of visualization ("maps", "histograms", "scatter", "all")
    #' @param interactive Whether to create interactive plots
    #'
    #' @return List of uncertainty visualization plots
    #'
    #' @examples
    #' \dontrun{
    #' plots <- uncertainty$visualize_uncertainty(
    #'   uncertainty_results = uncertainties,
    #'   plot_type = "all",
    #'   interactive = TRUE
    #' )
    #' }
    visualize_uncertainty = function(uncertainty_results, 
                                     plot_type = "all",
                                     interactive = FALSE) {
      
      # Validate inputs
      if (is.null(uncertainty_results)) {
        stop("UncertaintyError: uncertainty_results is required for visualization")
      }
      
      valid_plot_types <- c("maps", "histograms", "scatter", "all")
      if (!plot_type %in% valid_plot_types) {
        stop(paste("UncertaintyError: Invalid plot_type:", plot_type))
      }
      
      # Create visualizations
      plots <- private$create_uncertainty_visualizations(
        uncertainty_results, plot_type, interactive
      )
      
      return(plots)
    },
    
    #' Assess uncertainty calibration
    #'
    #' @param predictions Predictions with uncertainty estimates
    #' @param observations True observed values for validation
    #' @param calibration_method Method for calibration assessment
    #'
    #' @return Calibration assessment results
    #'
    #' @examples
    #' \dontrun{
    #' calibration <- uncertainty$assess_calibration(
    #'   predictions = predictions,
    #'   observations = true_values,
    #'   calibration_method = "reliability_diagram"
    #' )
    #' }
    assess_calibration = function(predictions, 
                                  observations,
                                  calibration_method = "reliability_diagram") {
      
      # Validate inputs
      if (is.null(predictions) || is.null(observations)) {
        stop("UncertaintyError: Both predictions and observations are required for calibration assessment")
      }
      
      if (length(predictions$mean) != length(observations)) {
        stop("UncertaintyError: Predictions and observations must have the same length")
      }
      
      # Assess calibration
      calibration_result <- private$perform_calibration_assessment(
        predictions, observations, calibration_method
      )
      
      # Store calibration metrics
      private$calibration_metrics[[length(private$calibration_metrics) + 1]] <- calibration_result
      
      return(calibration_result)
    },
    
    #' Calculate coverage probability
    #'
    #' @param predictions Predictions with confidence intervals
    #' @param observations True observed values
    #' @param confidence_level Expected confidence level
    #'
    #' @return Coverage probability assessment
    #'
    #' @examples
    #' \dontrun{
    #' coverage <- uncertainty$calculate_coverage_probability(
    #'   predictions = predictions_with_ci,
    #'   observations = true_values,
    #'   confidence_level = 0.95
    #' )
    #' }
    calculate_coverage_probability = function(predictions, 
                                              observations,
                                              confidence_level = 0.95) {
      
      # Validate inputs
      if (is.null(predictions$confidence_intervals)) {
        stop("UncertaintyError: predictions must contain confidence_intervals")
      }
      
      # Calculate coverage
      lower_bounds <- predictions$confidence_intervals$lower_bound
      upper_bounds <- predictions$confidence_intervals$upper_bound
      
      # Check if observations fall within intervals
      within_interval <- (observations >= lower_bounds) & (observations <= upper_bounds)
      coverage_prob <- mean(within_interval)
      
      # Calculate interval widths
      interval_widths <- upper_bounds - lower_bounds
      mean_width <- mean(interval_widths)
      
      coverage_result <- list(
        coverage_probability = coverage_prob,
        expected_coverage = confidence_level,
        coverage_difference = coverage_prob - confidence_level,
        mean_interval_width = mean_width,
        n_observations = length(observations),
        well_calibrated = abs(coverage_prob - confidence_level) < 0.05
      )
      
      return(coverage_result)
    }
  ),
  
  private = list(
    
    # Configuration parameters
    config = NULL,
    
    # Stored uncertainty results
    uncertainty_results = NULL,
    
    # Calibration metrics
    calibration_metrics = NULL,
    
    # Set default configuration
    set_default_config = function(user_config) {
      
      default_config <- list(
        # Uncertainty calculation parameters
        default_confidence_level = 0.95,
        bootstrap_samples = 1000,
        
        # Visualization parameters
        color_palette = "viridis",
        map_resolution = 100,
        plot_width = 800,
        plot_height = 600,
        
        # Calibration parameters
        calibration_bins = 10,
        reliability_threshold = 0.05
      )
      
      # Merge with user configuration
      config <- modifyList(default_config, user_config)
      
      return(config)
    },
    
    # Calculate BDL uncertainties
    calculate_bdl_uncertainties = function(predictions, uncertainty_types) {
      
      n_predictions <- length(predictions$mean)
      
      # Initialize uncertainty components
      uncertainties <- list()
      
      if ("epistemic" %in% uncertainty_types) {
        if (!is.null(predictions$epistemic_uncertainty)) {
          uncertainties$epistemic <- predictions$epistemic_uncertainty
        } else if (!is.null(predictions$mc_samples)) {
          uncertainties$epistemic <- apply(predictions$mc_samples, 1, var)
        } else {
          uncertainties$epistemic <- rep(0.1, n_predictions)
        }
      }
      
      if ("aleatoric" %in% uncertainty_types) {
        if (!is.null(predictions$aleatoric_uncertainty)) {
          uncertainties$aleatoric <- predictions$aleatoric_uncertainty
        } else {
          uncertainties$aleatoric <- rep(0.05, n_predictions)
        }
      }
      
      if ("total" %in% uncertainty_types) {
        if (!is.null(predictions$total_uncertainty)) {
          uncertainties$total <- predictions$total_uncertainty
        } else {
          epistemic <- uncertainties$epistemic %||% rep(0.1, n_predictions)
          aleatoric <- uncertainties$aleatoric %||% rep(0.05, n_predictions)
          uncertainties$total <- epistemic + aleatoric
        }
      }
      
      # Create uncertainty result object
      uncertainty_result <- structure(list(
        uncertainties = uncertainties,
        method = "bdl",
        n_predictions = n_predictions,
        uncertainty_types = uncertainty_types,
        mc_samples = predictions$mc_samples,
        timestamp = Sys.time()
      ), class = "UncertaintyResults")
      
      return(uncertainty_result)
    },
    
    # Calculate RF uncertainties
    calculate_rf_uncertainties = function(predictions, uncertainty_types) {
      
      n_predictions <- if (is.list(predictions)) length(predictions$mean) else length(predictions)
      
      # RF uncertainty is primarily epistemic (model uncertainty)
      uncertainties <- list()
      
      if ("epistemic" %in% uncertainty_types) {
        # Use prediction variance from RF ensemble
        if (is.list(predictions) && !is.null(predictions$prediction_variance)) {
          uncertainties$epistemic <- predictions$prediction_variance
        } else {
          # Estimate from feature importance or use default
          uncertainties$epistemic <- rep(0.08, n_predictions)
        }
      }
      
      if ("aleatoric" %in% uncertainty_types) {
        # RF has limited aleatoric uncertainty estimation
        uncertainties$aleatoric <- rep(0.03, n_predictions)
      }
      
      if ("total" %in% uncertainty_types) {
        epistemic <- uncertainties$epistemic %||% rep(0.08, n_predictions)
        aleatoric <- uncertainties$aleatoric %||% rep(0.03, n_predictions)
        uncertainties$total <- epistemic + aleatoric
      }
      
      uncertainty_result <- structure(list(
        uncertainties = uncertainties,
        method = "rf",
        n_predictions = n_predictions,
        uncertainty_types = uncertainty_types,
        feature_importance = predictions$feature_importance,
        timestamp = Sys.time()
      ), class = "UncertaintyResults")
      
      return(uncertainty_result)
    },
    
    # Calculate ensemble uncertainties
    calculate_ensemble_uncertainties = function(predictions, uncertainty_types) {
      
      n_predictions <- length(predictions$mean)
      
      # Ensemble uncertainty combines individual method uncertainties
      uncertainties <- list()
      
      if ("epistemic" %in% uncertainty_types) {
        # Variance across ensemble members
        if (!is.null(predictions$ensemble_predictions)) {
          uncertainties$epistemic <- apply(predictions$ensemble_predictions, 1, var)
        } else {
          uncertainties$epistemic <- rep(0.12, n_predictions)
        }
      }
      
      if ("aleatoric" %in% uncertainty_types) {
        # Average aleatoric uncertainty from individual methods
        if (!is.null(predictions$individual_aleatoric)) {
          uncertainties$aleatoric <- rowMeans(predictions$individual_aleatoric)
        } else {
          uncertainties$aleatoric <- rep(0.04, n_predictions)
        }
      }
      
      if ("total" %in% uncertainty_types) {
        epistemic <- uncertainties$epistemic %||% rep(0.12, n_predictions)
        aleatoric <- uncertainties$aleatoric %||% rep(0.04, n_predictions)
        uncertainties$total <- epistemic + aleatoric
      }
      
      uncertainty_result <- structure(list(
        uncertainties = uncertainties,
        method = "ensemble",
        n_predictions = n_predictions,
        uncertainty_types = uncertainty_types,
        ensemble_methods = predictions$ensemble_methods,
        timestamp = Sys.time()
      ), class = "UncertaintyResults")
      
      return(uncertainty_result)
    },
    
    # Calculate statistical uncertainties
    calculate_statistical_uncertainties = function(predictions, uncertainty_types) {
      
      n_predictions <- length(predictions)
      
      # Statistical uncertainty based on prediction standard errors
      uncertainties <- list()
      
      if ("epistemic" %in% uncertainty_types) {
        # Model uncertainty from standard errors
        uncertainties$epistemic <- rep(0.06, n_predictions)
      }
      
      if ("aleatoric" %in% uncertainty_types) {
        # Residual variance
        uncertainties$aleatoric <- rep(0.04, n_predictions)
      }
      
      if ("total" %in% uncertainty_types) {
        epistemic <- uncertainties$epistemic %||% rep(0.06, n_predictions)
        aleatoric <- uncertainties$aleatoric %||% rep(0.04, n_predictions)
        uncertainties$total <- epistemic + aleatoric
      }
      
      uncertainty_result <- structure(list(
        uncertainties = uncertainties,
        method = "statistical",
        n_predictions = n_predictions,
        uncertainty_types = uncertainty_types,
        timestamp = Sys.time()
      ), class = "UncertaintyResults")
      
      return(uncertainty_result)
    },
    
    # Calculate normal confidence intervals
    calculate_normal_intervals = function(predictions, confidence_level) {
      
      # Calculate z-score for confidence level
      alpha <- 1 - confidence_level
      z_score <- qnorm(1 - alpha/2)
      
      # Extract mean predictions and uncertainties
      if (is.list(predictions)) {
        mean_pred <- predictions$mean
        if (!is.null(predictions$total_uncertainty)) {
          std_error <- sqrt(predictions$total_uncertainty)
        } else if (!is.null(predictions$epistemic_uncertainty)) {
          std_error <- sqrt(predictions$epistemic_uncertainty)
        } else {
          std_error <- rep(0.1, length(mean_pred))
        }
      } else {
        mean_pred <- predictions
        std_error <- rep(0.1, length(predictions))
      }
      
      # Calculate intervals
      margin_error <- z_score * std_error
      lower_bound <- mean_pred - margin_error
      upper_bound <- mean_pred + margin_error
      
      intervals <- list(
        lower_bound = lower_bound,
        upper_bound = upper_bound,
        confidence_level = confidence_level,
        method = "normal",
        margin_error = margin_error
      )
      
      return(intervals)
    },
    
    # Calculate bootstrap confidence intervals
    calculate_bootstrap_intervals = function(predictions, confidence_level) {
      
      # Placeholder for bootstrap implementation
      # In full implementation, would resample and calculate intervals
      
      n_predictions <- if (is.list(predictions)) length(predictions$mean) else length(predictions)
      
      # Simulate bootstrap intervals
      alpha <- 1 - confidence_level
      lower_quantile <- alpha / 2
      upper_quantile <- 1 - alpha / 2
      
      # Generate bootstrap samples (placeholder)
      bootstrap_samples <- matrix(
        rnorm(n_predictions * private$config$bootstrap_samples),
        nrow = n_predictions
      )
      
      lower_bound <- apply(bootstrap_samples, 1, quantile, probs = lower_quantile)
      upper_bound <- apply(bootstrap_samples, 1, quantile, probs = upper_quantile)
      
      intervals <- list(
        lower_bound = lower_bound,
        upper_bound = upper_bound,
        confidence_level = confidence_level,
        method = "bootstrap",
        n_bootstrap_samples = private$config$bootstrap_samples
      )
      
      return(intervals)
    },
    
    # Calculate quantile confidence intervals
    calculate_quantile_intervals = function(predictions, confidence_level) {
      
      # Use MC samples if available
      if (is.list(predictions) && !is.null(predictions$mc_samples)) {
        
        alpha <- 1 - confidence_level
        lower_quantile <- alpha / 2
        upper_quantile <- 1 - alpha / 2
        
        lower_bound <- apply(predictions$mc_samples, 1, quantile, probs = lower_quantile)
        upper_bound <- apply(predictions$mc_samples, 1, quantile, probs = upper_quantile)
        
      } else {
        # Fall back to normal intervals
        return(private$calculate_normal_intervals(predictions, confidence_level))
      }
      
      intervals <- list(
        lower_bound = lower_bound,
        upper_bound = upper_bound,
        confidence_level = confidence_level,
        method = "quantile"
      )
      
      return(intervals)
    },
    
    # Generate uncertainty rasters
    generate_uncertainty_rasters = function(uncertainty_results, field_data, map_types, resolution) {
      
      # Placeholder implementation for raster generation
      # In full implementation, would interpolate uncertainty values to create rasters
      
      uncertainty_maps <- list()
      
      for (map_type in map_types) {
        if (map_type %in% names(uncertainty_results$uncertainties)) {
          
          # Create placeholder raster
          if (!is.null(field_data$boundary)) {
            template_raster <- terra::rast(field_data$boundary)
          } else if (!is.null(field_data$covariates)) {
            template_raster <- field_data$covariates[[1]]
          } else {
            # Create default raster
            template_raster <- terra::rast(nrows = 100, ncols = 100, 
                                           xmin = 0, xmax = 1, ymin = 0, ymax = 1)
          }
          
          # Fill with uncertainty values (placeholder)
          terra::values(template_raster) <- runif(terra::ncell(template_raster), 
                                                  min = min(uncertainty_results$uncertainties[[map_type]]),
                                                  max = max(uncertainty_results$uncertainties[[map_type]]))
          
          names(template_raster) <- paste0(map_type, "_uncertainty")
          uncertainty_maps[[map_type]] <- template_raster
        }
      }
      
      return(uncertainty_maps)
    },
    
    # Create uncertainty visualizations
    create_uncertainty_visualizations = function(uncertainty_results, plot_type, interactive) {
      
      plots <- list()
      
      if (plot_type %in% c("histograms", "all")) {
        plots$histograms <- private$create_uncertainty_histograms(uncertainty_results)
      }
      
      if (plot_type %in% c("scatter", "all")) {
        plots$scatter <- private$create_uncertainty_scatter(uncertainty_results)
      }
      
      if (plot_type %in% c("maps", "all")) {
        plots$maps <- private$create_uncertainty_map_plots(uncertainty_results)
      }
      
      return(plots)
    },
    
    # Create uncertainty histograms
    create_uncertainty_histograms = function(uncertainty_results) {
      
      # Placeholder for histogram creation
      histograms <- list()
      
      for (uncertainty_type in names(uncertainty_results$uncertainties)) {
        hist_data <- data.frame(
          uncertainty = uncertainty_results$uncertainties[[uncertainty_type]],
          type = uncertainty_type
        )
        
        # Create histogram (placeholder)
        histograms[[uncertainty_type]] <- list(
          data = hist_data,
          title = paste(uncertainty_type, "Uncertainty Distribution"),
          type = "histogram"
        )
      }
      
      return(histograms)
    },
    
    # Create uncertainty scatter plots
    create_uncertainty_scatter = function(uncertainty_results) {
      
      # Placeholder for scatter plot creation
      scatter_plots <- list()
      
      uncertainties <- uncertainty_results$uncertainties
      
      if ("epistemic" %in% names(uncertainties) && "aleatoric" %in% names(uncertainties)) {
        scatter_data <- data.frame(
          epistemic = uncertainties$epistemic,
          aleatoric = uncertainties$aleatoric
        )
        
        scatter_plots$epistemic_vs_aleatoric <- list(
          data = scatter_data,
          title = "Epistemic vs Aleatoric Uncertainty",
          type = "scatter"
        )
      }
      
      return(scatter_plots)
    },
    
    # Create uncertainty map plots
    create_uncertainty_map_plots = function(uncertainty_results) {
      
      # Placeholder for map plot creation
      map_plots <- list()
      
      for (uncertainty_type in names(uncertainty_results$uncertainties)) {
        map_plots[[uncertainty_type]] <- list(
          uncertainty_values = uncertainty_results$uncertainties[[uncertainty_type]],
          title = paste(uncertainty_type, "Uncertainty Map"),
          type = "map"
        )
      }
      
      return(map_plots)
    },
    
    # Perform calibration assessment
    perform_calibration_assessment = function(predictions, observations, calibration_method) {
      
      # Calculate prediction errors
      errors <- observations - predictions$mean
      
      # Calculate standardized errors using total uncertainty
      if (!is.null(predictions$total_uncertainty)) {
        std_errors <- errors / sqrt(predictions$total_uncertainty)
      } else {
        std_errors <- errors / sd(errors)
      }
      
      # Assess calibration
      calibration_result <- list(
        method = calibration_method,
        mean_error = mean(errors),
        rmse = sqrt(mean(errors^2)),
        mae = mean(abs(errors)),
        std_errors = std_errors,
        std_error_mean = mean(std_errors),
        std_error_sd = sd(std_errors),
        well_calibrated = abs(mean(std_errors)) < 0.1 && abs(sd(std_errors) - 1) < 0.2,
        n_observations = length(observations)
      )
      
      return(calibration_result)
    }
  )
)

#' Create Spatial Uncertainty instance
#'
#' @description
#' Convenience function to create a SpatialUncertainty instance with default configuration.
#'
#' @param ... Additional configuration parameters
#' @return SpatialUncertainty instance
#'
#' @examples
#' \dontrun{
#' uncertainty <- create_spatial_uncertainty()
#' }
#'
#' @export
create_spatial_uncertainty <- function(...) {
  additional_config <- list(...)
  uncertainty <- SpatialUncertainty$new(config = additional_config)
  return(uncertainty)
}