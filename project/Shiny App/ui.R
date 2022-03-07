library(shiny)
library(tidyverse)
library(leaflet)
library(tigris)
library(dplyr)
library(shinyTime)
library(shinydashboard)




shinyUI(fluidPage(

    # Application title
    titlePanel("NYC Uber Pickups"),

    #
    sidebarLayout(
        sidebarPanel(
            dateRangeInput(
                "dateRange",
                label = "Please choose date range:",
                start = "2014-6-1",
                end = "2014-6-30",
                min = "2014-6-1",
                max = "2014-6-30",
                startview = "month",
            ),
            
            dateInput("dateInput", "Please choose a date:",
                      value = "2014-06-01",
                      min = "2014-06-01", 
                      max = "2014-06-30"),
            
            timeInput("timeInput", "Please choose a time:", 
                      value = Sys.time())
        ),

        
        mainPanel(
            leafletOutput("ubermap"),
            plotOutput("Date"),
            plotOutput("Time")
        )
    ),
    
    column(6,
           
           verbatimTextOutput("dateRangeText"),
           
    )
))
