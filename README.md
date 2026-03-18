# Orthophoto Processing

This project provides a script to process large GeoTIFF (orthophoto) files into modern web-ready formats like **PMTiles** and **MBTiles**.

## Prerequisites

### 1. GDAL (Geospatial Data Abstraction Library)
GDAL is required for TIFF optimization and warping.

- **Check if installed**: Open PowerShell and run `gdalinfo --version`.
- **Installation (Windows)**:
  - Recommended: [OSGeo4W](https://trac.osgeo.org/osgeo4w/) (Standard for GIS).
  - Alternatively, use `choco install gdal` or `scoop install gdal`.
  - Ensure `C:\OSGeo4W\bin` (or your GDAL bin path) is in your System **PATH**.

### 2. PMTiles CLI
Required to convert COG (Cloud Optimized GeoTIFF) files to PMTiles.

- **Download**: [Grab the latest release from GitHub](https://github.com/protomaps/go-pmtiles/releases).
- **Setup**: Place `pmtiles.exe` in this project folder or add it to your PATH.

## Usage

### 1. Modern PMTiles Workflow (Recommended)
This script specifically follows the official PMTiles optimization path (TIF -> COG -> PMTiles).

```powershell
./scripts/tif_to_pmtiles.ps1 -InputPath "./orthophoto/12-2-2025/Reservoir-Road-12-2-2025-orthophoto.tif"
```

### 2. Traditional XYZ Tiles Workflow
Generates a standard `/z/x/y.png` folder structure (useful for simple hosting or Leaflet).

```powershell
./scripts/tif_to_xyz.ps1 -InputPath "./orthophoto/12-2-2025/Reservoir-Road-12-2-2025-orthophoto.tif" -ZoomLevels "16-22"
```

### 3. Full Processing (All-in-One)
Use this if you need PMTiles, MBTiles, and specific warping in one go.

### Script Arguments:
- `-InputPath`: Path to your source `.tif` file.
- `-OutputDir`: Where to save the results (default: `./processed`).
- `-GDALBinPath`: If GDAL is not in your PATH, point this to your `bin` folder (e.g., `C:\OSGeo4W\bin`).

## Processing Steps

The script performs the following:
1.  **Optimize**: Converts the TIF to a Cloud Optimized GeoTIFF (COG) using DEFLATE compression.
2.  **PMTiles**: Converts the COG to a PMTiles archive (modern, serverless format).
3.  **Warp**: Warps the original image to Web Mercator (EPSG:3857) for tile compatibility.
4.  **MBTiles**: Generates an MBTiles database with JPEG tiles (85% quality).

---

## Troubleshooting

- **"GDAL not found"**: The script looks in `C:\OSGeo4W\bin` by default. If you installed it elsewhere, either add it to your Windows PATH or edit the `$GDALBinPath` variable at the top of `process_ortho.ps1`.
- **Permission Errors**: Run PowerShell as Administrator if you encounter access issues.
