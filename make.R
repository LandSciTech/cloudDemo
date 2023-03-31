#' cloudDemo: A Research Compendium
#' 
#' @description 
#' A paragraph providing a full description of the project and describing each 
#' step of the workflow.
#' 
#' @author Sarah Endicott \email{sarah.endicott@canada.ca}
#' 
#' @date 2023/03/31



## Install Dependencies (listed in DESCRIPTION) ----

renv::restore()


## Load Project Addins (R Functions and Packages) ----

devtools::load_all(here::here())


## Global Variables ----

# You can list global variables here (or in a separate R script)

# set a global ggplot theme
theme_set(theme_classic())

## Run Project ----

# List all R scripts in a sequential order and using the following form:
source(here::here("analyses", "01_run_model.R"))
