library(shiny)
library(tidyverse)
library(leaflet)
library(tigris)
library(hms)
library(chron)
library(dplyr)
library(shinyTime)

# assign variables to the map type
vars <- c("Choropleth Map" = "choropleth",
          "Bubble Map" = "bubble")

navbarPage(
  "NYC Uber Pickups",
  tabPanel(
    "Interactive Map",
    div(
      id = "map_tab",
      tags$head(# Include custom CSS
        includeCSS("Style.css"),),
      
      leafletOutput("ubermap", width = "100%", height = "100%"),
      
      absolutePanel(
        id = "panel",
        class = "panel panel-default",
        fixed = TRUE,
        draggable = FALSE,
        top = 60,
        left = "auto",
        right = 20,
        bottom = "auto",
        
        width = 500,
        height = "auto",
        
        selectInput("type", "Map Type", vars),
        conditionalPanel(
          "input.type == 'choropleth'",
          h3("Uber pickups among NYC neighborhoods"),
          p(
            "This graph compares the total number of uber pickups
                                                     among each region in New York City."
          )
        ),
        
        # only prompt date and time input if bubble map is selected
        conditionalPanel(
          "input.type == 'bubble'",
          h3("Pickups visualization"),
          p(
            "This map visualizes each individual pickup with respect to time of the day
                                                  on any specific date from 2014/6/1 to 2014/6/30."
          ),
          
          # takes an date as input
          dateInput(
            "dateInput",
            label = "Please select a date:",
            startview = "month",
            value = "2014-6-1",
            min = "2014-6-1",
            max = "2014-6-30"
          ),
          # the start of the time range
          timeInput("time_range_start", "Start:",
                    value = as_hms("09:00:00")),
          # the end of the time range
          timeInput("time_range_end", "End:",
                    value = as_hms("12:00:00"))
        )
      )
      
    ) # end of div
  ),
  
  tabPanel(
    "Date Plot",
    
    dateRangeInput(
      "dateRange",
      label = "Please choose date range:",
      start = "2014-6-1",
      
      end = "2014-6-15",
      min = "2014-6-1",
      max = "2014-6-30",
      startview = "month",
    ),
    
    plotOutput("Date")
    
  ),
  
  tabPanel(
    "Time Plot",
    
    timeInput("timeStart", "Start:",
              value = as_hms("00:00:00")),
    
    timeInput("timeEnd", "End:",
              value = as_hms("23:59:59")),
    
    plotOutput("Time")
  ),
  
  
  
)
