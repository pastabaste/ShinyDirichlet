# Call the helpers file
source("helpers.R")
source("data_preprocessing.R")

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
    leaflet(data = data) %>%
      #addProviderTiles(providers$Esri.WorldImagery) %>% # background
      addPolygons(
        color = "black",
        weight = 1,
        fillColor = ~color_incumbant,
        fillOpacity = 0.6,
        highlightOptions = highlightOptions(
          color = "white",      # Border color on highlight
          weight = 3,         # Border thickness on highlight
          fillOpacity = 0.9,  # Fill opacity on highlight
          bringToFront = TRUE # Brings the highlighted polygon to the front
        ),
        popup = ~paste0("<strong>District: </strong>", KR, "<br>",
                        "<strong>Incumbant Party: </strong>", incumbant_party
        ),
        label = ~paste0(KR, "\n"
        ),
        labelOptions = labelOptions(
          style = list("color" = "black"),
          textsize = "12px",
          direction = "auto"
        ),
        layerId = ~NUTS_CODE
      )%>%
      addLegend(
        "bottomright",                          # Position of the legend
        colors = c("black", "blue", "yellow", "red", "green", "purple", "grey"),  # Colors for each party
        labels = c("CDU/CSU", "AfD", "FDP", "SPD", "Grüne", "Left", "Others"),   # Party names
        title = "Incumbant Party",
        opacity = 0.6
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
  
  selected_district_data <- reactive({
    req(input$map_shape_click)  # Ensure click event is triggered
    
    district_id <- input$map_shape_click$id  # Get the district ID from the click event
    #district_name <- districts$NUTS_NAME[districts$district_id == district_id]
    
    # Retrieve the data for the selected district
    district_data <- voting_shares[voting_shares_radar$NUTS_CODE == district_id, -1]  
    
    # Add rows for min and max values
    data <- rbind(district_data, rep(1, ncol(district_data)))  
    data <- rbind(rep(1, ncol(data)), rep(0, ncol(data)), data)  
    return(data)
  })
  
  observeEvent(input$map_shape_click, {
    clicked_district <- input$map_shape_click$id
    print(clicked_district)
    if (!is.null(clicked_district)) {
      # Update radar chart for the clicked district
      output$radarChart <- renderPlotly({
        district_data <- voting_shares[voting_shares_radar$NUTS_CODE == clicked_district, -1]
        print(district_data)
        chart_data <- rbind(rep(1, ncol(district_data)), rep(0, ncol(district_data)), district_data)
        radarchart(
          chart_data, axistype = 1,
          pcol = rgb(0.2, 0.5, 0.8, 0.7),
          pfcol = rgb(0.2, 0.5, 0.8, 0.5),
          plwd = 2, plty = 1,
          title = paste("Radar Chart for", clicked_district)
        )
      })
      updateTabsetPanel(session, "tabs", selected = "radarTab")
    }
 })
}