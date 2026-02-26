# Standardized Error Classes

Defines a hierarchy of error classes for MLSampling to ensure consistent
error reporting and handling across all modules.

## Examples

``` r
if (FALSE) { # \dontrun{
stop(MLSamplingError("General error"))
stop(BDLError("Model failed to converge"))
} # }
```
