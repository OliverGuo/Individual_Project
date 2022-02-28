library(tidyverse)
library(ggplot2)
library(sp)
library(dplyr)
library(tigris)
library(leaflet)
library(stringr)
library(maps)
library(maptools)


uber <- read_csv("uber.csv", na = ".")

# The single argument to this function, pointsDF, is a data.frame in which:
#   - column 1 contains the longitude in degrees (negative in the US)
#   - column 2 contains the latitude in degrees
# Downloading the shapefiles for states at the lowest resolution


# nyc %>%
#   leaflet() %>%
#   addTiles() %>%
#   addPolygons(popup=~NAME)

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

new_uber <- mutate(uber, counties)

write_csv(new_uber, "uber_county.csv")
