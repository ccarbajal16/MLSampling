# Package Rebranding Consistency Tests
# Tests for Requirements 1.2, 1.3, 1.4

library(testthat)

# Test context for package rebranding
context("Package Rebranding Consistency")

# Helper function to find package root directory
find_package_root <- function() {
  # Start from current directory and work up
  current_dir <- getwd()
  
  # Check if we're already in package root
  if (file.exists("DESCRIPTION") && file.exists("NAMESPACE")) {
    return(current_dir)
  }
  
  # Look for common package indicators
  search_paths <- c(
    ".",
    "..",
    "../..",
    "../../.."
  )
  
  for (path in search_paths) {
    test_path <- normalizePath(path, mustWork = FALSE)
    if (file.exists(file.path(test_path, "DESCRIPTION")) && 
        file.exists(file.path(test_path, "NAMESPACE"))) {
      return(test_path)
    }
  }
  
  # If not found, return current directory
  return(current_dir)
}

# Set working directory to package root
package_root <- find_package_root()
if (getwd() != package_root) {
  setwd(package_root)
}

# Helper function to check file content for package references
check_file_references <- function(file_path, expected_new_name = "MLSampling", 
                                  expected_old_name = "SoilSamplingTool") {
  if (!file.exists(file_path)) {
    return(list(
      has_new_name = FALSE,
      has_old_name = FALSE,
      is_deprecated_properly = FALSE,
      file_exists = FALSE
    ))
  }
  
  content <- readLines(file_path, warn = FALSE)
  content_text <- paste(content, collapse = " ")
  
  # Check for new package name
  has_new_name <- grepl(expected_new_name, content_text, ignore.case = FALSE)
  
  # Check for old package name (should only exist in deprecated contexts)
  has_old_name <- grepl(expected_old_name, content_text, ignore.case = FALSE)
  
  # Check if old name usage is properly deprecated
  is_deprecated_properly <- if (has_old_name) {
    # Look for deprecation markers
    grepl("deprecated|Deprecated|\\.Deprecated", content_text, ignore.case = FALSE) ||
    grepl("legacy|Legacy", content_text, ignore.case = FALSE)
  } else {
    TRUE  # No old name usage is fine
  }
  
  return(list(
    has_new_name = has_new_name,
    has_old_name = has_old_name,
    is_deprecated_properly = is_deprecated_properly,
    file_exists = TRUE,
    content_length = length(content)
  ))
}

# Unit tests for specific files
test_that("DESCRIPTION file has correct package name", {
  desc_check <- check_file_references("DESCRIPTION")
  
  expect_true(desc_check$file_exists, "DESCRIPTION file should exist")
  expect_true(desc_check$has_new_name, "DESCRIPTION should contain MLSampling")
  
  # Read DESCRIPTION specifically to check Package field
  desc_content <- readLines("DESCRIPTION", warn = FALSE)
  package_line <- grep("^Package:", desc_content, value = TRUE)
  expect_length(package_line, 1)
  expect_match(package_line, "Package:\\s*MLSampling")
})

test_that("NAMESPACE file exports MLSampling class", {
  namespace_check <- check_file_references("NAMESPACE")
  
  expect_true(namespace_check$file_exists, "NAMESPACE file should exist")
  expect_true(namespace_check$has_new_name, "NAMESPACE should export MLSampling")
  
  # Check specific exports
  namespace_content <- readLines("NAMESPACE", warn = FALSE)
  exports <- grep("^export\\(", namespace_content, value = TRUE)
  
  expect_true(any(grepl("MLSampling", exports)), "Should export MLSampling class")
  expect_true(any(grepl("create_ml_sampling_tool", exports)), "Should export create_ml_sampling_tool")
  
  # Check that deprecated functions are still exported for backward compatibility
  expect_true(any(grepl("SoilSamplingTool", exports)), "Should still export SoilSamplingTool for compatibility")
  expect_true(any(grepl("create_soil_sampling_tool", exports)), "Should still export create_soil_sampling_tool for compatibility")
})

test_that("Main R files have proper class definitions", {
  # Check MLSampling class file
  ml_sampling_check <- check_file_references("R/ml-sampling-tool.R")
  expect_true(ml_sampling_check$file_exists, "R/ml-sampling-tool.R should exist")
  expect_true(ml_sampling_check$has_new_name, "ml-sampling-tool.R should define MLSampling class")
  
  # Check that the file contains proper R6 class definition
  ml_content <- readLines("R/ml-sampling-tool.R", warn = FALSE)
  ml_text <- paste(ml_content, collapse = " ")
  expect_true(grepl("MLSampling.*<-.*R6::R6Class", ml_text), "Should contain MLSampling R6 class definition")
  
  # Check legacy file still exists
  legacy_check <- check_file_references("R/soil-sampling-tool.R")
  expect_true(legacy_check$file_exists, "R/soil-sampling-tool.R should still exist for compatibility")
  expect_true(legacy_check$is_deprecated_properly, "Legacy references should be properly deprecated")
})

test_that("README file reflects new package identity", {
  readme_check <- check_file_references("README.md")
  
  expect_true(readme_check$file_exists, "README.md should exist")
  expect_true(readme_check$has_new_name, "README should prominently feature MLSampling")
  
  # Check specific sections
  readme_content <- readLines("README.md", warn = FALSE)
  readme_text <- paste(readme_content, collapse = "\n")
  
  # Check title
  expect_true(grepl("# MLSampling", readme_text), "Title should be MLSampling")
  
  # Check installation instructions
  expect_true(grepl("library\\(MLSampling\\)", readme_text), "Should show library(MLSampling)")
  expect_true(grepl("create_ml_sampling_tool", readme_text), "Should show create_ml_sampling_tool usage")
})

# Property-based test for package rebranding consistency (simplified version)
test_that("Property 1: Package Rebranding Consistency - All package files maintain consistent naming", {
  
  # Define key files that should be checked for consistency
  key_files <- c(
    "DESCRIPTION",
    "NAMESPACE", 
    "README.md",
    "R/ml-sampling-tool.R",
    "R/soil-sampling-tool.R"
  )
  
  # Manual property test (simplified without quickcheck dependency)
  consistency_results <- lapply(key_files, function(file_path) {
    check_result <- check_file_references(file_path)
    
    # Core consistency requirements
    if (!check_result$file_exists) {
      message("File does not exist: ", file_path)
      return(FALSE)
    }
    
    # Files should either:
    # 1. Use new naming (MLSampling) primarily, OR
    # 2. Use old naming only in properly deprecated contexts
    
    if (file_path %in% c("DESCRIPTION", "README.md")) {
      # These files should primarily use new naming
      result <- check_result$has_new_name
      if (!result) message("File missing new name: ", file_path)
      return(result)
    } else if (file_path == "NAMESPACE") {
      # NAMESPACE should export both (new and deprecated old)
      result <- check_result$has_new_name
      if (!result) message("NAMESPACE missing new exports: ", file_path)
      return(result)
    } else if (file_path == "R/ml-sampling-tool.R") {
      # New ML file should use new naming
      result <- check_result$has_new_name
      if (!result) message("ML file missing new class: ", file_path)
      return(result)
    } else if (file_path == "R/soil-sampling-tool.R") {
      # Legacy file should have proper deprecation
      result <- check_result$is_deprecated_properly
      if (!result) message("Legacy file missing deprecation: ", file_path)
      return(result)
    }
    
    return(TRUE)
  })
  
  # All files should pass their consistency checks
  all_consistent <- all(unlist(consistency_results))
  
  expect_true(all_consistent, "Package rebranding should be consistent across all files")
  
  # Additional detailed checks
  failed_files <- key_files[!unlist(consistency_results)]
  if (length(failed_files) > 0) {
    message("Files that failed consistency check: ", paste(failed_files, collapse = ", "))
  }
})

# Test that verifies the property without complex dependencies
test_that("Simplified rebranding consistency check", {
  # Check that key files exist and have expected content
  expect_true(file.exists("DESCRIPTION"), "DESCRIPTION should exist")
  expect_true(file.exists("NAMESPACE"), "NAMESPACE should exist") 
  expect_true(file.exists("README.md"), "README.md should exist")
  expect_true(file.exists("R/ml-sampling-tool.R"), "R/ml-sampling-tool.R should exist")
  expect_true(file.exists("R/soil-sampling-tool.R"), "R/soil-sampling-tool.R should exist")
  
  # Check DESCRIPTION package name
  desc_content <- readLines("DESCRIPTION", warn = FALSE)
  package_line <- grep("^Package:", desc_content, value = TRUE)
  expect_true(grepl("MLSampling", package_line), "DESCRIPTION should have MLSampling as package name")
  
  # Check NAMESPACE exports
  namespace_content <- readLines("NAMESPACE", warn = FALSE)
  namespace_text <- paste(namespace_content, collapse = " ")
  expect_true(grepl("MLSampling", namespace_text), "NAMESPACE should export MLSampling")
  
  # Check README title
  readme_content <- readLines("README.md", warn = FALSE)
  readme_text <- paste(readme_content, collapse = "\n")
  expect_true(grepl("# MLSampling", readme_text), "README should have MLSampling title")
  
  # Check ML sampling tool file
  ml_content <- readLines("R/ml-sampling-tool.R", warn = FALSE)
  ml_text <- paste(ml_content, collapse = " ")
  expect_true(grepl("MLSampling.*R6Class", ml_text), "ml-sampling-tool.R should define MLSampling class")
  
  # Check deprecation in legacy file
  legacy_content <- readLines("R/soil-sampling-tool.R", warn = FALSE)
  legacy_text <- paste(legacy_content, collapse = " ")
  expect_true(grepl("deprecated|Deprecated", legacy_text), "soil-sampling-tool.R should have deprecation notices")
})

# Test working directory detection
test_that("Package root directory detection works", {
  expect_true(file.exists("DESCRIPTION"), "Should be able to find DESCRIPTION in package root")
  expect_true(file.exists("NAMESPACE"), "Should be able to find NAMESPACE in package root")
  expect_true(dir.exists("R"), "Should be able to find R directory in package root")
  expect_true(dir.exists("tests"), "Should be able to find tests directory in package root")
})