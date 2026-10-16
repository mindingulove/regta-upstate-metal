# reGTA Upstate Metal

Build kit for running **GTA III + Upstate Liberty** natively on **Apple Silicon Macs** with a Metal renderer, Metal ray tracing
(reflections, sun shadows, rain puddles) and MetalFX upscaling.

**This repository contains no game files and no game source.** It holds:

- `regta-upstate-metal.patch`: the changes to [reGTA](https://github.com/gmh5225/reGTA) (Upstate Liberty support, native ports of
  the mods listed below, the graphics options, the ray tracing and MetalFX passes)
- `build.sh`: downloads reGTA at a fixed commit, applies the patch, swaps in
  [librw-metal](https://github.com/mindingulove/librw-metal) (librw with the Metal backend) and builds two executables

You need your own legally obtained copy of GTA III (PC). Nothing from the game is downloaded or distributed here.

## Requirements

- Mac with Apple Silicon (M1 or newer), macOS 14 or newer
- [Homebrew](https://brew.sh) and Xcode command line tools (`xcode-select --install`)
- GTA III for PC, your own copy
- Optional: the Upstate Liberty mod and the mods below, from their authors' release pages

## Build

```sh
git clone https://github.com/mindingulove/regta-upstate-metal.git
cd regta-upstate-metal
./build.sh                      # executables land in ./out
./build.sh "/path/to/GTA III"   # also copies them into your game folder
```

The script installs the Homebrew packages it needs (cmake, glfw, openal-soft, mpg123, glslang, spirv-cross).

It produces:

- `re3_metal`: Metal renderer (recommended)
- `re3`: the same game with Apple's OpenGL (fallback)

## Set up the game folder

1. Copy your GTA III installation to a folder on the Mac.
2. Install Upstate Liberty and any of the supported mods into it, as their readme says (Modloader layout works).
3. Run `./build.sh "/path/to/that/folder"`. It copies the executables and reGTA's own `gamefiles` into it.
4. Start it from that folder: `./re3_metal`. Add `-mute` to start without sound.

Graphics options are in the game under Options → Graphics → Advanced graphics, and in `re3.ini` under `[Graphics]`
(`RenderScale`, `RenderMetalFX`, `RenderRT`, `RenderRTShadows`, `RainPuddles`, `Retina`, ...).

## Supported mods (native ports)

Windows `.asi` plugins cannot run on an ARM Mac. Their behaviour is reimplemented natively in this build. Install the mod files
as usual: the native port picks up their data and settings. All credit for the mods goes to their authors. This kit does not
include their files.

| Mod | Status |
|---|---|
| Upstate Liberty (map) | data loads natively |
| Modloader (thelink2012) | native loader for the `modloader/` folder |
| CLEO (cleolibrary III.VC.CLEO) | native CLEO script runtime (no DLL plugins) |
| LocalDent III | native damage and crash deformation port (`scripts/LocalDentIII.ini`) |
| SACarCam | native port |
| Classic Axis | native port (camera) |
| FramerateVigilante | native port |
| ZMenu (trainer, F7) | native subset: player cheats, vehicle spawner, weather |
| HD Tri-Pack | works (textures) |

If you are the author of one of these mods and want your port removed or changed, open an issue.

## Legal

- Not affiliated with or endorsed by Rockstar Games or Take-Two Interactive. GTA and Grand Theft Auto are their trademarks.
- No copyrighted game data, executables or assets are included or downloaded. You need your own copy of the game.
- reGTA is fetched from its own public repository and is subject to its own terms. The patch only contains the changes made
  for this project.
- New files written for this project, such as the Metal backend in librw-metal, are under the MIT license.
