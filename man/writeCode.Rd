% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AllGeneric.R, R/writeCode.R
\docType{methods}
\name{writeCode}
\alias{writeCode}
\alias{writeCode,GeneratedCode,logical-method}
\alias{writeCode,GeneratedCode,missing-method}
\alias{writeCode,GeneratedCode,character-method}
\title{Write Generated Code}
\usage{
writeCode(code, file, ...)

\S4method{writeCode}{GeneratedCode,logical}(code, file, overWrite = FALSE,
  prefix = "gen_")

\S4method{writeCode}{GeneratedCode,missing}(code, file, ...)

\S4method{writeCode}{GeneratedCode,character}(code, file, overWrite = FALSE,
  ...)
}
\arguments{
\item{code}{object of class \linkS4class{GeneratedCode}}

\item{file}{character name of the file to write the generated script. 
If FALSE then don't write anything to disk.
If TRUE and code comes from a file then use \code{prefix} to make a new
name and write a script.}

\item{...}{additional arguments to methods}

\item{overWrite}{logical write over existing file}

\item{prefix}{character prefix for generating file names}
}
\value{
expression R language object, suitable for further manipulation
}
\description{
Write the generated code to a file and return the code.
}
\seealso{
\code{\link{generate}} to generate the code from a schedule,
\code{\link{makeParallel}} to do everything all at once.
}
