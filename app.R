library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(DT)
library(here)
library(tidyverse)

source(here::here('modules', '01_aggregated', 'aggregated_module.R'))
source(here::here('modules', '02_disaggregated', 'disaggregated_module.R'))

ui <- dashboardPage(skin = "purple",
                    title = "DataBlaze - Instructor information",
                    dashboardHeader(
                      title = img(style = "align:top; margin:-15px -250px;",
                                  src="transparent-d-data-white.png",
                                  width="50",
                                  height="50",
                                  alt="Dixie Data"
                      )
                    ),
                    dashboardSidebar(
                      sidebarMenu(
                        menuItem("Aggregated data", tabName='agg_tab'),
                        menuItem("Disaggregated data", tabName='disagg_tab')
                      )
                    ),
                    dashboardBody(
                      tags$head(
                        tags$link(rel="stylesheet", type="text/css", href="dash_theme.css")
                      ),
                      tabItems(
                        tabItem('agg_tab', Aggregated_UI('agg')),
                        tabItem('disagg_tab', disaggregated_UI('disagg'))
                      )
                    )  
)

server <- function(input, output, session) {
  callModule(aggregated_server, 'agg')
  callModule(disaggregated_server, 'disagg')
}

shinyApp(ui, server)
