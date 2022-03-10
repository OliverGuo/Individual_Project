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
#register_google(key = "AIzaSyAnGi82u7r4pOg8fYXC_dugPcMeiA2OMf8")
uber <- read_csv("uber_county.csv")
# nyc_counties is a Simple Feature object that contains the geospacial data of counties in NYC
nyc_counties <- filter(counties("New York"), NAME %in% c("Bronx", "Kings", "New York", "Queens", "Richmond"))
# nyc converts all county names to lowercase
nyc <- mutate(nyc_counties, name = tolower(nyc_counties$NAME))

# df_uber_with_county filters trips that happen in NYC only and count their occurences across counties
df_uber_with_county <- uber %>%
    filter(counties %in% c("bronx", "kings", "new york", "queens", "richmond")) %>%
    group_by(counties) %>%
    summarize(total=n())
# number of pickups based on date
df_uber_date <- uber %>%
    group_by(date) %>%
    summarize(total=n())
# number of pickups based on time
df_uber_time <- uber %>%
    group_by(time) %>%
    summarize(total=n())

# merged merges the dataframe and county geospacial data
merged <- left_join(nyc, df_uber_with_county, by = c("name" = "counties"))
# Creating color bins based on the data range
bins <- c(0, 200, 3000, 32000, 38000, 500000)
pal <- colorBin("Blues", domain = merged$total, bins = bins)

# Getting rid of rows with NA values
merged <- subset(merged, !is.na(total))


# Define server logic required to draw a leaflet map
shinyServer(function(input, output) {
    
    output$ubermap <- renderLeaflet({
        
        # Setting up the pop up text
        popup_sb <- paste0("Total pickups in ",  
        as.character(merged$NAME)," : ",
        as.character(merged$total))
        leaflet(merged) %>%
          addProviderTiles(providers$CartoDB.Positron) %>%
          setView(-73.9, 40.7, zoom = 9) %>%
          addPolygons(data = merged,
                      fillColor = ~pal(merged$total),
                      fillOpacity = 0.8,
                      weight = 0.2,
                      smoothFactor = 0.2,
                      popup = ~popup_sb) %>%
          addLegend(
            "bottomright",
            pal = pal,
            values = merged$total,
            title = "Pickups frequency")
    })
    output$Date <- renderPlot({
        p <- ggplot(df_uber_date,
                    aes(x = date, y = total)) +
            geom_line(color="steelblue") +
            geom_point()
        p + scale_x_date(limit = c(as.Date(input$dateRange[1]), 
        as.Date(input$dateRange[2])),
                         date_labels = "%b %d")
    })
    output$Time <- renderPlot({
        p <- ggplot(df_uber_time, 
                    aes(x = time, y = total)) +
            geom_line() +
            geom_path() +
            scale_x_time(limit = c(as_hms(input$timeStart), as_hms(input$timeEnd)))
        p
    })

})
