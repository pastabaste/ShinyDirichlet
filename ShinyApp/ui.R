# Call the helpers file
source("helpers.R")


# Define UI for random distribution app ----
ui <- fluidPage(
  
  includeCSS("style.css"),
  

  # App title ----
  titlePanel("Elections based on INKAR data"),
  
  # Sidebar layout defined ----
  sidebarLayout(
    # Sidebar panel for inputs ----
    sidebarPanel(
      helpText("Click on a district to see the election results as a radar chart")
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      tags$head(tags$script(src="template.js")),
      
      # Output: tabsetPanel only needed for several tabs
      tabsetPanel(type = "tabs", id = "tabs",
                  tabPanel("Map",value = 1,
                           br(),
                           leafletOutput("map", height = "600px")),
                  tabPanel("Radar Chart", value = "radarTab",
                           br(),
                           plotlyOutput("radarChart", height = "600px"))
              
      )
    )
  ),
  uiOutput("fusszeile")
)

