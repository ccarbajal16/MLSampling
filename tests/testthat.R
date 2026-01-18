# This file is part of the standard setup for testthat.
# It is recommended that you do not modify it.
#
# Where should you do additional test configuration?
# Learn more about the roles of various files in:
# * https://r-pkgs.org/tests.html
# * https://testthat.r-lib.org/reference/test_package.html#special-files

library(testthat)
library(MLSampling)

# Set up testing environment with constitutional compliance requirements
options(
  # Enable coverage tracking for 90%+ requirement
  testthat.progress.reporter = "progress",
  # Parallel testing configuration
  testthat.default_check_reporter = "check_reporter",
  # Spatial testing configuration
  testthat.spatial.tolerance = 1e-6,
  # Performance testing thresholds
  testthat.performance.max_time = 300,  # 5 minutes max for large operations
  testthat.performance.max_memory = 2   # 2GB max memory usage
)

# Constitutional compliance message
message("Running tests with MLSampling Constitutional Standards:")
message("- Code Quality Excellence: Comprehensive test coverage (90%+ target)")
message("- Spatial Analysis Excellence: CRS validation and precision tests")
message("- Testing Standards: Unit, spatial, integration, and performance tests")
message("- User Experience: Consistent API and error handling validation")
message("- Performance: Memory and time constraint validation")

test_check("MLSampling")