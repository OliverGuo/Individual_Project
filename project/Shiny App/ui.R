library(shiny)
library(tidyverse)
library(leaflet)
library(tigris)
library(chron)
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
            
            sliderInput(
              inputId = "timeRange",
              label = "Please choose the time range",
              min = period_to_seconds(hms("00:00:00")),
              max = period_to_seconds(hms("23:59:59")),
              value = c(period_to_seconds(hms("07:00:00")) , period_to_seconds(hms("17:00:00")) )
  
              ),
            
            dateInput("dateInput", "Please choose a date:",
                      value = "2014-06-01",
                      min = "2014-06-01", 
                      max = "2014-06-30"),
            
            timeInput("timeStart", "Start:", 
                      value = as_hms("00:00:00")),
            
            timeInput("timeEnd", "End:", 
                      value = as_hms("23:59:59"))
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
