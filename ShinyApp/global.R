# check if pacman is installed, install it if not, then load it 
if (!requireNamespace("pacman", quietly = TRUE)) {
  install.packages("pacman")
}
library(pacman)
library(DirichletReg)
# use pacman to manage other packages
p_load(shiny, 
       DT, 
       ggplot2, 
       plotly, 
       shinyBS,
       shinycssloaders,
       shinydisconnect,
       leaflet,
       leaflet.providers,
       sf,
       ggmap,
       ggplot2,
       DirichReg
       )

# global options

options(spinner.color="#153268", spinner.color.background="#ffffff", spinner.size=2) # defines loading spinner used in plotly template