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
      id = "sidebar", width = 4,
      h3("Parameters", style = "font-weight: 700;"),
      
      withMathJax(), # for latex-ish mathjax code (how? Look into the input widgets)
      
      br(), # fill in space
      
      # Text input
      textInput("seed", label = "Set a seed", value = "123"),

      radioButtons("radio", label = "No. of observations",
                   choices = list("10" = 1, "100" = 2, "1000" = 3),
                   selected = 3),

      # Select Box / Dropbdown Input
      selectInput("select",
                  label = "\\( \\mu_1 \\)", #mathjax: \\( and \\) for math mode, \\LATEXRULE
                  choices = list("0", "-2", "2"),
                  selected = 1),

      # Slider input
      sliderInput("slider",
                  "\\( \\sigma_1 \\)",
                  value = 1,
                  min = 0.1,
                  max = 3,
                  step = 0.1),
      
      conditionalPanel("input.tabs == 1",
                       # Checkbox input
                       checkboxInput("checkbox", label = "Color the density", value = FALSE))
      
      # for further widgets see: https://shiny.rstudio.com/gallery/widget-gallery.html
      # or to render an input Widget in the server and call "uiOutput("...") in the ui: https://shiny.rstudio.com/reference/shiny/1.4.0/renderui
      # see other shinys for Code if the examples do not help
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      tags$head(tags$script(src="template.js")),
      
      # Output: tabsetPanel only needed for several tabs
      tabsetPanel(type = "tabs", id = "tabs",
                  tabPanel("Map",value = 1,
                           br(),
                           leafletOutput("map", height = "600px"))
      )
    )
  ),
  uiOutput("fusszeile")
)

