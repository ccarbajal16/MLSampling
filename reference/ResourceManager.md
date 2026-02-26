# ResourceManager

Manages system resources, memory usage, and batch processing for
MLSampling. Ensures constitutional compliance with resource limits.

## Details

The ResourceManager provides:

- Memory usage estimation and monitoring

- Batch processing for large datasets

- Resource-aware execution strategies

## Public fields

- `config_manager`:

  Configuration manager instance

- `memory_limit_mb`:

  Memory limit in MB Initialize Resource Manager

## Methods

### Public methods

- [`ResourceManager$new()`](#method-ResourceManager-new)

- [`ResourceManager$check_memory()`](#method-ResourceManager-check_memory)

- [`ResourceManager$can_fit_in_memory()`](#method-ResourceManager-can_fit_in_memory)

- [`ResourceManager$estimate_raster_memory()`](#method-ResourceManager-estimate_raster_memory)

- [`ResourceManager$process_in_batches()`](#method-ResourceManager-process_in_batches)

- [`ResourceManager$clone()`](#method-ResourceManager-clone)

------------------------------------------------------------------------

### Method `new()`

#### Usage

    ResourceManager$new(config_manager = NULL, memory_limit_mb = 2048)

#### Arguments

- `config_manager`:

  Optional ConfigManager instance

- `memory_limit_mb`:

  Memory limit in MB (default 2048) Check current memory usage

------------------------------------------------------------------------

### Method `check_memory()`

#### Usage

    ResourceManager$check_memory()

#### Returns

Current memory usage in MB Validate if operation fits in memory

------------------------------------------------------------------------

### Method `can_fit_in_memory()`

#### Usage

    ResourceManager$can_fit_in_memory(estimated_mb)

#### Arguments

- `estimated_mb`:

  Estimated memory requirement

#### Returns

Boolean Estimate memory for raster processing

------------------------------------------------------------------------

### Method `estimate_raster_memory()`

#### Usage

    ResourceManager$estimate_raster_memory(raster)

#### Arguments

- `raster`:

  SpatRaster object

#### Returns

Estimated memory in MB Process data in batches

------------------------------------------------------------------------

### Method `process_in_batches()`

#### Usage

    ResourceManager$process_in_batches(
      data,
      batch_fn,
      batch_size = 1000,
      combine_fn = rbind,
      progress_manager = NULL
    )

#### Arguments

- `data`:

  Data to process (vector, matrix, or list)

- `batch_fn`:

  Function to apply to each batch

- `batch_size`:

  Batch size

- `combine_fn`:

  Function to combine results (default rbind)

- `progress_manager`:

  Optional ProgressManager

#### Returns

Combined results

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    ResourceManager$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
