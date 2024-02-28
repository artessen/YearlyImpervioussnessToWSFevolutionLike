# Loading the required libraries
library(terra)

# Getting the list of rasters
sPath = "./GEE_GAIA" # Folder where the yearly imperviousness files are stored
sFiles = list.files(sPath, ".tif$", full.names=T)
sYears = as.numeric(sub(sPath,"",sub("/urban_","",sub(".tif","",sFiles))))

# Reading rasters as a multi-band object
rFiles = rast(sFiles)
NAflag(rFiles) = 0

# Adjusting the pixel values to years
for (i in 1:dim(rFiles)[3]) { rFiles[[i]] = rFiles[[i]]*sYears[i] }

# Computing when the pixels became impervious
rAgg = app(rFiles, min, na.rm=T)

# Saving the results to the disk
terra::writeRaster(rAgg, "GAIA_WSFevolution_1985-2022.tif", overwrite=TRUE, 
                   gdal=c("NUM_THREADS=ALL_CPUS", "BIGTIFF=YES", "COMPRESS=DEFLATE", "PREDICTOR=1", "ZLEVEL=9"))

# Only from a certain year
sYearStart = 1999
rAggYear = classify(rAgg, cbind(0, sYearStart, sYearStart))
terra::writeRaster(rAggYear, psate("GAIA_WSFevolution_",sYearStart,"-2022.tif",sep=""), overwrite=TRUE, 
                   gdal=c("NUM_THREADS=ALL_CPUS", "BIGTIFF=YES", "COMPRESS=DEFLATE", "PREDICTOR=1", "ZLEVEL=9"))
