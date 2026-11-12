# Licencias de los assets 3D del proyecto

Este documento acredita el origen y la licencia de los packs usados. Los
archivos se usan **in situ** desde `res://assets/`; `res://ai_assets/` solo
contiene este documento y los textos de licencia.

## Resumen

| Pack | Ubicación en el proyecto | Origen | Licencia | Uso |
|------|--------------------------|--------|----------|-----|
| Molten Maps SciFi Asset Pack v1 | `assets/Molten Maps SciFi Asset Pack/` | Moltenbolt (moltenbolt.com) | **CC0 1.0** | Interior del hábitat, consolas, pasarela |
| KayKit Space Base Bits 1.0 FREE | `assets/KayKit_Space_Base_Bits_1.0_FREE/` | Kay Lousberg (kaylousberg.com) | **CC0 1.0** | Exterior: carga, camión, paneles, lander |
| Planet Pack (Verdant World) | `assets/Planets_Asteroids_FREE_SAMPLE/planets/` | Zbik | Uso personal/no comercial, **sin redistribución** | Planeta de fondo |
| Planets & Asteroids (Cratered Potato) | `assets/Planets_Asteroids_FREE_SAMPLE/asteroids/` | Appeal Foundry | Comercial permitido, **sin redistribuir los originales** | Asteroide de fondo |

Los textos completos están en `ai_assets/LICENSES/`.

## Detalle

### Molten Maps SciFi Asset Pack (CC0)

- **Autor**: Moltenbolt (https://www.moltenbolt.com)
- **Licencia**: Creative Commons Zero v1.0 Universal (CC0) — dominio público.
  Ver `LICENSES/molten_maps_license.txt`.
- **Uso**: arquitectura (suelo, paredes, techo, ventanal), mobiliario y
  consolas del módulo habitable.
- **Atribución**: opcional.

### KayKit Space Base Bits (CC0)

- **Autor**: Kay Lousberg (https://kaylousberg.com)
- **Licencia**: CC0 1.0. Ver `LICENSES/kaykit_license.txt`.
- **Uso**: decorado exterior sobre el cubo gris (depósitos, contenedores,
  camión, paneles solares, plataforma de aterrizaje y farolas).

### Planet Pack — Verdant World (Zbik)

- **Autor**: Zbik (officialzbik@gmail.com)
- **Licencia**: uso en proyectos **personales o no comerciales**; se permite
  modificar; **no se permite redistribuir ni revender los assets**.
  Ver `LICENSES/planet_pack_license.txt`.
- **Uso**: planeta visible a través del ventanal.

### Planets & Asteroids — Cratered Potato (Appeal Foundry)

- **Autor**: Appeal Foundry
- **Licencia**: uso comercial en juegos permitido; **no se puede revender ni
  redistribuir los archivos originales**; no se permite entrenar modelos de IA
  con estos assets. Ver `LICENSES/appeal_foundry_license.txt`.
- **Uso**: asteroide visible a través del ventanal.

## Packs NO versionados en Git

Los tres packs permanecen en `assets/` pero están excluidos del repositorio
(ver `.gitignore`):

1. **Licencia**: dos packs prohíben redistribuir los archivos originales;
   publicarlos en un remoto constituiría una redistribución no autorizada.
2. **Tamaño**: ~136 MB en total.
3. **Separación**: el repositorio guarda escenas y scripts; los packs se
   colocan en `assets/` al preparar el entorno (`bash tools/check_assets.sh`).

Los modelos que antes se copiaban a `ai_assets/habitat/` y `ai_assets/space/`
se eliminaron: las escenas ahora referencian los packs originales, así que
esas copias eran duplicados sin uso.

## Atribución en el juego

Si el juego se distribuye públicamente, incluir en los créditos:

- Molten Maps (Moltenbolt) — CC0
- Kay Lousberg (KayKit) — CC0
- Zbik (Planet Pack) — licencia no comercial
- Appeal Foundry (Planets & Asteroids) — licencia con restricciones
