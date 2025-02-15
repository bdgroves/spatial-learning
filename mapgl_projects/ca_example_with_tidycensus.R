library(shiny)
library(mapgl)
library(tidycensus)
library(tidyverse)
library(sf)

ca_age <- get_acs(
  geography = "tract",
  variables = "B01002_001",
  state = "CA",
  year = 2023,
  geometry = TRUE
) |>
  separate_wider_delim(NAME, delim = "; ", names = c("tract", "county", "state")) %>%
  st_sf()

ui <- fluidPage(
  story_maplibre(
    map_id = "map",
    sections = list(
      "intro" = story_section(
        "Median Age in California",
        content = list(
          selectInput(
            "county",
            "Select a county",
            choices = sort(unique(ca_age$county))
          ),
          p("Scroll down to view the median age distribution in the selected county.")
        )
      ),
      "county" = story_section(
        title = NULL,
        content = list(
          uiOutput("county_text"),
          plotOutput("county_plot")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  
  sel_county <- reactive({
    filter(ca_age, county == input$county)
  })
  
  output$map <- renderMaplibre({
    maplibre(
      carto_style("positron"),
      bounds = ca_age,
      scrollZoom = FALSE
    ) |>
      add_fill_layer(
        id = "ca_tracts",
        source = ca_age,
        fill_color = interpolate(
          column = "estimate",
          values = c(20, 80),
          stops = c("lightblue", "darkblue"),
          na_color = "lightgrey"
        ),
        fill_opacity = 0.5
      ) |>
      add_legend(
        "Median age in California",
        values = c(20, 80),
        colors = c("lightblue", "darkblue"),
        position = "bottom-right"
      )
  })
  
  output$county_text <- renderUI({
    h2(toupper(input$county))
  })
  
  output$county_plot <- renderPlot({
    ggplot(sel_county(), aes(x = estimate)) +
      geom_histogram(fill = "lightblue", color = "black", bins = 10) +
      theme_minimal() +
      labs(x = "Median Age", y = "")
  })
  
  on_section("map", "intro", {
    maplibre_proxy("map") |>
      set_filter("ca_tracts", NULL) |>
      fit_bounds(ca_age, animate = TRUE)
  })
  
  on_section("map", "county", {
    maplibre_proxy("map") |>
      set_filter("ca_tracts", filter = list("==", "county", input$county)) |>
      fit_bounds(sel_county(), animate = TRUE)
  })
  
}

shinyApp(ui, server)