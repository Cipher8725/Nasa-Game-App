#!/usr/bin/env bash
# Restaura los assets 3D del juego desde la boveda externa.
#
# Uso:  bash tools/restore_assets.sh
#
# Contexto: en el repositorio solo se versionan los 18 MB de assets que el
# juego usa realmente. Los packs de terceros completos (130 MB) se conservan
# fuera del proyecto por licencia y tamaño. Este script copia de la boveda
# únicamente los archivos que el juego necesita.

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VAULT_DIR="${NASA_ASSET_VAULT:-H:/GodotProyects/GodotProyects 4.7.2/nasa-asset-vault}"
MOLTEN="$VAULT_DIR/Molten Maps SciFi Asset Pack/Assets/gtlf"
PLANETS="$VAULT_DIR/Planets_Asteroids_FREE_SAMPLE"
TARGET="$PROJECT_DIR/ai_assets"

if [ ! -d "$VAULT_DIR" ]; then
    echo "ERROR: no se encuentra la boveda de assets en: $VAULT_DIR" >&2
    echo "       Define NASA_ASSET_VAULT o ajusta VAULT_DIR en este script." >&2
    exit 1
fi

echo "Boveda:  $VAULT_DIR"
echo "Destino: $TARGET"
echo ""

mkdir -p "$TARGET/habitat" "$TARGET/space"

# --- Habitat (Molten Maps, CC0) ---
# Formato: "<archivo origen>|<nombre destino>|<textura asociada opcional>"
copy_model() {
    local src_dir="$1" src="$2" dest="$3" texture="$4"
    if [ ! -f "$src_dir/$src" ]; then
        echo "  FALTA: $src" >&2
        return 1
    fi
    cp "$src_dir/$src" "$TARGET/habitat/$dest"
    echo "  + $dest"
    if [ -n "$texture" ] && [ -f "$src_dir/$texture" ]; then
        cp "$src_dir/$texture" "$TARGET/habitat/$texture"
        echo "  + $texture"
    fi
}

echo "Habitat (Molten Maps):"
copy_model "$MOLTEN" "Floor_Tile_Metal.glb"              "floor_tile_metal.glb"              "Floor_Tile_Metal_Gradient Texture Atlas by Imphenzia.png"
copy_model "$MOLTEN" "Floor_Metal_Square_Grate.glb"      "floor_metal_square_grate.glb"      "Floor_Metal_Square_Grate_Gradient Texture Atlas by Imphenzia.png"
copy_model "$MOLTEN" "Wall_Grey.glb"                     "wall_grey.glb"                     "Wall_Grey_Gradient Texture Atlas by Imphenzia.png"
copy_model "$MOLTEN" "Command_Console.glb"               "command_console.glb"               "Command_Console_Gradient Texture Atlas by Imphenzia.png"
copy_model "$MOLTEN" "Ceiling_Light.glb"                 "ceiling_light.glb"                 "Ceiling_Light_Gradient Texture Atlas by Imphenzia.png"
copy_model "$MOLTEN" "Large_Monitor_Blue.glb"            "large_monitor_blue.glb"            "Large_Monitor_Blue_Gradient Texture Atlas by Imphenzia.png"
copy_model "$MOLTEN" "Wall_Display_Off.glb"              "wall_display_off.glb"              "Wall_Display_Off_Gradient Texture Atlas by Imphenzia.png"
copy_model "$MOLTEN" "Bunk_Single_Grey.glb"              "bunk_single_grey.glb"              "Bunk_Single_Grey_Gradient Texture Atlas by Imphenzia.png"
copy_model "$MOLTEN" "Cryo_Tube_OFF.glb"                 "cryo_tube_off.glb"                 "Cryo_Tube_OFF_Gradient Texture Atlas by Imphenzia.png"
copy_model "$MOLTEN" "Generator.glb"                     "generator.glb"                     "Generator_Gradient Texture Atlas by Imphenzia.png"
copy_model "$MOLTEN" "Chair_1.glb"                       "chair.glb"                        "Chair_1_Gradient Texture Atlas by Imphenzia.png"
copy_model "$MOLTEN" "Railing_Flat.glb"                  "railing_flat.glb"                  "Railing_Flat_Gradient Texture Atlas by Imphenzia.png"
copy_model "$MOLTEN" "Table_Light.glb"                   "table_light.glb"                   "Table_Light_Gradient Texture Atlas by Imphenzia.png"
copy_model "$MOLTEN" "Hydroponics_Empty.glb"             "hydroponics_empty.glb"             "Hydroponics_Empty_Gradient Texture Atlas by Imphenzia.png"

# --- Fondo espacial ---
echo "Espacio:"
cp "$PLANETS/planets/Verdant_World.glb" "$TARGET/space/planet_verdant_world.glb" 2>/dev/null && echo "  + planet_verdant_world.glb" || echo "  FALTA: Verdant_World.glb"
cp "$PLANETS/asteroids/Cratered_Potato.glb" "$TARGET/space/asteroid_cratered_potato.glb" 2>/dev/null && echo "  + asteroid_cratered_potato.glb" || echo "  FALTA: Cratered_Potato.glb"

echo ""
echo "Assets restaurados. Importa el proyecto para generar los .import:"
echo "  godot --headless --path . --import"
