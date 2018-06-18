library(shiny)
library(shinydashboard)
library(googlesheets)
library(rvest)
library(dplyr)
library(stringr)
library(DT)
library(shinyjs)

source("helpers.R")

ui <- dashboardPage(
  skin = "black", title = "Shiny Music Player",

  dashboardHeader(title = "Shiny Music Player", titleWidth = 350,

                  tags$li(a(href = 'http://github.com/paulc91',
                            target = "_blank",
                            icon("github"),
                            title = "See the code on github"),
                          class = "dropdown")
                  ),

  dashboardSidebar(width = 350,

                   textInput("track_url", "URL", placeholder = "YouTube, Soundcloud, bandcamp etc..."),

                   withBusyIndicatorUI(
                     shinyjs::disabled(
                       actionButton("get_track", "Add to Library", icon = icon("plus-circle"),
                                    style = "display: inline-block; color: #fff;", class = "btn-primary",
                                    title = "Enter a track URL from either YouTube, Soundcloud, Bandcamp, Mixcloud or Spotify")
                     )
                   ),

                   tags$hr(),

                   uiOutput("video")
  ),

  dashboardBody(

    useShinyjs(),

    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
      tags$script(src="toTop.js"),
      includeHTML("meta.html")
    ),

    fluidRow(

      div(class = "col-md-12",

          tabBox(width = NULL,

                 tabPanel("Library", fluidRow(column(12, DT::dataTableOutput("table")))),

                 tabPanel("About", 
                          fluidRow(
                          column(9, id = "about", 
                                 includeMarkdown("README.md")
                                 )
                          )
                 )

          )
      ),

      # back to top button with javascript functions attached via the toTop.js script in wwww/ folder
      HTML('<a id="back-to-top" href="#" class="btn back-to-top" role="button"><span class="fa fa-angle-up fa-2x"></span></a>')
    )
  )
)

server <- function(input, output, session) {

  observeEvent(input$track_url, {
    shinyjs::toggleState("get_track", any(str_detect(input$track_url, service_options)))
  })

  rv <- reactiveValues(tracks = gs_key(sheet_key) %>% gs_read_csv() %>% arrange(desc(Added)))

  observeEvent(input$get_track, {

    req(input$track_url)

    withBusyIndicatorServer("get_track", {

      new_track <- get_meta(input$track_url)

      gs_key(sheet_key) %>%
        gs_add_row(input = new_track)

      rv$tracks <- gs_key(sheet_key) %>% gs_read_csv() %>% arrange(desc(Added))

    })

  })

  output$table <- DT::renderDataTable({

    dt_dat <- rv$tracks %>% select(Artwork, Added, Track)

    DT::datatable(dt_dat, selection = "single", rownames = F, filter = "none", escape = FALSE,
                  caption = "hover images for track description",
                  options = list(pageLength = 50, lengthMenu = c(10, 25, 50, 100, 200))) %>%
      formatDate("Added", method = "toLocaleDateString")

  })

  output$video <- renderUI({

    if (!is.null(input$table_row_last_clicked)) {

      embed <- isolate(rv$tracks[input$table_row_last_clicked, "Embed", drop = TRUE])

      div(style = "padding: 0; position: fixed; bottom: 0;",
          HTML(paste0('<iframe width="350" height="305" allow="autoplay" src="', embed,'" frameborder="0" allowfullscreen></iframe>'))
      )
    } else {
      div(class = "text-center", helpText("Click on a track in the library to load the media player"))
    }

  })

}

shinyApp(ui, server)
