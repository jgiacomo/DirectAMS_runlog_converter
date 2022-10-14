# This R function will read the header from a NEC runlog.cat file and return it
# as a character vector.

library(readr)
library(dplyr)

getHeaderFromRunlog <- function(inFile) {
  
  # NEC runlog.cat files are fixed-width text files with header information in
  # the first 4 lines (last line is empty).
  
  # Read in each line and store as a character vector.
  header <- read_lines(inFile,n_max=4)
  
  return(header)
}