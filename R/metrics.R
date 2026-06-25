# ---------------------------------------------------------------------------
# metrics.R: sea-ice metrics computed from a SIC raster stack (values 0-1).
# ---------------------------------------------------------------------------

# Daily sea-ice extent in km^2: the area of all cells at or above the
# concentration threshold (the >= 0.15 convention). Returns one value per layer.
sic_extent_km2 <- function(r, threshold = 0.15) {
  cell_km2 <- prod(terra::res(r)) / 1e6
  counts <- terra::global(r, fun = function(v) sum(v >= threshold, na.rm = TRUE))[, 1]
  counts * cell_km2
}

# Mean regional SIC per layer.
sic_mean <- function(r) {
  terra::global(r, fun = "mean", na.rm = TRUE)[, 1]
}

# Root-mean-square error between two equal-geometry stacks, pooled over all
# cells and layers (the overall validation number).
sic_rmse <- function(a, b) {
  d <- terra::values(a) - terra::values(b)
  sqrt(mean(d^2, na.rm = TRUE))
}

# Per-pixel RMSE through time between two equal-geometry stacks: returns a
# single-layer SpatRaster of RMSE, the spatial view of agreement.
sic_rmse_pixel <- function(a, b) {
  sq <- (a - b)^2
  terra::app(sq, fun = function(x) {
    n <- sum(!is.na(x))
    if (n > 0) sqrt(sum(x, na.rm = TRUE) / n) else NA_real_
  })
}
