# ---------------------------------------------------------------------------
# harmonize.R: the cross-sensor harmonization primitives.
#
# These three functions are the mechanical core of the method. The chapters
# call them and explain what each does; recomputing on the sample is cheap, so
# every chapter can rebuild the aligned stacks and pair table from scratch and
# stay independent of the others. Only the trained model is passed forward.
# ---------------------------------------------------------------------------

# Resample the coarse product onto the fine product's grid. Both must already
# share a CRS (here EPSG:3976). Bilinear interpolation suits a continuous field
# like sea-ice concentration; the fine reference is the resampling target and is
# itself never altered.
align_products <- function(fine, coarse, method = "bilinear") {
  terra::resample(coarse, fine, method = method)
}

# Build the per-pixel, per-day training table from two equal-geometry stacks.
# Flattening with as.vector pairs the same cell and layer in both stacks, since
# they now share geometry and layer order. NA cells (land, missing) drop out.
build_pairs <- function(fine, coarse_aligned) {
  df <- data.frame(
    nsidc = as.vector(terra::values(coarse_aligned)),
    amsr  = as.vector(terra::values(fine))
  )
  df[stats::complete.cases(df), ]
}

# Apply a fitted transfer model across every cell of a coarse stack, producing
# the harmonized stack. Predictions are clamped to the valid [0, 1] range, and
# the layer dates are carried over from the input.
deploy_model <- function(model, coarse_stack) {
  h <- terra::app(coarse_stack, fun = function(x) {
    p <- predict(model, data.frame(nsidc = x))
    pmin(pmax(as.numeric(p), 0), 1)
  })
  terra::time(h) <- terra::time(coarse_stack)
  names(h) <- names(coarse_stack)
  h
}
