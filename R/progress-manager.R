# Progress Management for MLSampling
# Implements unified progress tracking with constitutional compliance

#' Progress Manager Class
#'
#' @description
#' Manages progress reporting for long-running operations in MLSampling.
#' Provides a consistent interface for progress bars and status updates.
#'
#' @details
#' The ProgressManager ensures:
#' - Consistent user experience (Constitutional requirement)
#' - Graceful fallback when not in interactive mode
#' - Integration with logging system
#'
#' @import R6
#' @import progress
#' @export
ProgressManager <- R6::R6Class("ProgressManager",
  
  public = list(
    
    #' @field config_manager Configuration manager instance
    config_manager = NULL,
    
    #' @field active_bar Current active progress bar
    active_bar = NULL,
    
    #' Initialize Progress Manager
    #'
    #' @param config_manager Optional ConfigManager instance
    initialize = function(config_manager = NULL) {
      self$config_manager <- config_manager
    },
    
    #' Start a new progress bar
    #'
    #' @param total Total number of steps
    #' @param format Format string for progress bar
    #' @param show_after Minimum seconds before showing progress
    #'
    #' @return self
    start_progress = function(total, format = "  :what [:bar] :percent eta: :eta", show_after = 0.5) {
      
      if (!interactive()) {
        # Non-interactive mode: just log start
        if (!is.null(self$config_manager)) {
          self$config_manager$log("INFO", "Starting operation with %d steps", total)
        }
        return(self)
      }
      
      if (requireNamespace("progress", quietly = TRUE)) {
        self$active_bar <- progress::progress_bar$new(
          format = format,
          total = total,
          clear = FALSE,
          show_after = show_after
        )
      } else {
        # Fallback to base R
        self$active_bar <- txtProgressBar(min = 0, max = total, style = 3)
      }
      
      return(self)
    },
    
    #' Update progress
    #'
    #' @param step Current step (optional, increments by 1 if NULL)
    #' @param status Status message
    #'
    #' @return self
    update_progress = function(step = NULL, status = "") {
      
      if (is.null(self$active_bar)) return(self)
      
      if (inherits(self$active_bar, "progress_bar")) {
        tokens <- if (nchar(status) > 0) list(what = status) else list(what = "Processing")
        self$active_bar$tick(tokens = tokens)
      } else if (inherits(self$active_bar, "txtProgressBar")) {
        if (is.null(step)) {
          # txtProgressBar needs explicit value, this is tricky without tracking state
          # Simplification: assuming we track it externally or this is a simple increment
          # If step is NULL, we can't easily increment txtProgressBar without getting current val
          curr <- getTxtProgressBar(self$active_bar)
          setTxtProgressBar(self$active_bar, curr + 1)
        } else {
          setTxtProgressBar(self$active_bar, step)
        }
      }
      
      return(self)
    },
    
    #' Finish progress tracking
    #'
    #' @return self
    finish_progress = function() {
      
      if (!is.null(self$active_bar)) {
        if (inherits(self$active_bar, "txtProgressBar")) {
          close(self$active_bar)
        } else {
          self$active_bar$terminate()
        }
        self$active_bar <- NULL
      }
      
      if (!is.null(self$config_manager)) {
        self$config_manager$log("INFO", "Operation completed")
      }
      
      return(self)
    }
  )
)

#' Create default progress manager
#'
#' @param config_manager Optional config manager
#' @return ProgressManager instance
#' @export
create_progress_manager <- function(config_manager = NULL) {
  ProgressManager$new(config_manager)
}
