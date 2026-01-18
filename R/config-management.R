# Configuration Management and Logging Service
# Constitutional Compliance: Code Quality Excellence and User Experience Consistency
# Centralized configuration management with constitutional standards enforcement

#' @title ConfigManager
#'
#' @description
#' Manages global configuration settings, logging, and constitutional compliance
#' for the soil sampling optimization interface. Provides consistent parameter
#' management and validation according to constitutional standards.
#'
#' @details
#' The ConfigManager ensures that all configuration settings meet constitutional
#' requirements for code quality excellence and user experience consistency.
#' It provides centralized logging, parameter validation, and system monitoring.
#'
#' @export
ConfigManager <- R6::R6Class("ConfigManager",
  public = list(
    #' @field config List containing all configuration parameters
    config = NULL,
    
    #' @field log_level Character indicating current logging level
    log_level = NULL,
    
    #' @field session_info List with session and system information
    session_info = NULL,
    
    #' Initialize configuration manager
    #'
    #' @param config_list Named list with configuration parameters
    #' @param validate_config Logical, if TRUE validates against constitutional standards
    #' 
    #' @examples
    #' \dontrun{
    #' config <- ConfigManager$new(list(
    #'   log_level = "INFO",
    #'   parallel_cores = 2,
    #'   memory_limit = "2GB"
    #' ))
    #' }
    initialize = function(config_list = NULL, validate_config = TRUE) {
      # Initialize with default constitutional configuration
      self$config <- private$get_default_config()
      self$log_level <- "INFO"
      
      # Override with user-provided configuration
      if (!is.null(config_list)) {
        self$update_config(config_list, validate_config)
      }
      
      # Initialize session information
      self$session_info <- private$collect_session_info()
      
      # Initialize logging
      private$setup_logging()
      
      self$log("INFO", "ConfigManager initialized with constitutional compliance")
      
      invisible(self)
    },
    
    #' Update configuration settings
    #'
    #' @param new_config Named list with new configuration values
    #' @param validate Logical, if TRUE validates changes
    update_config = function(new_config, validate = TRUE) {
      if (validate) {
        validation_result <- private$validate_config(new_config)
        if (!validation_result$is_valid) {
          stop(ConfigurationError(
            message = paste("ConfigManager: Configuration validation failed:", 
                           paste(validation_result$issues, collapse = "; ")),
            config_key = "config",
            config_value = new_config
          ))
        }
      }
      
      # Update configuration
      for (key in names(new_config)) {
        self$config[[key]] <- new_config[[key]]
      }
      
      # Update log level if changed
      if ("log_level" %in% names(new_config)) {
        self$log_level <- new_config$log_level
      }
      
      self$log("INFO", "Configuration updated successfully")
      invisible(self)
    },
    
    #' Get configuration parameter
    #'
    #' @param key Character key for configuration parameter
    #' @param default Default value if key not found
    #' @return Configuration value or default
    get = function(key, default = NULL) {
      if (key %in% names(self$config)) {
        return(self$config[[key]])
      } else {
        self$log("WARNING", paste("Configuration key not found:", key))
        return(default)
      }
    },
    
    #' Set configuration parameter
    #'
    #' @param key Character key for configuration parameter
    #' @param value Value to set
    #' @param validate Logical, if TRUE validates the change
    set = function(key, value, validate = TRUE) {
      new_config <- list()
      new_config[[key]] <- value
      self$update_config(new_config, validate)
      invisible(self)
    },
    
    #' Log message with timestamp and level
    #'
    #' @param level Character log level (DEBUG, INFO, WARNING, ERROR)
    #' @param message Character message to log
    #' @param ... Additional arguments passed to sprintf
    log = function(level, message, ...) {
      level <- toupper(level)
      
      # Check if level should be logged
      level_hierarchy <- c("DEBUG" = 1, "INFO" = 2, "WARNING" = 3, "ERROR" = 4)
      current_level <- level_hierarchy[self$log_level]
      message_level <- level_hierarchy[level]
      
      if (message_level >= current_level) {
        # Format message with additional arguments
        if (length(list(...)) > 0) {
          message <- sprintf(message, ...)
        }
        
        # Create log entry
        timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
        log_entry <- sprintf("[%s] %s: %s", timestamp, level, message)
        
        # Output based on level
        if (level %in% c("ERROR", "WARNING")) {
          cat(log_entry, "\n", file = stderr())
        } else {
          cat(log_entry, "\n")
        }
        
        # Store in log history (keep last 1000 entries)
        private$log_history <- c(private$log_history, log_entry)
        if (length(private$log_history) > 1000) {
          private$log_history <- tail(private$log_history, 1000)
        }
      }
      
      invisible(self)
    },
    
    #' Get system resource information
    #'
    #' @return List with current system resource usage
    get_system_resources = function() {
      resources <- list(
        memory_used_mb = as.numeric(utils::object.size(.GlobalEnv)) / (1024^2),
        available_cores = parallel::detectCores(),
        r_version = R.version.string,
        platform = .Platform$OS.type
      )
      
      # Add memory limit information
      if (!is.null(self$config$memory_limit)) {
        memory_limit_gb <- private$parse_memory_limit(self$config$memory_limit)
        resources$memory_limit_gb <- memory_limit_gb
        resources$memory_usage_percentage <- (resources$memory_used_mb / 1024) / memory_limit_gb * 100
      }
      
      return(resources)
    },
    
    #' Check constitutional compliance of current configuration
    #'
    #' @return List with compliance status and recommendations
    check_constitutional_compliance = function() {
      compliance <- list(
        overall_compliant = TRUE,
        violations = character(0),
        recommendations = character(0)
      )
      
      # Check code quality excellence requirements
      if (self$config$validation_strict != TRUE) {
        compliance$violations <- c(compliance$violations, 
          "Code Quality Excellence: Strict validation not enabled")
      }
      
      # Check user experience consistency requirements  
      if (self$config$progress_feedback != TRUE) {
        compliance$violations <- c(compliance$violations,
          "User Experience Consistency: Progress feedback not enabled")
      }
      
      # Check performance requirements
      memory_limit_gb <- private$parse_memory_limit(self$config$memory_limit)
      if (memory_limit_gb > 2) {
        compliance$recommendations <- c(compliance$recommendations,
          "Performance: Memory limit exceeds constitutional recommendation of 2GB")
      }
      
      # Check parallel processing configuration
      if (self$config$parallel_cores > parallel::detectCores()) {
        compliance$violations <- c(compliance$violations,
          "Performance: Parallel cores exceeds available system cores")
      }
      
      compliance$overall_compliant <- length(compliance$violations) == 0
      
      return(compliance)
    },
    
    #' Get log history
    #'
    #' @param n_entries Number of recent entries to return
    #' @return Character vector with recent log entries
    get_log_history = function(n_entries = 50) {
      if (length(private$log_history) == 0) {
        return(character(0))
      }
      
      start_idx <- max(1, length(private$log_history) - n_entries + 1)
      return(private$log_history[start_idx:length(private$log_history)])
    },
    
    #' Export configuration to file
    #'
    #' @param file_path Character path for configuration file
    #' @param format Character format ("json" or "yaml")
    export_config = function(file_path, format = "json") {
      config_export <- list(
        config = self$config,
        session_info = self$session_info,
        export_timestamp = Sys.time()
      )
      
      if (format == "json") {
        json_content <- jsonlite::toJSON(config_export, pretty = TRUE, auto_unbox = TRUE)
        writeLines(json_content, file_path)
      } else if (format == "yaml") {
        yaml::write_yaml(config_export, file_path)
      } else {
        stop("ConfigManager: Unsupported export format. Use 'json' or 'yaml'.")
      }
      
      self$log("INFO", "Configuration exported to: %s", file_path)
      invisible(self)
    },
    
    #' Import configuration from file
    #'
    #' @param file_path Character path to configuration file
    #' @param format Character format ("json" or "yaml")
    import_config = function(file_path, format = "json") {
      if (!file.exists(file_path)) {
        stop("ConfigManager: Configuration file not found: ", file_path)
      }
      
      tryCatch({
        if (format == "json") {
          imported <- jsonlite::fromJSON(file_path)
        } else if (format == "yaml") {
          imported <- yaml::read_yaml(file_path)
        } else {
          stop("Unsupported import format. Use 'json' or 'yaml'.")
        }
        
        if ("config" %in% names(imported)) {
          self$update_config(imported$config, validate = TRUE)
          self$log("INFO", "Configuration imported from: %s", file_path)
        } else {
          stop("Invalid configuration file format")
        }
        
      }, error = function(e) {
        self$log("ERROR", "Failed to import configuration: %s", e$message)
        stop("ConfigManager: Import failed - ", e$message)
      })
      
      invisible(self)
    }
  ),
  
  private = list(
    log_history = character(0),
    
    # Get default constitutional configuration
    get_default_config = function() {
      list(
        # Logging configuration
        log_level = "INFO",
        
        # Performance configuration (constitutional compliance)
        parallel_cores = 1L,
        memory_limit = "2GB",
        max_execution_time = 300,  # 5 minutes (constitutional requirement)
        
        # Spatial analysis configuration
        crs_validation_strict = TRUE,
        spatial_precision_tolerance = 1e-6,
        
        # User experience configuration
        progress_feedback = TRUE,
        validation_strict = TRUE,
        
        # File and directory configuration
        temp_dir = tempdir(),
        output_dir = "results",
        
        # Algorithm configuration
        optimization_timeout = 300,
        benchmark_enabled = TRUE,
        
        # Constitutional compliance flags
        enforce_constitutional_standards = TRUE,
        quality_gate_enabled = TRUE
      )
    },
    
    # Validate configuration against constitutional standards
    validate_config = function(config) {
      result <- list(
        is_valid = TRUE,
        issues = character(0),
        warnings = character(0)
      )
      
      # Validate log levels
      if ("log_level" %in% names(config)) {
        valid_levels <- c("DEBUG", "INFO", "WARNING", "ERROR")
        if (!config$log_level %in% valid_levels) {
          result$is_valid <- FALSE
          result$issues <- c(result$issues, 
            paste("Invalid log_level. Must be one of:", paste(valid_levels, collapse = ", ")))
        }
      }
      
      # Validate parallel cores
      if ("parallel_cores" %in% names(config)) {
        if (!is.integer(config$parallel_cores) || config$parallel_cores < 1) {
          result$is_valid <- FALSE
          result$issues <- c(result$issues, "parallel_cores must be a positive integer")
        }
        
        if (config$parallel_cores > parallel::detectCores()) {
          result$warnings <- c(result$warnings,
            "parallel_cores exceeds available system cores")
        }
      }
      
      # Validate memory limit
      if ("memory_limit" %in% names(config)) {
        memory_gb <- private$parse_memory_limit(config$memory_limit)
        if (length(memory_gb) != 1 || is.na(memory_gb) || memory_gb <= 0) {
          result$is_valid <- FALSE
          result$issues <- c(result$issues, 
            "memory_limit must be positive (e.g., '2GB', '1024MB')")
        }
        
        # Constitutional recommendation
        if (!is.na(memory_gb) && memory_gb > 2) {
          result$warnings <- c(result$warnings,
            "memory_limit exceeds constitutional recommendation of 2GB")
        }
      }
      
      # Validate directories
      directory_keys <- c("temp_dir", "output_dir")
      for (key in directory_keys) {
        if (key %in% names(config)) {
          if (!is.character(config[[key]]) || length(config[[key]]) != 1) {
            result$is_valid <- FALSE
            result$issues <- c(result$issues, paste(key, "must be a single character string"))
          }
        }
      }
      
      # Validate timeout values
      timeout_keys <- c("max_execution_time", "optimization_timeout")
      for (key in timeout_keys) {
        if (key %in% names(config)) {
          if (!is.numeric(config[[key]]) || config[[key]] <= 0) {
            result$is_valid <- FALSE
            result$issues <- c(result$issues, paste(key, "must be a positive number"))
          }
          
          # Constitutional limit check
          if (key == "max_execution_time" && config[[key]] > 300) {
            result$warnings <- c(result$warnings,
              "max_execution_time exceeds constitutional limit of 300 seconds")
          }
        }
      }
      
      return(result)
    },
    
    # Parse memory limit string to GB
    parse_memory_limit = function(memory_string) {
      if (!is.character(memory_string)) {
        return(NA)
      }
      
      # Extract number and unit
      memory_string <- toupper(trimws(memory_string))
      
      if (grepl("^[0-9.]+GB?$", memory_string)) {
        return(as.numeric(gsub("[^0-9.]", "", memory_string)))
      } else if (grepl("^[0-9.]+MB?$", memory_string)) {
        return(as.numeric(gsub("[^0-9.]", "", memory_string)) / 1024)
      } else if (grepl("^[0-9.]+$", memory_string)) {
        # Assume GB if no unit specified
        return(as.numeric(memory_string))
      } else {
        return(NA)
      }
    },
    
    # Collect system and session information
    collect_session_info = function() {
      list(
        r_version = R.version.string,
        platform = .Platform,
        locale = Sys.getlocale(),
        timezone = Sys.timezone(),
        working_directory = getwd(),
        user = Sys.getenv("USER"),
        session_start = Sys.time(),
        available_cores = parallel::detectCores(),
        installed_packages = list(
          terra = packageVersion("terra"),
          sf = packageVersion("sf"),
          torch = tryCatch(packageVersion("torch"), error = function(e) "not installed"),
          R6 = packageVersion("R6")
        )
      )
    },
    
    # Setup logging system
    setup_logging = function() {
      # Create log directory if needed
      if (!is.null(self$config$temp_dir)) {
        log_dir <- file.path(self$config$temp_dir, "logs")
        if (!dir.exists(log_dir)) {
          dir.create(log_dir, recursive = TRUE)
        }
      }
      
      # Initialize log history
      private$log_history <- character(0)
    }
  )
)

#' Create default configuration manager instance
#'
#' @description
#' Convenience function to create a ConfigManager instance with constitutional
#' defaults. This ensures consistent configuration across the application.
#'
#' @param ... Additional configuration parameters to override defaults
#' @return ConfigManager instance
#' 
#' @examples
#' \dontrun{
#' config <- create_default_config_manager(
#'   log_level = "DEBUG",
#'   parallel_cores = 2
#' )
#' }
#' 
#' @export
create_default_config_manager <- function(...) {
  additional_config <- list(...)
  config_manager <- ConfigManager$new(additional_config, validate_config = TRUE)
  return(config_manager)
}

#' Validate system requirements for constitutional compliance
#'
#' @description
#' Checks if the current system meets the constitutional requirements for
#' running the soil sampling optimization interface.
#'
#' @return List with system requirement validation results
#' 
#' @examples
#' \dontrun{
#' requirements <- validate_system_requirements()
#' if (!requirements$meets_requirements) {
#'   print(requirements$issues)
#' }
#' }
#' 
#' @export
validate_system_requirements <- function() {
  result <- list(
    meets_requirements = TRUE,
    issues = character(0),
    warnings = character(0),
    system_info = list()
  )
  
  # Check R version (constitutional requirement: R >= 4.3.0)
  r_version <- getRversion()
  result$system_info$r_version <- as.character(r_version)
  
  if (r_version < "4.3.0") {
    result$meets_requirements <- FALSE
    result$issues <- c(result$issues, 
      paste("R version", r_version, "< 4.3.0 (constitutional requirement)"))
  }
  
  # Check required packages
  required_packages <- list(
    "terra" = "1.7.0",
    "sf" = "1.0.0", 
    "R6" = "2.5.0"
  )
  
  for (pkg in names(required_packages)) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      result$meets_requirements <- FALSE
      result$issues <- c(result$issues, paste("Required package not installed:", pkg))
    } else {
      pkg_version <- packageVersion(pkg)
      min_version <- required_packages[[pkg]]
      if (pkg_version < min_version) {
        result$meets_requirements <- FALSE
        result$issues <- c(result$issues, 
          paste("Package", pkg, "version", pkg_version, "<", min_version))
      }
    }
  }
  
  # Check torch availability (optional but recommended)
  torch_available <- requireNamespace("torch", quietly = TRUE)
  result$system_info$torch_available <- torch_available
  
  if (!torch_available) {
    result$warnings <- c(result$warnings,
      "torch package not available - UFN models will use statistical fallbacks")
  }
  
  # Check system resources
  available_cores <- parallel::detectCores()
  result$system_info$available_cores <- available_cores
  
  if (available_cores < 2) {
    result$warnings <- c(result$warnings,
      "Less than 2 CPU cores available - parallel processing limited")
  }
  
  # Check memory (rough estimate)
  if (.Platform$OS.type == "windows") {
    # Windows memory check is complex, skip for now
    result$warnings <- c(result$warnings,
      "Memory check not available on Windows - ensure >4GB RAM available")
  }
  
  return(result)
}