library(shiny)
library(mapgl)

ui <- fluidPage(
  story_map(
    map_id = "map",
    sections = list(
      "intro" = story_section(
        "Introduction",
        "Welcome to the Eastern Caribbean! Explore the unique charm of its islands."
      ),
      "antigua" = story_section(
        "Antigua & Barbuda",
        "Discover the vibrant culture and stunning beaches of Antigua & Barbuda."
      ),
      "barbados" = story_section(
        "Barbados",
        "Experience the rich history and natural beauty of Barbados."
      ),
      "st_lucia" = story_section(
        "St. Lucia",
        "Enjoy the lush landscapes and iconic Pitons of St. Lucia."
      )
    )
  )
)

server <- function(input, output, session) {
  output$map <- renderMapboxgl({
    mapboxgl(scrollZoom = FALSE)
  })
  
  # Introduction: show a general Eastern Caribbean view
  on_section("map", "intro", {
    mapboxgl_proxy("map") |>
      fly_to(
        center = c(-61, 15),  # Approximate center for the Eastern Caribbean
        zoom = 7,
        pitch = 0,
        bearing = 0
      )
  })
  
  # Antigua & Barbuda
  on_section("map", "antigua", {
    mapboxgl_proxy("map") |>
      fly_to(
        center = c(-61.8, 17.1),  # Approximate coordinates for Antigua
        zoom = 10,
        pitch = 30,
        bearing = 0
      )
  })
  
  # Barbados
  on_section("map", "barbados", {
    mapboxgl_proxy("map") |>
      fly_to(
        center = c(-59.5, 13.1),  # Approximate coordinates for Barbados
        zoom = 10,
        pitch = 30,
        bearing = 0
      )
  })
  
  # St. Lucia
  on_section("map", "st_lucia", {
    mapboxgl_proxy("map") |>
      fly_to(
        center = c(-61.0, 13.9),  # Approximate coordinates for St. Lucia
        zoom = 10,
        pitch = 30,
        bearing = 0
      )
  })
}

shinyApp(ui, server)
