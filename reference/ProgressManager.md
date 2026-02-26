# ProgressManager

Manages progress reporting for long-running operations in MLSampling.
Provides a consistent interface for progress bars and status updates.

## Details

The ProgressManager ensures:

- Consistent user experience (Constitutional requirement)

- Graceful fallback when not in interactive mode

- Integration with logging system

## Public fields

- `config_manager`:

  Configuration manager instance

- `active_bar`:

  Current active progress bar Initialize Progress Manager

## Methods

### Public methods

- [`ProgressManager$new()`](#method-ProgressManager-new)

- [`ProgressManager$start_progress()`](#method-ProgressManager-start_progress)

- [`ProgressManager$update_progress()`](#method-ProgressManager-update_progress)

- [`ProgressManager$finish_progress()`](#method-ProgressManager-finish_progress)

- [`ProgressManager$clone()`](#method-ProgressManager-clone)

------------------------------------------------------------------------

### Method `new()`

#### Usage

    ProgressManager$new(config_manager = NULL)

#### Arguments

- `config_manager`:

  Optional ConfigManager instance Start a new progress bar

------------------------------------------------------------------------

### Method `start_progress()`

#### Usage

    ProgressManager$start_progress(
      total,
      format = "  :what [:bar] :percent eta: :eta",
      show_after = 0.5
    )

#### Arguments

- `total`:

  Total number of steps

- `format`:

  Format string for progress bar

- `show_after`:

  Minimum seconds before showing progress

#### Returns

self Update progress

------------------------------------------------------------------------

### Method `update_progress()`

#### Usage

    ProgressManager$update_progress(step = NULL, status = "")

#### Arguments

- `step`:

  Current step (optional, increments by 1 if NULL)

- `status`:

  Status message

#### Returns

self Finish progress tracking

------------------------------------------------------------------------

### Method `finish_progress()`

#### Usage

    ProgressManager$finish_progress()

#### Returns

self

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    ProgressManager$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
