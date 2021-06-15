#Segmentación de Imágenes
#El método superpixel aquí desarrollado tiene un límite de tres bandas
#K. Wiese 28 Junio 2020

# 1. Definir directorio de trabajo ----
#setwd("~/R/00_FabiolaDAI/Segmentacion/")

# 2. Librerias ----
# remotes::install_github("nmcdev/nmcMetIO")
library(nmcMetIO)
library(sp)
library(SuperpixelImageSegmentation)
library(raster)
library(OpenImageR)
options(warn=-1)

# 3. Cargar imagen para segmentación ----
# 3.1 Imagen con referencia espacial ----
SOM5 <- stack("./data//SOM5.tiff")

# 3.2 Imagen para segmentación ----
ImagenSOM5 <- OpenImageR::readImage("./data/SOM5.tiff")

# 3.3 Explorar imagen ----
OpenImageR::imageShow(ImagenSOM5)

# 4. Crear objeto para contener segmentación ----
Segmentacion <- Image_Segmentation$new()

# 5. Ejecutar modelo, preuba agrupaciones (clusters) de valores (colores) similares
SuperPixelSOM5 = Segmentacion$spixel_segmentation(input_image = ImagenSOM5,
                                  superpixel = 500,
                                  AP_data = TRUE,
                                  use_median = FALSE,
                                  sim_wL = 5,
                                  sim_wA = 10,
                                  sim_wB = 10,
                                  sim_color_radius = 5,
                                  kmeans_method = "kmeans",
                                  kmeans_initializer = "kmeans++",
                                  kmeans_num_init =5,
                                  kmeans_max_iters = 100,
                                  verbose = TRUE)

# 5.1 Imagen post-modelo ----
OpenImageR::imageShow(SuperPixelSOM5$AP_image_data)

# 5.2 Extraer Raster ----
SP_raster <- raster(SuperPixelSOM5$AP_image_data[,,1])

# 5.3 Asignar sistema de referencia de coordenadas ----
crs(SP_raster) <- CRS('+init=epsg:32616')

# 5.4 Definir espacio geográfico ---- 
extent(SP_raster) <- extent(SOM5)

# 5.5 Trabajar con entero2
SP_raster <- SP_raster * 100
plot(SP_raster)

# 5.6 Guardar Resultados ----
NombreRaster <- "SOM5segmentado.grd"
if(file.exists("Resultados") == FALSE) dir.create("Resultados")
writeRaster(SP_raster, filename = paste0("./Resultados/", NombreRaster), overwrite=TRUE)

# 5.7 Vectorizar usando gdal ----
#funciona en linux, system2 es mejor para windows
NombreVector <- "SOM5.gpkg"
system(paste0('gdal_polygonize.py ', 
              "./Resultados/", NombreRaster, 
              ' \"./Resultados/"', NombreVector, ' \ -b  1 -f "GPKG" DN'))

# 6. Información de sessión ----
sessionInfo()

#R version 4.0.3 (2020-10-10)
#Platform: x86_64-pc-linux-gnu (64-bit)
#Running under: Ubuntu 20.04.1

#Matrix products: default
#BLAS:   /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.9.0
#LAPACK: /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.9.0

#locale:
#[1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C               LC_TIME=es_HN.UTF-8        LC_COLLATE=en_US.UTF-8    
#[5] LC_MONETARY=es_HN.UTF-8    LC_MESSAGES=en_US.UTF-8    LC_PAPER=es_HN.UTF-8       LC_NAME=C                 
#[9] LC_ADDRESS=C               LC_TELEPHONE=C             LC_MEASUREMENT=es_HN.UTF-8 LC_IDENTIFICATION=C       

#attached base packages:
#[1] stats     graphics  grDevices utils     datasets  methods   base     

#other attached packages:
#[1] OpenImageR_1.1.7                  raster_3.3-13                     SuperpixelImageSegmentation_1.0.2
#[4] sp_1.4-4                          nmcMetIO_0.1.0                   

#loaded via a namespace (and not attached):
#[1] Rcpp_1.0.5       knitr_1.30       magrittr_1.5     xtable_1.8-4     lattice_0.20-41  R6_2.4.1         jpeg_0.1-8.1    
#[8] rlang_0.4.8      fastmap_1.0.1    tools_4.0.3      parallel_4.0.3   rgdal_1.5-16     grid_4.0.3       xfun_0.18       
#[15] png_0.1-7        htmltools_0.5.0  yaml_2.2.1       digest_0.6.25    shiny_1.5.0      later_1.1.0.1    codetools_0.2-16
#[22] promises_1.1.1   evaluate_0.14    mime_0.9         rmarkdown_2.3.9  tiff_0.1-5       compiler_4.0.3   httpuv_1.5.4 
