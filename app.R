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
  
  vals <- reactiveValues()
  
  eventReactive(input$runlogIn, {
    vals$runlog <- convertRunlogToDataframe(input$runlogIn)
    vals$header <- getHeaderFromRunlog(input$runlogIn)
    
    #### DEBUG ####
    print(str(vals$runlog()))
  })
  
  output$runlog <- renderTable({
    req(input$runlogIn, vals$runlog, vals$header)
    
    df <- convertDFtoDAMSrunlog(vals$runlog,
                                outputFile=NULL,
                                headerinfo=vals$header)
    
    df
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      "runlog.cat"
    },
    content = function(file) {
      convertDFtoDAMSrunlog(vals$runlog,
                            outputFile=file,
                            headerinfo=vals$header)
    },
    contentType = "text/fwf"
  )
}

# Run the application 
shinyApp(ui = ui, server = server)
