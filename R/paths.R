# ---------------------------------------------------------------------------
# Central configuration and path resolution for the tutorial.
#
# Every chapter sources this file. It does two things:
#   1. Defines the analysis constants in one place (sih_config), so the
#      threshold, winter months, target grid, and model settings are never
#      hardcoded in more than one spot.
#   2. Resolves where the data lives (sih_paths()), switching between the
#      bundled sample and your own full download via the SIH_MODE environment
#      variable.
#
# Usage at the top of a chapter:
#   source(here::here("R", "paths.R"))
#   paths <- sih_paths()
# ---------------------------------------------------------------------------

# Analysis constants -------------------------------------------------------

sih_config <- list(
  # Canonical analysis grid. Both products are distributed (and clipped here)
  # on the WGS 84 NSIDC Sea Ice polar stereographic projection (EPSG:3976), so
  # no cross-CRS reprojection is needed between them. We harmonize toward the
  # 12.5 km AMSR grid: the coarse 25 km Sea Ice Index is resampled onto that
  # grid, while the fine AMSR reference is never resampled and is preserved
  # exactly.
  target_crs    = "EPSG:3976",

  # Sea-ice extent threshold: a cell counts as ice-covered at SIC >= 0.15.
  ice_threshold = 0.15,

  # Austral winter sea-ice season for the western Antarctic Peninsula.
  winter_months = c(6, 7, 8, 9),

  # Reproducibility seed used for the train/test split and model fitting.
  seed          = 123,

  # ANN hyperparameter search grid (passed to nnet via a tuning loop).
  ann_size_grid  = c(3, 5, 7, 10, 15),
  ann_decay_grid = c(0.01, 0.001, 0.0001),

  # Final ANN hyperparameters selected in the paper.
  ann_size  = 7,
  ann_decay = 0.001,
  ann_maxit = 1500,

  # Fraction of paired pixels used for training (remainder is held out).
  train_frac = 0.8
)

# Mode and path resolution -------------------------------------------------

# Returns "sample" (default) or "full". Set SIH_MODE=full in your environment
# to point the pipeline at your own downloaded data.
sih_mode <- function() {
  Sys.getenv("SIH_MODE", unset = "sample")
}

# Resolve the directory layout for the active mode.
#   sample -> data/sample/ in the repo (small, committed, runs in minutes)
#   full   -> SIH_DATA_ROOT if set, else data/full/ in the repo
sih_paths <- function(mode = sih_mode()) {
  base <- if (identical(mode, "sample")) {
    here::here("data", "sample")
  } else {
    Sys.getenv("SIH_DATA_ROOT", unset = here::here("data", "full"))
  }

  list(
    mode       = mode,
    base       = base,
    # Daily per-product clips
    amsr_dir   = file.path(base, "amsr_12km"),
    nsidc_dir  = file.path(base, "nsidc_25km_seaiceindex"),
    # Ancillary layers
    land_mask  = file.path(base, "land_mask", "land_mask.tif"),
    study_area = file.path(base, "study_area", "wap_study_area.gpkg"),
    # Pre-computed outputs shown for the frozen full-record steps
    frozen     = here::here("data", "sample", "frozen"),
    # Scratch space written by early chapters and read by later ones
    work       = here::here("_work")
  )
}

# Create the scratch directory if it does not yet exist, and return its path.
sih_work_dir <- function() {
  w <- sih_paths()$work
  if (!dir.exists(w)) dir.create(w, recursive = TRUE, showWarnings = FALSE)
  w
}
