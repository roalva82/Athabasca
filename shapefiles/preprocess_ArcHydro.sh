#!/bin/bash

#download ArcHydro product from Alberta Government
wget https://extranet.gov.ab.ca/srd/geodiscover/srd_pub/inlandWaters/ArcHydro/AlbertaArcHydroPhase2.zip

#unzips ArcHydro
unzip AlbertaArcHydroPhase2.zip

#extract layers of interest from ArcHydro
ogr2ogr -f "ESRI Shapefile" DrainageLine_Athabasca.shp AlbertaArcHydroPhase2/Data/Geodatabase/10TM/AlbertaArcHydroPhase2Vector.gdb/ DrainageLine_Athabasca
ogr2ogr -f "ESRI Shapefile" Catchment_AthabascaRiver.shp AlbertaArcHydroPhase2/Data/Geodatabase/10TM/AlbertaArcHydroPhase2Vector.gdb/ Catchment_AthabascaRiver

#obtain data for dem
cp /work/comphyd_lab/data/geospatial-data/alberta-provincial-digital-elevation-model/100m_Raster_DEM_GDB_10TM_Resource/100m_Raster.gdb/ ./

#extract raster of dem
gdal_translate /work/comphyd_lab/data/geospatial-data/alberta-provincial-digital-elevation-model/100m_Raster_DEM_GDB_10TM_Resource/100m_Raster.gdb/ dem_100m.tif

#calculate the slope of the river network and save to new shapefile
python ProcessElevation.py

#continue with geofabric of model agnostic framework

