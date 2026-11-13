# Estado del Proyecto: NASA Space Apps - Junior Astronaut Mission Trainer

## 1. Resumen General

Juego de simulación y supervivencia mediante administración de recursos en
**Godot 4.7.2** para el reto "Junior Astronaut Mission Trainer". El jugador
administra cuatro recursos vitales (oxígeno, energía, agua y estructura)
durante una misión de 180 segundos dentro de un hábitat espacial 3D, reparando
las consolas del hábitat mientras las colisiones ambientales erosionan los
sistemas.

- **Motor**: Godot 4.7.2 (`H:\Godot V4.7.2\Godot_v4.7.2-stable_win64_console.exe`)
- **Lenguaje**: GDScript con tipado estricto (decisión del arquitecto, AGENTS.md §2)
- **Física**: Jolt Physics 3D
- **Renderizador**: `gl_compatibility`
- **Resolución**: 1280x720, landscape

## 2. ¿Qué se hizo?

### Hito 1 — Saneamiento del proyecto (Fase 0)

- Reorganización de `.opencode/skills/`: las 22 skills de `Open-Code-Godot-Studio`
  estaban en una ruta con directorio oculto (`.opencode/skills/Open-Code-Godot-Studio/.opencode/skills/`)
  y **no se autocargaban**. Se movieron a `.opencode/skills/<nombre>/SKILL.md`
  y ahora las 34 skills (12 de `Godot-Skills` + 22 del Studio) están activas.
- Normalización de `godot-class-name-checker` a `SKILL.md` con frontmatter válido
  (se reconstruyó en UTF-8 tras detectarse corrupción de caracteres).
- `.opencode/CONTEXT.md` movido a la ruta que exige `AGENTS.md` §9 (antes estaba
  en `.opencode/skills/CONTEXT.md`).
- `rules/`, `hooks/`, `docs/`, `mcp.json`, `settings.json` y `setup-mcp.*`
  promovidos a `.opencode/`; `design/gdd/` a la raíz; `OPENCODE.md` a la raíz.
- Reescrita `scenes/habitat.tscn` (antes `Habitat.tscn`): corregidos el UID
  malformado (`1234567890-...` → UIDs reales `uid://...`), el `load_steps`
  incorrecto, la doble instancia del `GameManager`, el nodo `AmbientLight`
  (WorldEnvironment sin `environment`) y la ausencia total de cámara.
- Reescrito `scripts/game_manager.gd` (antes `GameManager.gd`, obsoleto):
  `class_name GameManager`, `static var instance` + `get_instance()`,
  máquina de estados de misión, emisión de señales a 10 Hz, persistencia JSON.
- `project.godot`: escena principal, Autoload `Game`, mapa de entradas.

### Hito 2 — Bucle jugable completo (Fases 1-3)

- `scripts/habitat_player.gd` + `scenes/player.tscn`: `CharacterBody3D` con
  `CapsuleMesh`, cámara de tercera persona sobre `SpringArm3D`, `Area3D` de
  interacción con `SphereShape3D`, salto, gravedad y ratón capturado.
- `scripts/resource_console.gd` + `scenes/console.tscn`: consola por recurso con
  `Label3D` y material propio; se instancian 4 en el hábitat.
- `scripts/mission_hud.gd` + `scenes/hud.tscn`: HUD con 4 `ProgressBar`, valores
  numéricos, cronómetro, puntuación, alertas y panel de resultado. Observa
  señales; nunca modifica el estado.
- `scripts/emergency_system.gd` + `scenes/emergency_system.tscn`: generador de
  micrometeoritos, sobrecargas, caídas de presión y fugas de agua.
- `scripts/mission_config.gd` + `resources/default_mission.tres`: configuración
  data-driven (sin números mágicos).
- `scripts/mission_controller.gd` + `scenes/main.tscn`: orquestación, cuenta
  atrás y reinicio con `R`.
- `scripts/habitat.gd`: Registro y consulta de las consolas del hábitat.

### Hito 3 — Calidad y verificación

- Suite de 4 pruebas automatizadas en `tests/` (54 comprobaciones en total):
  `functional_test` (24), `interaction_test` (8), `simulation_test` (13),
  `asset_collision_test` (9 sobre 64 mallas / 537 pares).
- MCP de Godot **configurado y conectado** (`opencode.json`), con 14 tools
  operativas (`godot_run_project`, `godot_update_project_uids`, etc.).
- Skill `godot-unix-timestamp-fix` corregida: `OS.get_unix_time()` no existe en
  4.7.2 → `Time.get_unix_time_from_system()`.
- Tablas de `anchors_preset` corregidas en 3 skills tras verificarlas contra el
  motor (los valores publicados eran erróneos: `8`=CENTER, `12`=BOTTOM_WIDE).
- `engine-reference/godot/` actualizado a 4.7.2 con los hallazgos verificados.
- `design/gdd/game-concept.md` rellenado con el concepto de diseño real.

### Hito 4 — Control de versiones y assets 3D

- **Repositorio Git reparado y commit inicial creado** (`3f704e5`, rama `main`):
  - Eliminado el submódulo fantasma: `.opencode/skills/Godot-Skills` estaba en
    el índice como gitlink (modo `160000`) sin `.gitmodules`. Al clonar, el
    compañero recibía **0 de 34 skills**. Verificado con un clon real.
  - `.gitignore` corregido: `*.gd.uid` **no** se ignora (requisito de Godot
    4.4+; verificado que Godot regenera UIDs distintos si faltan).
  - `core.autocrlf=input` configurado (recomendación de Godot para Windows).
  - Identidad Git: `Cesar <flixian2@gmail.com>` (a nivel de repo, no global).
  - **Git LFS** configurado para `.glb`, `.png`, `.fbx`, `.obj`, audio y fuentes
    (antes del primer commit, como exige la documentación de Godot).
- **Assets 3D integrados** (fin del greyboxing del entorno):
  - Set curado de 16 modelos Molten Maps (CC0) + 2 de fondo espacial en
    `res://ai_assets/`, renombrados en `snake_case`.
  - `scenes/habitat_decor.tscn` con 25 baldosas, 20 paredes, 4 luces de techo
    y 10 props → 64 mallas en total.
  - `scenes/console.tscn` usa ahora `command_console.glb` real (escala 0,55).
  - Test `asset_collision_test.gd` que valida la colocación de los assets.
- **Packs de terceros retirados del proyecto** a la boveda
  `H:\GodotProyects\GodotProyects 4.7.2\nasa-asset-vault\` (130 MB),
  por licencia (dos packs prohíben redistribuir) y por tamaño.
  Los `.blend` (96 MB) se eliminaron: sin Blender son inservibles y Godot 4.7
  no los importa.
- `ai_assets/LICENSES.md` y `docs/ASSETS.md` documentan origen y licencias.

### Hito 5 — Estación espacial con los packs in situ (2026-11-12)

- **Los packs vuelven a `assets/` y se usan in situ** (orden del arquitecto:
  no moverlos). Se eliminaron las copias de `ai_assets/habitat/` y
  `ai_assets/space/`, que quedaron sin uso: las escenas ahora referencian
  `res://assets/Molten Maps SciFi Asset Pack/...`,
  `res://assets/KayKit_Space_Base_Bits_1.0_FREE/...` y
  `res://assets/Planets_Asteroids_FREE_SAMPLE/...`.
- **`scenes/station_platform.tscn`** (nuevo): cubo gris de 60 m (placeholder,
  material aislado en `resources/station_platform_material.tres`), pasarela y
  módulos laterales de Molten Maps, y decorado exterior de KayKit (depósitos
  de carga, contenedores apilados, camión, paneles solares, plataforma de
  aterrizaje con lander y farolas).
- **`scenes/habitat_decor.tscn` reconstruido** con piezas reales: 25 baldosas
  de suelo, 4 franjas de peligro, 20 paneles de pared (3 ventanales
  `Wall_Glass_Clear` al +Z y 2 puertas), 21 baldosas de techo + 4 luminarias y
  22 props (generador, baterías, literas, tubo criogénico, hidroponía,
  comedor, orrery, plantas, tuberías, aires acondicionados, pantallas y un
  monitor grande).
- **`scenes/habitat.tscn`**: instancia la plataforma y el interior, coloca las
  4 consolas en z = -7.85, añade 4 luces omni interiores y el fondo espacial
  (planeta Verdant World a escala 140 y asteroide). El sol se reorientó para
  iluminar la cara del planeta que mira al módulo; se añadió una luz de
  relleno sin sombras y tonemap ACES para contener los blancos.
- **Bug de física corregido**: las colisiones de las paredes laterales estaban
  sin rotar y cubrían media habitación (el jugador quedaba atrapado dentro de
  un sólido). Ahora están rotadas 90° sobre Y en x = ±9.6, con
  `BoxShape3D_wall` de `(20, 4, 0.74)`, coincidiendo con la cara interior de
  los paneles visuales.
- **Tests**: `asset_collision_test` actualizado (100 mallas, 911 pares; ignora
  el subárbol `StationPlatform` y los grupos `Floor`/`Ceiling`) y nuevo
  `tests/physics_test.tscn`, que con raycasts y `test_move` verifica que el
  centro de la sala es transitable, las 4 paredes y el suelo bloquean y el
  punto de aparición está libre.
- **Verificación real**: import + 5 suites (`functional`, `interaction`,
  `simulation`, `asset_collision`, `physics`) → `TODO OK`; además se
  renderizaron capturas del juego para revisar ventanal, consolas y exterior.
- **Limpieza**: `tools/restore_assets.sh` (obsoleto) sustituido por
  `tools/check_assets.sh`; `.gitignore` excluye los 3 packs por licencia y
  tamaño; `docs/ASSETS.md` y `ai_assets/LICENSES.md` actualizados.

### Hito 6 — Minijuegos de reparación (oxígeno y energía) (2026-11-12)

- Las reparaciones de **oxígeno y energía ya no son instantáneas**: al pulsar
  `E` en su consola se abre un **minijuego** con cuenta atrás. El agua y la
  estructura se siguen reparando al instante (aún sin minijuego).
- **Minijuego del oxígeno** (`scenes/ui/minigame_oxygen.tscn`): una aguja
  recorre una barra de presión y hay que **pulsar el botón** (ratón o ESPACIO)
  mientras la aguja está dentro de la zona verde. Acierto = +presión y +tiempo;
  fallo = −presión y −tiempo. La zona se estrecha al avanzar.
- **Minijuego de energía** (`scenes/ui/minigame_cables.tscn`): hay que
  **conectar 4 cables** con su conector (misma letra, conectores barajados).
  Una conexión incorrecta penaliza el tiempo y la presión. Las líneas
  conectadas se dibujan con `scripts/cable_wire_layer.gd`.
- **Arquitectura**:
  - `scripts/repair_minigame.gd` (`RepairMinigame`) es la base común:
    temporizador, progreso, resultado y puntos de extensión `_setup()`,
    `_update_visuals()` y `_handle_action_input()`.
  - `scripts/repair_minigame_manager.gd` (`RepairMinigameManager`, un
    `CanvasLayer` en el grupo `repair_minigames`) abre el minijuego que
    corresponde a cada recurso, bloquea el control del jugador y aplica la
    reparación en el `GameManager` al terminar.
  - El registro de minijuegos vive en `_scene_for()`: para añadir uno nuevo
    (agua, estructura, o mover las consolas cuando se amplíe el mapa) basta
    con registrar su escena y su script.
- **Jugador**: `set_input_enabled()` bloquea movimiento, salto e interacción
  mientras hay un minijuego abierto y libera el ratón (`MOUSE_MODE_VISIBLE`).
  Escape cancela la reparación; `R` no reinicia la misión con un minijuego
  abierto.
- **Grupos usados**: `player`, `mission_hud` y `repair_minigames`. Ojo: en
  Godot 4 los grupos van en la **cabecera del nodo**
  (`[node name="X" type="Y" groups=["grupo"]]`), no como propiedad aparte.
- **Tests**: nuevo `tests/minigame_test.tscn` (mecánica de ambos minijuegos +
  integración con la consola) y `tests/interaction_test.gd` reescrito para el
  nuevo flujo. Suite completa: 6 pruebas, todas en verde.

### Hito 7 — Módulos de habitación (2026-11-12)

- **9 módulos nuevos** en `scenes/rooms/`, construidos con piezas de Molten
  Maps (in situ, sin tocar ninguna escena existente):
  `room_cafeteria`, `room_quarters`, `room_generator`, `room_control`,
  `room_hydroponics`, `room_medbay`, `room_briefing`, `room_storage` y
  `corridor_module`.
- **Convención de módulos** (documentada en `scenes/rooms/README.md`):
  - Origen = centro de la zona de suelo; suelo de -4..+4 (8×8) o -2..+2 (8×4).
  - Paredes **por fuera** del suelo, centradas en `x/z = ±4.37` (`±2.37` en
    8×4); cara interior en `±4.00`.
  - **Puerta siempre en la pared −Z** (panel en `x = -2`), para encadenar
    módulos en filas separadas por pasillos.
  - Techo a `y = 4`; las luminarias cuelgan en `y = 3.66` (sin z-fighting).
  - Un `OmniLight3D` por luminaria (`y = 3.45`) con el tono de cada sala.
  - Colisión invisible en el nodo `Collision`: suelo + un tramo por panel; la
    puerta se hace con dos tramos para dejar un hueco de 1,6 m.
- **Trampa de la rejilla**: el `Transform3D` de un `.tscn` se interpreta en
  **filas**, así que una rotación de 90° invierte el desplazamiento del modelo.
  Varias piezas del pack tienen el origen descentrado (`Command_Console` va de
  `z = -1.73` a `3.15`, `Bunk_Double_Grey` de `x = -1.25` a `0.75`): hay que
  colocar midiendo la AABB real, no suponiendo que el modelo está centrado.
- **Tests**: nuevo `tests/room_collision_test.tscn` que instancia los 9
  módulos, valida su estructura y comprueba que ningún mueble se solapa con
  otro (AABB, umbral 0,05 m³). La suite completa queda en 7 pruebas.
- `scenes/rooms/rooms_preview.tscn` coloca los 9 módulos en fila para
  compararlos (no forma parte del juego).
- **Pendiente de decisión del arquitecto**: los módulos todavía no se
  instancian en el mapa; falta que indique dónde y con qué orientación.

### Hito 8 — Módulos IMG_ recreados desde `assets/IMG/` (2026-11-12)

- **8 módulos nuevos** en `scenes/rooms/`, recreados a partir de las fotos de
  referencia de `assets/IMG/` (renders del pack Molten Maps):
  `IMG_vestibulo` (6bDelJ), `IMG_sala_de_mando` (pGXT9C),
  `IMG_sala_del_generador` (PjBOyt), `IMG_enfermeria` (9tMILo),
  `IMG_criotanque` (bK2PlK), `IMG_cuartos` (DnG84u),
  `IMG_sala_de_reuniones` (S4lJ0w) y `IMG_sala_del_orrery` (vnoCXw).
- Misma convención que el Hito 7 (origen en el centro, paredes fuera, puerta
  en −Z, techo a y = 4, omni por luminaria, colisión invisible).
- **Dos criterios de colocación** que quedaron fijados:
  - Las franjas de peligro (`Hazard_Floor_1`) van en el nodo `Floor`: son
    superficie de apoyo, igual que las baldosas.
  - Las escaleras (`Ramp_Grey`) son piezas de 4 × 4 m con paredes propias, así
    que van **fuera** del módulo, junto al ventanal, como en las fotos.
- `tests/room_collision_test.tscn` valida ahora **17 módulos** (9 + 8) en
  total: estructura mínima + cero solapes.
- Las 8 escenas se generaron con un script temporal (fuera del repo) para
  mantener la estructura idéntica entre módulos; los `.tscn` resultantes son
  los que quedan versionados.

## 3. ¿Cómo se hizo?

### Arquitectura

```
scenes/main.tscn  (Node3D + mission_controller.gd)
├── Habitat       → instancia de scenes/habitat.tscn
│   ├── WorldEnvironment + SunLight + FillLight
│   ├── Floor / WallBack / WallFront / WallLeft / WallRight  (StaticBody3D + CollisionShape3D)
│   ├── StationPlatform → scenes/station_platform.tscn (cubo de 60 m + pasarela + exterior KayKit)
│   ├── Interior        → scenes/habitat_decor.tscn (suelo, paredes, techo y props)
│   ├── ConsoleOxygen / ConsoleEnergy / ConsoleWater / ConsoleStructure → scenes/console.tscn
│   ├── InteriorLights  → 4 OmniLight3D (uno por luminaria del techo)
│   └── SpaceBackdrop   → planeta Verdant World + asteroide
├── Player        → instancia de scenes/player.tscn (CharacterBody3D)
├── EmergencySystem → instancia de scenes/emergency_system.tscn (Node + Timer)
├── UILayer (CanvasLayer)
│   └── HUD       → instancia de scenes/hud.tscn (Control)
└── RepairMinigames (CanvasLayer, layer 10)
    └── (minijuego abierto) → scenes/ui/minigame_oxygen.tscn | minigame_cables.tscn
```

### Patrón de acceso al estado global

`GameManager` se registra como Autoload con el nombre **`Game`** y como clase
con `class_name GameManager`. Godot prohíbe que un `class_name` coincida con el
nombre de un Autoload (*"hides an autoload singleton"*), de ahí la separación.

El acceso **no** usa el identificador global `Game`, sino
`GameManager.get_instance()`, por dos motivos:

1. Las herramientas MCP ejecutan el motor con `--script`, modo en el que los
   identificadores de Autoload **no se registran** (`Compile Error: Identifier
   not found: Game`). Con `get_instance()` esas herramientas funcionan.
2. `get_instance()` tiene respaldo: si la variable estática aún no se publicó,
   busca el nodo del Autoload en el árbol.

`get_instance()` es **seguro en cualquier momento**: el inicializador de un
miembro de clase se ejecuta al construir el nodo (antes del `_ready()` del
Autoload), por lo que el acceso diferido es obligatorio en scripts que lo
necesiten durante el arranque.

### Flujo de señales (observador, nunca controlador)

```
GameManager (emite)                          Consumidores (observan)
─────────────────────────────────────        ──────────────────────────────────
resource_changed ──────────────────────────→ MissionHud (actualiza las 4 barras)
resource_critical ─────────────────────────→ MissionHud (alerta "nivel crítico")
resource_depleted ─────────────────────────→ MissionHud (alerta) + fail_mission()
resource_restored ────────────────────────→ MissionHud (confirmación)
emergency_triggered ───────────────────────→ MissionHud (alerta de emergencia)
mission_state_changed ─────────────────────→ MissionHud (etiqueta de estado)
mission_failed / mission_completed ───────→ MissionHud (panel de resultado)
```

`MissionHud` **nunca** modifica el estado: solo lee y refleja (regla de
`.opencode/rules/gameplay.md`).

### Capas de física (collision layer / mask)

| Objeto | Layer | Mask |
|--------|-------|------|
| Suelo y paredes (StaticBody3D) | 1 | 1 |
| Jugador (CharacterBody3D) | 2 | 1 |
| Consola (Area3D) | 4 | 0 |
| Área de interacción del jugador (Area3D) | 0 | 4 |

Así el `Area3D` del jugador detecta las consolas (`area_entered`) sin que el
cuerpo físico del jugador interfiera con ellas.

### Decaimiento y notificaciones

El decaimiento se aplica de forma continua en `_physics_process(delta)` (nunca
con números por frame), pero la señal `resource_changed` se emite a **10 Hz**
(`NOTIFICATION_HZ`) para no generar 240 señales por segundo. Los estados
`resource_critical` y `resource_depleted` son **transiciones de borde**
(`_critical_latched` / `_depleted_latched`), no estados continuos.

### Persistencia

`user://nasa_save_%d.json` con `JSON.stringify`. Marca de tiempo con
`Time.get_unix_time_from_system()` (verificado: `OS.get_unix_time()` ya no
existe en 4.7.2).

### 4. ¿Qué hay que hacer?

### Pendiente inmediato (siguiente hito)

1. **Textura del cubo de la estación**: sustituir el material gris
   (`resources/station_platform_material.tres`) por un mapa con textura. Basta
   con asignar `albedo_texture` o crear un material nuevo para `BaseCube`.
2. **Audio**: alarmas de recurso crítico, impacto de emergencia y confirmación
   de reparación. Usar `AudioStreamPlayer` definido en las escenas.
3. **Assets finales del jugador**: el astronauta sigue siendo una cápsula
   (`CapsuleMesh`). **Decisión actual: dejarlo así** (no hay modelo de
   astronauta en los packs). Si se quiere cambiar, usar Meshy
   (`MESHY_API_KEY`) y guardar el resultado en `res://ai_assets/`.
4. **Niveles adicionales**: segunda misión con distinta dificultad y más
   consolas, cargando una `MissionConfig` distinta.
5. **Remoto Git**: crear el repositorio en GitHub y añadirlo como `origin`
   (`git remote add origin <url>` + `git push -u origin main`). Pendiente de
   decisión del arquitecto: el repositorio debe ser **privado** mientras
   contenga assets con licencias restrictivas.

### Pendiente secundario

6. **Entrada de guardado/carga en el HUD**: botones `F5` (guardar) y `F9`
   (cargar) con la API `save_game` / `load_game` ya implementada.
7. **Sonido y música ambiental** del hábitat.
8. **Tutorial**: cartel inicial que explique los controles (WASD, ratón, `E`, `R`).
9. **Estadísticas de sesión**: tiempo total y misiones completadas, ya
   disponibles vía `get_missions_completed()`.
10. **Exportación**: crear `export_presets.cfg` para Windows/Linux.
11. **Minijuegos de agua y estructura**: replicar el patrón de oxígeno y
    energía cuando el arquitecto amplíe el mapa e indique las ubicaciones
    exactas de las nuevas consolas (o de los paneles de repairing).
12. **Colocar los módulos de `scenes/rooms/` en el mapa**: están listos y
    verificados, pero el arquitecto tiene que indicar dónde va cada uno y con
    qué orientación (la puerta mira siempre a −Z).

### Deuda técnica conocida

12. `scripts/mission_hud.gd` actualiza cronómetro y puntuación cada fotograma en
    `_process`. Es aceptable, pero puede pasar a 10 Hz igual que los recursos.
13. La skill `godot-console` menciona `--check-only` con `--script`; ese modo no
    registra Autoloads, así que solo sirve para scripts sin dependencias de
    Autoload (o usando `get_instance()`).
14. Los `.glb` de Molten Maps referencian sus texturas PNG por UID: **cada
    `.glb` debe permanecer junto a su PNG** (mismo nombre base). Por eso los
    packs se usan completos desde `assets/` y no se copian archivos sueltos.
15. Los tres packs de `assets/` **no están en Git** (licencias y ~136 MB). Al
    clonar hay que colocarlos y ejecutar `bash tools/check_assets.sh` antes de
    importar; sin ellos las escenas no cargan.
16. Los minijuegos son deliberadamente sencillos (el arquitecto los mejorará
    después): el de oxígeno solo mide pulsaciones y el de cables solo 4
    conexiones fijas. La dificultad está en los `@export` de cada script.

## 5. ¿Cómo hay que hacerlo?

### Reglas de implementación (obligatorias)

- **Tipado estricto** en todos los `.gd`: variables, parámetros y retornos.
  Sin excepciones (AGENTS.md §2, `.opencode/rules/gdscript.md`).
- **Nodos estructurales siempre en `.tscn`**: `CollisionShape3D`, `Camera3D`,
  `Timer`, `MeshInstance3D`, `Area3D`, `SpringArm3D`. Prohibido crearlos en
  `_ready()` (reglas del Studio + `coding-standards.md`).
- **La UI observa, la lógica decide**: el HUD se conecta a señales; el
  `GameManager` nunca conoce al HUD.
- **Todo valor ajustable es `@export` o un `Resource`** (`MissionConfig`).
  Sin números mágicos.
- **Toda lógica dependiente del tiempo usa `delta`**.
- **Acceso al gestor**: `GameManager.get_instance()`, nunca `Game.<algo>()`.
- **Verificar siempre contra el binario**: `--headless --import` para compilar y
  `opencode mcp list` / `godot_run_project` para el runtime. Ante la duda de si
  una API existe en 4.7.2, consultarla con
  `ClassDB.class_has_method("Clase", "metodo", true)`.

### Procedimiento de verificación (el que se usó)

```powershell
$godot = "H:\Godot V4.7.2\Godot_v4.7.2-stable_win64_console.exe"
$root  = "H:\GodotProyects\GodotProyects 4.7.2\na-sa-game"

# 1. Importar / compilar (detecta errores de parseo)
& $godot --headless --path $root --import

# 2. Suite de pruebas (OJO: --quit-after cuenta iteraciones, no segundos)
& $godot --headless --path $root --quit-after 20000 "res://tests/functional_test.tscn"
& $godot --headless --path $root --quit-after 20000 "res://tests/interaction_test.tscn"
& $godot --headless --path $root --quit-after 20000 "res://tests/simulation_test.tscn"
& $godot --headless --path $root --quit-after 2000  "res://tests/asset_collision_test.tscn"
& $godot --headless --path $root --quit-after 2000  "res://tests/physics_test.tscn"
& $godot --headless --path $root --quit-after 20000 "res://tests/minigame_test.tscn"
& $godot --headless --path $root --quit-after 3000  "res://tests/room_collision_test.tscn"

# 3. Juego principal
& $godot --headless --path $root --quit-after 5
```

> `--quit-after N` cuenta **iteraciones del bucle**, no segundos. En headless las
> iteraciones pasan muy rápido, así que hace falta un valor alto (20000) para
> que los temporizadores reales (cuenta atrás de 3 s) lleguen a dispararse.

### Patrón para añadir un recurso nuevo

1. Añadir la constante `StringName` en `GameManager` (`RESOURCE_*`).
2. Añadir su capacidad, tasa de decaimiento y getters en `MissionConfig`.
3. Añadir el `ProgressBar` + `Label` en `scenes/hud.tscn` con
   `unique_name_in_owner = true`.
4. Reflejarlo en `MissionHud._on_resource_changed` y en
   `MissionHud._update_resource_bar`.
5. Crear la consola correspondiente en `scenes/habitat.tscn` con su color.
6. Extender `tests/functional_test.gd` y `tests/simulation_test.gd`.

### Workflow de la skill `godot-gdscript`

La skill recomienda **no generar `.tscn` a mano** y usar MCP
(`godot_create_scene` + `godot_add_node` + `godot_save_scene`). Para el MCP
funciona, la ruta de la herramienta debe ser **relativa** (`.`), porque concatena
`res://` a la ruta recibida y una ruta absoluta produce `res://H:\...`.

### Control de versiones (reglas del proyecto)

- **Conventional commits** (lo valida el hook `validate-commit.sh`):
  `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`, `perf:`, `build:`,
  `ci:`, `style:`, `revert:`.
- **Nunca versionar** los `.uid` como ignorados: Godot 4.4+ los exige. Si
  faltan, se regeneran con valores distintos y se rompen las referencias
  `uid://` de las escenas.
- **Git LFS** para binarios (`.glb`, `.png`, `.fbx`, audio, fuentes). El
  `.gitattributes` ya está configurado.
- **Packs de terceros**: se usan **in situ** desde `assets/` y **no se
  versionan** (ver `.gitignore`). Dos licencias prohíben redistribuirlos y
  entre los tres suman ~136 MB. `ai_assets/` solo guarda las licencias y, en el
  futuro, los recursos generados por APIs. Antes de importar, comprobar el
  entorno con `bash tools/check_assets.sh`.
- **Verificar el clon** tras cambios en la estructura del repo:
  ```powershell
  git clone --no-hardlinks . <destino-temporal>
  # comprobar que llegan las skills, los .uid y los assets (LFS)
  ```

---
*Actualizado: 2026-11-12 — Hito 8 (módulos IMG_* recreados desde assets/IMG) completado.*
