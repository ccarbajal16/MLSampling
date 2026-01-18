% Generated manually to document internal helper
\name{execute_ufn_optimization}
\alias{execute_ufn_optimization}
\title{Execute Unified Feature Network optimization}
\description{
Internal helper used by \code{SoilSamplingTool} to run Unified Feature Network (UFN)
optimizations via either the neural-network pipeline or the statistical fallback
implementation when neural execution is not available.
}
\usage{
execute_ufn_optimization(field_data, existing_samples, n_new_samples,
  model_config, model_type)
}
\arguments{
\item{field_data}{List containing boundary geometries, aligned covariate rasters,
and metadata describing the field under analysis.}

\item{existing_samples}{Optional data frame or \code{sf} object of previously
collected sampling locations expressed in the same CRS as \code{field_data}.}

\item{n_new_samples}{Positive integer specifying the number of additional sampling
locations to generate.}

\item{model_config}{Optional list of hyperparameters forwarded to the neural network
optimization pipeline. Ignored when \code{model_type = "statistical_fallback"}.}

\item{model_type}{Character scalar identifying the execution path, expected to be
either \code{"neural_network"} or \code{"statistical_fallback"}.}
}
\value{
List containing the selected sampling locations along with performance diagnostics
and flags describing which model path executed.
}
\seealso{\code{\link{SoilSamplingTool}} for the public interface that calls this helper.}
\keyword{internal}
