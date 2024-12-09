# check if pacman is installed, install it if not, then load it 
if (!requireNamespace("pacman", quietly = TRUE)) {
  install.packages("pacman")
}
library(pacman)
library(DirichletReg)
#remotes::install_github("sumtxt/bonn", force = TRUE)
# use pacman to manage other packages
p_load(shiny, 
       DT, 
       tidyverse, 
       plotly, 
       shinyBS,
       shinyjs,
       shinycssloaders,
       shinydisconnect,
       leaflet,
       leaflet.providers,
       sf,
       ggmap,
       ggplot2,
       fmsb,
       openxlsx
       )


# global options
options(spinner.color="#153268", spinner.color.background="#ffffff", spinner.size=2) # defines loading spinner used in plotly template