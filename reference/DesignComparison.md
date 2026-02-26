# DesignComparison

Provides tools for comparing different sampling designs based on
coverage, efficiency, and spatial representativeness.

## Details

The DesignComparison class implements:

- Comparison metrics: Coverage (MSSD), Efficiency, Representativeness

- Statistical testing: Wilcoxon rank-sum test, t-test

- Spatial cross-validation for design assessment

## Methods

### Public methods

- [`DesignComparison$new()`](#method-DesignComparison-new)

- [`DesignComparison$compare_designs()`](#method-DesignComparison-compare_designs)

- [`DesignComparison$perform_statistical_test()`](#method-DesignComparison-perform_statistical_test)

- [`DesignComparison$cross_validate_design()`](#method-DesignComparison-cross_validate_design)

- [`DesignComparison$clone()`](#method-DesignComparison-clone)

------------------------------------------------------------------------

### Method `new()`

#### Usage

    DesignComparison$new(config = list())

#### Arguments

- `config`:

  Optional configuration list Compare Multiple Designs

------------------------------------------------------------------------

### Method `compare_designs()`

#### Usage

    DesignComparison$compare_designs(designs, field_data, true_values = NULL)

#### Arguments

- `designs`:

  List of sf objects representing different sampling designs

- `field_data`:

  Field data (SpatRaster or list with boundary/covariates)

- `true_values`:

  Optional raster of true values for validation (if available)

#### Returns

List containing comparison results and metrics Perform Statistical Test
Between Two Designs

------------------------------------------------------------------------

### Method `perform_statistical_test()`

#### Usage

    DesignComparison$perform_statistical_test(
      design1_metrics,
      design2_metrics,
      test_type = "wilcoxon"
    )

#### Arguments

- `design1_metrics`:

  Vector of metric values for design 1

- `design2_metrics`:

  Vector of metric values for design 2

- `test_type`:

  "wilcoxon" or "t-test"

#### Returns

Test result (htest object) Spatial Cross-Validation for Design
Assessment

------------------------------------------------------------------------

### Method `cross_validate_design()`

#### Usage

    DesignComparison$cross_validate_design(design, field_data, k = 5)

#### Arguments

- `design`:

  sf object of sampling locations

- `field_data`:

  Field data

- `k`:

  Number of folds

#### Returns

CV performance metrics

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    DesignComparison$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
