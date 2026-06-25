# ---------------------------------------------------------------------------
# build_frozen.R
#
# Generates the "frozen" figures shown in chapter 8 for the steps that cannot
# run on the bundled sample, namely the long-term trend that needs the full
# 1979-2023 harmonized record. It reads that record from the FrostBound_AQ
# archive (the real harmonized product behind the paper) and writes PNGs into
# data/sample/frozen/, which are committed. Tutorial users do not run this;
# it documents how the frozen figures were produced.
# ---------------------------------------------------------------------------

source(here::here("R", "setup.R"))

harm_path <- "C:/Users/michael.wethington.BRILOON/OneDrive - Biodiversity Research Institute/Documents/Manuscripts - Antarctica/FrostBound_AQ/Datasets/dataset-harmonization/complete-harmonized-dataset/tif/nsidc_12_5km_harmonized_1979-2023.tif"
frozen <- here::here("data", "sample", "frozen")
dir.create(frozen, recursive = TRUE, showWarnings = FALSE)

r <- terra::rast(harm_path)
dates <- as.Date(terra::time(r))
yr <- as.integer(format(dates, "%Y"))
cell_km2 <- prod(terra::res(r)) / 1e6

# --- Per-year winter mean extent (>= 0.15) and its trend ------------------
counts <- terra::global(r >= sih_config$ice_threshold, "sum", na.rm = TRUE)[, 1]
daily_ext <- counts * cell_km2
ann <- tapply(daily_ext, yr, mean)
ext_df <- data.frame(year = as.integer(names(ann)), extent = as.numeric(ann))

fit <- lm(extent ~ year, data = ext_df)
slope_per_decade <- coef(fit)[["year"]] * 10
p_pct <- summary(fit)$coefficients["year", "Pr(>|t|)"]

p_trend <- ggplot(ext_df, aes(year, extent / 1e6)) +
  geom_line(color = COLORS$muted, linewidth = 0.4) +
  geom_point(color = COLORS$accent_red, size = 1.6) +
  geom_smooth(method = "lm", se = TRUE, color = COLORS$title,
              fill = alpha(COLORS$ocean, 0.3), linewidth = 0.7) +
  labs(
    title = "Winter sea-ice extent, western Antarctic Peninsula, 1979-2023",
    subtitle = sprintf("Harmonized record. Linear trend %.0f km2 per decade (p = %.3g).",
                       slope_per_decade, p_pct),
    x = NULL, y = expression("Mean winter extent (" * 10^6 * " km"^2 * ")")
  ) +
  theme_bri()
ggsave(file.path(frozen, "winter_extent_trend_1979_2023.png"), p_trend,
       width = 8, height = 4.8, dpi = 150, bg = "white")

# --- Per-pixel winter trend map (% concentration per decade) --------------
yearly <- terra::tapp(r, index = yr, fun = mean, na.rm = TRUE)  # 45 winter-mean layers
years <- as.integer(gsub("[^0-9]", "", names(yearly)))
pixel_slope <- function(y) {
  if (sum(!is.na(y)) < 10) return(NA_real_)
  coef(lm(y ~ years))[2]
}
trend <- terra::app(yearly, fun = pixel_slope) * 10 * 100  # fraction/yr -> %/decade

land <- terra::resample(terra::rast(sih_paths()$land_mask), yearly[[1]], method = "near")
land_df <- subset(rast_to_df(land, "m"), !is.na(m)); lr <- terra::res(land)

p_map <- ggplot() +
  geom_tile(data = land_df, aes(x, y), fill = "grey25", width = lr[1], height = lr[2]) +
  geom_raster(data = rast_to_df(trend, "trend"), aes(x, y, fill = trend)) +
  scale_fill_gradient2(low = "#b2182b", mid = "white", high = "#2166ac",
                       midpoint = 0, name = "SIC trend\n(% per decade)", na.value = NA) +
  coord_equal() +
  labs(title = "Per-pixel winter sea-ice concentration trend, 1979-2023",
       x = NULL, y = NULL) +
  theme_bri_map()
ggsave(file.path(frozen, "winter_trend_map_1979_2023.png"), p_map,
       width = 6, height = 5.5, dpi = 150, bg = "white")

cat(sprintf("Frozen figures written. Trend = %.0f km2/decade, p = %.3g\n",
            slope_per_decade, p_pct))
