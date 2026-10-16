#!/bin/bash
# Builds the Metal version of reGTA with the Upstate Liberty ports from public sources.
# No game files are downloaded or included: you need your own copy of GTA III (see README.md).
#
#   ./build.sh                 build into ./work
#   ./build.sh /path/to/game   also copy the executables into your game folder
set -euo pipefail

REGTA_URL=https://github.com/gmh5225/reGTA.git
REGTA_COMMIT=b846c8f5ae168c8b7fe79d7193e142f5ac4448cb	# the commit the patch was made against
LIBRW_URL=https://github.com/mindingulove/librw-metal.git
LIBRW_COMMIT=b8dd020b9d014c9065f5b4bc76a17d2f5f732d62

HERE="$(cd "$(dirname "$0")" && pwd)"
WORK="$HERE/work"
GAME="${1:-}"

if [[ "$(uname -s)" != Darwin || "$(uname -m)" != arm64 ]]; then
	echo "This build is for Apple Silicon Macs (the Metal backend, ray tracing and MetalFX need it)." >&2
	exit 1
fi
command -v brew >/dev/null || { echo "Install Homebrew first: https://brew.sh" >&2; exit 1; }

echo "== dependencies (Homebrew)"
brew install cmake glfw openal-soft mpg123 glslang spirv-cross >/dev/null
BREW="$(brew --prefix)"
OAL="$(brew --prefix openal-soft)"

echo "== reGTA source"
mkdir -p "$WORK"
if [[ ! -d "$WORK/reGTA/.git" ]]; then
	git clone --quiet "$REGTA_URL" "$WORK/reGTA"
fi
cd "$WORK/reGTA"
git reset --quiet --hard
git clean -qfd
git checkout --quiet "$REGTA_COMMIT"
git submodule --quiet update --init vendor/ogg vendor/opus vendor/opusfile

echo "== Upstate + Metal changes"
git apply --whitespace=nowarn "$HERE/regta-upstate-metal.patch"

echo "== librw with the Metal backend"
rm -rf vendor/librw
git clone --quiet "$LIBRW_URL" vendor/librw
git -C vendor/librw checkout --quiet "$LIBRW_COMMIT"

COMMON=(-DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="$BREW;$OAL" -DCMAKE_CXX_FLAGS="-I$OAL/include"
	-DLIBRW_PLATFORM=GL3 -DLIBRW_GL3_GFXLIB=GLFW -DLIBRW_INSTALL=OFF -DLIBRW_TOOLS=OFF
	-DRE3_AUDIO=OAL -DRE3_INSTALL=OFF -DRE3_WITH_LIBSNDFILE=OFF -DRE3_WITH_OPUS=OFF
	-DOPENAL_INCLUDE_DIR="$OAL/include" -DOPENAL_LIBRARY="$OAL/lib/libopenal.dylib")
JOBS="$(sysctl -n hw.ncpu)"

echo "== building the Metal version (re3_metal)"
cmake -S . -B build-metal "${COMMON[@]}" -DLIBRW_METALGL=ON >/dev/null
cmake --build build-metal -j "$JOBS" >/dev/null
echo "== building the OpenGL version (re3)"
cmake -S . -B build-gl "${COMMON[@]}" >/dev/null
cmake --build build-gl -j "$JOBS" >/dev/null

mkdir -p "$HERE/out"
cp build-metal/src/re3 "$HERE/out/re3_metal"
cp build-gl/src/re3 "$HERE/out/re3"
codesign -f -s - "$HERE/out/re3_metal" "$HERE/out/re3" 2>/dev/null || true
echo "== done: $HERE/out/re3_metal and $HERE/out/re3"

if [[ -n "$GAME" ]]; then
	[[ -d "$GAME" ]] || { echo "game folder not found: $GAME" >&2; exit 1; }
	cp "$HERE/out/re3_metal" "$HERE/out/re3" "$GAME/"
	cp -Rn gamefiles/. "$GAME/" 2>/dev/null || true
	echo "== copied into $GAME (reGTA's own gamefiles were added where missing)"
fi
