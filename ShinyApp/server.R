# Call the helpers file
source("helpers.R")

# Define server logic for app ----
server <- function(input, output, session) {
  
  fusszeile <- div(class = "containerlow",
                   tags$text(paste0("University of Goettingen, Faculty of Business and 
                                    Economics, Chair of Spatial Data Science and Statistical Learning")),
                   #tags$br(),
                   tags$text(paste0("Project: Elections based on INKAR Data by Lukas Brüwer"))
  )
  
  output$fusszeile <- renderUI({
    fusszeile
  })
  
  output$map <- renderLeaflet({
    leaflet(data = germany_nuts3_wgs84) %>%
      addPolygons(
        color = "black",
        weight = 1,
        fillColor = "gray",
        fillOpacity = 0.6,
        highlightOptions = highlightOptions(
          color = "white",      # Border color on highlight
          weight = 3,           # Border thickness on highlight
          fillOpacity = 0.9,    # Fill opacity on highlight
          bringToFront = TRUE   # Brings the highlighted polygon to the front
        ),
        popup = ~paste0("<strong>County: </strong>", NUTS_NAME) # Replace 'county_name' with your actual field
      ) %>%
      addEasyButton(
        easyButton(
          icon = "fa-crosshairs", title = "Zoom to Clicked County",
          onClick = JS(
            "function(btn, map) { 
               map.on('click', function(e) { 
                  map.setView(e.latlng, map.getZoom()); 
               });
            }"
          )
        )
      )
  })
  
  
  
}
