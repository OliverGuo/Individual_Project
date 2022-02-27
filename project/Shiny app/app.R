library(shiny)
library(tidyverse)
library(ggmap)
#library(plotly)
library(maps)
library(openair)
register_google(key = "AIzaSyAnGi82u7r4pOg8fYXC_dugPcMeiA2OMf8")
uber <- read_csv("uber.csv", na = ".")
#View(uber)
#print(glimpse(uber))
# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("NYC Uber Pickups"),
    br(),
    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        position = "right",
        sidebarPanel(
            sliderInput(
            inputId = "zoom",
            label = "zoom ratio:",
            min = 3,
            max = 21,
            value = 11),
       
        
        dateRangeInput(
            "dateRange",
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
),

column(6,
       
       verbatimTextOutput("dateRangeText"),
      
)
)


# Define server logic required to draw a histogram
server <- function(input, output) {
  
  zm <- reactive(input$zoom)
  start_date <- reactive(format(input$dateRange[1], "%Y-%m-%d"))
  end_date <- reactive(format(input$dateRange[2], "%Y-%m-%d"))
  uberWithDate <- reactive(selectByDate(uber, start = start_date(), end = end_date(), 
                                        month = c(5, 6), day = 1:31))
  
    # output$dateRangeText  <- renderPrint({
    #     start_date <- format(input$dateRange[1], "%Y-%m-%d")
    #     end_date <- format(input$dateRange[2], "%Y-%m-%d")
    #     selectByDate(uber, start = start_date, end = end_date)
    # })

    output$pickupPlot <- renderPlot({
        
        nyc_map <- get_map(location = 'New York',
                           maptype='roadmap', color='color',source='google', zoom = zm())

        map <- ggmap(nyc_map)
        map +
            geom_point(data = uberWithDate(), aes(x= Lon,y= Lat), size=0.3,alpha=.3)
        
          #geom_point(data = uberWithDate(), aes(x= Lon,y= Lat), size=0.3,alpha=.3)
        
        


    })
}

# Run the application 
shinyApp(ui = ui, server = server)
