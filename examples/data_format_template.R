# Data Format Template for SoilSamplingTool
# This file shows the expected format for your data

# ================================================================
# REQUIRED DATA FORMAT
# ================================================================

# 1. RASTER DATA (Environmental Covariates)
# Put your .tif files in a folder (e.g., "data/")
# Required files (at minimum):
# - elevation.tif or dem.tif
# - At least 2-3 additional covariates like:
#   * ndvi.tif (vegetation index)
#   * slope.tif (terrain slope)
#   * clay.tif (soil texture)
#   * ph.tif (soil chemistry)

# All rasters must:
# - Have the same extent and resolution
# - Use the same coordinate reference system (CRS)
# - Be in GeoTIFF format (.tif)

# ================================================================
# 2. EXISTING SAMPLING LOCATIONS (CSV Format)
# ================================================================

# Your CSV file should have at minimum these columns:
# x, y (coordinates)
# Optional additional columns: site_id, date, soil_type, etc.

# Example CSV content:
existing_samples_template <- data.frame(
  x = c(500100, 500200, 500300, 500150, 500250),
  y = c(5000100, 5000200, 5000300, 5000150, 5000250),
  site_id = c("Site_01", "Site_02", "Site_03", "Site_04", "Site_05"),
  date_sampled = c("2023-05-01", "2023-05-02", "2023-05-03", "2023-05-04", "2023-05-05"),
  soil_type = c("Clay", "Loam", "Sand", "Clay", "Loam")
)

# Save template
write.csv(existing_samples_template, "existing_samples_template.csv", row.names = FALSE)

cat("📋 Template created: existing_samples_template.csv\n")

# ================================================================
# 3. ALTERNATIVE COLUMN NAMES SUPPORTED
# ================================================================

# The tool automatically recognizes these column name variations:
# - x, y
# - X, Y  
# - longitude, latitude
# - long, lat
# - easting, northing

# ================================================================
# 4. COORDINATE SYSTEMS
# ================================================================

# Your coordinates can be in:
# - Geographic (latitude/longitude): WGS84 (EPSG:4326)
# - Projected (meters): UTM zones (e.g., EPSG:32633 for UTM Zone 33N)
# - Local coordinate systems

# The tool will automatically transform coordinates to match your raster data

# ================================================================
# 5. DIRECTORY STRUCTURE EXAMPLE
# ================================================================

# Recommended folder structure:
# your_project/
# ├── data/
# │   ├── elevation.tif
# │   ├── ndvi.tif
# │   ├── slope.tif
# │   └── clay.tif
# ├── existing_samples.csv
# ├── run_analysis.R (your script)
# └── results/ (will be created)

# ================================================================
# 6. QUICK VALIDATION SCRIPT
# ================================================================

validate_your_data_format <- function(data_folder, samples_file) {
  
  cat("🔍 Validating your data format...\n\n")
  
  # Check raster files
  if (!dir.exists(data_folder)) {
    cat("❌ Data folder not found:", data_folder, "\n")
    return(FALSE)
  }
  
  raster_files <- list.files(data_folder, pattern = "\\.tif$", full.names = TRUE)
  
  if (length(raster_files) == 0) {
    cat("❌ No .tif files found in", data_folder, "\n")
    return(FALSE)
  }
  
  cat("✅ Found", length(raster_files), "raster files:\n")
  for (file in raster_files) {
    cat("  -", basename(file), "\n")
  }
  
  # Check samples file
  if (!file.exists(samples_file)) {
    cat("❌ Samples file not found:", samples_file, "\n")
    return(FALSE)
  }
  
  samples <- read.csv(samples_file)
  cat("✅ Samples file found with", nrow(samples), "rows\n")
  
  # Check required columns
  coord_cols <- c("x", "y")
  alt_cols <- list(
    c("X", "Y"),
    c("longitude", "latitude"),
    c("long", "lat"),
    c("easting", "northing")
  )
  
  has_coords <- any(c("x", "y") %in% names(samples))
  
  if (!has_coords) {
    for (alt in alt_cols) {
      if (all(alt %in% names(samples))) {
        has_coords <- TRUE
        cat("✅ Found coordinates as:", paste(alt, collapse = ", "), "\n")
        break
      }
    }
  } else {
    cat("✅ Found coordinates as: x, y\n")
  }
  
  if (!has_coords) {
    cat("❌ No coordinate columns found. Need x,y or longitude,latitude or similar\n")
    return(FALSE)
  }
  
  cat("✅ Data format validation passed!\n")
  return(TRUE)
}

# Example usage:
# validate_your_data_format("data", "field_data.csv")

cat("📋 Data format template and validation loaded!\n")
cat("Use validate_your_data_format('your_data_folder', 'your_samples.csv') to check your data\n")