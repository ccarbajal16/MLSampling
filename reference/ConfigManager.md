# ConfigManager

Manages global configuration settings, logging, and constitutional
compliance for the soil sampling optimization interface. Provides
consistent parameter management and validation according to
constitutional standards.

## Details

The ConfigManager ensures that all configuration settings meet
constitutional requirements for code quality excellence and user
experience consistency. It provides centralized logging, parameter
validation, and system monitoring.

## Public fields

- `config`:

  List containing all configuration parameters

- `log_level`:

  Character indicating current logging level

- `session_info`:

  List with session and system information Initialize configuration
  manager

## Methods

### Public methods

- [`ConfigManager$new()`](#method-ConfigManager-new)

- [`ConfigManager$update_config()`](#method-ConfigManager-update_config)

- [`ConfigManager$get()`](#method-ConfigManager-get)

- [`ConfigManager$set()`](#method-ConfigManager-set)

- [`ConfigManager$log()`](#method-ConfigManager-log)

- [`ConfigManager$get_system_resources()`](#method-ConfigManager-get_system_resources)

- [`ConfigManager$check_constitutional_compliance()`](#method-ConfigManager-check_constitutional_compliance)

- [`ConfigManager$get_log_history()`](#method-ConfigManager-get_log_history)

- [`ConfigManager$export_config()`](#method-ConfigManager-export_config)

- [`ConfigManager$import_config()`](#method-ConfigManager-import_config)

- [`ConfigManager$clone()`](#method-ConfigManager-clone)

------------------------------------------------------------------------

### Method `new()`

#### Usage

    ConfigManager$new(config_list = NULL, validate_config = TRUE)

#### Arguments

- `config_list`:

  Named list with configuration parameters

- `validate_config`:

  Logical, if TRUE validates against constitutional standards

#### Examples

    \dontrun{
    config <- ConfigManager$new(list(
      log_level = "INFO",
      parallel_cores = 2,
      memory_limit = "2GB"
    ))
    }

------------------------------------------------------------------------

### Method `update_config()`

#### Usage

    ConfigManager$update_config(new_config, validate = TRUE)

#### Arguments

- `new_config`:

  Named list with new configuration values

- `validate`:

  Logical, if TRUE validates changes Get configuration parameter

------------------------------------------------------------------------

### Method [`get()`](https://rdrr.io/r/base/get.html)

#### Usage

    ConfigManager$get(key, default = NULL)

#### Arguments

- `key`:

  Character key for configuration parameter

- `default`:

  Default value if key not found

#### Returns

Configuration value or default Set configuration parameter

------------------------------------------------------------------------

### Method `set()`

#### Usage

    ConfigManager$set(key, value, validate = TRUE)

#### Arguments

- `key`:

  Character key for configuration parameter

- `value`:

  Value to set

- `validate`:

  Logical, if TRUE validates the change Log message with timestamp and
  level

------------------------------------------------------------------------

### Method [`log()`](https://rdrr.io/r/base/Log.html)

#### Usage

    ConfigManager$log(level, message, ...)

#### Arguments

- `level`:

  Character log level (DEBUG, INFO, WARNING, ERROR)

- `message`:

  Character message to log

- `...`:

  Additional arguments passed to sprintf Get system resource information

------------------------------------------------------------------------

### Method `get_system_resources()`

#### Usage

    ConfigManager$get_system_resources()

#### Returns

List with current system resource usage Check constitutional compliance
of current configuration

------------------------------------------------------------------------

### Method `check_constitutional_compliance()`

#### Usage

    ConfigManager$check_constitutional_compliance()

#### Returns

List with compliance status and recommendations Get log history

------------------------------------------------------------------------

### Method `get_log_history()`

#### Usage

    ConfigManager$get_log_history(n_entries = 50)

#### Arguments

- `n_entries`:

  Number of recent entries to return

#### Returns

Character vector with recent log entries Export configuration to file

------------------------------------------------------------------------

### Method `export_config()`

#### Usage

    ConfigManager$export_config(file_path, format = "json")

#### Arguments

- `file_path`:

  Character path for configuration file

- `format`:

  Character format ("json" or "yaml") Import configuration from file

------------------------------------------------------------------------

### Method `import_config()`

#### Usage

    ConfigManager$import_config(file_path, format = "json")

#### Arguments

- `file_path`:

  Character path to configuration file

- `format`:

  Character format ("json" or "yaml")

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    ConfigManager$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r

## ------------------------------------------------
## Method `ConfigManager$new`
## ------------------------------------------------

if (FALSE) { # \dontrun{
config <- ConfigManager$new(list(
  log_level = "INFO",
  parallel_cores = 2,
  memory_limit = "2GB"
))
} # }
```
