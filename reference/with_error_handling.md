# Safe execution wrapper

Executes an expression and wraps any errors in MLSampling-specific error
types.

## Usage

``` r
with_error_handling(expr, error_type = "MLSamplingError", fallback = NULL)
```

## Arguments

- expr:

  Expression to evaluate

- error_type:

  Type of error to wrap (default "MLSamplingError")

- fallback:

  Optional fallback value to return on error

## Value

Result of expr or fallback
