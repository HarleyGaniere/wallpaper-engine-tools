# Wallpaper Engine Tools

Command-line tools for unpacking, editing and repacking Wallpaper Engine scene wallpapers on Linux.

| Command | What it does |
| --- | --- |
| `wallpaper-engine-unpack` | Extracts `.pkg` files and converts `.tex` textures to PNG/JPG/GIF/MP4. A Python port of [RePKG](https://github.com/notscuffed/repkg). |
| `wallpaper-engine-repack` | Packs an extracted folder back into a `scene.pkg`. |
| `wallpaper-engine-thumbnail-generator` | Makes a thumbnail (1920×1080 by default) named after the `project.json` title and points `"preview"` at it. |

## Install

```bash
./install.sh
```

Needs Python 3 and Pillow (`python3-pillow`). `python3-lz4` is optional and speeds up unpacking.

## Usage

```bash
# Unpack (extract is the default command)
wallpaper-engine-unpack scene.pkg -o output -c
wallpaper-engine-unpack info scene.pkg -e

# Edit files in output/, then repack
wallpaper-engine-repack output scene.pkg --like original/scene.pkg

# Thumbnail from the wallpaper's own art, any image, or a screenshot
wallpaper-engine-thumbnail-generator <wallpaper-folder> --from-extracted output
wallpaper-engine-thumbnail-generator <wallpaper-folder> --from picture.png --size 2560x1440
wallpaper-engine-thumbnail-generator <wallpaper-folder> --screenshot --delay 5
```

`--like` copies the version header from the original package; without it a generic `PKGV0001` header is used.

## Bulk Unpacking

Point `wallpaper-engine-unpack` at a folder laid out like Steam's Workshop folder (one numbered subfolder per wallpaper) and it unpacks every wallpaper that has a `.pkg`, each into its own folder:

```bash
WS=~/.local/share/Steam/steamapps/workshop/content/431960
wallpaper-engine-unpack extract "$WS" -o ~/wallpapers/unpacked -c -n
```

* `-c` also copies each wallpaper's `project.json` and preview image.
* `-n` names each folder after the wallpaper's title. Leave it out to use the Workshop ID instead; IDs are always unique, while two wallpapers with the same title would share one folder.
* `--no-tex-convert` skips converting textures to images: much faster, and about half the disk space.
* Running it again skips files that already exist, so an interrupted run can simply be restarted. Add `--overwrite` to redo everything.
* Video and web wallpapers have no `.pkg` and are skipped; their files in the Workshop folder are already usable as-is.
* Add `-r` to search nested folders at any depth instead of only one level down.

Common Workshop folder locations:

| Steam install | Workshop folder |
| --- | --- |
| Native package | `~/.local/share/Steam/steamapps/workshop/content/431960` |
| Debian/Ubuntu package | `~/.steam/debian-installation/steamapps/workshop/content/431960` |
| Flatpak | `~/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/workshop/content/431960` or `~/.var/app/com.valvesoftware.Steam/data/Steam/steamapps/workshop/content/431960` |
| Other library folders | `<library>/steamapps/workshop/content/431960` |

Check the space first: `du -sh "$WS"`. The unpacked copy is roughly that size again, or up to about double with texture conversion on.

## License

Copyright (C) 2026 HarleyGaniere

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. See [`LICENSE`](LICENSE) for the full text.

`wallpaper-engine-unpack` is based on RePKG by notscuffed, whose MIT License notice is kept in [`LICENSE.RePKG`](LICENSE.RePKG).
