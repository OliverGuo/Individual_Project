library(shiny)
library(tidyverse)
library(shinydashboard)
library(sp)
library(leaflet)
library(stringr)
library(maps)
library(maptools)
library(tigris)
library(dplyr)
library(openair)
#register_google(key = "AIzaSyAnGi82u7r4pOg8fYXC_dugPcMeiA2OMf8")
uber <- read_csv("uber_county.csv")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    output$ubermap <- renderLeaflet({
        #nyc <- county_subdivisions("New York", c("Bronx", "Kings", "New York", "Queens", "Richmond"))
        all_counties <- filter(counties("New York"), NAME %in% c("Bronx", "Kings", "New York", "Queens", "Richmond"))
        nyc <- mutate(all_counties, name = tolower(all_counties$NAME))
        
        nyc_county <- uber %>%
          filter(counties %in% c("bronx", "kings", "new york", "queens", "richmond")) %>%
          group_by(counties) %>%
          summarize(total=n())
        
        # Now we use the Tigris function geo_join to bring together 
        # the states shapefile and the sb_states dataframe -- STUSPS and state 
        # are the two columns they'll be joined by
        
        merged <- left_join(nyc, nyc_county, by = c("name" = "counties"))
        # Creating a color palette based on the number range in the total column
        #pal <- colorNumeric("Greens", merged$total)
        #pal <- colorQuantile("Blues", merged$total, n = 10)
        bins <- c(0, 200, 3000, 32000, 38000, 500000)
        pal <- colorBin("Blues", domain = merged$total, bins = bins)
        
        
        # # Getting rid of rows with NA values
        # # Using the Base R method of filtering subset() because we're dealing with a SpatialPolygonsDataFrame and not a normal data frame, thus filter() wouldn't work
        
        merged <- subset(merged, !is.na(total))
        
        # Setting up the pop up text
        popup_sb <- paste0("Total pickups in ", as.character(merged$NAME)," : ", as.character(merged$total))
        leaflet(merged) %>%
          addProviderTiles(providers$CartoDB.Positron) %>%
          setView(-73.9, 40.7, zoom = 10) %>%
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

})
