# ReportingService

Service for generating comprehensive reports for ML sampling results.
Integrates text summaries, performance metrics, and visualizations.

## Public fields

- `config_manager`:

  Configuration manager instance

- `visualization_service`:

  Visualization service instance Initialize Reporting Service

## Methods

### Public methods

- [`ReportingService$new()`](#method-ReportingService-new)

- [`ReportingService$generate_report()`](#method-ReportingService-generate_report)

- [`ReportingService$generate_optimization_report()`](#method-ReportingService-generate_optimization_report)

- [`ReportingService$generate_comparison_report()`](#method-ReportingService-generate_comparison_report)

- [`ReportingService$clone()`](#method-ReportingService-clone)

------------------------------------------------------------------------

### Method `new()`

#### Usage

    ReportingService$new(config_manager = NULL, visualization_service = NULL)

#### Arguments

- `config_manager`:

  Optional ConfigManager instance

- `visualization_service`:

  Optional VisualizationService instance Generate Unified Report

------------------------------------------------------------------------

### Method `generate_report()`

#### Usage

    ReportingService$generate_report(
      optimization_result,
      output_format = "html",
      report_config = NULL,
      export_path = NULL
    )

#### Arguments

- `optimization_result`:

  OptimizationResult or ModelComparison object

- `output_format`:

  Output format ("html", "pdf")

- `report_config`:

  Configuration list

- `export_path`:

  Full path to export report

#### Returns

List with success status and path Generate Optimization Report

------------------------------------------------------------------------

### Method `generate_optimization_report()`

#### Usage

    ReportingService$generate_optimization_report(
      result,
      output_dir = getwd(),
      filename = NULL,
      format = "html",
      include_plots = TRUE
    )

#### Arguments

- `result`:

  OptimizationResult object

- `output_dir`:

  Directory to save report

- `filename`:

  Report filename

- `format`:

  Output format ("html", "pdf")

- `include_plots`:

  Boolean

#### Returns

List with report path and status Generate Comparison Report

------------------------------------------------------------------------

### Method `generate_comparison_report()`

#### Usage

    ReportingService$generate_comparison_report(
      comparison_result,
      output_dir = getwd(),
      filename = NULL
    )

#### Arguments

- `comparison_result`:

  ModelComparison object

- `output_dir`:

  Directory to save report

- `filename`:

  Report filename

#### Returns

List with report path and status

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    ReportingService$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
