# Assets del proyecto

## Política: los packs se usan in situ

Los tres packs de terceros viven en `assets/` y las escenas los referencian
**directamente** (`res://assets/...`). No se copian, no se renombran y no se
mueven de esa carpeta (decisión del arquitecto).

```
assets/
├── Molten Maps SciFi Asset Pack/      → interior del módulo habitable (CC0)
├── KayKit_Space_Base_Bits_1.0_FREE/   → exterior: carga, camión, paneles, lander (CC0)
└── Planets_Asteroids_FREE_SAMPLE/     → planeta Verdant World y asteroide (restrictivas)
```

`ai_assets/` queda reservado para los recursos que se generen con APIs
externas (Meshy / Fal) según `AGENTS.md` §4. Los packs existentes **no** se
duplican ahí: las escenas apuntan a `assets/`.

Las licencias y la atribución están en `ai_assets/LICENSES.md` y los textos
originales en `ai_assets/LICENSES/`.

## Por qué los packs no se versionan en Git

Dos de los packs prohíben redistribuir los archivos originales y entre los
tres suman ~136 MB. Por eso `.gitignore` excluye las tres carpetas:

```
/assets/KayKit_Space_Base_Bits_1.0_FREE/
/assets/Molten Maps SciFi Asset Pack/
/assets/Planets_Asteroids_FREE_SAMPLE/
```

Al clonar el repositorio hay que colocar los packs en `assets/` y comprobar
que están todos:

```bash
bash tools/check_assets.sh
godot --headless --path . --import
```

## Estructura de las escenas

| Escena | Contenido |
|--------|-----------|
| `scenes/station_platform.tscn` | Cubo gris de 60 m + pasarela y módulos laterales (Molten Maps) + exterior KayKit |
| `scenes/habitat_decor.tscn` | Interior del módulo: suelo, paredes, techo, ventanal y props (Molten Maps) |
| `scenes/habitat.tscn` | Colisiones, consolas, luces, plataforma, decorado y espacio exterior |
| `scenes/console.tscn` | Consola de recurso sobre `Command_Console.glb` (Molten Maps) |

## Cubo gris de la estación (placeholder)

La estación se apoya sobre un cubo de 60 × 60 × 60 m cuya cara superior está
en `y = -0.15` (las baldosas del suelo ocupan `y = -0.14 .. 0.01`).

El material está aislado en un único archivo para poder sustituirlo por una
textura de mapa sin tocar la escena:

```
resources/station_platform_material.tres
```

Para cambiar el aspecto del cubo basta con asignarle un `albedo_texture`
(por ejemplo, una textura descargada en `res://ai_assets/`) o crear un
material nuevo y asignarlo a `StationPlatform/BaseCube` en
`scenes/station_platform.tscn`.

## Verificación automatizada

```powershell
$godot = "H:\Godot V4.7.2\Godot_v4.7.2-stable_win64_console.exe"

# Colocación de assets: AABB de las 100 mallas del interior (911 pares)
& $godot --headless --path . --quit-after 2000 "res://tests/asset_collision_test.tscn"

# Física: paredes, suelo, punto de aparición y movimiento del jugador
& $godot --headless --path . --quit-after 2000 "res://tests/physics_test.tscn"
```

`asset_collision_test` ignora:

- Las copias del mismo asset (baldosas y paneles repetidos).
- Los grupos `Floor` y `Ceiling` (superficies de apoyo).
- El subárbol `StationPlatform` (el cubo y el decorado exterior).
- Los contactos de borde (< 0,05 m³).

## Añadir una pieza de un pack

1. Localizarla dentro de `assets/<pack>/...` y **no moverla**.
2. Añadir un `ext_resource` con su ruta real, por ejemplo:
   `res://assets/Molten Maps SciFi Asset Pack/Assets/gtlf/Wall_Grey.glb`.
3. Colocarla en la escena y pasar el test de colisiones.
4. Si el modelo tiene el origen descentrado (AABB asimétrico), colócalo con
   margen respecto a la cara interior de la pared (`x/z = ±9.23`).

Los `.glb` de Molten Maps llevan su PNG en la misma carpeta; mantenerlos
juntos evita avisos de UID y materiales sin textura.
