# VisualizationService

Service for generating ML-specific visualizations including uncertainty
maps, feature importance plots, and design comparisons.

## Public fields

- `config_manager`:

  Configuration manager instance Initialize Visualization Service

## Methods

### Public methods

- [`VisualizationService$new()`](#method-VisualizationService-new)

- [`VisualizationService$plot_uncertainty_map()`](#method-VisualizationService-plot_uncertainty_map)

- [`VisualizationService$plot_feature_importance()`](#method-VisualizationService-plot_feature_importance)

- [`VisualizationService$plot_design_comparison()`](#method-VisualizationService-plot_design_comparison)

- [`VisualizationService$plot_sampling_locations()`](#method-VisualizationService-plot_sampling_locations)

- [`VisualizationService$clone()`](#method-VisualizationService-clone)

------------------------------------------------------------------------

### Method `new()`

#### Usage

    VisualizationService$new(config_manager = NULL)

#### Arguments

- `config_manager`:

  Optional ConfigManager instance Plot Uncertainty Map

------------------------------------------------------------------------

### Method `plot_uncertainty_map()`

#### Usage

    VisualizationService$plot_uncertainty_map(
      uncertainty_raster,
      field_data = NULL,
      output_path = NULL,
      title = "Uncertainty Map"
    )

#### Arguments

- `uncertainty_raster`:

  SpatRaster containing uncertainty values

- `field_data`:

  Field data object containing boundary

- `output_path`:

  Path to save the plot

- `title`:

  Plot title

#### Returns

List with success status and plot object Plot Feature Importance

------------------------------------------------------------------------

### Method `plot_feature_importance()`

#### Usage

    VisualizationService$plot_feature_importance(
      importance_scores,
      output_path = NULL,
      title = "Feature Importance"
    )

#### Arguments

- `importance_scores`:

  Named numeric vector of importance scores

- `output_path`:

  Path to save the plot

- `title`:

  Plot title

#### Returns

List with success status and plot object Plot Design Comparison

------------------------------------------------------------------------

### Method `plot_design_comparison()`

#### Usage

    VisualizationService$plot_design_comparison(
      comparison_data,
      metric = "score",
      output_path = NULL,
      title = "Design Comparison"
    )

#### Arguments

- `comparison_data`:

  Data frame with algorithm comparison results

- `metric`:

  Metric to plot (column name in comparison_data)

- `output_path`:

  Path to save the plot

- `title`:

  Plot title

#### Returns

List with success status and plot object Plot Sampling Locations

------------------------------------------------------------------------

### Method `plot_sampling_locations()`

#### Usage

    VisualizationService$plot_sampling_locations(
      locations,
      field_data = NULL,
      output_path = NULL,
      title = "Sampling Locations"
    )

#### Arguments

- `locations`:

  sf object or dataframe of locations

- `field_data`:

  Field data object containing boundary and covariates

- `output_path`:

  Path to save the plot

- `title`:

  Plot title

#### Returns

List with success status and plot object

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    VisualizationService$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
