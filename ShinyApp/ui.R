# Call the helpers file
source("helpers.R")

ui <- fluidPage(
  includeCSS("style.css"),
  
  # App title
  titlePanel("Elections based on INKAR data"),
  
  # Sidebar layout and tabsetPanel are made compatible
  sidebarLayout(
    sidebarPanel(
      helpText("Click on a district to see the election results as a radar chart")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel(
          "Map and Radar Chart",
          fluidRow(
            column(7, leafletOutput("map", height = "600px")),
            column(4, 
                   plotOutput("radarChart", height = "400px")) # radar chart observed shares
                   #plotOutput("predictedRadarChart", height = "300px")) # radar chart predicted shares
          )
        ),
        tabPanel(
          "Data Table",
          DTOutput("dataTable") # Placeholder for the data table
        )
      )
    )
  )
)
