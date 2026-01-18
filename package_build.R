
# Package Build and Maintenance Script

if (!requireNamespace("devtools", quietly = TRUE)) {
  message("Installing devtools...")
  install.packages("devtools")
}
if (!requireNamespace("roxygen2", quietly = TRUE)) {
  message("Installing roxygen2...")
  install.packages("roxygen2")
}

library(devtools)
library(roxygen2)

# 1. Update Documentation (man/ and NAMESPACE)
message("\n=== Updating Documentation ===")
tryCatch({
  devtools::document()

  # Fix NAMESPACE - remove bogus single-word exports caused by roxygen2/R6 bug
  namespace_file <- "NAMESPACE"
  if (file.exists(namespace_file)) {
    ns_content <- readLines(namespace_file)
    bogus_exports <- c("Analysis", "Bayesian", "Comparison", "Deep", "Design",
                       "Engine", "Ensemble", "Forest", "Framework", "Initialize",
                       "Learning", "Manager", "Module", "Optimization", "Random",
                       "Spatial", "Uncertainty")
    bogus_patterns <- paste0("^export\\(", bogus_exports, "\\)$")
    for (pattern in bogus_patterns) {
      ns_content <- ns_content[!grepl(pattern, ns_content)]
    }
    writeLines(ns_content, namespace_file)
    message("NAMESPACE cleaned - removed bogus exports.")
  }

  message("Documentation updated successfully.")
}, error = function(e) {
  message("Error updating documentation: ", e$message)
})

# Helper function to clean NAMESPACE
clean_namespace <- function() {
  namespace_file <- "NAMESPACE"
  if (file.exists(namespace_file)) {
    ns_content <- readLines(namespace_file)
    bogus_exports <- c("Analysis", "Bayesian", "Comparison", "Deep", "Design",
                       "Engine", "Ensemble", "Forest", "Framework", "Initialize",
                       "Learning", "Manager", "Module", "Optimization", "Random",
                       "Spatial", "Uncertainty")
    bogus_patterns <- paste0("^export\\(", bogus_exports, "\\)$")
    for (pattern in bogus_patterns) {
      ns_content <- ns_content[!grepl(pattern, ns_content)]
    }
    writeLines(ns_content, namespace_file)
    message("NAMESPACE cleaned - removed bogus exports.")
  }
}

# 2. Run Package Checks
# This runs R CMD check which verifies S3 methods, documentation consistency, and tests
message("\n=== Running Package Checks ===")
message("This may take a few minutes...")
tryCatch({
  clean_namespace()  # Clean before check
  devtools::check(document = FALSE)  # Prevent re-documenting
}, error = function(e) {
  message("Error during package check: ", e$message)
})

# 3. Build Source Package
message("\n=== Building Source Package ===")
tryCatch({
  clean_namespace()  # Clean before build
  path <- devtools::build(vignettes = FALSE)  # Skip vignettes initially
  message("Package built at: ", path)
}, error = function(e) {
  message("Error building package: ", e$message)
})

# 4. Install Package (Optional)
# message("\n=== Installing Package ===")
# devtools::install()
