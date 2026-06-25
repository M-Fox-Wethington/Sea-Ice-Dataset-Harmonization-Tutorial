# ---------------------------------------------------------------------------
# build_sample.R
#
# Builds the small bundled sample under data/sample/ from the full FrostBound_AQ
# data archive. This documents exactly how the committed sample was produced;
# tutorial users do NOT need to run it (they either use the committed sample or
# download the full data following chapter 2). It is kept for provenance.
#
# What it produces (all EPSG:3976, sea-ice concentration as a 0-1 fraction):
#   data/sample/amsr_12km/             daily AMSR clips, 12.5 km, WAP window
#   data/sample/nsidc_25km_seaiceindex/ daily Sea Ice Index clips, 25 km, WAP
#   data/sample/land_mask/land_mask.tif land cells = 1, else NA
#   data/sample/study_area/wap_study_area.gpkg  study-area polygon
#   data/sample/raw_example/           one untouched raw Sea Ice Index granule
#                                       (0-2540, full hemisphere) for the
#                                       ingestion-chapter scaling demo
#
# Sample window: calendar year 2013, every 4th day present in BOTH products,
# which spans a full melt-freeze cycle and gives a wide SIC range for training.
# ---------------------------------------------------------------------------

suppressMessages({
  library(terra)
})

# --- Source archive (read-only) -------------------------------------------
fb <- "C:/Users/michael.wethington.BRILOON/OneDrive - Biodiversity Research Institute/Documents/Manuscripts - Antarctica/FrostBound_AQ"
amsr_src <- file.path(fb, "Datasets/dataset-harmonization/12km_AMSR-Unified/processed-clipped")
sii_src  <- file.path(fb, "Datasets/dataset-harmonization/25km_Sea-Ice-Index/processed")
lm_src   <- file.path(fb, "Datasets/gis_data_antarctica/land_mask/land_mask.tif")
sa_dir   <- file.path(fb, "Datasets/gis_data_antarctica/study-area")

# --- Output (committed into the repo) -------------------------------------
out      <- here::here("data", "sample")
amsr_out <- file.path(out, "amsr_12km")
sii_out  <- file.path(out, "nsidc_25km_seaiceindex")
lm_out   <- file.path(out, "land_mask")
sa_out   <- file.path(out, "study_area")
raw_out  <- file.path(out, "raw_example")
for (d in c(amsr_out, sii_out, lm_out, sa_out, raw_out)) {
  dir.create(d, recursive = TRUE, showWarnings = FALSE)
}

# --- Parse available dates and find the common set ------------------------
amsr_files <- list.files(amsr_src, pattern = "\\.tif$", full.names = TRUE)
sii_files  <- list.files(sii_src,  pattern = "\\.tif$", full.names = TRUE)

amsr_date <- as.Date(sub(".*_(\\d{8})\\.tif$", "\\1", basename(amsr_files)), "%Y%m%d")
sii_date  <- as.Date(sub("^S_(\\d{8})_.*",      "\\1", basename(sii_files)),  "%Y%m%d")

amsr_lut <- setNames(amsr_files, format(amsr_date, "%Y%m%d"))
sii_lut  <- setNames(sii_files,  format(sii_date,  "%Y%m%d"))

common <- sort(as.Date(intersect(amsr_date, sii_date), origin = "1970-01-01"))
common_2013 <- common[format(common, "%Y") == "2013"]
sel <- common_2013[seq(1, length(common_2013), by = 4)]
cat(sprintf("Common dates: %d total, %d in 2013, %d selected (every 4th day)\n",
            length(common), length(common_2013), length(sel)))
stopifnot(length(sel) > 10)

# --- AMSR template defines the WAP window for cropping the Sea Ice Index ---
amsr_template <- rast(amsr_lut[[format(sel[1], "%Y%m%d")]])
# Buffer the AMSR extent by two coarse cells so the 25 km product fully covers
# it before resampling later.
sii_window <- ext(amsr_template) + 50000

# Sea Ice Index value coding: SIC is 0-1000 (tenths of a percent); 2510 pole
# hole, 2530 coast, 2540 land, 2550 missing. Anything above 1000 is a flag.
SII_MAX_VALID <- 1000

# --- Convert each selected date -------------------------------------------
# Iterate by index: a `for` over a Date vector would drop the Date class.
for (i in seq_along(sel)) {
  d   <- sel[i]
  key <- format(d, "%Y%m%d")

  # AMSR: already clean 0-100 percent, WAP-clipped, EPSG:3976. Scale to 0-1.
  a <- rast(amsr_lut[[key]]) / 100
  writeRaster(a, file.path(amsr_out, paste0("AMSR_12km_", key, ".tif")),
              overwrite = TRUE, datatype = "FLT4S")

  # Sea Ice Index: raw 0-2540, full hemisphere. Crop to WAP, flag sentinels to
  # NA, scale 0-1000 -> 0-1 fraction.
  s <- rast(sii_lut[[key]])
  s <- crop(s, sii_window)
  s <- clamp(s, upper = SII_MAX_VALID, values = FALSE)  # >1000 (flags) -> NA
  s <- s / 1000
  writeRaster(s, file.path(sii_out, paste0("NSIDC_SeaIceIndex_25km_", key, ".tif")),
              overwrite = TRUE, datatype = "FLT4S")
}
cat(sprintf("Wrote %d AMSR and %d Sea Ice Index daily clips.\n", length(sel), length(sel)))

# --- Land mask: copy as-is (EPSG:3976, 25 km, land = 1) -------------------
file.copy(lm_src, file.path(lm_out, "land_mask.tif"), overwrite = TRUE)

# --- Study-area polygon: prefer a non-deprecated subregions shapefile -----
shps <- list.files(sa_dir, pattern = "\\.shp$", recursive = TRUE, full.names = TRUE)
shps <- shps[!grepl("deprecated", shps, ignore.case = TRUE)]
sa_target <- file.path(sa_out, "wap_study_area.gpkg")
if (length(shps) >= 1) {
  pick <- shps[grepl("Subregion|Study", shps, ignore.case = TRUE)][1]
  if (is.na(pick)) pick <- shps[1]
  v <- project(vect(pick), "EPSG:3976")
  writeVector(v, sa_target, overwrite = TRUE)
  cat("Study area from:", basename(pick), "\n")
} else {
  # Fallback: a bounding-box polygon from the AMSR window.
  v <- as.polygons(ext(amsr_template), crs = "EPSG:3976")
  writeVector(v, sa_target, overwrite = TRUE)
  cat("Study area: bounding box fallback\n")
}

# --- One raw Sea Ice Index granule for the ingestion-chapter demo ---------
file.copy(sii_lut[[format(sel[1], "%Y%m%d")]],
          file.path(raw_out, basename(sii_lut[[format(sel[1], "%Y%m%d")]])),
          overwrite = TRUE)

cat("\nSample build complete under:", out, "\n")
