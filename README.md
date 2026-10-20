# Orthophoto to Tiles

This project processes large GeoTIFF (orthophoto) files into web-ready XYZ tile folder structures using `gdal2tiles`.

## Prerequisites

### 1. OSGeo4W (GDAL + PROJ)

Required for tile generation via `gdal2tiles.py`.

- **Download**: [OSGeo4W Installer](https://trac.osgeo.org/osgeo4w/)
- **During setup, install these packages**:
  - `gdal`
  - `proj`
  - `proj-runtime-data` (v9.8.1-1 or later)
  - `proj-data`

> **Note**: OSGeo4W may install to a non-default location (e.g., `C:\Users\<you>\AppData\Local\Programs\OSGeo4W`). Note the path — you'll need to pass it via `-OSGeo4WPath`.

---

## Usage

### XYZ Tiles (Primary Method)

Generates a standard `/z/x/y.png` folder structure, compatible with Leaflet and most tile servers.

```powershell
./scripts/tif_to_xyz.ps1 `
  -InputPath "C:\path\to\orthophoto.tif" `
  -OSGeo4WPath "C:\Users\<you>\AppData\Local\Programs\OSGeo4W"
```

**All arguments:**

| Argument | Default | Description |
|---|---|---|
| `-InputPath` | *(required)* | Path to the source `.tif` file |
| `-OutputDir` | `.\processed_tiles` | Where to save the tile folders |
| `-ZoomLevels` | `16-22` | Zoom range to generate |
| `-OSGeo4WPath` | `C:\OSGeo4W` | Path to your OSGeo4W installation |

Output tiles are saved to `<OutputDir>\<filename>\` in standard XYZ (`/z/x/y.png`) format.

---

## Troubleshooting

### `OSGeo4W Environment not found`
The default `-OSGeo4WPath` is `C:\OSGeo4W`. If you installed elsewhere, always pass `-OSGeo4WPath` explicitly:
```powershell
-OSGeo4WPath "C:\Users\<you>\AppData\Local\Programs\OSGeo4W"
```

### `proj.db contains DATABASE.LAYOUT.VERSION.MINOR = X whereas >= 4 is expected`
The PROJ database is outdated. Reopen the OSGeo4W installer and update these packages:
1. `proj` — provides the PROJ binaries and `proj.db`
2. `proj-runtime-data` — must be **v9.8.1-1 or later**

### `Cannot parse tms_*.json` warnings
These are harmless warnings from GDAL about unsupported TMS grid definitions. Tile generation proceeds normally.
