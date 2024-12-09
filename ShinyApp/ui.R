# Call the helpers file
source("helpers.R")


# Define UI for the app
ui <- fluidPage(
  useShinyjs(), # Initialize shinyjs
  includeCSS("style.css"),
  
  # App title
  titlePanel("Elections based on INKAR data"),
  
  # Sidebar layout
  sidebarLayout(
    # Sidebar panel for inputs
    sidebarPanel(
      helpText("Click on a district to see the election results as a radar chart")
    ),
    # Main panel layout
    mainPanel(
      tabsetPanel(
        id = "tabs", # Add an ID to identify the active tab
        # Map and Radar Chart tab
        tabPanel(
          "Map and Radar Chart",
          fluidRow(
            column(7, leafletOutput("map", height = "600px")),
            column(4, 
                   plotOutput("radarChart", height = "400px")) # Radar chart for observed shares
            #plotOutput("predictedRadarChart", height = "300px")) # Uncomment for predicted shares
          )
        ),
        
        # Data Table tab
        tabPanel(
          "Data Table",
          fluidRow(
            column(6,
                   # Dropdown for selecting file format
                   selectInput(
                     "downloadFormat", "Select File Format:",
                     choices = c("CSV" = "csv", "Excel" = "xlsx", "RDS" = "rds"),
                     selected = "csv"
                   )
            ),
            column(6,
                   # Download button for data
                   downloadButton("downloadData", "Download Data")
            )
          ),
          DTOutput("dataTable", width = "100%") 
        )
      )
    )
  )
)
