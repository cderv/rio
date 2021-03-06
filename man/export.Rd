\name{export}
\alias{export}
\title{Export}
\description{Write data.frame to a file}
\usage{
    export(x, file, format, ...)
}
\arguments{
    \item{x}{A data frame or matrix to be written into a file.}
    \item{file}{A character string naming a file. Must specify \code{file} and/or \code{format}.}
    \item{format}{An optional character string containing the file format, which can be used to override the format inferred from \code{file} or, in lieu of specifying \code{file}, a file with the symbol name of \code{x} and the specified file extension will be created. Must specify \code{file} and/or \code{format}. Shortcuts include: \dQuote{,} (for comma-separated values), \dQuote{;} (for semicolon-separated values), \dQuote{|} (for pipe-separated values), and \dQuote{dump} for \code{\link[base]{dump}}.}
    \item{...}{Additional arguments for the underlying export functions.}
}
\value{The name of the output file as a character string (invisibly).}
\details{This function exports a data frame or matrix into a file with file format based on the file extension (or the manually specified format, if \code{format} is specified).

The output file can be to a compressed directory, simply by adding an appropriate additional extensiont to the \code{file} argument, such as: \dQuote{iris.csv.tar}, \dQuote{iris.csv.zip}, or \dQuote{iris.csv.gz}.

\code{export} supports many file formats. See the documentation for the underlying export functions for optional arguments that can be passed via \code{...}

\itemize{
    \item Tab-separated data (.tsv), using \code{\link[utils]{write.table}} with \code{row.names = FALSE}. %Setting \code{fwrite = TRUE} will rely on \code{\link[data.table]{fwrite}} for much faster export.
    \item Comma-separated data (.csv), using \code{\link[utils]{write.csv}} with \code{row.names = FALSE}. %Setting \code{fwrite = TRUE} will rely on \code{\link[data.table]{fwrite}} for much faster export.
    \item \href{http://csvy.org/}{CSVY} (CSV with a YAML metadata header) using \code{\link[utils]{read.csv}} with \code{row.names = FALSE} and \code{stringsAsFactors = FALSE} (or, if \code{fread = TRUE}, \code{\link[data.table]{fread}}). The YAML header lines are preceded by R comment symbols (\#) by default; this can be turned off by passing a \code{comment_header = FALSE} argument to \code{export}. %Setting \code{fwrite = TRUE} will rely on \code{\link[data.table]{fwrite}} for much faster export.
    \item Pipe-separated data (.psv), using \code{\link[utils]{write.table}} with \code{sep = '|'} and \code{row.names = FALSE}. %Setting \code{fwrite = TRUE} will rely on \code{\link[data.table]{fwrite}} for much faster export.
    \item Fixed-width format data (.fwf), using \code{\link[utils]{write.table}} with \code{row.names = FALSE}, \code{quote = FALSE}, and \code{col.names = FALSE}
    \item Serialized R objects (.rds), using \code{\link[base]{saveRDS}}
    \item Saved R objects (.RData), using \code{\link[base]{save}}
    \item JSON (.json), using \code{\link[jsonlite]{toJSON}}
    \item YAML (.yml), using \code{\link[yaml]{as.yaml}}
    \item Stata (.dta), using \code{\link[haven]{write_dta}}
    \item SPSS (.sav), using \code{\link[haven]{write_sav}}
    \item "XBASE" database files (.dbf), using \code{\link[foreign]{write.dbf}}
    \item Weka Attribute-Relation File Format (.arff), using \code{\link[foreign]{write.arff}}
    \item R syntax object (.R), using \code{\link[base]{dput}} (by default) or \code{\link[base]{dump}} (if \code{format = 'dump'}
    \item Excel (.xlsx), using \code{\link[openxlsx]{write.xlsx}}
    \item XML (.xml), using a custom method to create a simple XML tree
    \item HTML (.html), using a custom method to create a single-table HTML file
    \item Clipboard export (on Windows and Mac OS), using \code{\link[utils]{write.table}} with \code{row.names = FALSE}
}

}
\examples{
# specify only `file` argument
export(iris, "iris.csv")

# specify only `format` argument
"iris.dta" %in% dir()
export(iris, format = "stata")
"iris.dta" %in% dir()

# specify `file` and `format` to override default format
export(iris, file = "iris.txt", format = "csv")

# export to JSON
export(iris, "iris.json")

# pass arguments to underlying export function
export(iris, "iris.csv", col.names = FALSE)

# write data to .R syntax file and append additional data
export(iris, file = "data.R", format = "dump")
export(mtcars, file = "data.R", format = "dump", append = TRUE)
source("data.R", echo = TRUE)

# write data to a zip-compressed CSV
export(iris, "iris.csv.zip")

# cleanup
unlink("iris.csv")
unlink("iris.dta")
unlink("iris.json")
unlink("data.R")
unlink("iris.csv.zip")
}
