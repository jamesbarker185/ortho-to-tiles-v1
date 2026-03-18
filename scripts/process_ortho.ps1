# Process Orthophoto Script
# This script automates the conversion of GeoTIFF to PMTiles and MBTiles.

param (
    [string]$InputPath = ".\orthophoto\12-2-2025\Reservoir-Road-12-2-2025-orthophoto.tif",
    [string]$OutputDir = ".\processed",
    [string]$PMTilesPath = "pmtiles", # Path to pmtiles executable
    [string]$GDALBinPath = "C:\OSGeo4W\bin" # Default GDAL bin path
)

# 1. Setup Environment
$ErrorActionPreference = "Stop"

if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

$BaseName = [System.IO.Path]::GetFileNameWithoutExtension($InputPath)
$TempCOG = Join-Path $OutputDir "$BaseName`_temp_cog.tif"
$OutputPMTiles = Join-Path $OutputDir "$BaseName.pmtiles"
$WarpedOrtho = Join-Path $OutputDir "$BaseName`_warped.tif"
$OutputMBTiles = Join-Path $OutputDir "$BaseName.mbtiles"

# Function to get command path
function Get-CommandPath($cmd, $pathHint = "") {
    # 1. Check if already in PATH
    $where = where.exe $cmd 2>$null
    if ($where) {
        return $where[0]
    }
    # 2. Check path hint
    if ($pathHint -and (Test-Path "$pathHint\$cmd.exe")) {
        return "$pathHint\$cmd.exe"
    }
    return $null
}

# Find GDAL tools
$gdalTranslate = Get-CommandPath "gdal_translate" $GDALBinPath
$gdalWarp = Get-CommandPath "gdalwarp" $GDALBinPath

if (-not $gdalTranslate) {
    Write-Error "GDAL not found. Please ensure GDAL is installed and in your PATH or update GDALBinPath in this script."
}

# Find pmtiles
$pmtilesCmd = Get-CommandPath "pmtiles"
if (-not $pmtilesCmd) {
    Write-Warning "pmtiles CLI not found in PATH. Searching current directory..."
    if (Test-Path ".\pmtiles.exe") {
        $pmtilesCmd = ".\pmtiles.exe"
    } else {
        Write-Warning "pmtiles CLI not found. You can download it from: https://github.com/protomaps/go-pmtiles/releases"
    }
}

Write-Host "--- Processing: $InputPath ---" -ForegroundColor Cyan

# Option 1: PMTiles (The modern way)
Write-Host "Step 1: Optimizing TIF to COG..." -ForegroundColor Yellow
& $gdalTranslate $InputPath $TempCOG -co TILED=YES -co COPY_SRC_OVERVIEWS=YES -co COMPRESS=DEFLATE

if ($pmtilesCmd) {
    Write-Host "Step 2: Converting to PMTiles..." -ForegroundColor Yellow
    & $pmtilesCmd convert $TempCOG $OutputPMTiles
} else {
    Write-Warning "Skipping PMTiles conversion as pmtiles CLI is missing."
}

# Option 2: MBTiles
Write-Host "Step A: Warping to Web Mercator (EPSG:3857)..." -ForegroundColor Yellow
& $gdalWarp -t_srs EPSG:3857 -r bilinear -of GTiff $InputPath $WarpedOrtho

Write-Host "Step B: Creating MBTiles File..." -ForegroundColor Yellow
& $gdalTranslate $WarpedOrtho $OutputMBTiles -of MBTILES -co TILE_FORMAT=JPEG -co QUALITY=85

Write-Host "--- DONE ---" -ForegroundColor Green
Write-Host "Outputs available in: $OutputDir"
