# SpatialAnalysisEngine

Provides advanced spatial analysis capabilities including
autocorrelation detection, anisotropy analysis, and spatial
cross-validation strategies.

## Details

The SpatialAnalysisEngine class integrates with terra and sf to provide:

- Global spatial autocorrelation metrics (Moran's I, Geary's C)

- Spatial heterogeneity and non-stationarity detection

- Advanced spatial cross-validation methods (Block CV, Buffer CV)

- Spatial weight matrix generation

## Methods

### Public methods

- [`SpatialAnalysisEngine$new()`](#method-SpatialAnalysisEngine-new)

- [`SpatialAnalysisEngine$calculate_autocorrelation()`](#method-SpatialAnalysisEngine-calculate_autocorrelation)

- [`SpatialAnalysisEngine$create_spatial_folds()`](#method-SpatialAnalysisEngine-create_spatial_folds)

- [`SpatialAnalysisEngine$detect_anisotropy()`](#method-SpatialAnalysisEngine-detect_anisotropy)

- [`SpatialAnalysisEngine$clone()`](#method-SpatialAnalysisEngine-clone)

------------------------------------------------------------------------

### Method `new()`

#### Usage

    SpatialAnalysisEngine$new(config = list())

#### Arguments

- `config`:

  Optional configuration list Calculate Global Spatial Autocorrelation

------------------------------------------------------------------------

### Method `calculate_autocorrelation()`

#### Usage

    SpatialAnalysisEngine$calculate_autocorrelation(
      data,
      variable = NULL,
      method = "moran"
    )

#### Arguments

- `data`:

  Spatial data (terra SpatRaster or sf object)

- `variable`:

  Name of variable to analyze (for sf objects)

- `method`:

  "moran" or "geary"

#### Returns

Autocorrelation statistic Create Spatial Cross-Validation Folds

------------------------------------------------------------------------

### Method `create_spatial_folds()`

#### Usage

    SpatialAnalysisEngine$create_spatial_folds(
      data,
      k = 5,
      method = "block",
      buffer_dist = NULL
    )

#### Arguments

- `data`:

  sf object containing sample locations

- `k`:

  Number of folds

- `method`:

  "random", "block", or "buffer"

- `buffer_dist`:

  Distance for buffer CV (if method="buffer")

#### Returns

List of fold indices Detect Anisotropy (Basic Implementation)

------------------------------------------------------------------------

### Method `detect_anisotropy()`

#### Usage

    SpatialAnalysisEngine$detect_anisotropy(data, variable = NULL)

#### Arguments

- `data`:

  SpatRaster or sf object

- `variable`:

  Variable to analyze

#### Returns

List describing anisotropy (major axis, ratio)

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    SpatialAnalysisEngine$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
