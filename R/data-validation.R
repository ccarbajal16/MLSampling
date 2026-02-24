# Spatial Data Validation Service
# Constitutional Compliance: Spatial Analysis Excellence
# Comprehensive validation for CRS consistency, geometry integrity, and data quality

#' Validate field data structure and spatial integrity
#'
#' @description
#' Comprehensive validation function that ensures field data meets constitutional 
#' requirements for spatial analysis excellence. Validates CRS consistency, 
#' geometry integrity, and data quality standards.
#'
#' @param field_data List containing boundary, covariates, and metadata
#' @param strict_validation Logical, if TRUE applies strict constitutional standards
#' 
#' @return List with validation results and detailed diagnostic information
#' 
#' @examples
#' \dontrun{
#' # Create test field data
#' field_data <- list(
#'   boundary = sf::st_read("field_boundary.shp"),
#'   covariates = terra::rast("environmental_layers.tif")
#' )
#' 
#' # Validate with constitutional standards
#' validation_result <- validate_field_data(field_data, strict_validation = TRUE)
#' if (!validation_result$is_valid) {
#'   print(validation_result$issues)
#' }
#' }
#' 
#' @export
validate_field_data <- function(field_data, strict_validation = TRUE) {
  validation_result <- list(
    is_valid = TRUE,
    issues = character(0),
    warnings = character(0),
    crs_info = list(),
    geometry_info = list(),
    data_quality = list(),
    constitutional_compliance = TRUE
  )
  
  # Validate required structure
  required_fields <- c("boundary", "covariates")
  missing_fields <- setdiff(required_fields, names(field_data))
  
  if (length(missing_fields) > 0) {
    validation_result$is_valid <- FALSE
    validation_result$issues <- c(validation_result$issues,
      paste("Missing required fields:", paste(missing_fields, collapse = ", ")))
  }
  
  if (!validation_result$is_valid) {
    return(validation_result)
  }
  
  # Validate boundary geometry
  boundary_validation <- validate_boundary_geometry(field_data$boundary)
  validation_result$geometry_info$boundary <- boundary_validation
  
  if (!boundary_validation$is_valid) {
    validation_result$is_valid <- FALSE
    validation_result$issues <- c(validation_result$issues, boundary_validation$issues)
  }
  
  # Validate covariates raster
  covariates_validation <- validate_covariates_raster(field_data$covariates)
  validation_result$geometry_info$covariates <- covariates_validation
  
  if (!covariates_validation$is_valid) {
    validation_result$is_valid <- FALSE
    validation_result$issues <- c(validation_result$issues, covariates_validation$issues)
  }
  
  # Validate CRS consistency (constitutional requirement)
  if (validation_result$is_valid) {
    crs_validation <- validate_crs_consistency(field_data$boundary, field_data$covariates)
    validation_result$crs_info <- crs_validation
    
    if (!crs_validation$is_consistent) {
      if (strict_validation) {
        validation_result$is_valid <- FALSE
        validation_result$issues <- c(validation_result$issues, crs_validation$issues)
      } else {
        validation_result$warnings <- c(validation_result$warnings, crs_validation$issues)
      }
    }
  }
  
  # Validate spatial extent alignment
  if (validation_result$is_valid) {
    extent_validation <- validate_spatial_extent_alignment(field_data$boundary, field_data$covariates)
    
    if (!extent_validation$is_aligned) {
      validation_result$warnings <- c(validation_result$warnings, extent_validation$warnings)
    }
  }
  
  # Validate data quality
  if (validation_result$is_valid) {
    quality_validation <- validate_data_quality(field_data$covariates, strict_validation)
    validation_result$data_quality <- quality_validation
    
    if (!quality_validation$meets_standards) {
      if (strict_validation) {
        validation_result$is_valid <- FALSE
        validation_result$issues <- c(validation_result$issues, quality_validation$issues)
      } else {
        validation_result$warnings <- c(validation_result$warnings, quality_validation$warnings)
      }
    }
  }
  
  # Constitutional compliance check
  validation_result$constitutional_compliance <- validate_constitutional_spatial_standards(validation_result)
  
  return(validation_result)
}

#' Validate boundary geometry integrity
#' 
#' @param boundary sf object representing field boundary
#' @return List with geometry validation results
validate_boundary_geometry <- function(boundary) {
  result <- list(
    is_valid = TRUE,
    issues = character(0),
    geometry_type = NULL,
    area = NULL,
    is_simple = NULL,
    is_valid_geom = NULL
  )
  
  # Check if boundary is sf object
  if (!inherits(boundary, "sf")) {
    result$is_valid <- FALSE
    result$issues <- c(result$issues, "Boundary must be an sf object")
    return(result)
  }
  
  # Check geometry validity
  result$is_valid_geom <- sf::st_is_valid(boundary)
  if (any(!result$is_valid_geom, na.rm = TRUE)) {
    result$is_valid <- FALSE
    result$issues <- c(result$issues, "Boundary contains invalid geometries")
  }
  
  # Check if geometry is empty
  if (any(sf::st_is_empty(boundary))) {
    result$is_valid <- FALSE
    result$issues <- c(result$issues, "Boundary contains empty geometries")
  }
  
  # Get geometry type
  result$geometry_type <- sf::st_geometry_type(boundary)
  expected_types <- c("POLYGON", "MULTIPOLYGON")
  
  if (!all(result$geometry_type %in% expected_types)) {
    result$is_valid <- FALSE
    result$issues <- c(result$issues, 
      paste("Boundary must be POLYGON or MULTIPOLYGON, found:", 
            paste(unique(result$geometry_type), collapse = ", ")))
  }
  
  # Calculate area (if valid)
  if (result$is_valid) {
    tryCatch({
      result$area <- sf::st_area(boundary)
      
      # Check for reasonable area (not zero or extremely small)
      if (any(result$area <= units::set_units(1, "m^2"))) {
        result$is_valid <- FALSE
        result$issues <- c(result$issues, "Boundary area is too small (≤1 m²)")
      }
    }, error = function(e) {
      result$is_valid <- FALSE
      result$issues <- c(result$issues, paste("Error calculating area:", e$message))
    })
  }
  
  return(result)
}

#' Validate covariates raster integrity
#' 
#' @param covariates SpatRaster object with environmental covariates
#' @return List with raster validation results
validate_covariates_raster <- function(covariates) {
  result <- list(
    is_valid = TRUE,
    issues = character(0),
    n_layers = NULL,
    resolution = NULL,
    extent = NULL,
    crs = NULL,
    has_data = NULL
  )
  
  # Check if covariates is SpatRaster
  if (!inherits(covariates, "SpatRaster")) {
    result$is_valid <- FALSE
    result$issues <- c(result$issues, "Covariates must be a SpatRaster object")
    return(result)
  }
  
  # Get raster properties
  result$n_layers <- terra::nlyr(covariates)
  result$resolution <- terra::res(covariates)
  result$extent <- terra::ext(covariates)
  result$crs <- terra::crs(covariates)
  
  # Validate number of layers
  if (result$n_layers < 1) {
    result$is_valid <- FALSE
    result$issues <- c(result$issues, "Covariates must have at least one layer")
  }
  
  # Validate resolution
  if (any(result$resolution <= 0)) {
    result$is_valid <- FALSE
    result$issues <- c(result$issues, "Covariates resolution must be positive")
  }
  
  # Check for extremely small or large resolution
  if (any(result$resolution < 0.001) || any(result$resolution > 100000)) {
    result$issues <- c(result$issues, 
      "Warning: Unusual resolution values detected (very small <0.001 or very large >100,000)")
  }
  
  # Validate CRS
  if (is.na(result$crs) || result$crs == "") {
    result$is_valid <- FALSE
    result$issues <- c(result$issues, "Covariates must have a defined CRS")
  }
  
  # Check extent validity
  extent_coords <- as.vector(result$extent)
  if (length(extent_coords) != 4) {
    result$is_valid <- FALSE
    result$issues <- c(result$issues, "Invalid extent coordinates")
  } else if (extent_coords[1] >= extent_coords[2] || extent_coords[3] >= extent_coords[4]) {
    result$is_valid <- FALSE
    result$issues <- c(result$issues, "Invalid extent: xmin >= xmax or ymin >= ymax")
  }
  
  # Check if raster has data
  tryCatch({
    result$has_data <- !all(is.na(terra::values(covariates, na.rm = FALSE)))
    
    if (!result$has_data) {
      result$is_valid <- FALSE
      result$issues <- c(result$issues, "Covariates raster contains no valid data")
    }
  }, error = function(e) {
    result$issues <- c(result$issues, paste("Error checking raster data:", e$message))
  })
  
  return(result)
}

#' Validate CRS consistency between spatial objects
#' 
#' @param boundary sf boundary object  
#' @param covariates SpatRaster covariates object
#' @return List with CRS validation results
#' 
#' @export
validate_crs_consistency <- function(boundary, covariates) {
  result <- list(
    is_consistent = TRUE,
    issues = character(0),
    boundary_crs = NULL,
    covariates_crs = NULL,
    crs_match = FALSE,
    can_transform = FALSE
  )
  
  # Get CRS information
  tryCatch({
    result$boundary_crs <- sf::st_crs(boundary)$input
    result$covariates_crs <- terra::crs(covariates)

    # Compare CRS objects directly — avoids string representation mismatches
    # (e.g. "WGS 84" vs full WKT for the same EPSG:4326 datum)
    boundary_crs_obj   <- sf::st_crs(boundary)
    covariates_crs_obj <- sf::st_crs(result$covariates_crs)
    crs_equal <- isTRUE(boundary_crs_obj == covariates_crs_obj)

    # Fallback: compare EPSG codes when available
    if (!crs_equal) {
      b_epsg <- boundary_crs_obj$epsg
      c_epsg <- covariates_crs_obj$epsg
      if (!is.na(b_epsg) && !is.na(c_epsg)) {
        crs_equal <- (b_epsg == c_epsg)
      }
    }

    result$crs_match <- crs_equal
    
    # Test transformation capability
    if (!result$crs_match) {
      test_transform <- tryCatch({
        sf::st_transform(boundary[1,], result$covariates_crs)
        TRUE
      }, error = function(e) FALSE)
      
      result$can_transform <- test_transform
    } else {
      result$can_transform <- TRUE
    }
    
  }, error = function(e) {
    result$is_consistent <- FALSE
    result$issues <- c(result$issues, paste("Error validating CRS:", e$message))
    return(result)
  })
  
  # Determine consistency
  if (!result$crs_match && !result$can_transform) {
    result$is_consistent <- FALSE
    result$issues <- c(result$issues, 
      paste("CRS mismatch and transformation not possible:",
            "Boundary CRS:", result$boundary_crs,
            "Covariates CRS:", result$covariates_crs))
  } else if (!result$crs_match) {
    result$issues <- c(result$issues,
      paste("CRS mismatch but transformation possible:",
            "Boundary CRS:", result$boundary_crs,
            "Covariates CRS:", result$covariates_crs))
  }
  
  return(result)
}

#' Validate spatial extent alignment
#' 
#' @param boundary sf boundary object
#' @param covariates SpatRaster covariates object
#' @return List with extent alignment results
validate_spatial_extent_alignment <- function(boundary, covariates) {
  result <- list(
    is_aligned = TRUE,
    warnings = character(0),
    boundary_extent = NULL,
    covariates_extent = NULL,
    overlap_percentage = NULL
  )
  
  tryCatch({
    # Get extents in same CRS (transform boundary if needed)
    boundary_crs <- sf::st_crs(boundary)$input
    covariates_crs <- terra::crs(covariates)
    
    if (boundary_crs != covariates_crs) {
      boundary_transformed <- sf::st_transform(boundary, covariates_crs)
    } else {
      boundary_transformed <- boundary
    }
    
    result$boundary_extent <- sf::st_bbox(boundary_transformed)
    result$covariates_extent <- as.vector(terra::ext(covariates))
    
    # Calculate overlap
    overlap_xmin <- max(result$boundary_extent[1], result$covariates_extent[1])
    overlap_ymin <- max(result$boundary_extent[2], result$covariates_extent[3])
    overlap_xmax <- min(result$boundary_extent[3], result$covariates_extent[2])
    overlap_ymax <- min(result$boundary_extent[4], result$covariates_extent[4])
    
    if (overlap_xmin >= overlap_xmax || overlap_ymin >= overlap_ymax) {
      result$is_aligned <- FALSE
      result$warnings <- c(result$warnings, "No spatial overlap between boundary and covariates")
      result$overlap_percentage <- 0
    } else {
      overlap_area <- (overlap_xmax - overlap_xmin) * (overlap_ymax - overlap_ymin)
      boundary_area <- (result$boundary_extent[3] - result$boundary_extent[1]) * 
                       (result$boundary_extent[4] - result$boundary_extent[2])
      
      result$overlap_percentage <- (overlap_area / boundary_area) * 100
      
      if (result$overlap_percentage < 90) {
        result$warnings <- c(result$warnings,
          paste("Limited overlap between boundary and covariates:", 
                sprintf("%.1f%%", result$overlap_percentage)))
      }
    }
    
  }, error = function(e) {
    result$is_aligned <- FALSE
    result$warnings <- c(result$warnings, paste("Error checking extent alignment:", e$message))
  })
  
  return(result)
}

#' Validate data quality standards
#' 
#' @param covariates SpatRaster with environmental data
#' @param strict_validation Logical for constitutional standards
#' @return List with data quality results
validate_data_quality <- function(covariates, strict_validation = TRUE) {
  result <- list(
    meets_standards = TRUE,
    issues = character(0),
    warnings = character(0),
    na_percentage = NULL,
    value_ranges = NULL,
    layer_names = NULL
  )
  
  tryCatch({
    # Get layer names
    result$layer_names <- names(covariates)
    
    # Check for missing layer names
    if (any(is.na(result$layer_names)) || any(result$layer_names == "")) {
      result$warnings <- c(result$warnings, "Some layers have missing or empty names")
    }
    
    # Calculate NA percentages per layer
    # For boundary-masked rasters, cells outside the polygon are legitimately NA.
    # We compute NA% relative to the valid (in-boundary) area only, detected as
    # cells that are NA across ALL layers simultaneously (= outside mask).
    total_cells <- terra::ncell(covariates)

    all_na_flags <- lapply(seq_len(terra::nlyr(covariates)), function(i)
      is.na(terra::values(covariates[[i]], na.rm = FALSE)))
    outside_mask <- Reduce(`&`, all_na_flags)
    n_outside  <- sum(outside_mask)
    valid_cells <- total_cells - n_outside   # cells inside the boundary

    result$na_percentage <- numeric(terra::nlyr(covariates))
    result$value_ranges <- list()

    for (i in seq_len(terra::nlyr(covariates))) {
      layer_values <- terra::values(covariates[[i]], na.rm = FALSE)
      na_count     <- sum(is.na(layer_values))
      # Subtract outside-mask NAs; remaining are genuine internal missing values
      internal_na  <- max(0L, na_count - n_outside)
      result$na_percentage[i] <- if (valid_cells > 0) (internal_na / valid_cells) * 100 else 0
      
      # Get value ranges for non-NA values
      valid_values <- layer_values[!is.na(layer_values)]
      if (length(valid_values) > 0) {
        result$value_ranges[[i]] <- c(min(valid_values), max(valid_values))
        names(result$value_ranges)[i] <- result$layer_names[i]
      }
    }
    
    # Constitutional standard: No more than 5% missing values
    max_na_allowed <- ifelse(strict_validation, 5, 10)
    layers_with_high_na <- which(result$na_percentage > max_na_allowed)
    
    if (length(layers_with_high_na) > 0) {
      layer_names_high_na <- result$layer_names[layers_with_high_na]
      na_percentages_high <- result$na_percentage[layers_with_high_na]
      
      message <- paste("Layers with >", max_na_allowed, "% missing values:",
                      paste(paste(layer_names_high_na, sprintf("(%.1f%%)", na_percentages_high)), 
                            collapse = ", "))
      
      if (strict_validation) {
        result$meets_standards <- FALSE
        result$issues <- c(result$issues, message)
      } else {
        result$warnings <- c(result$warnings, message)
      }
    }
    
    # Check for layers with no variation
    for (i in seq_len(length(result$value_ranges))) {
      if (length(result$value_ranges[[i]]) == 2 && 
          diff(result$value_ranges[[i]]) < 1e-10) {
        result$warnings <- c(result$warnings,
          paste("Layer", names(result$value_ranges)[i], "has no variation (constant values)"))
      }
    }
    
  }, error = function(e) {
    result$meets_standards <- FALSE
    result$issues <- c(result$issues, paste("Error validating data quality:", e$message))
  })
  
  return(result)
}

#' Validate constitutional spatial standards compliance
#' 
#' @param validation_result Complete validation result object
#' @return Logical indicating constitutional compliance
validate_constitutional_spatial_standards <- function(validation_result) {
  constitutional_requirements <- c(
    "CRS consistency maintained" = validation_result$crs_info$is_consistent,
    "Geometry integrity validated" = validation_result$geometry_info$boundary$is_valid &&
                                   validation_result$geometry_info$covariates$is_valid,
    "Data quality standards met" = validation_result$data_quality$meets_standards,
    "Modern packages compliance" = TRUE  # Enforced by using terra/sf
  )
  
  compliance_status <- all(constitutional_requirements, na.rm = TRUE)
  
  if (!compliance_status) {
    failed_requirements <- names(constitutional_requirements)[!constitutional_requirements]
    warning("Constitutional spatial standards violations detected: ",
            paste(failed_requirements, collapse = ", "))
  }
  
  return(compliance_status)
}

#' Validate sampling locations against field data
#' 
#' @description
#' Validates that sampling locations fall within the field boundary and
#' have valid coordinates according to constitutional standards.
#'
#' @param sampling_locations Data frame with x, y coordinates
#' @param field_data Field data list with boundary and covariates
#' @param tolerance Numeric tolerance for boundary checking in map units
#' 
#' @return List with sampling location validation results
#' 
#' @examples
#' \dontrun{
#' validation_result <- validate_sampling_locations(
#'   sampling_locations = data.frame(x = c(100, 200), y = c(150, 250)),
#'   field_data = field_data,
#'   tolerance = 1
#' )
#' }
#' 
#' @export
validate_sampling_locations <- function(sampling_locations, field_data, tolerance = 1) {
  result <- list(
    is_valid = TRUE,
    issues = character(0),
    warnings = character(0),
    n_locations = nrow(sampling_locations),
    locations_inside_boundary = NULL,
    locations_outside_boundary = NULL,
    duplicate_locations = NULL,
    constitutional_compliance = TRUE
  )
  
  # Validate required columns
  required_cols <- c("x", "y")
  missing_cols <- setdiff(required_cols, names(sampling_locations))
  
  if (length(missing_cols) > 0) {
    result$is_valid <- FALSE
    result$issues <- c(result$issues,
      paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
    return(result)
  }

  if (!is.numeric(sampling_locations$x) || !is.numeric(sampling_locations$y)) {
    result$is_valid <- FALSE
    result$issues <- c(result$issues, "Coordinates x and y must be numeric")
    return(result)
  }
  
  # Check for valid coordinates
  invalid_coords <- is.na(sampling_locations$x) | is.na(sampling_locations$y) |
                   !is.finite(sampling_locations$x) | !is.finite(sampling_locations$y)
  
  if (any(invalid_coords)) {
    result$issues <- c(result$issues,
      paste("Invalid coordinates found in", sum(invalid_coords), "locations"))
  }
  
  # Convert to sf points for spatial operations
  tryCatch({
    boundary_crs <- sf::st_crs(field_data$boundary)$input
    points_sf <- sf::st_as_sf(
      sampling_locations[!invalid_coords, ], 
      coords = c("x", "y"), 
      crs = boundary_crs
    )
    
    # Check which points are inside boundary (with tolerance buffer if specified)
    if (tolerance > 0) {
      boundary_buffered <- sf::st_buffer(field_data$boundary, tolerance)
      inside_boundary <- sf::st_within(points_sf, boundary_buffered, sparse = FALSE)
    } else {
      inside_boundary <- sf::st_within(points_sf, field_data$boundary, sparse = FALSE)
    }
    
    result$locations_inside_boundary <- sum(inside_boundary)
    result$locations_outside_boundary <- sum(!inside_boundary)
    
    if (result$locations_outside_boundary > 0) {
      result$warnings <- c(result$warnings,
        paste(result$locations_outside_boundary, "locations fall outside field boundary"))
    }
    
  }, error = function(e) {
    result$is_valid <- FALSE
    result$issues <- c(result$issues, paste("Error checking boundary containment:", e$message))
  })
  
  # Check for duplicate locations
  coord_pairs <- paste(sampling_locations$x, sampling_locations$y)
  duplicated_coords <- duplicated(coord_pairs)
  result$duplicate_locations <- sum(duplicated_coords)
  
  if (result$duplicate_locations > 0) {
    result$warnings <- c(result$warnings,
      paste(result$duplicate_locations, "duplicate coordinate pairs found"))
  }
  
  # Constitutional compliance check
  result$constitutional_compliance <- result$is_valid && 
                                     (result$locations_outside_boundary == 0) &&
                                     (result$duplicate_locations == 0)
  
  return(result)
}

#' Validate data for ML modeling
#' 
#' @description
#' Validates that training data is suitable for ML algorithms.
#' Checks for target variable existence, feature alignment with covariates,
#' and data quality issues.
#'
#' @param data Training data frame or sf object
#' @param target_col Name of target variable column
#' @param field_data Optional FieldData object to validate feature alignment
#' 
#' @return List with ML validation results
#' @export
validate_ml_data <- function(data, target_col, field_data = NULL) {
  result <- list(
    is_valid = TRUE,
    issues = character(0),
    warnings = character(0),
    n_samples = 0,
    has_target = FALSE,
    feature_alignment = TRUE,
    crs_compatible = TRUE
  )
  
  # Check data existence
  if (is.null(data) || nrow(data) == 0) {
    result$is_valid <- FALSE
    result$issues <- c(result$issues, "Training data is empty or NULL")
    return(result)
  }
  
  result$n_samples <- nrow(data)
  
  # Check target column
  if (!target_col %in% names(data)) {
    result$is_valid <- FALSE
    result$issues <- c(result$issues, paste("Target column", target_col, "not found in data"))
  } else {
    result$has_target <- TRUE
    
    # Check for NA in target
    na_targets <- sum(is.na(data[[target_col]]))
    if (na_targets > 0) {
      result$warnings <- c(result$warnings, 
        paste(na_targets, "samples have NA target values (will be dropped)"))
    }
    
    # Check variance
    if (length(unique(na.omit(data[[target_col]]))) < 2) {
      result$warnings <- c(result$warnings, 
        paste("Target column", target_col, "has zero variance (constant value)"))
    }
  }
  
  # Validate feature alignment if field_data provided
  if (!is.null(field_data) && !is.null(field_data$covariates)) {
    covariate_names <- names(field_data$covariates)
    
    missing_features <- setdiff(covariate_names, names(data))
    
    if (length(missing_features) > 0 && length(missing_features) < length(covariate_names)) {
      # Partial match - suspicious
      result$warnings <- c(result$warnings, 
        paste("Some covariate features missing from training data:", 
              paste(head(missing_features), collapse=", ")))
    }
  }

  if (inherits(data, "sf")) {
    data_crs <- sf::st_crs(data)
    if (is.na(data_crs)) {
      result$is_valid <- FALSE
      result$issues <- c(result$issues, "Training sf data is missing CRS")
    } else if (!is.null(field_data)) {
      ref_crs <- NULL
      if (!is.null(field_data$boundary) && inherits(field_data$boundary, "sf")) {
        ref_crs <- sf::st_crs(field_data$boundary)
      } else if (!is.null(field_data$covariates) && inherits(field_data$covariates, "SpatRaster")) {
        ref_crs <- sf::st_crs(terra::crs(field_data$covariates))
      }

      if (!is.null(ref_crs) && !(sf::st_crs(data_crs) == sf::st_crs(ref_crs))) {
        result$is_valid <- FALSE
        result$crs_compatible <- FALSE
        result$issues <- c(result$issues, "CRS mismatch between training data and field_data")
      }
    }
  }

  if (all(c("x", "y") %in% names(data))) {
    if (!is.numeric(data$x) || !is.numeric(data$y)) {
      result$is_valid <- FALSE
      result$issues <- c(result$issues, "Coordinates x and y must be numeric")
    } else {
      if (any(!is.finite(data$x) | !is.finite(data$y))) {
        result$is_valid <- FALSE
        result$issues <- c(result$issues, "Coordinates contain non-finite values")
      }
      coord_pairs <- paste(data$x, data$y)
      n_dup <- sum(duplicated(coord_pairs))
      if (n_dup > 0) {
        result$warnings <- c(result$warnings, paste(n_dup, "duplicate coordinate pairs found in training data"))
      }
    }
  }

  numeric_cols <- names(data)[vapply(data, is.numeric, logical(1))]
  if (length(numeric_cols) > 0) {
    for (col in numeric_cols) {
      non_finite <- sum(!is.finite(data[[col]]) & !is.na(data[[col]]))
      if (non_finite > 0) {
        result$is_valid <- FALSE
        result$issues <- c(result$issues, paste("Non-finite values found in numeric column:", col))
      }
      na_rate <- mean(is.na(data[[col]]))
      if (is.finite(na_rate) && na_rate > 0.5) {
        result$warnings <- c(result$warnings, paste("High missing rate in numeric column:", col))
      }
    }
  }
  
  return(result)
}
