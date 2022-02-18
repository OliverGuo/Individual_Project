#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(ggmap)
library(openair)
register_google(key = "AIzaSyAnGi82u7r4pOg8fYXC_dugPcMeiA2OMf8")
uber <- read_csv("uber.csv", na = ".")
#print(glimpse(uber))
# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("NYC Uber pickups"),
    br(),
    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        
        sidebarPanel(
            sliderInput(
            inputId = "zoom",
            label = "zoom ratio:",
            min = 3,
            max = 21,
            value = 11),
       
        
        dateRangeInput(
            inputId = "date",
            label = "Date range:",
            start = "2014-6-1",
            end = "2014-6-30",
            min = "2014-6-1",
            max = "2014-6-30",
            startview = "month",
        )
    ),
        
        mainPanel(
            plotOutput("pickupPlot")
        
    )
)
)


# Define server logic required to draw a histogram
server <- function(input, output) {

    output$pickupPlot <- renderPlot({
        nyc.map <- get_map(location= 'Lower Manhattan, New York', 
                           maptype='roadmap', color='color',source='google', zoom = input$zoom)
        
        ggmap(nyc.map) + 
            geom_point(data = uber, aes(x= Lon,y= Lat), size=0.3,alpha=.3)
        
        
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
