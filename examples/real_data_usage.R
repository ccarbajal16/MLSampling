# =============================================================================
# MLSampling — Real Data Workflow: Andean Basin (Peru)
# =============================================================================
#
# Data in data/:
#   basin.gpkg      — field boundary (1 polygon, WGS 84)
#   dem_basin.tif   — Digital Elevation Model, ~68 m, WGS 84, range 3371–4732 m
#   ndvi_basin.tif  — NDVI (Sentinel-2A), ~27 m, WGS 84, range -0.64 to 0.89
#   savi_basin.tif  — SAVI (Sentinel-2A), ~27 m, WGS 84, range -0.03 to 0.69
#
# Derived covariates (computed here from DEM):
#   slope           — terrain steepness (degrees)
#   aspect          — slope face direction (degrees)
#
# Final covariate stack (5 layers at 27 m, matching paper's input structure):
#   elevation, slope, aspect, NDVI, SAVI
#
# =============================================================================

library(MLSampling)   # install with: devtools::install_github("ccarbajal16/MLSampling")
library(terra)
library(sf)

# Project root — adjust if running from a different working directory
PROJECT_ROOT <- "C:/Users/USER/OneDrive/Works/INIA-Projects/MLSampling-master"
DATA_DIR     <- file.path(PROJECT_ROOT, "data")
OUTPUT_DIR   <- file.path(PROJECT_ROOT, "results_basin")

if (!dir.exists(OUTPUT_DIR)) dir.create(OUTPUT_DIR, recursive = TRUE)


# =============================================================================
# STEP 1 — Load the field boundary
# =============================================================================

cat("\n[1/6] Loading field boundary ...\n")

boundary <- sf::st_read(file.path(DATA_DIR, "basin.gpkg"), quiet = TRUE)

cat("  CRS     :", sf::st_crs(boundary)$input, "\n")
cat("  Features:", nrow(boundary), "\n")
cat("  Name    :", boundary$nombre, "\n")
bbox <- sf::st_bbox(boundary)
cat("  BBox    : lon [", round(bbox["xmin"], 4), ",", round(bbox["xmax"], 4), "]",
                " lat [", round(bbox["ymin"], 4), ",", round(bbox["ymax"], 4), "]\n")


# =============================================================================
# STEP 2 — Load and prepare raster covariates
# =============================================================================

cat("\n[2/6] Loading and aligning raster covariates ...\n")

# --- Load raw rasters
dem  <- terra::rast(file.path(DATA_DIR, "dem_basin.tif"))
ndvi <- terra::rast(file.path(DATA_DIR, "ndvi_basin.tif"))
savi <- terra::rast(file.path(DATA_DIR, "savi_basin.tif"))

cat("  DEM  resolution:", round(terra::res(dem)[1]  * 111320, 0), "m\n")
cat("  NDVI resolution:", round(terra::res(ndvi)[1] * 111320, 0), "m\n")

# --- Derive slope and aspect from DEM
# (replaces the paper's 'flow accumulation' layer, which requires a hydrological DEM)
cat("  Deriving slope and aspect from DEM ...\n")
slope  <- terra::terrain(dem, v = "slope",  unit = "degrees")
aspect <- terra::terrain(dem, v = "aspect", unit = "degrees")

# --- Resample everything to the NDVI/SAVI reference grid (finer, ~27 m)
#     NDVI and SAVI are already aligned; DEM-derived layers need resampling.
reference <- ndvi   # template for spatial reference
elevation  <- terra::resample(dem,    reference, method = "bilinear")
slope_r    <- terra::resample(slope,  reference, method = "bilinear")
aspect_r   <- terra::resample(aspect, reference, method = "bilinear")

# --- Rename layers for clarity
names(elevation) <- "elevation"
names(slope_r)   <- "slope"
names(aspect_r)  <- "aspect"
names(ndvi)      <- "NDVI"
names(savi)      <- "SAVI"

# --- Stack into a single 5-layer SpatRaster
covariates <- c(elevation, slope_r, aspect_r, ndvi, savi)
cat("  Covariate stack:", terra::nlyr(covariates), "layers at",
    round(terra::res(covariates)[1] * 111320, 0), "m resolution\n")
cat("  Layers         :", paste(names(covariates), collapse = ", "), "\n")

# --- Mask to the basin polygon
boundary_v  <- terra::vect(boundary)    # convert sf → SpatVector for terra
covariates  <- terra::mask(
  terra::crop(covariates, boundary_v),
  boundary_v
)
cat("  Cells inside basin:", terra::global(!is.na(covariates[[1]]), sum)[[1]], "\n")


# =============================================================================
# STEP 3 — Assemble field_data (the package's input format)
# =============================================================================

cat("\n[3/6] Assembling field_data list ...\n")

field_data <- list(
  boundary   = boundary,                          # sf polygon
  covariates = covariates,                        # 5-layer masked SpatRaster
  # validate_field_data_structure() requires these three at the top level:
  crs        = sf::st_crs(boundary)$input,        # "WGS 84"
  resolution = terra::res(covariates)[1],         # cell size in degrees (~0.000274)
  extent     = as.vector(terra::ext(covariates)), # c(xmin, xmax, ymin, ymax)
  metadata   = list(
    location   = "Andean basin, Peru",
    layers     = names(covariates)
  )
)

# Validate before running any model.
# validate_field_data_structure() either stop()s on failure or returns
# the standardised field_data (with crs/resolution/extent populated).
field_data <- tryCatch(
  validate_field_data_structure(field_data, strict_validation = FALSE),
  error = function(e) {
    stop("field_data validation failed: ", conditionMessage(e))
  }
)
cat("  field_data validation passed\n")
if (length(field_data$validation_log$warnings) > 0) {
  cat("  Warnings:\n")
  for (w in field_data$validation_log$warnings) cat("    -", w, "\n")
}


# =============================================================================
# STEP 4 — Existing sample locations
# =============================================================================
#
# If you have real GPS points from previous field campaigns, load them here:
#
#   existing_samples <- read.csv("path/to/your_samples.csv")
#   # CSV must contain columns x (longitude) and y (latitude) in WGS 84
#
# For this demonstration we generate random points inside the basin.

cat("\n[4/6] Preparing existing sample locations ...\n")

N_EXISTING <- 15   # <- replace with nrow(existing_samples) when using real data

set.seed(42)
random_pts <- sf::st_sample(boundary, size = N_EXISTING, type = "random")
existing_samples <- data.frame(
  x = sf::st_coordinates(random_pts)[, 1],
  y = sf::st_coordinates(random_pts)[, 2]
)

cat("  Using", nrow(existing_samples), "existing sample locations",
    ifelse(N_EXISTING == 15, "(synthetic — replace with your GPS data)", ""), "\n")


# =============================================================================
# STEP 5 — Run sampling optimisation
# =============================================================================

cat("\n[5/6] Running ML-based sampling optimisation ...\n")

N_NEW <- 20   # number of new sample locations to select

tool <- create_ml_sampling_tool(
  config = list(log_level = "INFO", progress_feedback = TRUE)
)

# ---------------------------------------------------------------------------
# Option A: Bayesian Deep Learning (BDL)
#   - Targets locations with highest EPISTEMIC uncertainty
#   - Best when you have a limited budget and want to focus on knowledge gaps
# ---------------------------------------------------------------------------
cat("\n  --- BDL (Bayesian Deep Learning) ---\n")

t_bdl <- system.time({
  bdl_result <- tool$run_bdl(
    field_data       = field_data,
    existing_samples = existing_samples,
    n_new_samples    = N_NEW,
    uncertainty_type = "epistemic",   # or "aleatoric", "total"
    mc_iterations    = 100,
    save_csv         = FALSE
  )
})

cat("  BDL selected:", nrow(bdl_result$selected_locations), "locations\n")
cat("  Execution time:", round(t_bdl["elapsed"], 2), "s\n")

# ---------------------------------------------------------------------------
# Option B: Random Forest (RF)
#   - Maximises coverage in the feature space of the most important covariates
#   - Best when you want to know which variables drive spatial variability
# ---------------------------------------------------------------------------
cat("\n  --- RF (Random Forest) ---\n")

t_rf <- system.time({
  rf_result <- tool$run_rf_optimization(
    field_data       = field_data,
    existing_samples = existing_samples,
    n_new_samples    = N_NEW
  )
})

cat("  RF selected:", nrow(rf_result$selected_locations), "locations\n")
cat("  Execution time:", round(t_rf["elapsed"], 2), "s\n")

# ---------------------------------------------------------------------------
# Option C: UDL (Unified Deep Learning) — optimisation strategy
#   NOTE: The genetic/simulated_annealing variants are currently under
#   development (stub implementations). "greedy" is the active path.
#   See R/ml-sampling-tool.R:run_greedy_optimization for the current logic.
# ---------------------------------------------------------------------------
cat("\n  --- UDL (greedy, current implementation) ---\n")

udl_result <- tool$run_udl(
  field_data          = field_data,
  existing_samples    = existing_samples,
  n_new_samples       = N_NEW,
  optimization_method = "greedy"   # "genetic" and "simulated_annealing" are stubs
)

cat("  UDL selected:", nrow(udl_result$selected_locations), "locations\n")

# ---------------------------------------------------------------------------
# Option D: Ensemble (BDL + RF consensus)
#   - Combines both models via voting for a robust, method-agnostic design
# ---------------------------------------------------------------------------
cat("\n  --- Ensemble (BDL + RF voting) ---\n")

ensemble_result <- tool$run_ensemble(
  field_data       = field_data,
  existing_samples = existing_samples,
  n_new_samples    = N_NEW,
  methods          = c("BDL", "RF"),
  ensemble_method  = "voting"
)

cat("  Ensemble selected:", nrow(ensemble_result$selected_locations), "locations\n")


# =============================================================================
# STEP 6 — Export results
# =============================================================================

cat("\n[6/6] Exporting results to:", OUTPUT_DIR, "\n")

# --- Save coordinates as CSV (field-ready, one row per new sample point)
tool$save_coordinates_to_csv(
  bdl_result,
  file_path = file.path(OUTPUT_DIR, "bdl_new_locations.csv")
)

tool$save_coordinates_to_csv(
  rf_result,
  file_path = file.path(OUTPUT_DIR, "rf_new_locations.csv")
)

tool$save_coordinates_to_csv(
  ensemble_result,
  file_path = file.path(OUTPUT_DIR, "ensemble_new_locations.csv")
)

# --- Manual CSV export (fallback / for inspection)
write.csv(
  bdl_result$selected_locations,
  file.path(OUTPUT_DIR, "bdl_selected_locations_raw.csv"),
  row.names = FALSE
)

# --- HTML report with interactive maps and methodology notes
tool$generate_ml_report(
  bdl_result,
  output_dir = OUTPUT_DIR
)

cat("\nDone! Files written to:", OUTPUT_DIR, "\n")
cat("  bdl_new_locations.csv      — BDL sample coordinates\n")
cat("  rf_new_locations.csv       — RF sample coordinates\n")
cat("  ensemble_new_locations.csv — Ensemble sample coordinates\n")
cat("  *.html                     — Interactive HTML report\n")


# =============================================================================
# QUICK INSPECTION
# =============================================================================

cat("\n=== BDL result summary ===\n")
cat("Locations (first 5 rows):\n")
print(head(bdl_result$selected_locations, 5))

if (!is.null(bdl_result$uncertainties)) {
  cat("\nUncertainty components available:",
      paste(names(bdl_result$uncertainties), collapse = ", "), "\n")
}

if (!is.null(rf_result$feature_importance) &&
    length(rf_result$feature_importance) > 0) {
  cat("\n=== RF feature importance ===\n")
  imp <- rf_result$feature_importance
  if (is.data.frame(imp) && all(c("feature", "importance") %in% names(imp))) {
    imp_sorted <- imp[order(-imp$importance), ]
    for (i in seq_len(nrow(imp_sorted))) {
      cat(sprintf("  %-12s %.3f\n", imp_sorted$feature[i], imp_sorted$importance[i]))
    }
  } else if (is.numeric(imp) && !is.null(names(imp))) {
    imp_sorted <- sort(imp, decreasing = TRUE)
    for (nm in names(imp_sorted)) {
      cat(sprintf("  %-12s %.3f\n", nm, imp_sorted[[nm]]))
    }
  }
}

cat("\n=== Covariate stack summary ===\n")
print(covariates)
