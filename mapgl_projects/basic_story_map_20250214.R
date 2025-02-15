library(shiny)
library(mapgl)

ui <- fluidPage(
  story_map(
    map_id = "map",
    sections = list(
      "intro" = story_section(
        "Introduction",
        "This is a story map."
      ),
      "location" = story_section(
        "Location",
        "Check out this interesting location."
      )
    )
  )
)

server <- function(input, output, session) {
  output$map <- renderMapboxgl({
    mapboxgl(scrollZoom = FALSE)
  })
}

shinyApp(ui, server)