# Quick Start: Using Your Own Field Data
# Example using the data already in your workspace

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
# USING YOUR EXISTING DATA IN THE WORKSPACE
# ================================================================

quick_analysis_with_existing_data <- function() {
  
  cat("🌾 Quick analysis with your existing data...\n")
  
  # Step 1: Load your raster data from the 'data' folder
  data_path <- "data"
  
  # Check what raster files you have
  raster_files <- list.files(data_path, pattern = "\\.tif$", full.names = TRUE)
  cat("Found raster files:\n")
  print(basename(raster_files))
  
  if (length(raster_files) == 0) {
    stop("No .tif files found in data/ folder")
  }
  
  # Load your raster stack
  field_data <- terra::rast(raster_files)
  names(field_data) <- tools::file_path_sans_ext(basename(raster_files))
  
  # Set CRS if missing
  if (is.na(terra::crs(field_data))) {
    terra::crs(field_data) <- "EPSG:32633"  # Adjust to your area
    cat("Set default CRS to UTM Zone 33N\n")
  }
  
  cat("✅ Loaded field data with", terra::nlyr(field_data), "layers:\n")
  print(names(field_data))
  
  # Step 2: Load your existing samples
  sample_files <- c("field_data.csv", "sample_locations.csv")
  existing_samples <- NULL
  
  for (file in sample_files) {
    if (file.exists(file)) {
      cat("Loading existing samples from:", file, "\n")
      existing_samples <- read.csv(file)
      
      # Ensure x, y columns exist
      if ("X" %in% names(existing_samples)) names(existing_samples)[names(existing_samples) == "X"] <- "x"
      if ("Y" %in% names(existing_samples)) names(existing_samples)[names(existing_samples) == "Y"] <- "y"
      if ("longitude" %in% names(existing_samples)) names(existing_samples)[names(existing_samples) == "longitude"] <- "x"
      if ("latitude" %in% names(existing_samples)) names(existing_samples)[names(existing_samples) == "latitude"] <- "y"
      
      if (all(c("x", "y") %in% names(existing_samples))) {
        break
      }
    }
  }
  
  if (is.null(existing_samples)) {
    cat("No existing samples found. Generating some example locations...\n")
    # Generate some random points within the field extent
    ext <- terra::ext(field_data)
    n_samples <- 10
    existing_samples <- data.frame(
      x = runif(n_samples, ext[1], ext[2]),
      y = runif(n_samples, ext[3], ext[4])
    )
  }
  
  cat("✅ Using", nrow(existing_samples), "existing sample locations\n")
  
  # Step 3: Validate data
  validation_result <- validate_field_data_structure(field_data, strict_validation = FALSE)
  if (!validation_result$is_valid) {
    cat("⚠️ Some validation warnings (proceeding anyway):\n")
    for (issue in validation_result$issues) {
      cat("  -", issue, "\n")
    }
  }
  
  # Step 4: Create tool and run optimization
  tool <- create_soil_sampling_tool(
    config = list(
      log_level = "INFO",
      progress_feedback = TRUE
    )
  )
  
  # Run UDL optimization
  cat("\n🚀 Running UDL optimization...\n")
  udl_result <- tool$run_udl(
    field_data = field_data,
    existing_samples = existing_samples,
    n_new_samples = 15,
    optimization_method = "genetic",
    max_iter = 50,  # Reduced for quick test
    save_csv = TRUE
  )
  
  # Run UFN optimization (if torch available)
  if (torch::torch_is_installed()) {
    cat("\n🚀 Running UFN optimization...\n")
    ufn_result <- tool$run_ufn(
      field_data = field_data,
      existing_samples = existing_samples,
      n_new_samples = 15,
      save_csv = TRUE
    )
  } else {
    cat("\n⚠️ Torch not available, skipping UFN\n")
    ufn_result <- NULL
  }
  
  # Step 5: Display results
  cat("\n📊 Results Summary:\n")
  cat("UDL Optimization:\n")
  print(udl_result$metrics)
  
  if (!is.null(ufn_result)) {
    cat("\nUFN Optimization:\n")
    print(ufn_result$metrics)
  }
  
  # Step 6: Save results
  write.csv(udl_result$new_locations, "udl_optimized_locations.csv", row.names = FALSE)
  cat("\n💾 UDL results saved to: udl_optimized_locations.csv\n")
  
  if (!is.null(ufn_result)) {
    write.csv(ufn_result$new_locations, "ufn_optimized_locations.csv", row.names = FALSE)
    cat("💾 UFN results saved to: ufn_optimized_locations.csv\n")
  }
  
  # Step 7: Create visualization
  cat("\n📈 Creating visualization...\n")
  
  # Simple visualization using base R (works without additional packages)
  png("sampling_locations_plot.png", width = 800, height = 600)
  
  # Get field extent for plotting
  ext <- terra::ext(field_data)
  
  # Plot field boundary
  plot(c(ext[1], ext[2]), c(ext[3], ext[4]), type = "n",
       xlab = "X Coordinate", ylab = "Y Coordinate",
       main = "Optimized Sampling Locations")
  
  # Add existing samples
  points(existing_samples$x, existing_samples$y, 
         col = "red", pch = 16, cex = 1.2)
  
  # Add new UDL locations
  points(udl_result$new_locations$x, udl_result$new_locations$y,
         col = "blue", pch = 17, cex = 1.2)
  
  # Add new UFN locations if available
  if (!is.null(ufn_result)) {
    points(ufn_result$new_locations$x, ufn_result$new_locations$y,
           col = "green", pch = 18, cex = 1.2)
  }
  
  # Add legend
  legend_items <- c("Existing Samples", "UDL New Locations")
  legend_colors <- c("red", "blue")
  legend_pch <- c(16, 17)
  
  if (!is.null(ufn_result)) {
    legend_items <- c(legend_items, "UFN New Locations")
    legend_colors <- c(legend_colors, "green")
    legend_pch <- c(legend_pch, 18)
  }
  
  legend("topright", legend = legend_items, 
         col = legend_colors, pch = legend_pch)
  
  dev.off()
  cat("📈 Plot saved to: sampling_locations_plot.png\n")
  
  cat("\n✅ Analysis complete!\n")
  cat("Check the generated CSV files and PNG plot for results.\n")
  
  return(list(
    field_data = field_data,
    existing_samples = existing_samples,
    udl_result = udl_result,
    ufn_result = ufn_result
  ))
}

# Run the quick analysis
if (interactive()) {
  cat("To run quick analysis with your data, execute:\n")
  cat("results <- quick_analysis_with_existing_data()\n")
} else {
  cat("Quick analysis function loaded. Use quick_analysis_with_existing_data()\n")
}