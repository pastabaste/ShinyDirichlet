# Call the helpers file
source("helpers.R")

# Define server logic for app ----
server <- function(input, output, session) {
  
  fusszeile <- div(class = "containerlow",
                   tags$text(paste0("University of Goettingen, Faculty of Business and 
                                    Economics, Chair of Spatial Data Science and Statistical Learning")),
                   #tags$br(),
                   tags$text(paste0("Project: ENTER YOUR PROJECT NAME by ENTER YOUR NAME"))
  )
  
  output$fusszeile <- renderUI({
    fusszeile
  })
  a = 10,
  
  
  # adjust the template from here on
  dat_react <- reactive({
    s <- as.numeric(input$seed)
    
    if (input$radio == 1) {
      n <- 10
    } else if (input$radio == 2) {
      n <- 100
    } else if (input$radio == 3) {
      n <- 1000
    }
    
    m <- as.numeric(input$select)
    va <- input$slider
    
    set.seed(s)
    dat <- rnorm2(n, m, sqrt(va))
    dens <- density(dat)
    empV <- round(var(dat), 4)
    empsd <- round(sd(dat), 4)
    
    empMu <- round(mean(dat), 4)
    
    x_s <- m - 3 * sqrt(va)
    x_l <- m + 3 * sqrt(va)
    
    return(list(dat = dat, dens = dens, empMu = empMu, x_s = x_s, x_l = x_l))
  })
  
  output$histogram <- renderPlot({
    dat_r <- dat_react()
    
    dat <- dat_r$dat
    dens <- dat_r$dens
    empMu <- dat_r$empMu
    x_s <- dat_r$x_s
    x_l <- dat_r$x_l
    
    hist(dat, breaks = 20, freq = F,
         xlab = "Distribution of the data",
         main = "Data",
         xlim = c(x_s, x_l),ylim = c(0, 0.5))
    lines(dens, col = "orange")
    
    if (input$checkbox) {
      polygon(c(dens$x), 
              c(dens$y),
              col = alpha("orange", 0.4))
    }
    
    rug(empMu, col = "red", lwd = 2, ticksize = -0.03)
    rug(empMu, col = "red", lwd = 2, ticksize = 0.1)
  })
  
  output$formula1 <- renderUI({
    Text_b_0 <- paste("
            \\begin{align}
            
            \\textsf{Example formula:} \\\\~\\\\
            
            B_j^{l=0}(z) = I (\\kappa_j \\leq z < \\kappa_{j+1}) \\\\
            \\end{align}

            where \\(l\\) is the degree of the basis functions, \\(\\kappa_j\\) is the
            \\(j\\)-th knot, \\(m\\) is the number of knots and \\(d = m + l -1\\).
            \\(I\\) is an indicator function defined as:

            \\begin{align} \\\\ I (\\kappa_j \\leq z < \\kappa_{j+1}) = \\begin{cases}
            1 & \\kappa_j \\leq z < \\kappa_j+1,\\quad j=1,\\ldots, d-1 \\\\
            0 & \\text{otherwise}. \\end{cases} \\\\ \\\\ \\end{align}
            
            ")
    
    withMathJax(
      helpText(Text_b_0)
    )
  })
  
  output$basicplot <- renderPlot({
    x <- 1:10
    y <- x^2
    
    plot(x,y)
  })
  
  output$plotly <- renderPlotly({
    dat_r <- dat_react()
    dens <- dat_r$dens
    
    # matrix stuff only for the computation time purposes
    A <- matrix(rnorm(1000000, 100, 5), ncol = 1000, nrow = 1000)
    B <- solve(A) %*% A %*% A %*% solve(A)
    
    plot_ly(x = dens$x, y = dens$y, type = 'scatter', mode = 'lines', fill = 'tozeroy')
  })
  
  output$exampletext <- renderText({
    "Here you can add some descriptive, explanatory text as well as formulas. "
  })
  
  # Filter data based on selections
  output$table <- DT::renderDataTable(DT::datatable({
    data <- mpg
    data
  }))
  
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
