#### Preamble ####
# Purpose: Download data on Toronto's street trees using opendatatoronto 
# Author: Ethan Sansom
# Contact: ethan.sansom@mail.utotoronto.ca
# Date: 2022-02-05
# Pre-requisites: None
# Warning: This script saves a large (109.4 MB) CSV file locally

#### Workplace setup ####
library(opendatatoronto)   # For getting data
library(tidyverse)
library(here)              # For file path management

#### Retrieve raw data from Open Data Toronto ####
# Load Toronto city-tree data
raw_tree_data <-
  list_package_resources("6ac4569e-fd37-4cbc-ac63-db3624c5f6a2") |> 
  filter(name == "Alternate File_Street Tree Data_WGS84.csv") |> 
  get_resource()

# Load Toronto ward map data (needed to graph ward boundaries)
raw_ward_map_data <-
  list_package_resources("5e7a8234-f805-43ac-820f-03d7c360b588") |> 
  filter(name == "25-ward-model-december-2018-wgs84-latitude-longitude") |> 
  get_resource()

# Save city-tree data (Warning: "raw_tree_data.csv" is 109.4 MB)
write_csv(raw_tree_data, file = here("inputs/data/raw_tree_data.csv"))

# Save ward map data
write_rds(raw_ward_map_data, file = here("inputs/data/raw_ward_map_data.rds"))

