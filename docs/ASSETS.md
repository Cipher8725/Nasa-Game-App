# Assets del proyecto

## Estructura

```
res://ai_assets/          → assets 3D que USA el juego (versionados en Git)
├── habitat/              → arquitectura y props del hábitat (Molten Maps, CC0)
│   ├── *.glb             → modelos 3D
│   └── *.png             → texturas del atlas (referenciadas por los .glb)
├── space/                → decorado del fondo espacial
│   ├── planet_*.glb
│   └── asteroid_*.glb
└── LICENSES/             → textos de licencia de cada origen
```

Los assets de terceros completos **no** están en el repositorio. Se conservan en:

```
H:\GodotProyects\GodotProyects 4.7.2\nasa-asset-vault\
```

Motivos y licencias detallados en → `res://ai_assets/LICENSES.md`.

## ⚠️ Importante: los `.glb` necesitan sus texturas PNG

Los archivos `.glb` de Molten Maps son glTF con **texturas externas** referenciadas
por UID. Si se copia un `.glb` sin su PNG correspondiente, Godot avisa:

```
WARNING: 'res://ai_assets/habitat/command_console.glb': In external resource #0,
invalid UID: 'uid://bhyqi287r070t' - using text path instead: '...'
```

El juego sigue funcionando, pero con **materiales sin textura**. Para restaurar
los assets tras clonar el repositorio hay que copiar **el `.glb` y su PNG
asociado** (mismo nombre base).

## Procedimiento para añadir un asset nuevo

1. Copiar el `.glb` (y su `.png` si existe) a `res://ai_assets/<categoria>/`.
2. Renombrarlo a `snake_case` descriptivo (convención del proyecto).
3. Verificar la licencia del pack de origen y anotarla en `LICENSES.md`.
4. Importar: `godot --headless --path . --import`.
5. Colocarlo en la escena y **verificar que no se solapa** con otros assets:
   ```powershell
   godot --headless --path . --quit-after 500 "res://tests/asset_collision_test.tscn"
   ```
   El test lista los solapes significativos (> 0,05 m³) y falla si hay alguno.
6. Si el asset tiene licencia restrictiva (no CC0), **no versionarlo**: dejarlo
   solo en la boveda.

## Test de colisiones

`tests/asset_collision_test.gd` recorre la escena del hábitat y compara los AABB
de las 64 mallas placed (1536 pares). Ignora:

- Copias del mismo asset (tejas y paredes repetidas).
- El suelo (los objetos se apoyan sobre las baldosas).
- Contactos de borde (< 0,05 m³).

Falla si algún asset se solapa de forma significativa con otro o con una pared.
