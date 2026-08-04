# Package level import declarations.
#
# These base packages are called without a namespace prefix in several places,
# which R CMD check reports as undefined global functions. Declaring them here
# keeps NAMESPACE authoritative about where they come from.

#' @importFrom stats dist na.omit setNames
#' @importFrom utils head packageVersion
NULL
