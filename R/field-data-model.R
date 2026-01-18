# Enhanced Field Data Model with ML Metadata Support
# Constitutional Compliance: Spatial Analysis Excellence
# Comprehensive field data structure validation with CRS consistency and ML enhancements

#' Enhanced Field Data Model with ML Metadata Support
#'
#' @description
#' Provides comprehensive validation for field data structures following
#' constitutional principles for spatial analysis excellence. Ensures CRS
#' consistency, geometry integrity, and data quality standards. Enhanced with
#' ML-specific metadata support for feature importance, uncertainty maps, and
#' spatial weights.
#'
#' @param field_data List containing boundary, covariates, and metadata
#' @param strict_validation Logical, apply strict constitutional standards
#'
#' @return Validated field data list with standardized structure and ML metadata
#'
#' @examples
#' \dontrun{
#' # Create enhanced field data with ML metadata
#' field_data <- list(
#'   boundary = sf::st_read("boundary.shp"),
#'   covariates = terra::rast("covariates.tif"),
#'   crs = "EPSG:32633",
#'   ml_metadata = list(
#'     feature_importance = c(0.3, 0.2, 0.5),
#'     uncertainty_maps = terra::rast("uncertainty.tif"),
#'     spatial_weights = matrix(c(1, 0.5, 0.5, 1), nrow = 2)
#'   )
#' )
#' 
#' # Validate and standardize
#' validated_data <- validate_field_data_structure(field_data)
#' }
#'
#' @export
validate_field_data_structure <- function(field_data, strict_validation = TRUE) {
  
  # Initialize validation tracking
  validation_log <- list(
    timestamp = Sys.time(),
    strict_mode = strict_validation,
    issues = character(0),
    warnings = character(0),
    fixes_applied = character(0)
  )
  
  # Required fields for constitutional compliance (enhanced with ML support)
  required_fields <- c("boundary", "covariates", "crs", "resolution", "extent")
  optional_ml_fields <- c("ml_metadata", "feature_importance", "uncertainty_maps", "spatial_weights")
  
  # Check required structure
  missing_fields <- setdiff(required_fields, names(field_data))
  if (length(missing_fields) > 0) {
    stop(SpatialDataError(
      message = paste("Missing required fields:", 
                     paste(missing_fields, collapse = ", ")),
      validation_details = list(missing = missing_fields),
      suggestion = paste("Provide all required fields: boundary (sf),", 
                        "covariates (SpatRaster), crs, resolution, extent")
    ))
  }
  
  if ("boundary" %in% names(field_data) && inherits(field_data$boundary, "sfc") && !inherits(field_data$boundary, "sf")) {
    field_data$boundary <- sf::st_sf(geometry = field_data$boundary)
  }

  # Validate ML metadata if present
  if ("ml_metadata" %in% names(field_data)) {
    ml_validation <- validate_ml_metadata(field_data$ml_metadata, field_data)
    if (!ml_validation$valid) {
      if (strict_validation) {
        stop(SpatialDataError(
          message = "Invalid ML metadata structure",
          validation_details = ml_validation,
          suggestion = "Ensure ML metadata contains valid feature importance, uncertainty maps, or spatial weights"
        ))
      } else {
        validation_log$warnings <- c(validation_log$warnings, 
                                   "ML metadata validation issues detected")
      }
    }
  }
  
  # Validate boundary (sf object)
  boundary_validation <- validate_field_boundary_geometry(field_data$boundary, strict_validation)
  if (!boundary_validation$valid) {
    stop(SpatialDataError(
      message = "Invalid boundary geometry",
      validation_details = boundary_validation,
      suggestion = "Ensure boundary is valid sf polygon with defined CRS"
    ))
  }
  
  # Validate covariates (SpatRaster)
  covariate_validation <- validate_covariate_rasters(field_data$covariates, strict_validation)
  if (!covariate_validation$valid) {
    stop(SpatialDataError(
      message = "Invalid covariate rasters",
      validation_details = covariate_validation,
      suggestion = "Ensure covariates are valid SpatRaster with consistent CRS and extent"
    ))
  }
  
  # Validate CRS consistency
  crs_validation <- validate_field_crs_consistency(field_data, strict_validation)
  if (!crs_validation$consistent) {
    if (strict_validation) {
      stop(SpatialDataError(
        message = "CRS inconsistency detected",
        validation_details = crs_validation,
        suggestion = "Reproject all spatial objects to consistent CRS"
      ))
    } else {
      validation_log$warnings <- c(validation_log$warnings, "CRS inconsistency - attempting automatic fix")
      field_data <- harmonize_crs(field_data)
      validation_log$fixes_applied <- c(validation_log$fixes_applied, "CRS harmonization")
    }
  }
  
  # Validate spatial alignment
  alignment_validation <- validate_spatial_alignment(field_data$boundary, field_data$covariates)
  if (!alignment_validation$aligned) {
    validation_log$warnings <- c(validation_log$warnings, "Spatial misalignment detected")
    if (!strict_validation) {
      field_data <- align_spatial_data(field_data)
      validation_log$fixes_applied <- c(validation_log$fixes_applied, "Spatial alignment correction")
    }
  }
  
  # Standardize field data structure with ML enhancements
  standardized_data <- standardize_field_data_structure(field_data)
  standardized_data$validation_log <- validation_log
  
  return(standardized_data)
}

#' Validate boundary geometry
#' @param boundary sf object with field boundary
#' @param strict_validation Logical for strict validation mode
#' @return List with validation results
validate_field_boundary_geometry <- function(boundary, strict_validation = TRUE) {
  validation <- list(
    valid = TRUE,
    issues = character(0),
    geometry_type = NULL,
    area = NULL,
    crs_defined = FALSE
  )
  
  if (inherits(boundary, "sfc") && !inherits(boundary, "sf")) {
    boundary <- sf::st_sf(geometry = boundary)
  }

  if (!inherits(boundary, "sf")) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "Boundary is not sf object")
    return(validation)
  }
  
  # Check CRS definition
  crs_info <- sf::st_crs(boundary)
  validation$crs_defined <- !is.na(crs_info$input)
  
  if (!validation$crs_defined) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "CRS not defined")
  }
  
  # Check geometry type
  geom_types <- sf::st_geometry_type(boundary)
  validation$geometry_type <- unique(as.character(geom_types))
  
  if (!all(validation$geometry_type %in% c("POLYGON", "MULTIPOLYGON"))) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "Boundary must be POLYGON or MULTIPOLYGON")
  }
  
  # Check validity
  if (validation$valid) {
    valid_geom <- sf::st_is_valid(boundary)
    if (!all(valid_geom)) {
      validation$valid <- FALSE
      validation$issues <- c(validation$issues, "Invalid geometry detected")
    }
  }
  
  # Calculate area
  if (validation$valid && validation$crs_defined) {
    validation$area <- as.numeric(sf::st_area(boundary))
    
    if (strict_validation && validation$area < 1e-6) {
      validation$valid <- FALSE
      validation$issues <- c(validation$issues, "Boundary area too small")
    }
  }
  
  return(validation)
}

#' Validate covariate rasters
#' @param covariates SpatRaster object
#' @param strict_validation Logical for strict validation mode
#' @return List with validation results
validate_covariate_rasters <- function(covariates, strict_validation = TRUE) {
  validation <- list(
    valid = TRUE,
    issues = character(0),
    n_layers = 0,
    resolution = NULL,
    extent = NULL,
    crs_defined = FALSE,
    has_na_values = FALSE
  )
  
  # Check if SpatRaster object
  if (!inherits(covariates, "SpatRaster")) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "Covariates is not SpatRaster object")
    return(validation)
  }
  
  # Basic properties
  validation$n_layers <- terra::nlyr(covariates)
  validation$resolution <- terra::res(covariates)
  validation$extent <- as.vector(terra::ext(covariates))
  
  # Check CRS definition
  crs_info <- terra::crs(covariates)
  validation$crs_defined <- !is.na(crs_info) && nchar(crs_info) > 0
  
  if (!validation$crs_defined) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "CRS not defined for covariates")
  }
  
  # Check for missing values
  if (validation$valid) {
    validation$has_na_values <- any(is.na(terra::values(covariates, na.rm = FALSE)))
    
    if (strict_validation && validation$has_na_values) {
      validation$valid <- FALSE
      validation$issues <- c(validation$issues, "NA values detected in covariates")
    }
  }
  
  # Check minimum requirements
  if (validation$n_layers < 1) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "No covariate layers found")
  }
  
  if (terra::ncell(covariates) < 4) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "Insufficient spatial resolution")
  }
  
  return(validation)
}

#' Validate CRS consistency across spatial objects
#' @param field_data List with spatial objects
#' @param strict_validation Logical for strict validation mode
#' @return List with consistency results
validate_field_crs_consistency <- function(field_data, strict_validation = TRUE) {
  consistency <- list(
    consistent = TRUE,
    reference_crs = NULL,
    crs_conflicts = character(0),
    objects_checked = character(0)
  )
  
  boundary_has <- "boundary" %in% names(field_data) && inherits(field_data$boundary, "sf")
  cov_has <- "covariates" %in% names(field_data) && inherits(field_data$covariates, "SpatRaster")

  if (boundary_has) {
    consistency$objects_checked <- c(consistency$objects_checked, "boundary")
  }
  if (cov_has) {
    consistency$objects_checked <- c(consistency$objects_checked, "covariates")
  }

  if (boundary_has) {
    consistency$reference_crs <- sf::st_crs(field_data$boundary)
  } else if (cov_has) {
    consistency$reference_crs <- terra::crs(field_data$covariates)
  }

  if (boundary_has && cov_has) {
    boundary_crs <- sf::st_crs(field_data$boundary)
    cov_crs <- sf::st_crs(terra::crs(field_data$covariates))
    if (!(sf::st_crs(boundary_crs) == sf::st_crs(cov_crs))) {
      consistency$consistent <- FALSE
      consistency$crs_conflicts <- c(consistency$crs_conflicts, "covariates")
    }
  }
  
  return(consistency)
}

harmonize_crs <- function(field_data) {
  if (!("boundary" %in% names(field_data)) || !("covariates" %in% names(field_data))) {
    return(field_data)
  }
  if (!inherits(field_data$boundary, "sf") || !inherits(field_data$covariates, "SpatRaster")) {
    return(field_data)
  }

  target_crs <- terra::crs(field_data$covariates)
  field_data$boundary <- sf::st_transform(field_data$boundary, target_crs)
  field_data$crs <- target_crs
  field_data$resolution <- terra::res(field_data$covariates)[1]
  field_data$extent <- as.vector(terra::ext(field_data$covariates))
  field_data
}

validate_spatial_alignment <- function(boundary, covariates) {
  result <- list(aligned = TRUE, issues = character(0))
  if (!inherits(boundary, "sf") || !inherits(covariates, "SpatRaster")) {
    result$aligned <- FALSE
    result$issues <- c(result$issues, "Boundary must be sf and covariates must be SpatRaster")
    return(result)
  }

  boundary_crs <- sf::st_crs(boundary)$input
  cov_crs <- terra::crs(covariates)
  boundary_aligned <- if (!is.na(boundary_crs) && !is.na(cov_crs) && boundary_crs != cov_crs) {
    sf::st_transform(boundary, cov_crs)
  } else {
    boundary
  }

  b <- sf::st_bbox(boundary_aligned)
  e <- terra::ext(covariates)

  overlap_xmin <- max(b[["xmin"]], e$xmin)
  overlap_xmax <- min(b[["xmax"]], e$xmax)
  overlap_ymin <- max(b[["ymin"]], e$ymin)
  overlap_ymax <- min(b[["ymax"]], e$ymax)

  if (overlap_xmin >= overlap_xmax || overlap_ymin >= overlap_ymax) {
    result$aligned <- FALSE
    result$issues <- c(result$issues, "No spatial overlap between boundary and covariates")
  }

  result
}

align_spatial_data <- function(field_data) {
  field_data
}

#' Standardize field data structure with ML enhancements
#' @param field_data Raw field data list
#' @return Standardized field data structure with ML metadata support
standardize_field_data_structure <- function(field_data) {
  standardized <- list(
    boundary = field_data$boundary,
    covariates = field_data$covariates,
    crs = determine_primary_crs(field_data),
    resolution = terra::res(field_data$covariates)[1],
    extent = as.vector(terra::ext(field_data$covariates)),
    metadata = list(
      n_covariate_layers = terra::nlyr(field_data$covariates),
      boundary_area = as.numeric(sf::st_area(field_data$boundary)),
      processing_timestamp = Sys.time(),
      constitutional_compliance = TRUE
    )
  )
  
  # Add ML-specific enhancements
  if ("ml_metadata" %in% names(field_data)) {
    standardized$ml_metadata <- standardize_ml_metadata(field_data$ml_metadata, 
                                                       field_data$covariates)
  } else {
    # Create empty ML metadata structure for future use
    standardized$ml_metadata <- create_empty_ml_metadata(field_data$covariates)
  }
  
  # Add individual ML components if present at top level
  if ("feature_importance" %in% names(field_data)) {
    standardized$ml_metadata$feature_importance <- field_data$feature_importance
  }
  
  if ("uncertainty_maps" %in% names(field_data)) {
    standardized$ml_metadata$uncertainty_maps <- field_data$uncertainty_maps
  }
  
  if ("spatial_weights" %in% names(field_data)) {
    standardized$ml_metadata$spatial_weights <- field_data$spatial_weights
  }
  
  # Add optional fields if present
  optional_fields <- c("quality_flags", "transformation_log")
  for (field in optional_fields) {
    if (field %in% names(field_data)) {
      standardized[[field]] <- field_data[[field]]
    }
  }
  
  return(standardized)
}

#' Validate ML metadata structure
#' @param ml_metadata ML metadata list
#' @param field_data Parent field data for validation context
#' @return List with validation results
validate_ml_metadata <- function(ml_metadata, field_data) {
  validation <- list(
    valid = TRUE,
    issues = character(0),
    warnings = character(0),
    components_validated = character(0)
  )
  
  if (!is.list(ml_metadata)) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "ML metadata must be a list")
    return(validation)
  }
  
  # Validate feature importance if present
  if ("feature_importance" %in% names(ml_metadata)) {
    fi_validation <- validate_feature_importance(ml_metadata$feature_importance, 
                                               field_data$covariates)
    if (!fi_validation$valid) {
      validation$valid <- FALSE
      validation$issues <- c(validation$issues, fi_validation$issues)
    } else {
      validation$components_validated <- c(validation$components_validated, 
                                         "feature_importance")
    }
  }
  
  # Validate uncertainty maps if present
  if ("uncertainty_maps" %in% names(ml_metadata)) {
    um_validation <- validate_uncertainty_maps(ml_metadata$uncertainty_maps, 
                                             field_data$covariates)
    if (!um_validation$valid) {
      validation$valid <- FALSE
      validation$issues <- c(validation$issues, um_validation$issues)
    } else {
      validation$components_validated <- c(validation$components_validated, 
                                         "uncertainty_maps")
    }
  }
  
  # Validate spatial weights if present
  if ("spatial_weights" %in% names(ml_metadata)) {
    sw_validation <- validate_spatial_weights(ml_metadata$spatial_weights)
    if (!sw_validation$valid) {
      validation$valid <- FALSE
      validation$issues <- c(validation$issues, sw_validation$issues)
    } else {
      validation$components_validated <- c(validation$components_validated, 
                                         "spatial_weights")
    }
  }
  
  return(validation)
}

#' Validate feature importance scores
#' @param feature_importance Numeric vector of feature importance scores
#' @param covariates SpatRaster with covariate layers
#' @return List with validation results
validate_feature_importance <- function(feature_importance, covariates) {
  validation <- list(
    valid = TRUE,
    issues = character(0)
  )
  
  if (!is.numeric(feature_importance)) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, 
                          "Feature importance must be numeric vector")
    return(validation)
  }
  
  # Check length matches number of covariate layers
  n_layers <- terra::nlyr(covariates)
  if (length(feature_importance) != n_layers) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, 
                          paste("Feature importance length (", 
                               length(feature_importance), 
                               ") does not match covariate layers (", 
                               n_layers, ")"))
  }
  
  # Check for valid range (0-1 or positive values)
  if (any(feature_importance < 0)) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, 
                          "Feature importance scores cannot be negative")
  }
  
  # Check for missing values
  if (any(is.na(feature_importance))) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, 
                          "Feature importance scores cannot contain NA values")
  }
  
  return(validation)
}

#' Validate uncertainty maps
#' @param uncertainty_maps SpatRaster with uncertainty layers
#' @param covariates Reference SpatRaster for spatial consistency
#' @return List with validation results
validate_uncertainty_maps <- function(uncertainty_maps, covariates) {
  validation <- list(
    valid = TRUE,
    issues = character(0)
  )
  
  if (!inherits(uncertainty_maps, "SpatRaster")) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, 
                          "Uncertainty maps must be SpatRaster object")
    return(validation)
  }
  
  # Check spatial consistency with covariates
  if (!terra::compareGeom(uncertainty_maps, covariates, stopOnError = FALSE)) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, 
                          "Uncertainty maps geometry does not match covariates")
  }
  
  # Check for valid uncertainty values (should be non-negative)
  uncertainty_values <- terra::values(uncertainty_maps, na.rm = TRUE)
  if (any(uncertainty_values < 0, na.rm = TRUE)) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, 
                          "Uncertainty values cannot be negative")
  }
  
  return(validation)
}

#' Validate spatial weights matrix
#' @param spatial_weights Matrix or list of spatial weights
#' @return List with validation results
validate_spatial_weights <- function(spatial_weights) {
  validation <- list(
    valid = TRUE,
    issues = character(0)
  )
  
  if (is.matrix(spatial_weights)) {
    # Validate matrix properties
    if (!is.numeric(spatial_weights)) {
      validation$valid <- FALSE
      validation$issues <- c(validation$issues, 
                            "Spatial weights matrix must be numeric")
    }
    
    # Check for square matrix (typical for spatial weights)
    if (nrow(spatial_weights) != ncol(spatial_weights)) {
      validation$issues <- c(validation$issues, 
                            "Spatial weights matrix is not square - may be intentional")
    }
    
  } else if (is.list(spatial_weights)) {
    # Validate list structure (e.g., for different weight types)
    if (!all(sapply(spatial_weights, is.matrix))) {
      validation$valid <- FALSE
      validation$issues <- c(validation$issues, 
                            "All elements in spatial weights list must be matrices")
    }
    
  } else {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, 
                          "Spatial weights must be matrix or list of matrices")
  }
  
  return(validation)
}

#' Standardize ML metadata structure
#' @param ml_metadata Raw ML metadata
#' @param covariates Reference SpatRaster for context
#' @return Standardized ML metadata list
standardize_ml_metadata <- function(ml_metadata, covariates) {
  standardized <- list(
    feature_importance = NULL,
    uncertainty_maps = NULL,
    spatial_weights = NULL,
    preprocessing_steps = list(),
    normalization_params = list(),
    feature_engineering = list(),
    spatial_statistics = list(),
    creation_timestamp = Sys.time(),
    ml_methods_applied = character(0)
  )
  
  # Copy existing components
  if ("feature_importance" %in% names(ml_metadata)) {
    standardized$feature_importance <- as.numeric(ml_metadata$feature_importance)
    names(standardized$feature_importance) <- names(covariates)
  }
  
  if ("uncertainty_maps" %in% names(ml_metadata)) {
    standardized$uncertainty_maps <- ml_metadata$uncertainty_maps
  }
  
  if ("spatial_weights" %in% names(ml_metadata)) {
    standardized$spatial_weights <- ml_metadata$spatial_weights
  }
  
  # Copy optional components
  optional_components <- c("preprocessing_steps", "normalization_params", 
                          "feature_engineering", "spatial_statistics", 
                          "ml_methods_applied")
  
  for (component in optional_components) {
    if (component %in% names(ml_metadata)) {
      standardized[[component]] <- ml_metadata[[component]]
    }
  }
  
  return(standardized)
}

#' Create empty ML metadata structure for future use
#' @param covariates Reference SpatRaster for structure
#' @return Empty ML metadata list with proper structure
create_empty_ml_metadata <- function(covariates) {
  n_layers <- terra::nlyr(covariates)
  layer_names <- names(covariates)
  
  list(
    feature_importance = rep(NA_real_, n_layers) |> setNames(layer_names),
    uncertainty_maps = NULL,
    spatial_weights = NULL,
    preprocessing_steps = list(),
    normalization_params = list(),
    feature_engineering = list(),
    spatial_statistics = list(),
    creation_timestamp = Sys.time(),
    ml_methods_applied = character(0),
    ready_for_ml = FALSE
  )
}

#' Determine primary CRS from field data
#' @param field_data Field data list
#' @return Primary CRS string
determine_primary_crs <- function(field_data) {
  if ("crs" %in% names(field_data) && !is.null(field_data$crs)) {
    return(field_data$crs)
  }
  
  if (inherits(field_data$boundary, "sf")) {
    crs_obj <- sf::st_crs(field_data$boundary)
    if (!is.na(crs_obj$input)) {
      return(crs_obj$input)
    }
  }
  
  if (inherits(field_data$covariates, "SpatRaster")) {
    crs_string <- terra::crs(field_data$covariates)
    if (!is.na(crs_string) && nchar(crs_string) > 0) {
      return(crs_string)
    }
  }
  
  return("EPSG:4326")  # Default fallback
}
