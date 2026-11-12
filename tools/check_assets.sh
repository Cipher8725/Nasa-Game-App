#!/usr/bin/env bash
# Verifica que los tres packs de terceros estén disponibles en `assets/`.
#
# Las escenas usan los packs IN SITU (no se copian ni se mueven), así que el
# proyecto no carga si falta alguno. Este script comprueba su presencia antes
# de abrir el editor o ejecutar los tests.
#
# Uso:  bash tools/check_assets.sh

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSETS="$PROJECT_DIR/assets"

missing=0

check_dir() {
    local path="$1"
    if [ -d "$path" ]; then
        echo "  [OK]    ${path#"$PROJECT_DIR/"}"
    else
        echo "  [FALTA] ${path#"$PROJECT_DIR/"}" >&2
        missing=1
    fi
}

check_file() {
    local path="$1"
    if [ -f "$path" ]; then
        echo "  [OK]    ${path#"$PROJECT_DIR/"}"
    else
        echo "  [FALTA] ${path#"$PROJECT_DIR/"}" >&2
        missing=1
    fi
}

echo "Comprobando packs en: $ASSETS"

echo ""
echo "Molten Maps (interior del hábitat):"
check_dir  "$ASSETS/Molten Maps SciFi Asset Pack/Assets/gtlf"
check_file "$ASSETS/Molten Maps SciFi Asset Pack/Assets/gtlf/Floor_Tile_Metal.glb"
check_file "$ASSETS/Molten Maps SciFi Asset Pack/Assets/gtlf/Wall_Glass_Clear.glb"
check_file "$ASSETS/Molten Maps SciFi Asset Pack/Assets/gtlf/Command_Console.glb"

echo ""
echo "KayKit Space Base Bits (exterior de la estación):"
check_dir  "$ASSETS/KayKit_Space_Base_Bits_1.0_FREE/Assets/gltf"
check_file "$ASSETS/KayKit_Space_Base_Bits_1.0_FREE/Assets/gltf/cargodepot_A.gltf"
check_file "$ASSETS/KayKit_Space_Base_Bits_1.0_FREE/Assets/gltf/lander_A.gltf"

echo ""
echo "Planets & Asteroids (fondo espacial):"
check_dir  "$ASSETS/Planets_Asteroids_FREE_SAMPLE/planets"
check_file "$ASSETS/Planets_Asteroids_FREE_SAMPLE/planets/Verdant_World.glb"
check_file "$ASSETS/Planets_Asteroids_FREE_SAMPLE/asteroids/Cratered_Potato.glb"

echo ""
if [ "$missing" -ne 0 ]; then
    echo "ERROR: faltan packs. Restáuralos en assets/ (ver ai_assets/LICENSES.md)." >&2
    exit 1
fi

echo "Todo listo. Importa el proyecto con:"
echo "  godot --headless --path . --import"
