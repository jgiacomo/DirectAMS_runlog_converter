# This R function will take a NEC runlog.cat AMS results file as input and will
# convert this file into an R data.frame object.

library(readr)
library(dplyr)

convertRunlogToDataframe <- function(inFile) {
  
  # NEC runlog.cat files are fixed-width text files with header information in
  # the first 4 lines.
  
  # Get the column widths and the column names from the runlog.cat file
  colWidths <- fwf_empty(inFile, skip=4)
  colNames <- read_fwf(inFile, colWidths, skip=4, show_col_types=FALSE )[1,]
  
  # Write out a data.frame of the runlog.cat contents
  df <- read_fwf(inFile, colWidths, skip=6, show_col_types=FALSE)
  names(df) <- as.character(colNames)
  
  return(df)
}