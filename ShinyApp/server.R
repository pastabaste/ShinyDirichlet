# Call the helpers file
source("helpers.R")
source("data_preprocessing.R")

# Define server logic for app ----
server <- function(input, output, session) {
  fusszeile <- div(class = "containerlow", tags$text(
    paste0(
      "University of Goettingen, Faculty of Business and
                                    Economics, Chair of Spatial Data Science and Statistical Learning"
    )
  ), #tags$br(),
  tags$text(paste0(
    "Project: Elections based on INKAR Data by Lukas Brüwer"
  )))
  
  output$fusszeile <- renderUI({
    fusszeile
  })
  # Map Kreise
  output$map <- renderLeaflet({
    leaflet(data = data) %>%
      #addProviderTiles(providers$Esri.WorldImagery) %>% # background
      addPolygons(
        color = "black",
        weight = 1,
        fillColor = ~ color_incumbant,
        fillOpacity = 0.6,
        highlightOptions = highlightOptions(
          color = "white",
          # Border color on highlight
          weight = 3,
          # Border thickness on highlight
          fillOpacity = 0.9,
          # Fill opacity on highlight
          bringToFront = TRUE # Brings the highlighted polygon to the front
        ),
        popup = ~ paste0(
          "<strong>District: </strong>",
          KR,
          "<br>",
          "<strong>Incumbant Party: </strong>",
          incumbant_party
        ),
        label = ~ paste0(KR, "\n"),
        labelOptions = labelOptions(
          style = list("color" = "black"),
          textsize = "12px",
          direction = "auto"
        ),
        layerId = ~ KR
      ) %>%
      addLegend(
        "bottomright",
        # Position of the legend
        colors = c("black", "blue", "yellow", "red", "green", "purple", "grey"),
        # Colors for each party
        labels = c("CDU/CSU", "AfD", "FDP", "SPD", "Grüne", "Left", "Others"),
        # Party names
        title = "Incumbant Party",
        opacity = 0.6
      ) %>%
      addEasyButton(easyButton(
        icon = "fa-crosshairs",
        title = "Zoom to Clicked County",
        onClick = JS(
          "function(btn, map) {
           map.on('click', function(e) {
              map.setView(e.latlng, map.getZoom());
           });
        }"
        )
      ))
  })
  # reactive radar chart (triggered by click on district)
  observeEvent(input$map_shape_click, {
    clicked_district <- input$map_shape_click$id
    if (!is.null(clicked_district)) {
      # Update radar chart for the clicked district
      output$radarChart <- renderPlot({
        district_data <- voting_shares_radar[voting_shares_radar$KR == clicked_district, -1]
        chart_data <- rbind(rep(1, ncol(district_data)),
                            rep(0, ncol(district_data)),
                            district_data,
                            rep(1, ncol(district_data)
                                ))
        radarchart(chart_data,
          axistype = 1,# standard axis
          pcol = "grey27", # polygon bordor color
          pfcol = adjustcolor("white", 0.2), # polygon fill color
          plwd = 2, # line width
          plty = 1, # line type
          cglcol = "grey80", # grind line color
          cglty = 2, # grid line type (solid)
          cglwd = 0.8, # grid line width
          axislabcol = "grey30", # axis label color
          vlcex = 0.8, # axis label font size
          title = paste("Share of Votes for", clicked_district),
          cex.main = 0.85, # title font size
          caxislabels = c("0%", "25%", "50%", "75%", "100%") # Custom grid labels
        )
        # Add an annotation
        legend("bottomright", legend = c("Actual Shares"), col = "grey80", pch = 15, bty = "n", cex = 1)
        
        
        
      })
      updateTabsetPanel(session, "tabs", selected = "radarTab")
    }
  })
  # data - view 
  output$dataTable <- renderDT({
    datatable(
      data[,],
      options = list(
        pageLength = 10,  # Number of rows per page
        autoWidth = TRUE, # Adjust column widths
        dom = "tip",      # Simplified interface (table, info, pagination)
        scrollX = TRUE
      )
    )
  })
  # data - download via dropdown
  output$downloadData <- downloadHandler(
    filename = function() {
      print(paste0("data.", input$downloadFormat))  # Debugging: log filename
      paste0("data.", input$downloadFormat)
    },
    content = function(file) {
      format <- input$downloadFormat
      print(format)
      if (format == "csv") {
        write_csv(data, file, row.names = FALSE)
      } else if(format == "xlsx") {
        write.xlsx(data, file)
      }
      else if(format == "rds") {
      saveRDS(data, file)
    } }
  )
}