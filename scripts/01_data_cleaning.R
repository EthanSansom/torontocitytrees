#### Preamble ####
# Purpose: Clean Toronto street tree and ward map data
# Author: Ethan Sansom
# Contact: ethan.sansom@mail.utotoronto.ca
# Date: 2022-02-05
# Pre-requisites:
# - run "00_data_import.R" script

#### Workplace setup ####
library(tidyverse)
library(dplyr)
library(stringr)   # For processing strings
library(janitor)   # For cleaning data
library(sf)        # For working with Shapefile and Polygon objects
library(here)      # For file path management

#### Clean Toronto city-trees data ####
# Load raw data
raw_tree_data <- read_csv(here("inputs/data/raw_tree_data.csv"))

# Select and rename columns needed for analysis 
clean_tree_data <- 
  clean_names(raw_tree_data) |>
  select(x_id, ward, dbh_trunk, geometry) |>
  rename(
    "tree_id" = x_id, 
    "trunk_diameter" = dbh_trunk, # diameter of trunk in inches at 2 meters height
    "coordinates" = geometry      # string containing tree's latitude and longitude
  )

# Drop two observations with missing ward data
clean_tree_data <- filter(clean_tree_data, !is.na(ward))

# Recode trunk diameters of 0 as NA
# line coded with help from: https://stackoverflow.com/questions/11036989/replace-all-0-values-to-na
clean_tree_data$trunk_diameter[clean_tree_data$trunk_diameter == 0] <- NA

# Remove suffix and prefix from observations in the coordinates column
# Resulting observations are strings of the form "longitude, latitude"
clean_tree_data$coordinates <-
  clean_tree_data$coordinates |>
  str_replace(
    pattern = fixed("{u'type': u'Point', u'coordinates': ("), 
    replacement = ""
  ) |>
  str_replace(
    pattern = fixed(")}"), 
    replacement = ""
  )

# Create numeric longitude and latitude variables
clean_tree_data <-
  clean_tree_data |>
  separate(
    col = coordinates,
    into = c('longitude', 'latitude'),
    sep = ", "
  ) |>
  mutate(
    longitude = as.numeric(longitude),
    latitude = as.numeric(latitude)
  )

# Create dummy variable for trunk_diameter greater than 3rd quantile
clean_tree_data <-
  clean_tree_data |>
  mutate(
    is_large = trunk_diameter > quantile(trunk_diameter, 0.75, na.rm = TRUE),
    is_small = trunk_diameter < quantile(trunk_diameter, 0.25, na.rm = TRUE)
  )

# Save cleaned data
write_csv(clean_tree_data, here("inputs/data/clean_tree_data.csv"))

#### Clean Toronto ward map data ####
# Load raw data
raw_ward_map_data <- read_rds(here("inputs/data/raw_ward_map_data.rds"))

# Select and rename columns needed for analysis
clean_ward_map_data <- 
  clean_names(raw_ward_map_data) |>
  select(area_s_cd, area_name, longitude, latitude, geometry) |>
  rename(
    "ward" = area_s_cd,
    "ward_name" = area_name,
  )

# Coerce ward from string to numeric
clean_ward_map_data <- mutate(clean_ward_map_data, ward = as.numeric(ward))

# Create an area of ward in square kilometers numeric variable
clean_ward_map_data <- 
  clean_ward_map_data |>
  mutate(area_meters_sq = st_area(geometry)) |>
  mutate(area_kilometers_sq = as.numeric(area_meters_sq) / 1000**2) |>
  select(-area_meters_sq)

# Save cleaned data
write_rds(clean_ward_map_data, here("inputs/data/clean_ward_map_data.rds"))
