#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("External AMS Lab runlog to CRABS compatible runlog"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            fileInput("runlogIn","External runlog.cat",
                      multiple=FALSE),
            HTML("</br>"),
            HTML("<p><b>Downlaod a CRABS compatible runlog.cat</b></p>"),
            downloadButton("downloadData",label="Download runlog.cat")
        ),

        # Show a plot of the generated distribution
        mainPanel(
           HTML("<H4>The External Lab's Runlog</H4></br>"),
           tableOutput("header"),
           tableOutput("runlog")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  # source needed functions
  source("R/convertDataframeToDAMSrunlog.R")
  source("R/convertRunlogToDataframe.R")
  source("R/getHeaderFromRunlog.R")
  
  # Get runlog from input file
  runlog <- reactive({
    req(input$runlogIn)
    
    colWidths <- fwf_empty(input$runlogIn$datapath, skip=4)
    colNames <- read_fwf(input$runlogIn$datapath, colWidths, skip=4,
                         show_col_types=FALSE )[1,]
    
    df <- read_fwf(input$runlogIn$datapath, colWidths, skip=6,
                   show_col_types=FALSE)
    names(df) <- as.character(colNames)
    df
  })
  
  # Get header text from input file
  header.txt <- reactive({
    header.txt <- read_lines(input$runlogIn$datapath,n_max=4)
  })
  
  # Get header as a data frame from input file
  header.table <- reactive({
    headerWidths <- fwf_empty(input$runlogIn$datapath, skip=0, n=2)
    headerDF <- read_fwf(input$runlogIn$datapath, headerWidths, skip=0, n_max=3,
                         show_col_types=FALSE )
    names(headerDF) <- as.character(headerDF[1,])
    header.table <- headerDF %>% slice(2,3)
    header.table
  })
  
  output$header <- renderTable({
    req(input$runlogIn)
    header.table()
  })
  
  output$runlog <- renderTable({
    req(input$runlogIn)
    
    runlog()
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      "runlog.cat"
    },
    content = function(con) {
      convertDFtoDAMSrunlog(runlog(),
                            outputFile="CRABS_runlog.cat",
                            headerinfo=header.txt())
      file.copy("CRABS_runlog.cat", con)
    },
    contentType = "text/fwf"
  )
}

# Run the application 
shinyApp(ui = ui, server = server)
