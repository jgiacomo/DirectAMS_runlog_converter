# This R function will take a data.frame that was created from a NEC runlog.cat
# AMS results file and will convert this data.frame into a CRABS compatible
# DirectAMS runlog.cat file.

library(readr)
library(dplyr)
library(gdata)  # for the write.fwf function

convertDFtoDAMSrunlog <- function(inDF, outputFile=NULL,
                                  headerinfo=NULL) {
  
  # NEC runlog.cat files are fixed-width text files with header information in
  # the first 4 lines. The data.frame does not contain the header information,
  # so without a headerinput argument, this function will only write the column
  # names and the column widths (as "=") and the data to the fixed-width
  # runlog.cat output file. If a headerinput argument is passed, this function
  # will attempt to place that header information at the top of the runlog.cat
  # file to preserve the usual NEC file format. Otherwise the header will be
  # padded with empty lines so CRABS can still read in the file.
  
  # inDF: must be a data.frame of NEC AMS runlog.cat results.
  
  # outputFile: file name to save a fixed-width file. If NULL no file is written
  
  # headerinfo: can be NULL or a character vector of header lines for the file.
  
  # Get the CRABS compatible column widths and the column names.
  colWidths <- read_rds("DAMS_runlog_columns_with_widths.RDS")
  
  # Columns that are necessary for CRABS to run.
  CRABScols <- c("E", "Item", "Run Completion Time", "Pos", "Meas",
                 "SmType", "Sample Name", "Cycles", "13Che", "CntTotGT",
                 "13/12he", "14/13he")
  
  # Get names of DAMS runlog columns
  DAMSnames <- colWidths$col_names
  
  # Check if all DAMS columns exist in inDF
  missingColNames <- setdiff(DAMSnames, names(inDF))
  
  # Check if any of the missing columns are necessary for CRABS abort if so.
  needed <- intersect(missingColNames, CRABScols)
  if(length(needed) > 0){stop(paste(needed, "column(s) is missing from the",
                  "runlog data. CRABS needs these values to process data."))}
  
  # Create a new data frame with just the CRABS columns and pad any missing
  # columns with 0's.
  if(length(missingColNames) > 0) {
    d <- data.frame("x"=rep("x",nrow(inDF)))  # initialize data.frame
    for(i in length(missingColNames)) {
      f <- data.frame(rep(0,nrow(inDF)))
      names(f) <- missingColNames[i]
      d <- cbind(d,f)
    }
    d <- select(d,-x) # remove initialization column
    df <- cbind(inDF,d)
  } else { df <- inDF }
  
  # Filter new data.frame to just those columns in DAMSnames.
  df <- df %>%
    select(DAMSnames)
  
  # add row of equal signs signifying the column widths
  fixedWidths <- colWidths$end - colWidths$begin
  equalLine <- rep(".", length(fixedWidths))
  for(i in 1:length(fixedWidths)){
    equalLine[i] <- paste(rep("=",fixedWidths[i]), collapse="")
  }
  
  dfExport <- rbind(names(df), equalLine, df)
  
  # If an output file is requested:
  if(!is.null(outputFile)){
    
    # Write the header to the file.
    if(is.null(headerinfo)) {
      write_lines(c('','','',''),file=outFile)
    } else if(!is.character(headerinfo)) {
      stop("Header Info is not the correct format")
    } else {
      write_lines(headerinfo,file=outputFile)
    }
    
    # Append this data to the output file after the header info.
    write.fwf(dfExport, file=outputFile, colnames=FALSE, append=TRUE)
    
  }
  
  # Return the dfExport data.frame
  return(dfExport)
}