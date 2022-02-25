library(shiny)
library(tidyverse)
library(shinydashboard)
#library(ggmap)
library(leaflet)
library(openair)
#register_google(key = "AIzaSyAnGi82u7r4pOg8fYXC_dugPcMeiA2OMf8")
uber <- read_csv("uber.csv", na = ".")


# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    output$distPlot <- renderPlot({

        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white')

    })

})
