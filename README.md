# Wallpaper Engine Tools

Command-line tools for unpacking, editing and repacking Wallpaper Engine scene wallpapers on Linux.

| Command | What it does |
| --- | --- |
| `wallpaper-engine-unpack` | Extracts `.pkg` files and converts `.tex` textures to PNG/JPG/GIF/MP4. A Python port of [RePKG](https://github.com/notscuffed/repkg). |
| `wallpaper-engine-repack` | Packs an extracted folder back into a `scene.pkg`. |
| `wallpaper-engine-copy-videos` | Copies every video wallpaper from the Workshop into one folder, named by title, exactly as it is. |
| `wallpaper-engine-copy-videos-optimized` | The same, but as MP4, re-encoding badly encoded videos, with options to cap the resolution or convert to HEVC. |
| `wallpaper-engine-copy-wallpapers` | Copies every Workshop wallpaper (scene, video and web) into a folder named after its title instead of its Workshop ID. |
| `wallpaper-engine-thumbnail-generator` | Makes a thumbnail (1920×1080 by default) named after the `project.json` title and points `"preview"` at it. |

## Install

```bash
./install.sh
```

Needs Python 3 and Pillow (`python3-pillow`). `python3-lz4` is optional and speeds up unpacking.

## Usage

```bash
# Unpack into my-wallpaper/unpacked-scenes/, with project.json and the preview in my-wallpaper/
wallpaper-engine-unpack scene.pkg -o my-wallpaper -c -u unpacked-scenes
wallpaper-engine-unpack info scene.pkg -e

# Edit files in my-wallpaper/unpacked-scenes/, then rebuild my-wallpaper/scene.pkg
wallpaper-engine-repack my-wallpaper -u unpacked-scenes

# Thumbnail from the wallpaper's own art, any image, or a screenshot
wallpaper-engine-thumbnail-generator my-wallpaper --from-extracted my-wallpaper/unpacked-scenes
wallpaper-engine-thumbnail-generator my-wallpaper --from picture.png --size 2560x1440
wallpaper-engine-thumbnail-generator my-wallpaper --screenshot --delay 5
```

`extract` is the default command, so it can be left out. The original package header version is saved in `my-wallpaper/.pkg-version` and reused when repacking.

To pack any extracted folder into a `.pkg` of your choosing instead, give both paths: `wallpaper-engine-repack extracted-folder out.pkg --like original/scene.pkg`. `--like` copies the version header from the original package; without it a generic `PKGV0001` header is used.

## Bulk Unpacking

Point `wallpaper-engine-unpack` at a folder laid out like Steam's Workshop folder (one numbered subfolder per wallpaper) and it unpacks every wallpaper that has a `.pkg`, each into its own folder:

```bash
WS=~/.local/share/Steam/steamapps/workshop/content/431960
wallpaper-engine-unpack extract "$WS" -o /home/$USER/Pictures/Wallpapers/Unpacked -c -n -u unpacked-scenes
```

Each wallpaper folder then keeps the same layout as in the Workshop, with the package contents in their own subfolder:

```
/home/$USER/Pictures/Wallpapers/Unpacked/
└── Wallpaper Title/
    ├── project.json
    ├── preview.jpg
    └── unpacked-scenes/     ← contents of scene.pkg (scene.json, materials/, ...)
```

* `-c` also copies each wallpaper's `project.json` and preview image.
* `-n` names each folder after the wallpaper's title. Leave it out to use the Workshop ID instead; IDs are always unique, while two wallpapers with the same title would share one folder.
* `-u unpacked-scenes` puts the package contents in that subfolder. Leave it out to unpack them straight into the wallpaper folder.
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

## Bulk Repacking

After editing, rebuild `scene.pkg` next to `project.json` in one wallpaper folder, or in all of them:

```bash
wallpaper-engine-repack "/home/$USER/Pictures/Wallpapers/Unpacked/Wallpaper Title" -u unpacked-scenes
wallpaper-engine-repack --all /home/$USER/Pictures/Wallpapers/Unpacked -u unpacked-scenes
```

Each folder ends up with `project.json`, the preview and `scene.pkg`, the same files a Workshop wallpaper has, ready for a player like Waywallen. The original package header version is saved in `.pkg-version` while unpacking and reused automatically. `-u` must match the subfolder name used when unpacking; `unpacked-scenes` is also the default, so it can be left out.

## Bulk Copying Video Wallpapers

Video wallpapers are plain video files, not packages, so they don't need unpacking. Two commands gather them all into one folder, ready for a player like Waywallen:

* `wallpaper-engine-copy-videos` copies every video exactly as it is. Fast, and needs nothing but Python.
* `wallpaper-engine-copy-videos-optimized` saves them as MP4 and fixes badly encoded ones on the way (see [Optimizing](#optimizing)). It needs `ffmpeg`.

Both name each video after its wallpaper's title, such as `Rainy Night.mp4`, adding the Workshop ID when two titles match.

```bash
WS=~/.local/share/Steam/steamapps/workshop/content/431960

# Preview, then copy every video unchanged
wallpaper-engine-copy-videos "$WS" -o /home/$USER/Pictures/Wallpapers/WallpaperEngineVideos --dry-run
wallpaper-engine-copy-videos "$WS" -o /home/$USER/Pictures/Wallpapers/WallpaperEngineVideos

# Or preview, then copy and optimize them, also shrinking anything larger than 1080p
wallpaper-engine-copy-videos-optimized "$WS" -o /home/$USER/Pictures/Wallpapers/WallpaperEngineVideos --1080p --dry-run
wallpaper-engine-copy-videos-optimized "$WS" -o /home/$USER/Pictures/Wallpapers/WallpaperEngineVideos --1080p
```

Use the Workshop folder for your Steam install from the [table above](#bulk-unpacking), or leave `"$WS"` out and it searches the usual locations itself (native, Debian/Ubuntu and Flatpak). To gather videos from several Steam libraries at once, list each Workshop folder:

```bash
wallpaper-engine-copy-videos "$WS" /mnt/games/SteamLibrary/steamapps/workshop/content/431960 \
  -o /home/$USER/Pictures/Wallpapers/WallpaperEngineVideos
```

After subscribing to new wallpapers, run the same command again; only the new videos are processed. `--overwrite` redoes the ones already there, for example to optimize videos you first copied unchanged:

```bash
wallpaper-engine-copy-videos-optimized "$WS" -o /home/$USER/Pictures/Wallpapers/WallpaperEngineVideos --1080p --overwrite
```

Copying unchanged keeps each video's original extension (`.mp4`, `.webm`, ...), while optimizing always writes `.mp4`. If you switch from one to the other, delete the old copies of any non-MP4 videos.

### Optimizing

`wallpaper-engine-copy-videos-optimized` checks each video with `ffprobe` and only fixes what needs fixing:

| Problem | What happens |
| --- | --- |
| A codec other than the target (H.264, or HEVC with `--hevc`) | Re-encoded to the target |
| 10-bit or 4:2:2 / 4:4:4 color | Re-encoded to standard 8-bit 4:2:0 |
| Bitrate far above what the resolution needs | Re-encoded; if that doesn't make it smaller, the original is kept |
| More than 60 frames per second | Re-encoded at 60 fps |
| Interlaced | Deinterlaced and re-encoded |
| Larger than the `--1080p` / `--1440p` / `--4k` limit | Shrunk to fit, keeping its shape |
| Not an MP4, or not "fast start" | Remuxed into a fast-start MP4, without re-encoding |
| Nothing wrong | Copied as is |

#### Options

| Option | What it does |
| --- | --- |
| `--1080p`, `--1440p`, `--4k` | Shrink anything larger than 1920×1080, 2560×1440 or 3840×2160 to fit. Smaller videos are left alone, never upscaled, since upscaling adds no detail and only makes files bigger and heavier to play. Ultrawide and other shapes are scaled to fit, not cropped. Pick one. |
| `--hevc` | Encode to HEVC (H.265) instead of H.264. Files are typically 30–50% smaller at the same quality, but HEVC is much heavier to play on GPUs without hardware HEVC decoding. Converting H.264 to HEVC is done only when it actually saves space. |
| `--only-bloated` | Re-encode only videos whose bitrate is far too high, and copy everything else unchanged: no codec conversion, no remuxing. Combines with `--hevc` and the resolution limits. |
| `--crf N` | Quality of re-encodes: lower means better quality and bigger files. Defaults are 18 for H.264 and 22 for HEVC, both close to visually lossless. Around 23 (H.264) or 26 (HEVC) gives noticeably smaller files with a small quality loss. |
| `--preset P` | Encoding speed: `veryfast` (default), `fast`, `medium`, `slow`, `slower`. Slower presets make smaller files at the same quality, but take much longer. |

Examples:

```bash
# Fix only the bloated files, nothing else
wallpaper-engine-copy-videos-optimized "$WS" --only-bloated

# Keep everything at most 4K
wallpaper-engine-copy-videos-optimized "$WS" --4k

# Smallest files: HEVC, capped at 1080p, slower preset
wallpaper-engine-copy-videos-optimized "$WS" --hevc --1080p --preset slow
```

**What counts as bloated:** the bitrate is compared with the video's resolution and frame rate (bits per pixel per frame). A well-made H.264 wallpaper sits around 0.05–0.15, and HEVC around half that, so files are flagged at roughly 2–3× the size they need to be: above 0.30 for H.264 (about 19 Mb/s, or 140 MB a minute, at 1080p30; about 75 Mb/s at 4K30) and above 0.15 for HEVC and VP9. A very large file that is long, high-resolution and still within that range is simply a big video, not a bloated one.

* A codec conversion to H.264 can make a file slightly larger (VP9 and HEVC compress better), but H.264 is far lighter to play, which matters most on GPUs without hardware video decoding. Audio is kept, or converted to AAC if MP4 can't hold it.
* Each video's size before and after is shown, with a total at the end.
* Needs `ffmpeg` and `ffprobe` with the `libx264` encoder, and `libx265` for `--hevc` (on Fedora, the full `ffmpeg` package from RPM Fusion).

## Copying Wallpapers by Title

The Workshop stores each wallpaper in a folder named by its Workshop ID, like `2970990736`. `wallpaper-engine-copy-wallpapers` copies them, with every file, into folders named after the title in their `project.json`:

```
/home/$USER/Pictures/Wallpapers/
├── [ BLUEY ] Bluey's Big Play ( WIP )/
│   ├── index.html
│   ├── preview.gif
│   └── project.json
└── Rainy Night/
    ├── project.json
    ├── preview.jpg
    └── scene.pkg
```

```bash
WS=~/.local/share/Steam/steamapps/workshop/content/431960

# Preview, then copy every wallpaper
wallpaper-engine-copy-wallpapers "$WS" -o /home/$USER/Pictures/Wallpapers --dry-run
wallpaper-engine-copy-wallpapers "$WS" -o /home/$USER/Pictures/Wallpapers

# Only some types
wallpaper-engine-copy-wallpapers "$WS" -o /home/$USER/Pictures/Wallpapers --type scene,web
```

* Titles are kept as they are, except for characters a folder name can't contain (`/` becomes `_`). When two wallpapers share a title, the Workshop ID is added: `Rainy Night (123456)`.
* `--type` picks wallpaper types: `scene`, `video`, `web` or `application`.
* Folders that already exist are skipped, so running it again only copies new subscriptions. `--overwrite` replaces existing folders, for example after a wallpaper was updated on the Workshop.
* Leave `"$WS"` out to search the usual Steam locations, or list several Workshop folders to copy from more than one Steam library.

### For Waywallen

Waywallen's Wallpaper Engine plugin only finds wallpapers in a Steam-style layout. `--waywallen` copies them there:

```bash
wallpaper-engine-copy-wallpapers "$WS" -o /home/$USER/Pictures/Wallpapers/WallpaperEngine --waywallen
```

This creates `WallpaperEngine/steamapps/common/wallpaper_engine/projects/myprojects/<title>/`. Then add `/home/$USER/Pictures/Wallpapers/WallpaperEngine` as a library under Plugins → Wallpaper Engine in Waywallen. It also keeps the preview images deep enough that Waywallen's image plugin doesn't list them as separate still wallpapers, which happens when wallpaper folders sit directly in a folder the image plugin scans.

## License

Copyright (C) 2026 HarleyGaniere

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. See [`LICENSE`](LICENSE) for the full text.

`wallpaper-engine-unpack` is based on RePKG by notscuffed, whose MIT License notice is kept in [`LICENSE.RePKG`](LICENSE.RePKG).
