# Load the necessary libraries
library(terra)
library(elevatr)
library(tidycensus)
library(sf)

# FIPS codes for Tuolumne County and California
county_fips <- "109"  # FIPS code for Tuolumne County
state_fips <- "06"    # FIPS code for California

# Get the census data for Tuolumne County using the correct variable
county_sf <- tidycensus::get_decennial(
  geography = "county", 
  variables = "P1_001N",  # Correct variable for total population (2020 census)
  state = state_fips, 
  county = county_fips, 
  geometry = TRUE
)

# Ensure that the county_sf object contains the boundary geometry of Tuolumne County
head(county_sf)

# Plot the county boundary to confirm
plot(st_geometry(county_sf))

# Extract DEM data as a raster for Tuolumne County
dem_raster <- elevatr::get_elev_raster(
  county_sf,  # This is the boundary of Tuolumne County
  z = 10      # Set zoom level, 10 is a good level for county-scale data
)

# Plot the DEM raster
plot(dem_raster, main = "DEM of Tuolumne County")

# Convert the county boundary to a Spatial object
county_sp <- as(county_sf, "Spatial")

# Convert the DEM to a terra raster if it's not already in 'terra' format
dem_terra <- rast(dem_raster)

# Convert the county boundary to SpatVector format (required for terra package)
county_vect <- vect(county_sp)

# Clip the DEM using the county boundary
dem_clipped <- mask(dem_terra, county_vect)

# Plot the clipped DEM
plot(dem_clipped, main = "Clipped DEM of Tuolumne County")

# Save the clipped DEM to a GeoTIFF file, overwrite if the file already exists
writeRaster(dem_clipped, "clipped_dem.tif", filetype = "GTiff", overwrite = TRUE)

