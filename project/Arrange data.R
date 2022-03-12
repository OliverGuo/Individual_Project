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


uber <- read_csv("uber.csv", na = ".")

# The single argument to this function, pointsDF, is a data.frame in which:
#   - column 1 contains the longitude in degrees (negative in the US)
#   - column 2 contains the latitude in degrees
# Downloading the shapefiles for states at the lowest resolution


latlong2county <- function(pointsDF) {
  # Prepare SpatialPolygons object with one SpatialPolygon
  # per county
  counties <- maps::map('county', fill=TRUE, col="transparent", plot=FALSE)
  IDs <- sapply(strsplit(counties$names, ":"), function(x) x[1])
  counties_sp <- map2SpatialPolygons(counties, IDs=IDs,
                                     proj4string=CRS("+proj=longlat +datum=WGS84"))
  
  # Convert pointsDF to a SpatialPoints object 
  pointsSP <- SpatialPoints(pointsDF, 
                            proj4string=CRS("+proj=longlat +datum=WGS84"))
  
  # Use 'over' to get _indices_ of the Polygons object containing each point 
  indices <- over(pointsSP, counties_sp)
  
  # Return the county names of the Polygons object containing each point
  countyNames <- sapply(counties_sp@polygons, function(x) x@ID)
  result <- c(countyNames[indices])
  word(result, 2, sep = fixed(","))
}

# Test the function using points in Wisconsin and Oregon.
testPoints <- data.frame(x = c(-90, -120), y = c(44, 44))

counties <- latlong2county(as.data.frame(select(uber, c("Lon", "Lat"))))

df_uber <- mutate(uber, counties)
# nyc_counties is a Simple Feature object that contains the geospacial data of counties in NYC
nyc_counties <- filter(counties("New York"), NAME %in% c("Bronx", "Kings", "New York", "Queens", "Richmond"))
# nyc converts all county names to lowercase
nyc <- mutate(nyc_counties, name = tolower(nyc_counties$NAME))

# df_uber_with_county filters trips that happen in NYC only and count their occurences across counties
df_uber_with_county <- df_uber %>%
  filter(counties %in% c("bronx", "kings", "new york", "queens", "richmond")) %>%
  group_by(counties) %>%
  summarize(total=n())
# number of pickups based on date
df_uber_date <- df_uber %>%
  group_by(date) %>%
  summarize(total=n())
# number of pickups based on time
df_uber_time <- df_uber %>%
  group_by(time) %>%
  summarize(total=n())

# merged merges the dataframe and county geospacial data
merged <- left_join(nyc, df_uber_with_county, by = c("name" = "counties"))
#write_csv(new_uber, "uber_county.csv")
