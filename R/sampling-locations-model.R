# Sampling Locations Data Structure and Validation
# Constitutional Compliance: Code Quality Excellence and Spatial Analysis Excellence
# Standardized representation and validation of sampling point coordinates

#' Sampling Locations Model
#'
#' @description
#' Provides standardized data structure and validation for sampling point coordinates
#' following constitutional principles for spatial analysis excellence and code quality.
#'
#' @details
#' SamplingLocations ensures consistent representation of sampling points with proper
#' validation, coordinate checking, and metadata management. All locations are validated
#' for spatial integrity and constitutional compliance.

#' Create standardized sampling locations data frame
#'
#' @param coordinates Matrix or data.frame with x, y coordinates
#' @param sample_ids Character vector of unique identifiers
#' @param types Character vector of location types (existing, new, validation)
#' @param models Character vector of model attribution (UDL, UFN, manual)
#' @param field_data Field data list for boundary validation
#' @param additional_columns Named list of additional columns to include
#'
#' @return Standardized data.frame with validated sampling locations
#'
#' @examples
#' \dontrun{
#' # Create sampling locations
#' coords <- data.frame(x = c(100, 200, 300), y = c(100, 200, 300))
#' locations <- create_sampling_locations(
#'   coordinates = coords,
#'   sample_ids = c("S001", "S002", "S003"),
#'   types = c("existing", "new", "new"),
#'   models = c("manual", "UDL", "UDL"),
#'   field_data = field_data
#' )
#' }
#'
#' @export
create_sampling_locations <- function(coordinates, 
                                    sample_ids = NULL,
                                    types = "new",
                                    models = "unknown",
                                    field_data = NULL,
                                    additional_columns = NULL) {
  
  # Validate input coordinates
  coords_validation <- validate_coordinates_input(coordinates)
  if (!coords_validation$valid) {
    stop(SpatialDataError(
      message = "Invalid coordinate input",
      validation_details = coords_validation,
      suggestion = "Provide numeric coordinates as matrix or data.frame with x, y columns"
    ))
  }
  
  # Standardize coordinates to data.frame
  if (is.matrix(coordinates)) {
    coords_df <- data.frame(
      x = coordinates[, 1],
      y = coordinates[, 2]
    )
  } else {
    coords_df <- data.frame(
      x = coordinates$x,
      y = coordinates$y
    )
  }
  
  n_locations <- nrow(coords_df)
  
  # Generate sample IDs if not provided
  if (is.null(sample_ids)) {
    sample_ids <- generate_sample_ids(n_locations, types)
  }
  
  # Validate and expand vectors to match coordinate count
  sample_ids <- validate_and_expand_vector(sample_ids, n_locations, "sample_ids")
  types <- validate_and_expand_vector(types, n_locations, "types")
  models <- validate_and_expand_vector(models, n_locations, "models")
  
  # Create base data frame
  sampling_locations <- data.frame(
    x = coords_df$x,
    y = coords_df$y,
    sample_id = sample_ids,
    type = factor(types, levels = c("existing", "new", "validation", "calibration")),
    model = factor(models),
    stringsAsFactors = FALSE
  )
  
  # Add additional columns if provided
  if (!is.null(additional_columns) && is.list(additional_columns)) {
    for (col_name in names(additional_columns)) {
      col_values <- validate_and_expand_vector(
        additional_columns[[col_name]], 
        n_locations, 
        col_name
      )
      sampling_locations[[col_name]] <- col_values
    }
  }
  
  # Validate against field boundary if provided
  if (!is.null(field_data)) {
    boundary_validation <- validate_locations_in_boundary(sampling_locations, field_data)
    if (!boundary_validation$all_inside) {
      warning(SpatialDataError(
        message = paste(boundary_validation$n_outside, "locations outside field boundary"),
        validation_details = boundary_validation,
        suggestion = "Check coordinate reference system and boundary definition"
      ))
    }
    
    # Add boundary validation results
    sampling_locations$inside_boundary <- boundary_validation$inside_flags
  }
  
  # Add metadata
  attr(sampling_locations, "creation_timestamp") <- Sys.time()
  attr(sampling_locations, "n_locations") <- n_locations
  attr(sampling_locations, "constitutional_compliance") <- TRUE
  attr(sampling_locations, "validation_log") <- list(
    coordinates_valid = TRUE,
    ids_unique = length(unique(sample_ids)) == length(sample_ids),
    types_valid = all(types %in% c("existing", "new", "validation", "calibration")),
    boundary_checked = !is.null(field_data)
  )
  
  # Set class for method dispatch
  class(sampling_locations) <- c("SamplingLocations", "data.frame")
  
  return(sampling_locations)
}

#' Validate sampling locations data structure
#'
#' @param sampling_locations Data frame with sampling locations
#' @param field_data Optional field data for boundary validation
#' @param strict_validation Logical for strict constitutional compliance
#'
#' @return List with validation results
#'
#' @export
validate_sampling_locations_model <- function(sampling_locations, 
                                             field_data = NULL,
                                             strict_validation = TRUE) {
  
  validation <- list(
    valid = TRUE,
    issues = character(0),
    warnings = character(0),
    n_locations = 0,
    constitutional_compliance = TRUE
  )
  
  # Check basic structure
  if (!is.data.frame(sampling_locations)) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "Input is not a data.frame")
    return(validation)
  }
  
  validation$n_locations <- nrow(sampling_locations)
  
  # Check required columns
  required_columns <- c("x", "y", "sample_id", "type", "model")
  missing_columns <- setdiff(required_columns, names(sampling_locations))
  
  if (length(missing_columns) > 0) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, 
                          paste("Missing columns:", paste(missing_columns, collapse = ", ")))
    return(validation)
  }
  
  # Validate coordinates
  coord_validation <- validate_numeric_coordinates(sampling_locations)
  if (!coord_validation$valid) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, coord_validation$issues)
  }
  
  # Validate sample IDs
  id_validation <- validate_sample_ids(sampling_locations$sample_id)
  if (!id_validation$valid) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, id_validation$issues)
  }
  
  # Validate types
  type_validation <- validate_location_types(sampling_locations$type)
  if (!type_validation$valid) {
    if (strict_validation) {
      validation$valid <- FALSE
      validation$issues <- c(validation$issues, type_validation$issues)
    } else {
      validation$warnings <- c(validation$warnings, type_validation$issues)
    }
  }
  
  # Check for duplicate coordinates
  duplicate_validation <- check_duplicate_coordinates(sampling_locations)
  if (duplicate_validation$has_duplicates) {
    if (strict_validation) {
      validation$valid <- FALSE
      validation$issues <- c(validation$issues, 
                            paste("Duplicate coordinates detected:", 
                                  duplicate_validation$n_duplicates, "pairs"))
    } else {
      validation$warnings <- c(validation$warnings, "Duplicate coordinates detected")
    }
  }
  
  # Boundary validation if field data provided
  if (!is.null(field_data)) {
    boundary_validation <- validate_locations_in_boundary(sampling_locations, field_data)
    if (!boundary_validation$all_inside) {
      validation$warnings <- c(validation$warnings,
                              paste(boundary_validation$n_outside, 
                                    "locations outside boundary"))
    }
    validation$boundary_validation <- boundary_validation
  }
  
  return(validation)
}

#' Generate automatic sample IDs
#' @param n_locations Number of locations
#' @param types Vector of location types
#' @return Character vector of sample IDs
generate_sample_ids <- function(n_locations, types) {
  if (length(types) == 1) {
    types <- rep(types, n_locations)
  }
  
  # Create prefixes based on type
  prefixes <- ifelse(types == "existing", "EX", 
                    ifelse(types == "new", "NW",
                          ifelse(types == "validation", "VL", "UN")))
  
  # Generate sequential numbers
  sample_ids <- paste0(prefixes, sprintf("%03d", seq_len(n_locations)))
  
  return(sample_ids)
}

#' Validate coordinate input format
#' @param coordinates Input coordinates (matrix or data.frame)
#' @return List with validation results
validate_coordinates_input <- function(coordinates) {
  validation <- list(
    valid = TRUE,
    issues = character(0),
    n_locations = 0
  )
  
  if (is.null(coordinates)) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "Coordinates cannot be NULL")
    return(validation)
  }
  
  if (is.matrix(coordinates)) {
    if (ncol(coordinates) < 2) {
      validation$valid <- FALSE
      validation$issues <- c(validation$issues, "Matrix must have at least 2 columns (x, y)")
    } else {
      validation$n_locations <- nrow(coordinates)
    }
  } else if (is.data.frame(coordinates)) {
    if (!"x" %in% names(coordinates) || !"y" %in% names(coordinates)) {
      validation$valid <- FALSE
      validation$issues <- c(validation$issues, "Data.frame must contain 'x' and 'y' columns")
    } else {
      validation$n_locations <- nrow(coordinates)
    }
  } else {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "Coordinates must be matrix or data.frame")
  }
  
  return(validation)
}

#' Validate numeric coordinates
#' @param sampling_locations Data frame with sampling locations
#' @return List with validation results
validate_numeric_coordinates <- function(sampling_locations) {
  validation <- list(
    valid = TRUE,
    issues = character(0)
  )
  
  # Check if x and y are numeric
  if (!is.numeric(sampling_locations$x)) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "x coordinates must be numeric")
  }
  
  if (!is.numeric(sampling_locations$y)) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "y coordinates must be numeric")
  }
  
  # Check for missing values
  if (any(is.na(sampling_locations$x))) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "x coordinates contain NA values")
  }
  
  if (any(is.na(sampling_locations$y))) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "y coordinates contain NA values")
  }
  
  # Check for infinite values
  if (any(is.infinite(sampling_locations$x))) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "x coordinates contain infinite values")
  }
  
  if (any(is.infinite(sampling_locations$y))) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "y coordinates contain infinite values")
  }
  
  return(validation)
}

#' Validate sample IDs
#' @param sample_ids Character vector of sample IDs
#' @return List with validation results
validate_sample_ids <- function(sample_ids) {
  validation <- list(
    valid = TRUE,
    issues = character(0)
  )
  
  # Check uniqueness
  if (length(unique(sample_ids)) != length(sample_ids)) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "Sample IDs must be unique")
  }
  
  # Check for missing values
  if (any(is.na(sample_ids))) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "Sample IDs cannot be NA")
  }
  
  # Check for empty strings
  if (any(nchar(as.character(sample_ids)) == 0)) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues, "Sample IDs cannot be empty strings")
  }
  
  return(validation)
}

#' Validate location types
#' @param types Character vector of location types
#' @return List with validation results
validate_location_types <- function(types) {
  validation <- list(
    valid = TRUE,
    issues = character(0)
  )
  
  valid_types <- c("existing", "new", "validation", "calibration")
  invalid_types <- setdiff(unique(types), valid_types)
  
  if (length(invalid_types) > 0) {
    validation$valid <- FALSE
    validation$issues <- c(validation$issues,
                          paste("Invalid types:", paste(invalid_types, collapse = ", "),
                                "Valid types:", paste(valid_types, collapse = ", ")))
  }
  
  return(validation)
}

#' Check for duplicate coordinates
#' @param sampling_locations Data frame with sampling locations
#' @param tolerance Numeric tolerance for coordinate comparison
#' @return List with duplicate checking results
check_duplicate_coordinates <- function(sampling_locations, tolerance = 1e-6) {
  coords <- data.frame(
    x = sampling_locations$x,
    y = sampling_locations$y
  )
  
  # Calculate pairwise distances
  distances <- as.matrix(dist(coords))
  diag(distances) <- Inf  # Ignore self-distances
  
  # Find duplicates within tolerance
  duplicates <- which(distances < tolerance, arr.ind = TRUE)
  
  list(
    has_duplicates = nrow(duplicates) > 0,
    n_duplicates = nrow(duplicates),
    duplicate_pairs = duplicates
  )
}

#' Validate locations are within field boundary
#' @param sampling_locations Data frame with sampling locations
#' @param field_data Field data list with boundary
#' @return List with boundary validation results
validate_locations_in_boundary <- function(sampling_locations, field_data) {
  if (!"boundary" %in% names(field_data)) {
    return(list(
      all_inside = FALSE,
      n_outside = nrow(sampling_locations),
      inside_flags = rep(FALSE, nrow(sampling_locations)),
      error = "No boundary in field_data"
    ))
  }
  
  # Create sf points from sampling locations
  points_sf <- sf::st_as_sf(
    sampling_locations[, c("x", "y")],
    coords = c("x", "y"),
    crs = sf::st_crs(field_data$boundary)
  )
  
  # Check which points are inside boundary
  inside_flags <- as.logical(sf::st_within(points_sf, field_data$boundary, sparse = FALSE))
  
  list(
    all_inside = all(inside_flags),
    n_outside = sum(!inside_flags),
    inside_flags = inside_flags,
    outside_indices = which(!inside_flags)
  )
}

#' Validate and expand vector to match required length
#' @param vector Input vector
#' @param target_length Required length
#' @param vector_name Name for error messages
#' @return Expanded vector
validate_and_expand_vector <- function(vector, target_length, vector_name) {
  if (length(vector) == 1) {
    return(rep(vector, target_length))
  } else if (length(vector) == target_length) {
    return(vector)
  } else {
    stop(ConfigurationError(
      message = paste(vector_name, "length does not match number of locations"),
      suggestion = paste("Provide either 1 value or", target_length, "values for", vector_name)
    ))
  }
}
