
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
  message("Documentation updated successfully.")
}, error = function(e) {
  message("Error updating documentation: ", e$message)
})

# 2. Run Package Checks
# This runs R CMD check which verifies S3 methods, documentation consistency, and tests
message("\n=== Running Package Checks ===")
message("This may take a few minutes...")
tryCatch({
  devtools::check()
}, error = function(e) {
  message("Error during package check: ", e$message)
})

# 3. Build Source Package
message("\n=== Building Source Package ===")
tryCatch({
  path <- devtools::build()
  message("Package built at: ", path)
}, error = function(e) {
  message("Error building package: ", e$message)
})

# 4. Install Package (Optional)
# message("\n=== Installing Package ===")
# devtools::install()
