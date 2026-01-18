# Real Data Usage Guide for SoilSamplingTool
# This script shows how to use your own field data

# Load the main SoilSamplingTool functions
if (!exists("run_udl_enhanced")) {
  cat("Loading SoilSamplingTool from source files...\n")
  source("main.R")
}

# Load required packages
required_packages <- c("terra", "sf")
for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("Installing", pkg, "...\n")
    install.packages(pkg)
    library(pkg, character.only = TRUE)
  }
}

# ================================================================
# STEP 1: DATA PREPARATION
# ================================================================

# Your data should include:
# 1. Field covariates (raster data): elevation, NDVI, slope, etc.
# 2. Existing sampling locations (CSV/shapefile): x, y coordinates

# Example data structure:
# data/
# ├── elevation.tif       # Digital Elevation Model
# ├── ndvi.tif           # Normalized Difference Vegetation Index
# ├── slope.tif          # Slope values
# ├── clay.tif           # Soil clay content (optional)
# ├── ph.tif             # Soil pH (optional)
# └── existing_samples.csv # Your current sampling points

# ================================================================
# STEP 2: LOAD YOUR FIELD DATA
# ================================================================

load_your_field_data <- function(data_directory) {
  
  cat("Loading field data from:", data_directory, "\n")
  
  # Method 1: Load individual raster files
  raster_files <- list.files(data_directory, pattern = "\\.tif$", full.names = TRUE)
  
  if (length(raster_files) == 0) {
    stop("No .tif files found in the directory")
  }
  
  cat("Found raster files:\n")
  print(basename(raster_files))
  
  # Load and stack rasters
  field_rasters <- terra::rast(raster_files)
  
  # Set names based on file names
  names(field_rasters) <- tools::file_path_sans_ext(basename(raster_files))
  
  # Validate CRS
  if (is.na(terra::crs(field_rasters))) {
    warning("No CRS found in raster data. Setting default to UTM Zone 33N")
    terra::crs(field_rasters) <- "EPSG:32633"
  }
  
  cat("✅ Loaded", terra::nlyr(field_rasters), "raster layers\n")
  cat("CRS:", terra::crs(field_rasters), "\n")
  cat("Extent:", as.character(terra::ext(field_rasters)), "\n")
  
  return(field_rasters)
}

# ================================================================
# STEP 3: LOAD YOUR EXISTING SAMPLES
# ================================================================

load_your_existing_samples <- function(sample_file, field_data_crs) {
  
  cat("Loading existing samples from:", sample_file, "\n")
  
  # Determine file type and load accordingly
  file_ext <- tools::file_ext(sample_file)
  
  if (file_ext == "csv") {
    # Load from CSV
    samples <- read.csv(sample_file)
    
    # Check required columns
    required_cols <- c("x", "y")
    missing_cols <- setdiff(required_cols, names(samples))
    
    if (length(missing_cols) > 0) {
      # Try alternative column names
      if ("longitude" %in% names(samples) && "latitude" %in% names(samples)) {
        samples$x <- samples$longitude
        samples$y <- samples$latitude
      } else if ("X" %in% names(samples) && "Y" %in% names(samples)) {
        samples$x <- samples$X
        samples$y <- samples$Y
      } else {
        stop("CSV must contain 'x', 'y' or 'X', 'Y' or 'longitude', 'latitude' columns")
      }
    }
    
    # Convert to sf object
    samples_sf <- sf::st_as_sf(samples, coords = c("x", "y"))
    
    # Set CRS (assume geographic if not specified)
    if (is.na(sf::st_crs(samples_sf))) {
      sf::st_crs(samples_sf) <- 4326  # WGS84
    }
    
  } else if (file_ext %in% c("shp", "gpkg")) {
    # Load from shapefile or geopackage
    samples_sf <- sf::st_read(sample_file)
    
  } else {
    stop("Unsupported file format. Use CSV, SHP, or GPKG")
  }
  
  # Transform to match field data CRS
  if (!sf::st_crs(samples_sf) == sf::st_crs(field_data_crs)) {
    cat("Transforming samples CRS to match field data\n")
    samples_sf <- sf::st_transform(samples_sf, field_data_crs)
  }
  
  # Extract coordinates
  coords <- sf::st_coordinates(samples_sf)
  samples_df <- data.frame(
    x = coords[, 1],
    y = coords[, 2]
  )
  
  # Add any additional attributes
  if (ncol(samples_sf) > 1) {
    attr_data <- sf::st_drop_geometry(samples_sf)
    samples_df <- cbind(samples_df, attr_data)
  }
  
  cat("✅ Loaded", nrow(samples_df), "existing samples\n")
  
  return(samples_df)
}

# ================================================================
# STEP 4: VALIDATE YOUR DATA
# ================================================================

validate_your_data <- function(field_data, existing_samples) {
  
  cat("🔍 Validating your data...\n")
  
  # Use the built-in validation function
  validation_result <- validate_field_data_structure(
    field_data = field_data,
    strict_validation = TRUE
  )
  
  if (!validation_result$is_valid) {
    cat("❌ Data validation issues found:\n")
    for (issue in validation_result$issues) {
      cat("  -", issue, "\n")
    }
    return(FALSE)
  }
  
  # Check if samples fall within field extent
  field_extent <- terra::ext(field_data)
  samples_within <- existing_samples$x >= field_extent[1] && 
                   existing_samples$x <= field_extent[2] &&
                   existing_samples$y >= field_extent[3] && 
                   existing_samples$y <= field_extent[4]
  
  if (!all(samples_within)) {
    warning("Some existing samples fall outside field data extent")
  }
  
  cat("✅ Data validation passed\n")
  return(TRUE)
}

# ================================================================
# STEP 5: RUN OPTIMIZATION WITH YOUR DATA
# ================================================================

run_optimization_with_your_data <- function(field_data, existing_samples, 
                                           n_new_samples = 25, 
                                           method = "UDL") {
  
  cat("🚀 Running optimization with your data...\n")
  
  # Create enhanced tool
  tool <- create_soil_sampling_tool(
    config = list(
      log_level = "INFO",
      validation_strict = TRUE,
      progress_feedback = TRUE
    )
  )
  
  # Run optimization based on method
  if (method == "UDL") {
    
    result <- tool$run_udl(
      field_data = field_data,
      existing_samples = existing_samples,
      n_new_samples = n_new_samples,
      optimization_method = "genetic",
      max_iter = 100,
      save_csv = TRUE
    )
    
  } else if (method == "UFN") {
    
    result <- tool$run_ufn(
      field_data = field_data,
      existing_samples = existing_samples,
      n_new_samples = n_new_samples,
      graph_connectivity = "delaunay",
      save_csv = TRUE
    )
    
  } else if (method == "compare") {
    
    result <- tool$compare_models(
      field_data = field_data,
      existing_samples = existing_samples,
      n_new_samples = n_new_samples,
      algorithms = c("UDL", "UFN")
    )
    
  }
  
  cat("✅ Optimization completed!\n")
  return(result)
}

# ================================================================
# STEP 6: COMPLETE WORKFLOW EXAMPLE
# ================================================================

analyze_your_field <- function(data_directory, 
                              existing_samples_file,
                              n_new_samples = 25,
                              output_directory = "results") {
  
  cat("🌾 Starting analysis of your field data...\n\n")
  
  # Create output directory
  if (!dir.exists(output_directory)) {
    dir.create(output_directory, recursive = TRUE)
  }
  
  # Step 1: Load field data
  field_data <- load_your_field_data(data_directory)
  
  # Step 2: Load existing samples
  existing_samples <- load_your_existing_samples(
    existing_samples_file, 
    terra::crs(field_data)
  )
  
  # Step 3: Validate data
  if (!validate_your_data(field_data, existing_samples)) {
    stop("Data validation failed. Please check your data.")
  }
  
  # Step 4: Run optimization
  cat("\n📊 Running UDL optimization...\n")
  udl_result <- run_optimization_with_your_data(
    field_data, existing_samples, n_new_samples, "UDL"
  )
  
  cat("\n📊 Running UFN optimization...\n")
  ufn_result <- run_optimization_with_your_data(
    field_data, existing_samples, n_new_samples, "UFN"
  )
  
  cat("\n📊 Comparing models...\n")
  comparison <- run_optimization_with_your_data(
    field_data, existing_samples, n_new_samples, "compare"
  )
  
  # Step 5: Export results
  cat("\n💾 Exporting results...\n")
  
  # Save optimized coordinates
  write.csv(udl_result$new_locations, 
           file.path(output_directory, "udl_new_locations.csv"), 
           row.names = FALSE)
  
  write.csv(ufn_result$new_locations, 
           file.path(output_directory, "ufn_new_locations.csv"), 
           row.names = FALSE)
  
  # Save comparison report
  write.csv(comparison$performance_summary, 
           file.path(output_directory, "model_comparison.csv"), 
           row.names = FALSE)
  
  # Step 6: Create visualizations
  cat("\n📈 Creating visualizations...\n")
  
  # Create visualization
  visualization_data <- create_sampling_visualizations(
    field_data = field_data,
    optimization_results = list(UDL = udl_result, UFN = ufn_result),
    existing_samples = existing_samples
  )
  
  # Save plots
  ggsave(file.path(output_directory, "sampling_locations_map.png"), 
         visualization_data$spatial_plot, 
         width = 12, height = 8, dpi = 300)
  
  cat("✅ Analysis complete! Results saved to:", output_directory, "\n")
  
  return(list(
    field_data = field_data,
    existing_samples = existing_samples,
    udl_result = udl_result,
    ufn_result = ufn_result,
    comparison = comparison,
    visualizations = visualization_data
  ))
}

# ================================================================
# USAGE EXAMPLES
# ================================================================

# Example 1: Basic usage with your data
if (FALSE) {  # Set to TRUE to run
  
  # Analyze your field
  results <- analyze_your_field(
    data_directory = "C:/path/to/your/raster/data/",
    existing_samples_file = "C:/path/to/your/existing_samples.csv",
    n_new_samples = 30,
    output_directory = "my_field_results"
  )
  
  # View results
  print(results$comparison$recommendations)
  
}

# Example 2: Step-by-step approach
if (FALSE) {  # Set to TRUE to run
  
  # Load your data
  my_field <- load_your_field_data("data/")
  my_samples <- load_your_existing_samples("field_data.csv", terra::crs(my_field))
  
  # Validate
  validate_your_data(my_field, my_samples)
  
  # Create tool
  tool <- create_soil_sampling_tool()
  
  # Run single optimization
  result <- tool$run_udl(
    field_data = my_field,
    existing_samples = my_samples,
    n_new_samples = 25
  )
  
  # View results
  print(result$metrics)
  head(result$new_locations)
  
}

cat("📋 Real data usage guide loaded!\n")
cat("Use analyze_your_field() for complete workflow\n")
cat("Or follow step-by-step examples above\n")