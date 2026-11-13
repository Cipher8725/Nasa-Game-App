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

`ai_assets/` queda reservado para los recursos propios (texturas y modelos
generados con APIs externas, según `AGENTS.md` §4). Los packs existentes **no**
se duplican ahí: las escenas apuntan a `assets/`.

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
| `scenes/station_platform.tscn` | Cubo de 60 m con regolita lunar + pasarela y módulos laterales (Molten Maps) + exterior KayKit |
| `scenes/habitat_decor.tscn` | Interior del módulo: suelo con regolita marciana, paredes, techo, ventanal de cristal claro y props (Molten Maps) |
| `scenes/habitat.tscn` | Colisiones, consolas, luces, plataforma, decorado y espacio exterior |
| `scenes/console.tscn` | Consola de recurso sobre `Command_Console.glb` (Molten Maps) |

## Cubo gris de la estación → regolita lunar

La estación se apoya sobre un cubo de 60 × 60 × 60 m cuya cara superior está
en `y = -0.15` (las baldosas del suelo ocupan `y = -0.14 .. 0.01`).

El material está aislado en un único archivo:

```
resources/station_platform_material.tres   → regolita lunar (albedo + normal, uv1_scale = 12)
```

`uv1_scale = 12` reparte 12 repeticiones por cara del cubo (una baldosa de
textura cada 5 m). Si se cambia el tamaño del cubo, ajustar la escala para
mantener esa densidad.

Para volver a un cubo liso, poner `albedo_texture = null` y `albedo_color` gris.

## Texturas generadas con IA

Las cinco texturas propias están en `ai_assets/textures/` (sí se versionan: son
propias y pesan 1,69 MB en total). **Ninguna llega a 4K ni a Full HD:**

| Archivo | Tamaño | Uso |
|---------|--------|-----|
| `sky_space.webp` | 2048×1024 (q95) | Panorámica equirectangular del cielo |
| `moon_regolith.webp` + `_normal.webp` | 1024² (q90) / 512² (q92) | Regolita lunar del cubo base |
| `mars_regolith.webp` + `_normal.webp` | 1024² (q90) / 512² (q92) | Suelo interior del hábitat |

Se generaron con la API de **Layer** (`LAYER_API_KEY`, modelo `flux-3-image`,
1 crédito por imagen) y se procesaron con:

```bash
python tools/process_ai_textures.py --raw <carpeta_cruda> --out ai_assets/textures
```

El script recorta el borde, hace los suelos repetibles con **fundido cruzado
circular** (`O = A·I + (1−A)·I'`, banda del 20 %), deriva las normales con Sobel
circular (convención OpenGL) y guarda en **WebP**. Se descartó el JPEG: en un
campo de estrellas sobre negro produce bloques de 8×8 px que se ven al ampliar
la panorámica en pantalla (`~3×` a 1280×720).

Prompts usados (resumen): cielo = "Vía Láctea tenue sobre negro, sin nebulosa
exagerada ni destellos, campo de estrellas fino"; luna = "regolita lunar gris,
cráteres pequeños, vista cenital, textura plana y uniforme"; Marte = "suelo
marciano de regolita rojiza, piedras pequeñas y grietas de barro, vista cenital".

> Los `.import` deben conservar `compress/mode = 0`,
> `detect_3d/compress_to = 0` y `mipmaps/generate = true`. Si `detect_3d` vale 1,
> Godot recomprime la textura a VRAM al usarla en 3D y vuelven los bloques.

### Cómo se aplica cada textura

| Textura | Material | Dónde se aplica |
|---------|----------|-----------------|
| Cielo | `resources/sky_space_material.tres` (`PanoramaSkyMaterial`) | `WorldEnvironment` de `scenes/habitat.tscn` |
| Luna | `resources/station_platform_material.tres` | `StationPlatform/BaseCube` |
| Marte | `resources/mars_ground_material.tres` (triplanar de mundo) | `scripts/regolith_floor.gd` en el nodo `StationInterior` de `scenes/habitat_decor.tscn` (257 mallas de suelo) |

Para **desactivar** el suelo marciano: desmarcar `enabled` en el nodo
`StationInterior`. Para **cambiar el cielo**: sustituir `panorama` en
`resources/sky_space_material.tres` por otra equirectangular 2:1.

### Cristal de las ventanas

El pack trae el cristal de `Wall_Glass_Clear.glb` tintado (alfa 0.45). En el
renderizador Compatibility no hay transmisión, así que se veía como un panel azul
opaco. `scripts/window_glass.gd` (nodo `Walls`) sustituye **solo** la superficie
cuyo material se llama `Atlas Glass` por
`resources/window_glass_material.tres` (alfa 0.10, sin sombreado); el marco
`Atlas` se queda intacto. Se desactiva con `enabled = false` en ese nodo.

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
