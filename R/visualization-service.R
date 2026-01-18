
#' Visualization Service Class
#'
#' @description
#' Service for generating ML-specific visualizations including uncertainty maps,
#' feature importance plots, and design comparisons.
#'
#' @import ggplot2
#' @import terra
#' @import sf
#' @import viridis
#' @import gridExtra
#' @export
VisualizationService <- R6::R6Class("VisualizationService",
  public = list(
    
    #' @field config_manager Configuration manager instance
    config_manager = NULL,
    
    #' Initialize Visualization Service
    #' @param config_manager Optional ConfigManager instance
    initialize = function(config_manager = NULL) {
      self$config_manager <- config_manager
    },
    
    #' Plot Uncertainty Map
    #' 
    #' @param uncertainty_raster SpatRaster containing uncertainty values
    #' @param field_data Field data object containing boundary
    #' @param output_path Path to save the plot
    #' @param title Plot title
    #' @return List with success status and plot object
    plot_uncertainty_map = function(uncertainty_raster, field_data = NULL, output_path = NULL, title = "Uncertainty Map") {
      
      tryCatch({
        # Convert raster to dataframe for ggplot
        unc_df <- as.data.frame(uncertainty_raster, xy = TRUE)
        names(unc_df)[3] <- "uncertainty"
        
        p <- ggplot() +
          geom_raster(data = unc_df, aes(x = x, y = y, fill = uncertainty)) +
          scale_fill_viridis_c(option = "inferno", name = "Uncertainty") +
          labs(title = title, x = "Easting", y = "Northing") +
          theme_minimal() +
          theme(legend.position = "right")
        
        # Add boundary if provided
        if (!is.null(field_data) && !is.null(field_data$boundary)) {
          p <- p + geom_sf(data = field_data$boundary, fill = NA, color = "white", linewidth = 1)
        }
        
        # Save if path provided
        if (!is.null(output_path)) {
          ggsave(output_path, plot = p, width = 10, height = 8, dpi = 300)
        }
        
        return(list(success = TRUE, plot = p))
      }, error = function(e) {
        warning(paste("Error generating uncertainty map:", e$message))
        return(list(success = FALSE, error = e$message))
      })
    },
    
    #' Plot Feature Importance
    #' 
    #' @param importance_scores Named numeric vector of importance scores
    #' @param output_path Path to save the plot
    #' @param title Plot title
    #' @return List with success status and plot object
    plot_feature_importance = function(importance_scores, output_path = NULL, title = "Feature Importance") {
      
      tryCatch({
        # Prepare data
        imp_df <- data.frame(
          feature = names(importance_scores),
          importance = as.numeric(importance_scores)
        )
        
        # Reorder features by importance
        imp_df$feature <- factor(imp_df$feature, levels = imp_df$feature[order(imp_df$importance)])
        
        p <- ggplot(imp_df, aes(x = importance, y = feature)) +
          geom_col(fill = "steelblue") +
          labs(title = title, x = "Importance Score", y = "Feature") +
          theme_minimal()
        
        if (!is.null(output_path)) {
          ggsave(output_path, plot = p, width = 8, height = 6, dpi = 300)
        }
        
        return(list(success = TRUE, plot = p))
      }, error = function(e) {
        warning(paste("Error generating feature importance plot:", e$message))
        return(list(success = FALSE, error = e$message))
      })
    },
    
    #' Plot Design Comparison
    #' 
    #' @param comparison_data Data frame with algorithm comparison results
    #' @param metric Metric to plot (column name in comparison_data)
    #' @param output_path Path to save the plot
    #' @param title Plot title
    #' @return List with success status and plot object
    plot_design_comparison = function(comparison_data, metric = "score", output_path = NULL, title = "Design Comparison") {
      
      tryCatch({
        if (!metric %in% names(comparison_data)) {
          stop(paste("Metric", metric, "not found in comparison data"))
        }
        
        p <- ggplot(comparison_data, aes(x = algorithm, y = .data[[metric]], fill = algorithm)) +
          geom_boxplot() +
          scale_fill_viridis_d() +
          labs(title = title, x = "Algorithm", y = metric) +
          theme_minimal() +
          theme(legend.position = "none", axis.text.x = element_text(angle = 45, hjust = 1))
        
        if (!is.null(output_path)) {
          ggsave(output_path, plot = p, width = 8, height = 6, dpi = 300)
        }
        
        return(list(success = TRUE, plot = p))
      }, error = function(e) {
        warning(paste("Error generating design comparison plot:", e$message))
        return(list(success = FALSE, error = e$message))
      })
    },
    
    #' Plot Sampling Locations
    #' 
    #' @param locations sf object or dataframe of locations
    #' @param field_data Field data object containing boundary and covariates
    #' @param output_path Path to save the plot
    #' @param title Plot title
    #' @return List with success status and plot object
    plot_sampling_locations = function(locations, field_data = NULL, output_path = NULL, title = "Sampling Locations") {
      
      tryCatch({
        # Convert to sf if dataframe
        if (!inherits(locations, "sf") && all(c("x", "y") %in% names(locations))) {
            locations <- sf::st_as_sf(locations, coords = c("x", "y"))
            if (!is.null(field_data$boundary)) {
                sf::st_crs(locations) <- sf::st_crs(field_data$boundary)
            }
        }

        p <- ggplot()
        
        # Add background raster if available
        if (!is.null(field_data) && !is.null(field_data$covariates)) {
          # Use first layer for background
          bg_df <- as.data.frame(field_data$covariates[[1]], xy = TRUE)
          names(bg_df)[3] <- "value"
          p <- p + geom_raster(data = bg_df, aes(x = x, y = y, fill = value), alpha = 0.6) +
               scale_fill_viridis_c(name = names(field_data$covariates)[1])
        }
        
        # Add boundary
        if (!is.null(field_data) && !is.null(field_data$boundary)) {
          p <- p + geom_sf(data = field_data$boundary, fill = NA, color = "black", linewidth = 0.8)
        }
        
        # Add points
        p <- p + geom_sf(data = locations, color = "red", size = 2) +
             labs(title = title, x = "Easting", y = "Northing") +
             theme_minimal()
        
        if (!is.null(output_path)) {
          ggsave(output_path, plot = p, width = 10, height = 8, dpi = 300)
        }
        
        return(list(success = TRUE, plot = p))
      }, error = function(e) {
        warning(paste("Error generating sampling locations plot:", e$message))
        return(list(success = FALSE, error = e$message))
      })
    }
  )
)
