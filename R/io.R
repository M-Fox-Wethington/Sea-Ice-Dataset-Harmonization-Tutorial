# ---------------------------------------------------------------------------
# io.R: load the daily sea-ice clips as a dated raster stack.
# ---------------------------------------------------------------------------

# Load every GeoTIFF in `dir` into one multi-layer SpatRaster, sorted by the
# YYYYMMDD date embedded in each filename, with terra::time() and layer names
# set to those dates. Both products in this tutorial carry the date as an
# 8-digit run in the filename, so one helper serves both.
load_sic_stack <- function(dir, pattern = "\\.tif$") {
  files <- sort(list.files(dir, pattern = pattern, full.names = TRUE))
  if (length(files) == 0) stop("No rasters found in: ", dir)
  date_str <- regmatches(basename(files), regexpr("[0-9]{8}", basename(files)))
  dates <- as.Date(date_str, "%Y%m%d")
  r <- terra::rast(files)
  terra::time(r) <- dates
  names(r) <- format(dates, "%Y-%m-%d")
  r
}

# Convenience: pull the layer dates back out of a stack as a Date vector.
stack_dates <- function(r) as.Date(terra::time(r))

# Convert a single raster layer to a data frame (x, y, value) for plotting with
# ggplot2::geom_raster. Keeping NA cells lets a land mask show through. This
# avoids a tidyterra dependency and matches the approach used in the paper code.
rast_to_df <- function(r, value_name = "value") {
  stopifnot(terra::nlyr(r) == 1)
  df <- terra::as.data.frame(r, xy = TRUE, na.rm = FALSE)
  names(df)[3] <- value_name
  df
}
