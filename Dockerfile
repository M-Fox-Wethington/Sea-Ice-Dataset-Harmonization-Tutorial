# A self-contained environment for the tutorial.
#
# The rocker/geospatial image provides R, RStudio Server, Quarto, the tidyverse,
# and the GDAL / GEOS / PROJ / HDF5 system libraries that terra and sf depend on,
# which are the hardest part of a geospatial R setup to get right. We add only
# the few packages it does not already carry.
#
#   docker build -t seaice-harmonization .
#   docker run --rm -p 8787:8787 -e PASSWORD=yourpassword seaice-harmonization
#
# Then open http://localhost:8787 (user: rstudio) and render with: quarto render
FROM rocker/geospatial:4.4.1

# nnet ships with R; here, patchwork, and renv are the additions.
RUN install2.r --error --skipinstalled \
    here \
    patchwork \
    renv

WORKDIR /home/rstudio/tutorial
COPY . .

EXPOSE 8787
