% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ghost_par_ests.R
\name{ghost_par_ests}
\alias{ghost_par_ests}
\title{Provide parameter estimates from sensitivity analysis function}
\usage{
ghost_par_ests(step3, parameter_label, remove_NA = FALSE)
}
\arguments{
\item{step3}{The object returned from SA_step3.}

\item{parameter_label}{The label used for the parameter in the lavaan code.}

\item{remove_NA}{Remove rows for combinations of phantom variable parameters that resulted in inadmissable solutions in lavaan.}
}
\value{
A dataframe of the parameter estimates from the lavaan model.
}
\description{
\code{ghost_par_ests()} Selects certain parameter estimates from the output of the sensitivity analysis.
}
