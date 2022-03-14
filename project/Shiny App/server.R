library(shiny)
library(tidyverse)
library(shinydashboard)
library(sp)
library(chron)
library(leaflet)
library(stringr)
library(maps)
library(maptools)
library(hms)
library(tigris)
library(dplyr)
library(openair)
options(tigris_use_cache = TRUE)

# reading dataset and files
uber <- read_csv("uber_county.csv")
merged <- readRDS("df_shapefile")
df_uber_date <- readRDS("df_date")
df_uber_time <- readRDS("df_time")

# Creating color bins based on the data range
bins <- c(0, 200, 3000, 32000, 38000, 500000)
pal <- colorBin("Blues", domain = merged$total, bins = bins)

# Getting rid of rows with NA values
merged <- subset(merged, !is.na(total))


function(input, output) {
  output$ubermap <- renderLeaflet({
    # Setting up the pop up text
    
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      setView(-73.9, 40.7, zoom = 10)
  })
  
  observe({
    type <- input$type
    if (type == "choropleth") {
      popup_sb <- paste0(
        "Total pickups in ",
        as.character(merged$NAME),
        " : ",
        as.character(merged$total)
      )
      
      leafletProxy("ubermap", data = merged) %>%
        clearShapes() %>%
        addPolygons(
          data = merged,
          fillColor = ~ pal(merged$total),
          fillOpacity = 0.8,
          weight = 0.2,
          smoothFactor = 0.2,
          popup = ~ popup_sb
        ) %>%
        
        addLegend(
          "bottomright",
          pal = pal,
          values = merged$total,
          title = "Pickups frequency"
        )
    }
  })
  
  observe({
    type <- input$type
    if (type == "bubble") {
      df <- uber %>%
        select(-Base) %>%
        filter(
          as.Date(uber$date) == as.Date(input$dateInput) &
            as_hms(uber$time) >= as_hms(input$time_range_start) &
            as_hms(uber$time) <= as_hms(input$time_range_end)
        )
      map_data <- df
      popup_sb <-
        paste0("Pickup time ",  " : ", as.character(df$time))
      leafletProxy("ubermap", data = map_data) %>%
        clearShapes() %>%
        clearControls() %>%
        addCircles(
          ~ Lon,
          ~ Lat,
          popup = ~ popup_sb,
          weight = 3,
          radius = 40,
          color = "#0989de",
          stroke = TRUE,
          fillOpacity = 0.8
        )
    }
    
  })
  
  
  output$Date <- renderPlot({
    p <- ggplot(df_uber_date,
                aes(x = date, y = total)) +
      geom_line(color = "steelblue") +
      geom_point() +
      scale_x_date(limit = c(as.Date(input$dateRange[1]), as.Date(input$dateRange[2])),
                   date_labels = "%b %d")
    p + labs(title = "Total uber pickup based on date")
  })
  
  output$Time <- renderPlot({
    p <- ggplot(df_uber_time,
                aes(x = time, y = total)) +
      geom_line(color = "steelblue") +
      scale_x_time(limit = c(as_hms(input$timeStart), as_hms(input$timeEnd)))
    p + labs(title = "Total uber pickup based on date")
  })
  
}
