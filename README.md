<!-- README.md is generated from README.Rmd. Please edit that file -->

# cloudDemo

<!-- badges: start -->

[![License: GPL (&gt;=
2)](https://img.shields.io/badge/License-GPL%20%28%3E%3D%202%29-blue.svg)](https://choosealicense.com/licenses/gpl-2.0/)
[![Dependencies](https://img.shields.io/badge/dependencies-7/106-orange?style=flat)](#)
<!-- badges: end -->

Research Compendium to demonstrate how to run an analysis in the cloud.

### Steps to create

This compendium was setup by creating a new GitHub repo on GitHub,
cloning it by starting a new project from version control in RStudio,
and running
`rcompendium::new_compendium(create_repo = FALSE, renv = TRUE)`

### Content

This repository is structured as follow:

-   [`data/`](https://github.com/see24/cloudDemo/tree/master/data):
    contains all raw data required to perform analyses

-   [`analyses/`](https://github.com/see24/cloudDemo/tree/master/analyses/):
    contains R scripts to run each step of the workflow

-   [`outputs/`](https://github.com/see24/cloudDemo/tree/master/outputs):
    contains all the results created during the workflow

-   [`figures/`](https://github.com/see24/cloudDemo/tree/master/figures):
    contains all the figures created during the workflow

-   [`R/`](https://github.com/see24/cloudDemo/tree/master/R): contains R
    functions developed especially for this project

-   [`man/`](https://github.com/see24/cloudDemo/tree/master/man):
    contains help files of R functions

-   [`DESCRIPTION`](https://github.com/see24/cloudDemo/tree/master/DESCRIPTION):
    contains project metadata (author, date, dependencies, etc.)

-   [`make.R`](https://github.com/see24/cloudDemo/tree/master/make.R):
    main R script to run the entire project by calling each R script
    stored in the `analyses/` folder

### Usage

Clone the repository, open R/RStudio and run:

    source("make.R")

### Notes

-   All required packages, listed in the `DESCRIPTION` file, will be
    installed (if necessary)
-   All required packages and R functions will be loaded
-   Some analyses listed in the `make.R` might take time
