# Harmonizing Antarctic Sea-Ice Datasets

A reproducible R tutorial for combining two satellite sea-ice products that disagree on resolution and time span into one continuous, internally consistent record. The worked example rebuilds the harmonized western Antarctic Peninsula sea-ice dataset behind [Wethington and Lynch (2026)](https://doi.org/10.3354/meps15149), but the method applies to any two gridded sea-ice concentration products that overlap in time.

**Read the tutorial:** <https://m-fox-wethington.github.io/Sea-Ice-Dataset-Harmonization-Tutorial/>

## What it teaches

The long satellite sea-ice record (the 25 km NSIDC Sea Ice Index, 1979 to present) is coarse, and the fine record (the 12.5 km AMSR product) is short. This tutorial learns the relationship between the two during the years they overlap, using a small artificial neural network, then applies it to the full coarse record to produce a continuous 12.5 km dataset reaching back to 1979. It covers the whole pipeline: downloading the products from NSIDC, converting them to analysis-ready rasters, building a land mask, aligning and pairing the products, training and validating the model, and using the harmonized record to estimate a long-term trend.

## Quickstart

Everything runs on a small bundled sample (`data/sample/`) drawn from the real products, so you can work through the tutorial in minutes with no account and no large download.

```bash
git clone https://github.com/M-Fox-Wethington/Sea-Ice-Dataset-Harmonization-Tutorial.git
cd Sea-Ice-Dataset-Harmonization-Tutorial
```

```r
# Optional: install the pinned package versions
renv::restore()
# Otherwise install directly:
# install.packages(c("terra","sf","nnet","dplyr","tidyr","lubridate",
#                    "scales","ggplot2","patchwork","here"))
```

Render the book with [Quarto](https://quarto.org):

```bash
quarto render
```

The rendered site lands in `_book/`. The default data mode is the sample; set `SIH_MODE=full` (with `SIH_DATA_ROOT` pointing at your download) to run the full pipeline.

## What is inside

| Chapter | Topic |
|---|---|
| 1 | Setup and the harmonization problem |
| 2 | Getting the data from NSIDC |
| 3 | Ingestion: native files to analysis-ready clips |
| 4 | Building the land mask |
| 5 | Aligning and pairing the two products |
| 6 | Training the transfer model and baselines |
| 7 | Deploying and validating |
| 8 | Using the harmonized dataset |
| 9 | Scaling up and adapting |

The reusable R functions are in `R/`, the sample-building and frozen-figure scripts are in `scripts/`, and the bundled data with its provenance is in `data/`.

## Data

The bundled sample is derived from two NSIDC products for instructional use: the AMSR-E/AMSR2 Unified 12.5 km product (AU_SI12) and the 25 km Sea Ice Index (G02135). See [`data/README.md`](data/README.md) for sources, citations, and how the sample was built, and Chapter 2 for downloading the full records.

## Built from and citing

This tutorial is adapted from the research code in the [FrostBound_AQ repository](https://github.com/M-Fox-Wethington/FrostBound_AQ). If you use the tutorial or the method, please cite the paper:

> Wethington, M. and Lynch, H. J. (2026). Winter sea-ice decline drives gentoo penguin population expansion along the western Antarctic Peninsula. *Marine Ecology Progress Series* 787, 1-19. <https://doi.org/10.3354/meps15149>

## License

Code is released under the [MIT License](LICENSE); the written content and figures are under [CC BY 4.0](LICENSE-CONTENT.md). The NSIDC source data is subject to its own terms.
