# kNavigate — Karunya Navigator

A GPS-guided campus tour app for **Karunya Institute of Technology and Sciences**, Coimbatore. As you walk the campus, Karunya Navigator plays short audio narration at each stop, with an offline map, photos, and a satellite view.

Built on the open-source [TourForge](https://github.com/tourforge) engine.

---

## Features

- 🎧 **GPS audio tour** — narration triggers automatically as you reach each of the 27 campus stops
- 🗺️ **Offline base map** — the campus vector map is bundled in the app (works with no signal)
- 🛰️ **Satellite view** — toggle to Esri World Imagery (no API key)
- 📥 **Download once, use offline** — tour audio, photos, and map cached on device
- 🔄 **Over-the-air updates** — the app updates itself from v2 onward (no Play Store needed)
- 🎨 **Karunya design system** — royal blue `#034DA2` + gold `#B59758`, light & dark, large legible type

## Architecture

This is a Flutter **pub workspace** (white-label pattern):

```
apps/karunya-navigator/   → the Karunya app: branding, theme, onboarding, bundled offline map
packages/baseline/        → forked TourForge "baseline" engine (UI, MapLibre map, downloader)
```

- **Engine:** a fork of [`tourforge/baseline`](https://github.com/tourforge) — the app injects branding/theme/endpoints via `TourForgeConfig`.
- **Tour content** is hosted on **Cloudflare R2** and read at runtime from `…/v2/tourforge.json` (content-addressed assets). Content updates roll out automatically — no app rebuild.
- **Base map** is a bundled `assets/tiles.mbtiles` (OpenMapTiles vector tiles of the campus, generated with [planetiler](https://github.com/onthegomap/planetiler) from OpenStreetMap data).
- **Auto-updater:** on launch the app checks `…/app/version.json`; if a newer build exists it downloads and installs the APK.

## Build

Requirements: **Flutter 3.44+** (Dart 3.12), **JDK 17**, Android SDK (compile/target 36).

```bash
flutter pub get                       # from the workspace root (resolves all members)
cd apps/karunya-navigator
flutter build apk --release           # signed release (see Signing below)
```

### Signing
Release signing reads `apps/karunya-navigator/android/key.properties` (git-ignored) which points to a keystore (also git-ignored). Create your own `key.properties` + keystore to build signed releases.

## Content & releases

- **Tour content:** edited in the TourForge builder, exported as `tourforge.json` + hash-named assets, and synced to the R2 bucket under `v2/`.
- **App releases:** the APK is uploaded to R2 under `app/` and `app/version.json` is bumped; installed apps then prompt to update. Tagged builds are also published under [Releases](../../releases).

## Credits

- Engine: [TourForge](https://github.com/tourforge) (open source)
- Map data: © [OpenStreetMap](https://www.openstreetmap.org/copyright) contributors, styled with [OpenMapTiles](https://openmaptiles.org/)
- Satellite imagery: © Esri, Maxar, Earthstar Geographics

---

_Karunya Navigator is an independent project for Karunya Institute of Technology and Sciences._
