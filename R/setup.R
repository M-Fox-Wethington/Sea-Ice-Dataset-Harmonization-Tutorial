# ---------------------------------------------------------------------------
# setup.R: one-line preamble for every chapter.
#
#   source(here::here("R", "setup.R"))
#
# Loads the common libraries and the tutorial's helper modules. Packages used by
# only one or two chapters (nnet) are loaded in those chapters instead.
# ---------------------------------------------------------------------------

suppressMessages({
  library(here)
  library(terra)
  library(sf)
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(lubridate)
  library(scales)
})

source(here::here("R", "paths.R"))
source(here::here("R", "io.R"))
source(here::here("R", "metrics.R"))
source(here::here("R", "theme.R"))
