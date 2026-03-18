# PMTiles Processing Script (Modern Workflow)
# Converts GeoTIFF to MBTiles, then to PMTiles.

param (
    [Parameter(Mandatory=$true)]
    [string]$InputPath,
    [string]$OutputDir = ".\processed",
    [string]$GDALBinPath = "C:\OSGeo4W\bin"
)

# 1. Setup Environment
$ErrorActionPreference = "Stop"

if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

$BaseName = [System.IO.Path]::GetFileNameWithoutExtension($InputPath)
$TempMBTiles = Join-Path $OutputDir "$BaseName`_temp.mbtiles"
$OutputPMTiles = Join-Path $OutputDir "$BaseName.pmtiles"

# Function to get command path
function Get-CommandPath($cmd, $pathHint = "") {
    $where = where.exe $cmd 2>$null
    if ($where) { return $where[0] }
    if ($pathHint -and (Test-Path "$pathHint\$cmd.exe")) { return "$pathHint\$cmd.exe" }
    return $null
}

# Find Tools
$gdalTranslate = Get-CommandPath "gdal_translate" $GDALBinPath
$pmtilesCmd = Get-CommandPath "pmtiles"

if (-not $gdalTranslate) {
    Write-Error "GDAL (gdal_translate) not found. Please ensure it is in your PATH or update GDALBinPath."
}
if (-not $pmtilesCmd) {
    if (Test-Path ".\pmtiles.exe") {
        $pmtilesCmd = ".\pmtiles.exe"
    } else {
        Write-Error "pmtiles CLI not found. Please place pmtiles.exe in this folder or your PATH."
    }
}

Write-Host "--- PMTiles Workflow: $InputPath ---" -ForegroundColor Cyan

# Step 1: Create intermediate MBTiles
Write-Host "Step 1: Converting TIF to intermediate MBTiles..." -ForegroundColor Yellow
& $gdalTranslate $InputPath $TempMBTiles -of MBTILES -co TILE_FORMAT=JPEG -co QUALITY=85

# Step 2: Convert to PMTiles
Write-Host "Step 2: Converting MBTiles to PMTiles..." -ForegroundColor Yellow
& $pmtilesCmd convert $TempMBTiles $OutputPMTiles

# Cleanup temporary files
if (Test-Path $TempMBTiles) {
    Remove-Item $TempMBTiles
}

Write-Host "--- DONE ---" -ForegroundColor Green
Write-Host "Output saved to: $OutputPMTiles"
