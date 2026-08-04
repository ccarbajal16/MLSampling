# Design Comparison Framework for MLSampling
# Implements metrics and statistical testing for comparing sampling designs

#' @title DesignComparison
#'
#' @description
#' Provides tools for comparing different sampling designs based on coverage,
#' efficiency, and spatial representativeness.
#'
#' @details
#' The DesignComparison class implements:
#' - Comparison metrics: Coverage (MSSD), Efficiency, Representativeness
#' - Statistical testing: Wilcoxon rank-sum test, t-test
#' - Spatial cross-validation for design assessment
#'
#' @export
DesignComparison <- R6::R6Class("DesignComparison",
  
  public = list(
    
    #' Initialize Design Comparison Framework
    #'
    #' @param config Optional configuration list
    initialize = function(config = list()) {
      private$config <- private$set_default_config(config)
      invisible(self)
    },
    
    #' Compare Multiple Designs
    #'
    #' @param designs List of sf objects representing different sampling designs
    #' @param field_data Field data (SpatRaster or list with boundary/covariates)
    #' @param true_values Optional raster of true values for validation (if available)
    #'
    #' @return List containing comparison results and metrics
    compare_designs = function(designs, field_data, true_values = NULL) {
      
      if (!is.list(designs) || length(designs) == 0) {
        stop("designs must be a non-empty list of sf objects")
      }
      
      results <- list()
      metrics_df <- data.frame()
      
      for (name in names(designs)) {
        design <- designs[[name]]
        metrics <- private$calculate_metrics(design, field_data, true_values)
        metrics$design <- name
        metrics_df <- rbind(metrics_df, as.data.frame(metrics))
        results[[name]] <- metrics
      }
      
      return(list(
        metrics_summary = metrics_df,
        detailed_results = results
      ))
    },
    
    #' Perform Statistical Test Between Two Designs
    #'
    #' @param design1_metrics Vector of metric values for design 1
    #' @param design2_metrics Vector of metric values for design 2
    #' @param test_type "wilcoxon" or "t-test"
    #'
    #' @return Test result (htest object)
    perform_statistical_test = function(design1_metrics, design2_metrics, test_type = "wilcoxon") {
      
      if (test_type == "wilcoxon") {
        return(wilcox.test(design1_metrics, design2_metrics))
      } else if (test_type == "t-test") {
        return(t.test(design1_metrics, design2_metrics))
      } else {
        stop("Unknown test type")
      }
    },
    
    #' Spatial Cross-Validation for Design Assessment
    #'
    #' @param design sf object of sampling locations
    #' @param field_data Field data
    #' @param k Number of folds
    #'
    #' @return CV performance metrics
    cross_validate_design = function(design, field_data, k = 5) {
      # This would typically involve:
      # 1. Splitting the design into K folds
      # 2. Training a model (e.g., Kriging or RF) on K-1 folds
      # 3. Predicting on the Kth fold
      # 4. Calculating RMSE/MAE
      
      # For this implementation, we'll calculate the average nearest neighbor distance
      # within folds as a proxy for spatial spread consistency
      
      coords <- sf::st_coordinates(design)
      n <- nrow(coords)
      
      # Simple random CV for demonstration
      folds <- sample(rep(1:k, length.out = n))
      
      cv_metrics <- numeric(k)
      
      for (i in 1:k) {
        test_idx <- which(folds == i)
        train_idx <- which(folds != i)
        
        # Calculate coverage of training set (MSSD)
        train_coords <- coords[train_idx, , drop = FALSE]
        
        # Calculate Mean Squared Shortest Distance (MSSD) for training set
        # This measures how well the training set covers the area
        # Using a simple approximation based on nearest neighbors
        if (nrow(train_coords) > 1) {
          dists <- as.matrix(dist(train_coords))
          diag(dists) <- Inf
          min_dists <- apply(dists, 1, min)
          cv_metrics[i] <- mean(min_dists^2)
        } else {
          cv_metrics[i] <- NA
        }
      }
      
      return(list(
        mean_metric = mean(cv_metrics, na.rm = TRUE),
        fold_metrics = cv_metrics
      ))
    }
  ),
  
  private = list(
    
    config = NULL,
    
    set_default_config = function(user_config) {
      default <- list(
        metric_types = c("coverage", "representativeness")
      )
      
      if (is.null(user_config)) {
        user_config <- list()
      }
      
      modifyList(default, user_config)
    },
    
    calculate_metrics = function(design, field_data, true_values = NULL) {
      
      metrics <- list()
      coords <- sf::st_coordinates(design)
      
      # 1. Coverage Metric: Mean Squared Shortest Distance (MSSD)
      # Measures how well samples cover the space
      # Ideally, we calculate this against a dense grid of the field
      if (!is.null(field_data$boundary)) {
        # Generate grid points within boundary for MSSD calculation
        boundary_v <- if (inherits(field_data$boundary, "sf")) terra::vect(field_data$boundary) else field_data$boundary
        grid_vec <- terra::spatSample(boundary_v, size = 1000, method = "regular")
        grid_coords <- terra::crds(grid_vec)
        
        # Distance from every grid point to nearest sample
        # Using a simple loop or apply for now (can be optimized with dedicated spatial libs)
        dists_to_samples <- apply(grid_coords, 1, function(pt) {
          min(sqrt((coords[,1] - pt[1])^2 + (coords[,2] - pt[2])^2))
        })
        
        metrics$mssd <- mean(dists_to_samples^2)
      } else {
        metrics$mssd <- NA
      }
      
      # 2. Representativeness: Feature Space Coverage
      # If covariates are available, check how well samples cover feature space distribution
      if (!is.null(field_data$covariates)) {
        # Sample covariates at design locations.
        # terra::extract() returns an ID column only for SpatVector input, not
        # for a coordinate matrix. Drop it only when it is actually present,
        # otherwise the first covariate is discarded instead.
        sample_vals <- terra::extract(field_data$covariates, coords)
        if ("ID" %in% names(sample_vals)) {
          sample_vals <- sample_vals[, names(sample_vals) != "ID", drop = FALSE]
        }
        
        # Sample covariates from the whole field (reference distribution)
        field_vals <- terra::spatSample(field_data$covariates, size = 1000, method = "random", na.rm = TRUE)
        
        # Calculate Kolmogorov-Smirnov test statistic average across features
        ks_stats <- numeric(ncol(sample_vals))
        for (i in 1:ncol(sample_vals)) {
           # Ensure we have enough data and no NAs
           s_v <- na.omit(sample_vals[, i])
           f_v <- na.omit(field_vals[, i])
           if (length(s_v) > 0 && length(f_v) > 0) {
             ks <- ks.test(s_v, f_v)
             ks_stats[i] <- ks$statistic
           } else {
             ks_stats[i] <- NA
           }
        }
        metrics$feature_ks_mean <- mean(ks_stats, na.rm = TRUE)
      } else {
        metrics$feature_ks_mean <- NA
      }
      
      return(metrics)
    }
  )
)
