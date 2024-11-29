# call all the necessary packages
library(shiny)
library(DT)
library(ggplot2)
library(plotly)
library(shinyBS)
library(shinycssloaders)
library(shinydisconnect)
options(spinner.color="#153268", spinner.color.background="#ffffff", spinner.size=2)

# you might need to load your data here
# data <- read.csv("mydata.csv")

# only necessary for template
rnorm2 <- function(n, mu, sd) {
  data_sd <- rnorm (n, mu, 1)
  data_sd_m <- mean(data_sd)
  
  data_df <- data_sd - data_sd_m
  
  data_sc <- sd * data_df
  
  data <- data_sd_m + data_sc
  
  return(data)
}