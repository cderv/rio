import_delim <- function(file, fread = TRUE, sep = "auto", header = "auto", stringsAsFactors = FALSE, data.table = FALSE, ...) {
  if (fread) {
    fread(input = file, sep = sep, sep2 = "auto", header = header, stringsAsFactors = stringsAsFactors, data.table = data.table, ...)
  } else {
    if (missing(sep) || is.null(sep) || sep == "auto") {
      sep <- "\t"
    }
    if (missing(header) || is.null(header) || header == "auto") {
      header <- TRUE
    }
    read.table(file = file, sep = sep, header = header, stringsAsFactors = stringsAsFactors, ...)
  }
}

.import.rio_r <- function(file, ...){
  dget(file = file, ...)
}

.import.rio_tsv <- function(file, ...){
  import_delim(file = file, sep = "\t", ...)
}

.import.rio_txt <- function(file, ...){
  import_delim(file = file, sep = "\t", ...)
}

.import.rio_fwf <- function(file, widths, header = FALSE, col.names, readr = FALSE, progress = FALSE, ...) {
  if (missing(widths)) {
    stop("Import of fixed-width format data requires a 'widths' argument. See ? read.fwf().")
  }
  a <- list(...)
  if (readr) {
    if (is.null(widths)) {
      if (!missing(col.names)) {
        widths <- fwf_empty(file = file, col_names = col.names)
      } else {
        widths <- fwf_empty(file = file)
      }
      read_fwf(file = file, col_positions = widths, progress = progress, ...)
    } else if (is.numeric(widths)) {
      if (any(widths < 0)) {
        if (!"col_types" %in% names(a)) {
          col_types <- rep("?", length(widths))
          col_types[widths < 0] <- "?"
          col_types <- paste0(col_types, collapse = "")
        }
        if (!missing(col.names)) {
          widths <- fwf_widths(abs(widths), col_names = col.names)
        } else {
          widths <- fwf_widths(abs(widths))
        }
        read_fwf(file = file, col_positions = widths, col_types = col_types, progress = progress, ...)
      } else {
        if (!missing(col.names)) {
          widths <- fwf_widths(abs(widths), col_names = col.names)
        } else {
          widths <- fwf_widths(abs(widths))
        }
        read_fwf(file = file, col_positions = widths, progress = progress, ...)
      }
    } else if (is.list(widths)) {
      if (!c("begin", "end") %in% names(widths)) {
        if (!missing(col.names)) {
          widths <- fwf_widths(widths, col_names = col.names)
        } else {
          widths <- fwf_widths(widths)
        }
      }
      read_fwf(file = file, col_positions = widths, progress = progress, ...)
    }
  } else {
    if (!missing(col.names)) {
      read.fwf2(file = file, widths = widths, header = header, col.names = col.names, ...)
    } else {
      read.fwf2(file = file, widths = widths, header = header, ...)
    }
  }
}

.import.rio_rds <- function(file, ...){
  readRDS(file = file, ...)
}

.import.rio_csv <- function(file, ...){
  import_delim(file = file, sep = ",", ...)
}

.import.rio_csv2 <- function(file, ...){
  import_delim(file = file, sep = ";", ...)
}

.import.rio_csvy <- function(file, ...) {
  # read in whole file
  f <- readLines(file)
  
  # identify yaml delimiters
  g <- grep("^#?---", f)
  if (length(g) > 2) {
    stop("More than 2 yaml delimiters found in file")
  } else if (length(g) == 1) {
    stop("Only one yaml delimiter found")
  } else if (length(g) == 0) {
    stop("No yaml delimiters found")
  }
  
  # extract yaml front matter and convert to R list
  y <- f[(g[1]+1):(g[2]-1)]
  if (all(grepl("^#", y))) {
    y <- gsub("^#", "", y)
  }
  y <- yaml.load(paste(y, collapse = "\n"))
  
  # load the data
  out <- import_delim(file = paste0(f[(g[2]+1):length(f)], collapse = "\n"), ...)
  for (i in seq_along(y$fields)) {
    attributes(out[, i]) <- y$fields[[i]]
  }
  y$fields <- NULL
  
  meta <- c(list(out), y)
  out <- do.call("structure", meta)
}

.import.rio_psv <- function(file, ...){
  import_delim(file = file, sep = "|", ...)
}

.import.rio_rdata <- function(file, which, ...) {
  e <- new.env()
  load(file = file, envir = e, ...)
  if (missing(which)) {
      if (length(ls(e)) > 1) {
          warning("Rdata file contains multiple objects. Returning first object.")
      }
      which <- 1
  }
  if (is.numeric(which)) {
      get(ls(e)[which], e)
  } else {
      get(ls(e)[grep(which, ls(e))[1]], e)
  }
}

.import.rio_dta <- function(file, haven = TRUE, 
                            convert.dates = TRUE, 
                            convert.factors = FALSE, 
                            missing.type = FALSE, ...) {
  if (haven) {
    a <- list(...)
    if (length(a)) {
      warning("File imported using haven. Arguments to '...' ignored.")
    }
    convert_attributes(read_dta(path = file))
  } else {
    out <- read.dta(file = file, 
                    convert.dates = convert.dates, 
                    convert.factors = convert.factors, 
                    missing.type = missing.type, ...)
    attr(out, "expansion.fields") <- NULL
    attr(out, "time.stamp") <- NULL
    convert_attributes(out)
  }
}

.import.rio_dbf <- function(file, ...){
  read.dbf(file = file, ...)
}

.import.rio_dif <- function(file, ...){
  read.DIF(file = file, ...)
}

.import.rio_sav <- function(file, haven = TRUE, use.value.labels = FALSE, ...) {
  if (haven) {
    convert_attributes(read_sav(path = file))
  } else {
    convert_attributes(read.spss(file = file, to.data.frame = TRUE, 
                                 use.value.labels = use.value.labels, ...))
  }
}

.import.rio_por <- function(file, ...) {
  convert_attributes(read_por(path = file))
}

.import.rio_sas7bdat <- function(file, column.labels = FALSE, ...) {
  convert_attributes(read_sas(b7dat = file, ...))
}

.import.rio_xpt <- function(file, ...){
  read.xport(file = file, ...)
}

.import.rio_mtp <- function(file, ...){
  read.mtp(file = file, ...)
}

.import.rio_syd <- function(file, ...){
  read.systat(file = file, to.data.frame = TRUE, ...)
}

.import.rio_json <- function(file, ...){
  fromJSON(txt = file, ...)
}

.import.rio_rec <- function(file, ...){
  read.epiinfo(file = file, ...)
}

.import.rio_arff <- function(file, ...){
  read.arff(file = file)
}

.import.rio_xls <- function(file, ...){
  read_excel(path = file, ...)
}

.import.rio_xlsx <- function(file, readxl = TRUE, ...) {
  if (readxl) {
    read_excel(path = file, ...)
  } else {
    read.xlsx(xlsxFile = file, ...)
  }
}

.import.rio_fortran <- function(file, style, ...) {
    if (missing(style)) {
        stop("Import of Fortran format data requires a 'style' argument. See ? foreign::read.fortran().")
    }
    read.fortran(file = file, format = style, ...)
}

.import.rio_ods <- function(file, header = TRUE, sheet = NULL, ...) {
    handlingODSheader <- function(x) {
        colnames(x) <- x[1,]
        g <- x[2:nrow(x),]
        rownames(g) <- seq(from = 1, to = nrow(g))
        return(g)
    }
    if (getNrOfSheetsInODS(file) > 1 & is.null(sheet)) {
        msg <- paste0("There are ", getNrOfSheetsInODS(file), " sheets in the ODS file. Only the first sheet will be returned. Use sheet option from read.ods to select which sheet to import.")
        warning(msg)
        sheet <- 1
    } else if (getNrOfSheetsInODS(file) == 1) {
        sheet <- 1
    }
    res <- read.ods(file = file, sheet = sheet, ...)
    if (header & !is.data.frame(res)) {
        res <- lapply(res, handlingODSheader)
    }
    if (header & is.data.frame(res)) {
        res <- handlingODSheader(res)
    }
    return(res)
}

.import.rio_xml <- function(file, stringsAsFactors = FALSE, ...) {
    x <- as_list(read_xml(unclass(file)))
    d <- do.call("rbind", c(lapply(x, unlist)))
    row.names(d) <- 1:nrow(d)
    d <- as.data.frame(d, stringsAsFactors = stringsAsFactors)
    tc2 <- function(x) {
        out <- type.convert(x)
        if (is.factor(out)) {
            x
        } else {
            out
        }
    }
    if (!stringsAsFactors) {
        d[] <- lapply(d, tc2)
    } else {
        d[] <- lapply(d, type.convert)
    }
    d
}

.import.rio_html <- function(file, stringsAsFactors = FALSE, ...) {
    x <- as_list(read_html(unclass(file)))[["body"]][["table"]]
    if ("th" %in% names(x[[1]])) {
        col_names <- unlist(x[[1]][names(x[[1]]) %in% "th"])
        out <- do.call("rbind", lapply(x[-1], function(y) {
            unlist(y[names(y) %in% "td"])
        }))
        colnames(out) <- col_names
    } else {
        out <- do.call("rbind", lapply(x, function(y) {
            unlist(y[names(y) %in% "td"])
        }))
        colnames(out) <- paste0("V", 1:ncol(out))
    }
    row.names(out) <- 1:nrow(out)
    as.data.frame(out, ..., stringsAsFactors = stringsAsFactors)
}

.import.rio_yml <- function(file, stringsAsFactors = FALSE, ...) {
  as.data.frame(yaml.load(file, ...), stringsAsFactors = stringsAsFactors)
}

.import.rio_clipboard <- function(file = "clipboard", header = TRUE, sep = "\t", ...) {
    if (Sys.info()["sysname"] == "Darwin") {
        clip <- pipe("pbpaste")
        read.table(file = clip, sep = sep, ...)
        close(clip)
    } else if(Sys.info()["sysname"] == "Windows") {
        read.table(file = file, sep = sep, header = header, ...)
    } else {
        stop("Reading from clipboard is not supported on your OS")
    }
}
