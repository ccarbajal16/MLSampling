% Generated manually to document internal helper
\name{execute_udl_optimization}
\alias{execute_udl_optimization}
\title{Execute Unified Deep Learning optimization}
\description{
Internal helper used by \code{SoilSamplingTool} to perform Unified Deep Learning (UDL)
optimization. The routine selects an appropriate heuristic algorithm, generates
candidate locations when required, and compiles performance diagnostics for the
resulting sampling plan.
}
\usage{
execute_udl_optimization(field_data, existing_samples, n_new_samples,
  optimization_method, model_config, parallel)
}
\arguments{
\item{field_data}{List containing boundary geometries, covariate rasters, and
associated metadata for the field under analysis. Candidate locations are generated
automatically if absent.}

\item{existing_samples}{Optional data frame or \code{sf} object describing existing
sampling locations in the same coordinate reference system as \code{field_data}.}

\item{n_new_samples}{Positive integer giving the number of new sampling locations to
select.}

\item{optimization_method}{Character scalar naming the heuristic algorithm to run,
such as \code{"greedy"}, \code{"genetic"}, \code{"simulated_annealing"}, or \code{"random"}.}

\item{model_config}{Optional list of hyperparameters forwarded to the chosen
optimization algorithm.}

\item{parallel}{Logical flag indicating whether the optimizer may use parallel
processing when supported.}
}
\value{
List summarising the optimization outcome, including selected sampling locations,
an optimization score, and performance metrics.
}
\seealso{\code{\link{SoilSamplingTool}} for the public interface that invokes this helper.}
\keyword{internal}
