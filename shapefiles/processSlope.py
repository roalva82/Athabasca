import geopandas as gpd
import rasterio
from shapely.geometry import Point

# Load river network
rivers = gpd.read_file("DrainageLine_Athabasca.shp")

# Create a new slope column initialized with NaN
rivers['Slope'] = None

# Open DEM
with rasterio.open("dem_100m.tif") as src:
    for i, row in rivers.iterrows():
        line = row.geometry
        start = line.coords[0]
        end = line.coords[-1]
        
        z1 = list(src.sample([start]))[0][0]
        z2 = list(src.sample([end]))[0][0]

        length = line.length
        slope = -1 * (z2 - z1) / length if length != 0 else -999

        # This prevents unreliable slopes due to lack of raster data
        if slope > 1 or slope < -1: slope = 1e-8

        rivers.loc[i, 'Slope'] = slope

# Build a lookup from HydroID to DrainID
hydro_to_drain = rivers.set_index("HydroID")["DrainID"]

# Map NextDownID through the lookup to get the downstream DrainID
rivers["NextDrain"] = rivers["NextDownID"].map(hydro_to_drain)

# Replace NaN with -9999 and convert to standard int
rivers["NextDrain"] = rivers["NextDrain"].fillna(-9999).astype(int)

# Ensures the slope column is of numeric type
rivers['Slope'] = rivers['Slope'].astype(float).round(6)

# Save to new shapefile
rivers.to_file("river_with_slope.shp")

