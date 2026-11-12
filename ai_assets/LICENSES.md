# Licencias de los assets 3D del proyecto

Este documento acredita el origen y la licencia de cada asset usado en el juego.
Los archivos están en `res://ai_assets/`.

## Resumen

| Asset | Origen | Licencia | Uso |
|-------|--------|----------|-----|
| `habitat/*.glb` | Molten Maps SciFi Asset Pack v1 (moltenbolt.com) | **CC0 1.0** | Hábitat, consolas, decoración |
| `space/planet_verdant_world.glb` | Planet Pack (Zbik) | Uso personal/no comercial, **sin redistribución** | Fondo espacial |
| `space/asteroid_cratered_potato.glb` | Appeal Foundry — Planets & Asteroids | Comercial permitido, **sin redistribución** de los archivos originales | Fondo espacial |

## Detalle

### Molten Maps SciFi Asset Pack (CC0)

- **Autor**: Moltenbolt (https://www.moltenbolt.com)
- **Licencia**: Creative Commons Zero v1.0 Universal (CC0) — dominio público.
  Ver `LICENSES/molten_maps_license.txt`.
- **Uso**: modelos de arquitectura y props del hábitat.
- **Atribución**: opcional (el autor pide crédito, pero CC0 no lo exige).

### Planet Pack (Zbik)

- **Autor**: Zbik (officialzbik@gmail.com)
- **Licencia**: uso en proyectos **personales o no comerciales**; se permite
  modificar; **no se permite redistribuir ni revender los assets**.
  Ver `LICENSES/planet_pack_license.txt`.
- **Uso en este proyecto**: el planeta aparece como decorado de fondo.
- ⚠️ **Este pack NO se versiona en el repositorio** (ver más abajo).

### Planets & Asteroids (Appeal Foundry)

- **Autor**: Appeal Foundry
- **Licencia**: uso comercial en juegos permitido; **no se puede revender ni
  redistribuir los archivos originales**; no se permite entrenar modelos de IA
  con estos assets. Ver `LICENSES/appeal_foundry_license.txt`.
- **Uso en este proyecto**: asteroide de fondo.
- ⚠️ **Este pack NO se versiona en el repositorio** (ver más abajo).

## Packs NO versionados (decisión del arquitecto)

Los packs de terceros se conservan **fuera del repositorio Git** en:

```
H:\GodotProyects\GodotProyects 4.7.2\nasa-asset-vault\
├── KayKit_Space_Base_Bits_1.0_FREE/
├── Molten Maps SciFi Asset Pack/
├── Planets_Asteroids_FREE_SAMPLE/
├── LICENSE_PlanetPack.txt
└── README_PlanetPack.txt
```

Motivos:

1. **Licencia**: dos de los packs prohíben redistribuir los archivos originales.
   Versionarlos en un repositorio accesible lo constituiría en una
   redistribución no autorizada.
2. **Tamaño**: 130 MB de assets que solo se usan parcialmente.
3. **Regenerabilidad**: en `res://ai_assets/` solo están los 17 archivos
   (18,6 MB) que el juego utiliza realmente, ya renombrados con la convención
   del proyecto.

Al clonar el repositorio hay que restaurar esos 17 archivos en
`res://ai_assets/` (ver `docs/ASSETS.md`).

## Atribución en el juego

Si el juego se distribuye públicamente, se recomienda incluir en los créditos:

- Molten Maps (Moltenbolt) — CC0
- Kay Lousberg (KayKit) — CC0
- Zbik (Planet Pack) — licencia no comercial
- Appeal Foundry (Planets & Asteroids) — licencia con restricciones
