# ---------------------------------------------------------------------------
# theme.R: BRI house-style figure theme and sea-ice color scales.
#
# theme_bri() / theme_bri_map() reproduce the canonical BRI ggplot2 theme so the
# tutorial's figures match the look of the program's other work. The palette and
# theme follow the BRI figure-style specification.
# ---------------------------------------------------------------------------

suppressMessages({
  library(ggplot2)
  library(scales)
})

COLORS <- list(
  parchment    = "#f5f2ed",
  ocean        = "#8facc0",
  land         = "#d8dce0",
  coastline    = "#3d5a6e",
  title        = "#2c3e50",
  subtitle     = "#5d6d7e",
  muted        = "#8899a6",
  grid         = "#5a7080",
  accent_red   = "#c93312",
  accent_amber = "#e09430",
  accent_teal  = "#1d7e8a",
  accent_green = "#4a9e4a"
)

theme_bri <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.background   = element_rect(fill = "white", color = NA),
      panel.background  = element_rect(fill = "white", color = NA),
      panel.grid.major  = element_line(color = alpha(COLORS$grid, 0.12), linewidth = 0.2),
      panel.grid.minor  = element_blank(),
      plot.title        = element_text(size = 16, face = "bold", color = COLORS$title, margin = margin(b = 4)),
      plot.subtitle     = element_text(size = 10, color = COLORS$subtitle, margin = margin(b = 8)),
      plot.caption      = element_text(size = 7, color = COLORS$muted, hjust = 1, margin = margin(t = 8), lineheight = 1.3),
      axis.title        = element_text(size = 9, color = COLORS$subtitle),
      axis.text         = element_text(size = 8, color = COLORS$muted),
      legend.title      = element_text(size = 9, face = "bold", color = COLORS$title),
      legend.text       = element_text(size = 8, color = COLORS$muted),
      legend.background = element_rect(fill = alpha("white", 0.85), color = NA),
      strip.text        = element_text(size = 10, face = "bold", color = COLORS$title),
      plot.margin       = margin(12, 16, 10, 12)
    )
}

theme_bri_map <- function(base_size = 11) {
  theme_bri(base_size) +
    theme(
      panel.background = element_rect(fill = COLORS$ocean, color = NA),
      axis.title       = element_blank(),
      axis.text        = element_text(size = 6, color = COLORS$muted)
    )
}

# Line colors for the three products in comparison plots.
dataset_colors <- c(
  "AMSR (observed)"     = COLORS$accent_teal,
  "Sea Ice Index (raw)" = COLORS$accent_amber,
  "Harmonized"          = COLORS$accent_red
)

# Sequential fill for sea-ice concentration on a 0-1 scale (open water dark,
# consolidated ice white), suitable for SIC maps.
scale_fill_sic <- function(name = "SIC", ...) {
  scale_fill_gradientn(
    colours  = c("#08306b", "#2171b5", "#6baed6", "#c6dbef", "#ffffff"),
    limits   = c(0, 1),
    na.value = NA,
    name     = name,
    ...
  )
}

# Diverging fill for AMSR-minus-product differences, matching the paper's
# steel-blue / white / orange scale clipped to +/- 0.5.
scale_fill_sic_diff <- function(limits = c(-0.5, 0.5),
                                name = "SIC difference\n(AMSR - product)", ...) {
  scale_fill_gradient2(
    low      = "steelblue",
    mid      = "white",
    high     = "orange",
    midpoint = 0,
    limits   = limits,
    na.value = NA,
    name     = name,
    ...
  )
}
