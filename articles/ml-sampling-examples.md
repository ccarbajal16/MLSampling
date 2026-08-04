# Soil Sampling Examples: Practical Guide to Constitutional Compliance

## Enhanced Soil Sampling Tool: Practical Examples

This vignette provides comprehensive examples for using the Enhanced
Soil Sampling Tool with constitutional compliance for spatial analysis
excellence.

### Constitutional Compliance Features

The Enhanced Soil Sampling Tool implements all constitutional
principles:

- ✅ **Spatial Analysis Excellence**: Modern terra/sf packages with CRS
  validation
- ✅ **Code Quality Excellence**: Comprehensive error handling and
  validation  
- ✅ **Testing Standards**: Unit, spatial, integration and performance
  tests with a TDD approach
- ✅ **User Experience Consistency**: Consistent APIs and progress
  feedback
- ✅ **Performance Excellence**: Memory efficiency and parallel support

### Quick Start

#### 1. System Validation

Always start by validating your system environment:

``` r

library(MLSampling)

# Validate system environment for constitutional compliance
validation_result <- validate_system_environment()

if (validation_result) {
  cat("✅ System ready for soil sampling analysis\n")
} else {
  cat("⚠️ System environment issues detected\n")
}
```

#### 2. Creating a Tool Instance

``` r

# Create tool with default constitutional settings
tool <- create_soil_sampling_tool()

# Create tool with custom configuration
tool_custom <- create_soil_sampling_tool(
  config = list(
    log_level = "DEBUG",
    parallel_cores = 4,
    memory_limit = "4GB",
    validation_strict = TRUE,
    progress_feedback = TRUE
  ),
  interactive = TRUE
)
```

### Working with Synthetic Data

#### 3. Generate Test Data

``` r

# Generate synthetic field data for testing
field_data <- generate_synthetic_field(
  field_size = c(1000, 800),  # 1000m x 800m field
  resolution = 50,            # 50m resolution
  crs = "EPSG:32633"         # UTM Zone 33N
)

# Generate existing sampling locations
existing_samples <- generate_existing_samples(
  field_data = field_data,
  n_samples = 25,
  sampling_strategy = "random"
)

# Inspect the data structure
str(field_data)
str(existing_samples)
```

#### 4. Basic UDL Optimization

``` r

# Run UDL optimization with constitutional compliance
udl_result <- tool$run_udl(
  field_data = field_data,
  existing_samples = existing_samples,
  n_new_samples = 30,
  optimization_method = "genetic",
  max_iter = 100,
  save_csv = TRUE
)

# Inspect results
str(udl_result)
print(udl_result$metrics)
```

#### 5. UFN Optimization with Torch

``` r

# Check if torch is available
if (torch::torch_is_installed()) {
  
  # Run UFN optimization with Graph Neural Networks
  ufn_result <- tool$run_ufn(
    field_data = field_data,
    existing_samples = existing_samples,
    n_new_samples = 30,
    graph_connectivity = "delaunay",
    feature_aggregation = "attention",
    save_csv = TRUE
  )
  
  # Inspect UFN-specific results
  print(ufn_result$graph_metrics)
  
} else {
  cat("Torch not available - UFN will use statistical fallback\n")
  
  # UFN with fallback method
  ufn_result <- tool$run_ufn(
    field_data = field_data,
    existing_samples = existing_samples,
    n_new_samples = 30,
    fallback_method = "statistical"
  )
}
```

### Model Comparison and Analysis

#### 6. Comprehensive Model Comparison

``` r

# Compare UDL and UFN models with statistical testing
comparison_result <- tool$compare_models(
  field_data = field_data,
  existing_samples = existing_samples,
  n_new_samples = 25,
  algorithms = c("UDL", "UFN"),
  n_replicates = 5,
  statistical_test = "wilcoxon",
  detailed_metrics = TRUE
)

# View comparison summary
print(comparison_result$performance_summary)
print(comparison_result$statistical_tests)
print(comparison_result$recommendations)
```

#### 7. Generate Comprehensive Reports

``` r

# Generate report for single optimization
udl_report <- tool$generate_report(
  result = udl_result,
  report_type = "comprehensive",
  include_visualizations = TRUE
)

# Generate comparative report
comparison_report <- tool$generate_report(
  result = comparison_result,
  report_type = "comparison",
  include_statistical_analysis = TRUE
)

# View report summaries
cat("UDL Report saved to:", udl_report$file_path, "\n")
cat("Comparison Report saved to:", comparison_report$file_path, "\n")
```

### Working with Real Data

#### 8. Loading Real Field Data

``` r

# Load real field data with constitutional validation
real_field_data <- load_real_field_data(
  data_path = "data/",
  validate_crs = TRUE,
  ensure_consistency = TRUE
)

# Load existing samples from CSV
real_existing_samples <- read.csv("field_data.csv")

# Validate real data structure
validation_result <- validate_field_data_structure(
  field_data = real_field_data,
  strict_validation = TRUE
)

if (validation_result$is_valid) {
  cat("✅ Real field data passed constitutional validation\n")
} else {
  cat("❌ Real field data validation issues:\n")
  print(validation_result$issues)
}
```

#### 9. Real Data Optimization

``` r

# Run optimization on real data
real_udl_result <- tool$run_udl(
  field_data = real_field_data,
  existing_samples = real_existing_samples,
  n_new_samples = 40,
  optimization_method = "simulated_annealing",
  max_iter = 200
)

# Export results with constitutional compliance
csv_file <- tool$save_coordinates_to_csv(
  result = real_udl_result,
  filename = "optimized_sampling_locations.csv",
  include_metadata = TRUE
)

cat("Optimized sampling locations saved to:", csv_file, "\n")
```

### Advanced Features

#### 10. Custom Optimization Parameters

``` r

# Advanced UDL configuration
advanced_udl <- tool$run_udl(
  field_data = field_data,
  existing_samples = existing_samples,
  n_new_samples = 35,
  optimization_method = "genetic",
  genetic_params = list(
    population_size = 100,
    mutation_rate = 0.15,
    crossover_rate = 0.8,
    elite_size = 10
  ),
  convergence_criteria = list(
    max_generations = 150,
    min_improvement = 0.001,
    patience = 20
  )
)
```

#### 11. Performance Benchmarking

``` r

# Get performance benchmarks with constitutional compliance
benchmark_results <- tool$get_benchmark_results()

print("Performance Metrics:")
print(benchmark_results$execution_times)
print(benchmark_results$memory_usage)
print(benchmark_results$constitutional_compliance)

# Performance validation against constitutional requirements
performance_validation <- validate_constitutional_performance(
  results = list(udl_result, ufn_result),
  requirements = list(
    max_execution_time = 300,  # 5 minutes
    max_memory_gb = 2,         # 2GB memory
    min_coverage = 0.7,        # 70% coverage
    min_spatial_balance = 0.6  # 60% spatial balance
  )
)

print(performance_validation)
```

#### 12. Error Handling Examples

``` r

# Example of graceful error handling
tryCatch({
  
  # Attempt optimization with invalid parameters
  invalid_result <- tool$run_udl(
    field_data = NULL,  # Invalid: NULL field_data
    n_new_samples = -5  # Invalid: negative samples
  )
  
}, SpatialDataError = function(e) {
  cat("Spatial Data Error:\n")
  cat("  Message:", e$message, "\n")
  cat("  Suggestion:", e$suggestion, "\n")
  
}, ConfigurationError = function(e) {
  cat("Configuration Error:\n")
  cat("  Message:", e$message, "\n")
  cat("  Suggestion:", e$suggestion, "\n")
  
}, error = function(e) {
  cat("General Error:", e$message, "\n")
})
```

### Visualization and Export

#### 13. Creating Visualizations

``` r

# Generate spatial visualizations
visualization_data <- create_sampling_visualizations(
  field_data = field_data,
  optimization_results = list(
    UDL = udl_result,
    UFN = ufn_result
  ),
  existing_samples = existing_samples
)

# Interactive map
interactive_map <- create_interactive_sampling_map(
  visualization_data = visualization_data,
  include_covariates = TRUE,
  include_optimization_trace = TRUE
)

# Static plots for reports
static_plots <- create_static_sampling_plots(
  visualization_data = visualization_data,
  plot_types = c("coverage", "efficiency", "comparison")
)
```

#### 14. Exporting Results

``` r

# Export comprehensive results package
export_package <- export_sampling_results(
  results = list(
    udl = udl_result,
    ufn = ufn_result,
    comparison = comparison_result
  ),
  export_format = "comprehensive",
  include_visualizations = TRUE,
  include_reports = TRUE,
  output_directory = "sampling_results/"
)

cat("Results exported to:", export_package$output_directory, "\n")
cat("Files created:\n")
print(export_package$file_list)
```

### Troubleshooting Common Issues

#### 15. Common Problems and Solutions

``` r

# Check for common configuration issues
diagnostic_results <- run_diagnostic_checks(tool)

if (diagnostic_results$all_passed) {
  cat("✅ All diagnostic checks passed\n")
} else {
  cat("⚠️ Diagnostic issues found:\n")
  for (issue in diagnostic_results$issues) {
    cat("  -", issue$problem, "\n")
    cat("    Solution:", issue$solution, "\n")
  }
}

# Memory usage optimization
if (diagnostic_results$memory_high) {
  # Optimize memory usage
  optimized_tool <- create_soil_sampling_tool(
    config = list(
      memory_limit = "1GB",
      parallel_cores = 2,
      batch_processing = TRUE
    )
  )
}
```

### Constitutional Compliance Summary

This vignette demonstrates the Enhanced Soil Sampling Tool’s adherence
to constitutional principles:

1.  **Spatial Analysis Excellence**: All examples use modern terra/sf
    packages with proper CRS handling
2.  **Code Quality Excellence**: Comprehensive error handling and
    validation throughout
3.  **Testing Standards**: Examples include validation and error
    checking
4.  **User Experience Consistency**: Consistent API patterns across all
    functions
5.  **Performance Excellence**: Benchmarking and optimization guidance
    provided

For more advanced topics, see: -
[`vignette("performance-optimization")`](https://ccarbajal16.github.io/MLSampling/articles/performance-optimization.md)
for performance tuning -
[`vignette("troubleshooting")`](https://ccarbajal16.github.io/MLSampling/articles/troubleshooting.md)
for detailed problem-solving guides -
[`?MLSampling`](https://ccarbajal16.github.io/MLSampling/reference/MLSampling.md)
for complete API documentation
