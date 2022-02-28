library(shiny)
library(tidyverse)
library(leaflet)
library(tigris)
library(dplyr)
library(shinydashboard)



# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("NYC Uber Pickups"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
        ),

        # Show a plot of the generated distribution
        mainPanel(
            leafletOutput("ubermap")
        )
    )
))
