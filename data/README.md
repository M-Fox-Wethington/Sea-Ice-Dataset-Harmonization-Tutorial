# Data

## Bundled sample (`sample/`)

The sample is a small, instructional subset derived from two NSIDC sea-ice products, clipped to the western Antarctic Peninsula. It lets every chapter run end to end in minutes with no Earthdata account and no large download. It was produced by [`scripts/build_sample.R`](../scripts/build_sample.R) from the full FrostBound_AQ data archive.

| Path | Contents |
|---|---|
| `sample/amsr_12km/` | 91 daily AMSR (AU_SI12) clips, 12.5 km, EPSG:3976, SIC as a 0-1 fraction, for 2013 (every fourth day) |
| `sample/nsidc_25km_seaiceindex/` | 91 matching daily Sea Ice Index (G02135) clips, 25 km, cleaned and clipped to the study area |
| `sample/land_mask/land_mask.tif` | land cells = 1, derived from the Sea Ice Index land and coast flags |
| `sample/study_area/wap_study_area.gpkg` | the study-area polygon (Peninsula subregions) |
| `sample/raw_example/` | one untouched raw Sea Ice Index granule (values 0-2540, full hemisphere) for the ingestion demo in Chapter 3 |
| `sample/frozen/` | pre-rendered figures for the full-record steps that cannot run on the sample (the 1979-2023 trend), produced by [`scripts/build_frozen.R`](../scripts/build_frozen.R) |

The sample spans a full melt-freeze cycle in 2013, which gives the wide range of concentrations the transfer model needs. It is a teaching subset, not a research product; build the full record from the sources below for any real analysis.

## Full data

Chapter 2 of the tutorial walks through downloading the complete products. They come from the U.S. National Snow and Ice Data Center:

- **AMSR-E/AMSR2 Unified L3 Daily 12.5 km, Version 1 (AU_SI12)** — <https://nsidc.org/data/au_si12/versions/1>. Requires a free NASA Earthdata Login.
- **Sea Ice Index, Version 3 (G02135)** — <https://nsidc.org/data/g02135>. Openly accessible.

## Citations

> Markus, T., Comiso, J. C., and Meier, W. N. (2018). *AMSR-E/AMSR2 Unified L3 Daily 12.5 km Brightness Temperatures, Sea Ice Concentration, Motion and Snow Depth Polar Grids, Version 1.* Boulder, Colorado USA: NASA National Snow and Ice Data Center DAAC. Confirm the current citation and DOI on the dataset landing page.

> Fetterer, F., Knowles, K., Meier, W. N., Savoie, M., and Windnagel, A. K. (2017). *Sea Ice Index, Version 3.* Boulder, Colorado USA: NSIDC National Snow and Ice Data Center. Confirm the current citation and DOI on the dataset landing page.

The NSIDC products are distributed under NSIDC's use-and-copyright terms; consult the landing pages before redistributing the full datasets. The small clips bundled here are included for instructional use.
