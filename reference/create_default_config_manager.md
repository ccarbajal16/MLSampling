# Create default configuration manager instance

Convenience function to create a ConfigManager instance with
constitutional defaults. This ensures consistent configuration across
the application.

## Usage

``` r
create_default_config_manager(...)
```

## Arguments

- ...:

  Additional configuration parameters to override defaults

## Value

ConfigManager instance

## Examples

``` r
if (FALSE) { # \dontrun{
config <- create_default_config_manager(
  log_level = "DEBUG",
  parallel_cores = 2
)
} # }
```
