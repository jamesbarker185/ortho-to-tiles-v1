# XYZ Tile Generation Script (Traditional Workflow)
# Generates a standard /z/x/y tiles folder structure using gdal2tiles.

param (
    [Parameter(Mandatory=$true)]
    [string]$InputPath,
    [string]$OutputDir = ".\processed_tiles",
    [string]$ZoomLevels = "16-22",
    [string]$OSGeo4WPath = "C:\OSGeo4W"
)

# 1. Setup Environment
$ErrorActionPreference = "Stop"

if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

$BaseName = [System.IO.Path]::GetFileNameWithoutExtension($InputPath)
$TargetFolder = Join-Path $OutputDir $BaseName

# Get absolute paths because gdal2tiles likes them (use forward slashes for compatibility)
$AbsInputPath = [System.IO.Path]::GetFullPath($InputPath).Replace('\', '/')
$AbsTargetFolder = [System.IO.Path]::GetFullPath($TargetFolder).Replace('\', '/')

Write-Host "--- XYZ Tiles Workflow: $InputPath ---" -ForegroundColor Cyan
Write-Host "Target Folder: $TargetFolder" -ForegroundColor Gray

# Setup OSGeo4W Environment wrapper
$EnvBat = Join-Path $OSGeo4WPath "bin\o4w_env.bat"
if (!(Test-Path $EnvBat)) {
    Write-Error "OSGeo4W Environment not found at $EnvBat. Please update OSGeo4WPath."
}

# Run gdal2tiles via cmd wrapper to ensure correct environment
Write-Host "Generating tiles (Zoom $ZoomLevels)... this may take a while..." -ForegroundColor Yellow

$CommandString = "call `"$EnvBat`" && python `"$OSGeo4WPath\apps\Python312\Scripts\gdal2tiles.py`" --xyz --zoom=$ZoomLevels -w leaflet `"$AbsInputPath`" `"$AbsTargetFolder`""
Start-Process cmd.exe -ArgumentList "/c $CommandString" -Wait -NoNewWindow

Write-Host "--- DONE ---" -ForegroundColor Green
Write-Host "Tiles available in: $TargetFolder"
