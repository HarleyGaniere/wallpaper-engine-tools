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

## Credits

`wallpaper-engine-unpack` is based on RePKG by notscuffed, used under the MIT License (see `LICENSE.RePKG`).
