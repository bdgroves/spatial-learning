# Install necessary packages
install.packages(c("shiny", "terra", "elevatr", "tidycensus", "sf"))

# Load libraries
library(shiny)
library(terra)
library(elevatr)
library(tidycensus)
library(sf)

# Define UI for the app
ui <- fluidPage(
  
  # App title
  titlePanel("Clipped DEM for County"),
  
  # Sidebar with inputs for state and county
  sidebarLayout(
    sidebarPanel(
      textInput("state", "Enter State FIPS Code", "06"),  # Default is California (FIPS code 06)
      textInput("county", "Enter County FIPS Code", "109"),  # Default is Tuolumne County (FIPS code 109)
      actionButton("goButton", "Generate DEM"),
      downloadButton("downloadMap", "Download Clipped DEM")
    ),
    
    # Main panel for displaying outputs
    mainPanel(
      plotOutput("demPlot"),
      textOutput("status")
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Reactive value to store the clipped DEM raster
  clipped_dem <- reactiveVal(NULL)
  
  observeEvent(input$goButton, {
    # Fetch state and county FIPS codes from input
    state_fips <- input$state
    county_fips <- input$county
    
    # Get the census data for the given county
    county_sf <- tryCatch({
      tidycensus::get_decennial(
        geography = "county", 
        variables = "P1_001N",  # Correct variable for total population (2020 census)
        state = state_fips, 
        county = county_fips, 
        geometry = TRUE
      )
    }, error = function(e) {
      return(NULL)
    })
    
    if (is.null(county_sf)) {
      output$status <- renderText("Error: Invalid state or county FIPS code.")
      return()
    }
    
    # Extract DEM data as a raster for the given county
    dem_raster <- elevatr::get_elev_raster(
      county_sf,  # This is the boundary of the county
      z = 10      # Set zoom level, 10 is a good level for county-scale data
    )
    
    # Convert the county boundary to a Spatial object
    county_sp <- as(county_sf, "Spatial")
    
    # Convert the DEM to a terra raster if it's not already in 'terra' format
    dem_terra <- rast(dem_raster)
    
    # Convert the county boundary to SpatVector format (required for terra package)
    county_vect <- vect(county_sp)
    
    # Clip the DEM using the county boundary
    dem_clipped <- mask(dem_terra, county_vect)
    
    # Store the clipped DEM
    clipped_dem(dem_clipped)
    
    # Plot the clipped DEM
    output$demPlot <- renderPlot({
      plot(dem_clipped, main = paste("Clipped DEM for", county_fips, "County"))
    })
    
    output$status <- renderText("DEM successfully generated!")
  })
  
  # Allow the user to download the clipped DEM as a GeoTIFF file
  output$downloadMap <- downloadHandler(
    filename = function() {
      paste("clipped_dem_", Sys.Date(), ".tif", sep = "")
    },
    content = function(file) {
      writeRaster(clipped_dem(), file, filetype = "GTiff", overwrite = TRUE)
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)
