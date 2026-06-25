# Sea-Ice Dataset Harmonization Tutorial — Project Memory

## What this is
Open-source R/Quarto tutorial teaching the sea-ice harmonization method from Wethington & Lynch 2026 (*Marine Ecology Progress Series* 787, 1-19, doi:10.3354/meps15149). Built 2026-06-25 from the research code in the [FrostBound_AQ repo](https://github.com/M-Fox-Wethington/FrostBound_AQ). It is a transferable-method guide, not just a paper-reproduction: the worked example is the western Antarctic Peninsula (AMSR 12.5 km AU_SI12 vs the 25 km Sea Ice Index G02135), but the method applies to any two overlapping gridded sea-ice concentration products.

- **Live site**: https://m-fox-wethington.github.io/Sea-Ice-Dataset-Harmonization-Tutorial/
- **Local working clone**: `C:\Users\michael.wethington.BRILOON\dev\Sea-Ice-Dataset-Harmonization-Tutorial` (deliberately NOT on OneDrive, to avoid sync corruption during renders)

## The method (what the tutorial teaches)
Train a per-pixel transfer function on the years the two products overlap, then apply it to the full coarse record to express 1979-2023 at the fine 12.5 km resolution. The model is a small `nnet` artificial neural network (`amsr ~ nsidc`), tuned over the paper's size/decay grid (size 3/5/7/10/15, decay 0.01/0.001/0.0001; final size 7, decay 0.001, 1500 iters, seed 123, 80/20 split). On the sample it cuts held-out RMSE from ~0.149 (raw) to ~0.075 (ANN), beating linear (~0.11) and quantile-mapping (~0.078) baselines. Validation: pooled and per-pixel RMSE, daily extent time series, AMSR-minus-product difference maps. Payoff: the real 1979-2023 winter trend (~ -46,000 km2/decade, p = 0.037).

## Load-bearing build decisions
- **Analysis grid is EPSG:3976** (WGS 84 NSIDC Sea Ice polar stereographic). Both clipped products are already on it, so there is NO cross-CRS reprojection between them, only a resample of the 25 km product onto the 12.5 km grid. (The raw AMSR HDF5 is native EPSG:3412 and is reprojected to 3976 during ingestion.)
- **The resample is made explicit.** The published notebook had the 25-to-12.5 km resample commented out, so its ANN ran on the native 25 km grid and the "12.5 km" label described alignment, not cell size. The tutorial turns the resample on so the output genuinely sits on the 12.5 km grid; Chapter 5 explains this. The harmonization is a per-pixel value (bias) correction, not super-resolution.
- **Sea Ice Index value coding**: raw 0-1000 (tenths of a percent), flags 2510 pole hole / 2530 coast / 2540 land / 2550 missing. Clean = flags to NA, divide by 1000. AMSR flags: 110 missing, 120 land; values 0-100, divide by 100.
- **SIC >= 0.15** extent threshold; austral winter = June-September; cell area from `prod(res)/1e6`.

## Structure
- `index.qmd` + `chapters/01..09` (Quarto book, `_quarto.yml`, HTML only; PDF was dropped to avoid the CI LaTeX dependency).
- `R/`: `setup.R` (chapter preamble), `paths.R` (config + SIH_MODE sample/full switch, EPSG:3976, thresholds, ANN grid), `io.R` (load_sic_stack, rast_to_df), `harmonize.R` (align_products, build_pairs, deploy_model), `metrics.R` (extent, mean, RMSE, per-pixel RMSE), `theme.R` (BRI `theme_bri()`/`theme_bri_map()` + SIC color scales). Figures use BRI house style.
- `scripts/`: `build_sample.R` (made the bundled sample), `build_frozen.R` (made the frozen 1979-2023 trend figures from the real product).
- `data/sample/`: 91 paired daily AMSR + Sea Ice Index clips for 2013 (every 4th day), land mask, study-area polygon, one raw granule for the ingestion demo, and `frozen/` PNGs. 8.1 MB committed.

## Data model
The book runs live on the committed sample (`SIH_MODE=sample`, default), so it builds in minutes with no Earthdata account. `SIH_MODE=full` with `SIH_DATA_ROOT` points at a real download (Chapter 2 covers the authenticated NSIDC fetch). A few heavy steps (full download, full-record deploy, the 1979-2023 trend) are shown but frozen: the trend figures are committed PNGs produced by `scripts/build_frozen.R` from the real harmonized product at `<OneDrive>/Manuscripts - Antarctica/FrostBound_AQ/Datasets/dataset-harmonization/complete-harmonized-dataset/tif/nsidc_12_5km_harmonized_1979-2023.tif` (4962 winter daily layers, 1979-2023).

## Environment
R 4.4.1. `renv.lock` is committed (93 packages) but renv is OPT-IN: `.Rprofile` is gitignored so the default `quarto render` uses the system library. The `Dockerfile` is rocker/geospatial (carries the GDAL/GEOS/PROJ/HDF5 stack). CI is `.github/workflows/publish.yml`: it installs R + system geospatial deps (must include `knitr` and `rmarkdown`, or Quarto cannot execute chunks), renders the book on the sample, and publishes to the `gh-pages` branch, which GitHub Pages serves. The `gh-pages` branch had to be initialized once (an empty orphan branch) before `quarto-actions/publish` would push to it.

## Licensing / authorship
Code MIT (`LICENSE`), prose/figures CC-BY-4.0 (`LICENSE-CONTENT.md`), `CITATION.cff` points to the MEPS paper. Commit authorship is `m-fox-wethington <michael.wethington@briwildlife.org>` only, no Claude attribution. This repo's history was rewritten 2026-06-25 to that single identity.

## Open items
- `references.bib`: the Wethington & Lynch DOI is verified; the two NSIDC dataset citations (AU_SI12, Sea Ice Index G02135) are marked "confirm the current citation and DOI on the landing page" rather than carrying invented DOIs. Drop in the official NSIDC DOIs before promoting the tutorial.
- The FrostBound_AQ working clone on OneDrive still points at pre-rewrite history (see that repo); reconcile only after its uncommitted changes are saved.
