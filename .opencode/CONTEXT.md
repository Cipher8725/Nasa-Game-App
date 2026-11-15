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

### Hito 9 — Módulos ampliados a 20 × 20 m (2026-11-12)

- **Todos los módulos de habitación pasan a 20 × 20 m**, con la **misma retícula
  que el módulo de habitat** (`scenes/habitat_decor.tscn`):
  - Suelo: 5 × 5 baldosas de 4 m con centros en −8, −4, 0, 4, 8 (−10..+10).
  - Paredes: 5 paneles de 4 m por lado centrados en ±9,6 (cara interior ±9,23);
    la puerta (`Wall_With_Door_Grey`) en la pared sur, en x = 0.
  - Techo: 21 baldosas + 4 luminarias en (±4, ±4); 8 luminarias en las salas
    técnicas. Luminarias en y = 3,66 y omni en y = 3,45.
  - Colisión: caja de suelo (20 × 0,4 × 20) y una por panel; la puerta con
    dos tramos para dejar un hueco de 1,6 m.
- **MobiliarioAmpliado** en los 17 módulos: ~90 mallas por habitación (el
  módulo de habitat tiene ~110), con más muebles y repartidos por los 400 m².
- **Excepción**: `corridor_module` pasa a 8 × 8 m (dos tramos de
  `Corridor_Boundary_4x8` del pack) porque su función es conectar, no alojar.
- Nuevas reglas de colocación que quedaron fijadas:
  - Los **paneles de pared comparten grupo** en el test: en las esquinas se
    solapan entre sí por diseño (igual que en habitat).
  - Las **piezas cerradas** (tramos de pasillo) van en el nodo `Shell` y el
    test las ignora: su AABB engloba el módulo y daría solapes falsos.
  - Las **lostas grandes de suelo** (`Floor_Command_Large`,
    `Floor_Medbay_Large`) van en el nodo `Floor` como decals (son 8 × 8 m y no
    cubren un módulo de 20 × 20 m).
- `rooms_preview.tscn` actualizado a 22 m de separación entre módulos.

### Hito 10 — Accesibilidad, primera persona y salas nuevas (2026-11-12)

- **Accesibilidad (el bug del "muro invisible")**: las colisiones del hábitat
  eran **cajas de 20 m** que cerraban las puertas. Ahora `scenes/habitat.tscn`
  tiene **una caja por panel de pared** y las puertas se parten en **dos
  tramos** (hueco de 1,6 m).
  - Doors del hábitat: oeste (z = 0), este (z = 0) y norte (x = 0).
  - Puertas nuevas en las salas: cuartos (norte y este), sala de reuniones
    (norte), enfermería (este) y sala del generador (oeste).
- **Nuevo test `tests/station_access_test.gd`**: recorre toda la estación y
  comprueba que el paso de cada puerta está libre y que por detrás hay 8 m de
  espacio abierto. Es la red de seguridad del bug de las puertas.
- **Cámara en primera persona**: `scenes/player.tscn` ya no tiene
  `CameraPivot` ni `SpringArm3D`; la `Camera3D` cuelga de la cabeza (y = 1,6) y
  las mallas del cuerpo y la cabeza se ocultan. El mouse gira el cuerpo (yaw) y
  la cámara (pitch).
- **Salas nuevas** (20 × 20 m) encadenadas al norte de la estación:
  `cuartos → pasillo → sala de reuniones → pasillo → enfermería → pasillo →
  hidroponía` (a 102 m del centro). Al oeste, la **sala del generador** enlaza
  con la **nueva sala de oxígeno** (`scenes/rooms/room_oxigeno.tscn`), que
  contiene el panel de control de oxígeno.
  - Criterio: dos salas de 20 m **no pueden solaparse**, así que se encadenan
    en línea con pasillos intermedios.
- **Paneles de consola reubicados**:
  - Oxígeno → en la sala de oxígeno (`room_oxigeno.tscn`).
  - Escudo radioactivo → **dentro del generador**, invisible pero
    interactuable (`ResourceConsole.panel_visible = false` oculta el modelo, la
    etiqueta y el cuerpo sólido).
- **Sistema "Estructura" → "Escudo radioactivo"**: `RESOURCE_STRUCTURE` pasa a
  `RESOURCE_SHIELD` (&"shield"), con `max_shield` y `shield_decay_rate` en
  `MissionConfig`, y la etiqueta del HUD y de la consola.
- La suite queda en **8 pruebas**: `functional`, `interaction`, `simulation`,
  `asset_collision`, `physics`, `minigame`, `room_collision` y
  `station_access` (todas en verde).

### Hito 11 — Cielo espacial, regolita lunar/marciana y HUD infantil (2026-11-13)

- **Cielo realista y sobrio** (`resources/sky_space_material.tres`):
  `PanoramaSkyMaterial` con panorámica equirectangular 2:1 de 2048×1024. Sustituye
  al `ProceduralSkyMaterial` anterior. La imagen se generó con IA (API de Layer,
  `flux-3-image`) y se procesó con `tools/process_ai_textures.py`.
  - Sin costura horizontal: mitad izquierda = imagen, mitad derecha = su reflejo.
  - Variación de brillo periódica (una sola onda por vuelta) para disimular la
    simetría del reflejo y desvanecido en los polos (las estrellas no se estiran
    en el cenit/nadir).
- **Regolita lunar** en el cubo base (`resources/station_platform_material.tres`):
  albedo + normal, `uv1_scale = 12` (una baldosa cada 5 m en un cubo de 60 m).
- **Regolita marciana** en todos los suelos interiores
  (`resources/mars_ground_material.tres` + `scripts/regolith_floor.gd`):
  - El pack modela el suelo como baldosas sueltas; en vez de tocar 257 nodos, el
    script del nodo `StationInterior` recorre los contenedores `Floor` /
    `FloorTiles` (incluidas las salas instanciadas) y asigna `material_override`.
  - Material **triplanar en espacio de mundo** (`uv1_triplanar`), así la textura
    es continua entre baldosas, salas y pasillos.
  - Un `@export var enabled` lo revierte al suelo original del pack.
- **Cristal de las ventanas** (`resources/window_glass_material.tres` +
  `scripts/window_glass.gd` en el nodo `Walls`): el `Wall_Glass_Clear.glb` del
  pack trae el cristal tintado (alfa 0.45) y en Compatibility no hay transmisión,
  así que se veía como un panel azul opaco. El script sustituye **solo** la
  superficie cuyo material se llama "... Glass" (el marco se respeta) por un
  material `transparency = ALPHA` + `shading_mode = UNSHADED` con alfa 0.10: deja
  ver el espacio y no se "enciende" con las lámparas del techo.
- **HUD "para niños" (7-12 años)**: `scenes/hud.tscn` reconstruido con tarjetas
  redondeadas, un color por recurso (oxígeno azul, energía amarilla, agua verde
  azulada, escudo violeta), etiquetas de 19 px, cuenta atrás de 46 px, avisos en
  "píldora" y panel de resultado con "Pulsa R para volver a jugar".
  `scripts/mission_hud.gd` muestra **tiempo restante** (no transcurrido) y lo
  colorea en ámbar a 30 s y rojo a 10 s; la etiqueta de estado cambia de color
  según `MissionState`. Los 15 nombres únicos (`%`) se mantienen.
- **Ajuste de luz**: el ambiente pasó de `ambient_light_source = SKY` (negro) a
  color `(0.42, 0.52, 0.78)` con energía `0.5`, `tonemap_exposure = 0.95`, sol
  `1.05`, relleno `0.3` y lámparas interiores `1.15`: las paredes ya no salen
  lavadas ni negras.
- **Bug corregido en `scenes/station_platform.tscn`**: los 4 paneles solares
  declaraban `parent="SolarArray"` (ruta relativa a la raíz) en vez de
  `parent="Exterior/SolarArray"`; Godot los descartaba con
  `WARNING: Parent path './SolarArray' ... has vanished`. Ya aparecen.
- **Texturas fuera de 4K/Full HD**: cielo 2048×1024 y suelos 1024² (normales
  512²), en **WebP** (q95 cielo, q90/q92 suelos; 1,69 MB en total). El JPEG
  producía bloques de 8×8 px visibles al ampliar el cielo en pantalla.
  - Los `.import` llevan `compress/mode = 0`, `detect_3d/compress_to = 0` y
    `mipmaps/generate = true`: Godot no las recomprime a VRAM al usarlas en 3D.
- Suite de 8 pruebas + `--headless --import` en verde tras los cambios.

### Hito 12 — Suelo sin regolita y plataforma a la medida del hábitat (2026-11-13)

- **Bug corregido: todo el suelo del hábitat se veía con regolita ("Marte").**
  El nodo `StationInterior` de `scenes/habitat_decor.tscn` tenía
  `floor_material = moon_ground_material.tres`, así que `RegolithFloor`
  sobrescribía **257 mallas** con la textura triplanar, incluidas las franjas de
  peligro `Hazard_Floor_1` (de ahí los manchones blancos: las rayas amarillas y
  negras se perdían). Ahora:
  - `StationInterior` lleva `enabled = false` y ya no tiene `floor_material`; se
    eliminó el `ext_resource` de `moon_ground_material.tres`.
  - El suelo muestra el **material original del pack Molten Maps**
    (`Floor_Tile_Metal` y las baldosas propias de cada sala), franjas de peligro
    incluidas.
  - `scripts/regolith_floor.gd`, `resources/moon_ground_material.tres` y
    `resources/mars_ground_material.tres` se conservan **reservados** y
    documentados para un futuro nivel lunar/marciano: no se cargan en el juego.
- **`resources/station_platform_material.tres` ya no usa textura**: pasó de
  regolita lunar (albedo + normal, `uv1_scale = 12`) a material sólido
  (`resource_name = "StationPlatformMetal"`, `albedo_color` gris
  `(0.42, 0.44, 0.48)`, `metallic = 0.15`, `roughness = 0.92`). **Ninguna
  textura de regolita se carga en el juego**, ni lunar ni marciana.
- **`scenes/station_platform.tscn` redimensionado**: de un cubo de 60 m a un
  `BoxMesh` de **84 × 60 × 160 m** centrado en `(0, -30.15, 37)`. La cara
  superior sigue en `y = -0.15` (las baldosas ocupan `y = -0.14 .. 0.01`, sin
  z-fighting) y la huella `x -42..42 · z -43..117` cubre con ~4 m de margen el
  AABB real del interior (`x -37,95..37,44 · z -37,62..111,8`), que incluye la
  hilera de salas del norte hasta hidroponía.
- **Decorado exterior recolocado** (medido con intersecciones de AABB): antes
  había piezas enterradas dentro de salas, porque el complejo creció hacia el
  norte en los hitos 7-10. Nuevo reparto, solo en zonas libres:
  - Balcón `ViewDeck` al borde **sur** (`z = -40,5`, barandillas a `-42,9`);
    antes estaba delante del ventanal norte, que hoy ocupa `room_quarters`.
  - `SideModules` en el ala oeste `(-33 / -27,5, -0.15, 40)`.
  - Patio de carga al sur: `CargoDepot_A (-12,-34)`, `CargoDepot_B (-4,-36)`,
    `CargoStack_0..3 (5/9, -34/-30)`, `SpaceTruck (13,-25)`.
  - Planta solar al suroeste (`x = -38`, `z = -40/-37,3/-34,6/-31,9`).
  - `Outpost` en el oeste-norte `(-24, -0.15, 60)`.
  - Plataforma de aterrizaje, lander y farolas sin cambios al este (`z = 15/19`).
  - Zonas libres documentadas en la cabecera de `station_platform.tscn`.
- **Verificación**: script de diagnóstico (ya eliminado) confirmó
  `TEXTURAS REGOLITA EN USO: 0` y `SOLAPES DECORADO/SALAS: 0`; capturas
  interiores (baldosas metálicas del pack + franjas de peligro) y vistas cenital
  y oblicua con todas las salas sobre la plataforma.
- **Tests**: se corrigió la cabecera de `tests/asset_collision_test.gd` (hablaba
  del "cubo de 60 m"). Suite de 9 pruebas + `--headless --import` en verde.
- **Ruido conocido (no es regresión)**: en `--headless` el renderizador dummy
  emite `ERROR: Parameter "material" is null.`
  (`material_storage.cpp:264`). Se reprodujo con escenas aisladas y con el menú
  solo (sin emitirlo), y no afecta a ninguna prueba: es del renderizador dummy,
  no del proyecto.

### Hito 13 — Menú principal (2026-11-14)

- **La escena de arranque pasó a ser el menú**: `project.godot` tiene
  `run/main_scene="res://scenes/main_menu.tscn"`. El menú (`scripts/main_menu.gd`,
  `scenes/main_menu.tscn`) tiene dos pantallas en el mismo archivo: inicio
  (`%MainPanel`, botón `%StartButton`) y selector de destino (`%LevelPanel`,
  `%MoonButton`, `%MarsButton`, `%BackButton`). Solo el nivel Luna está activo
  (`LEVEL_MOON = "res://scenes/main.tscn"`); Marte se ve pero está desactivado
  (`LEVEL_MARS = ""`).
- **Test**: `tests/menu_test.gd` comprueba que la escena de arranque es el menú,
  que el selector abre y cierra y que Marte sigue desactivado.
- El juego (`scenes/main.tscn` + `GameManager`) no cambia: el menú solo cambia
  de escena.

### Hito 14 — Puertas que se abren solas (2026-11-14)

- **Puerta corredera con dos hojas** (`scenes/DoorAnim.tscn`): las hojas se
  deslizan en X con la animación `Open` (0,45 s). El script
  `scripts/animated_door.gd` (`class_name AnimatedDoor`) mide la distancia
  horizontal al jugador (grupo `player`) y **abre a 3,5 m o menos** y **cierra
  al alejarse**.
- **Cierre en reversa**: se usa una sola animación. El cierre es la misma
  animación reproducida al revés (`play(nombre, 0.0, -1.0, false)`), así que no
  hay dos animaciones que sincronizar y una interrupción a mitad no produce
  saltos. Detalle de Godot 4.7: hay que **pasar la velocidad en la llamada a
  `play()`**; si se deja el valor por defecto, una animación ya terminada no
  vuelve a reproducirse (verificado con un script de sonda).
- **Sin colisión**: la puerta no tiene `CollisionShape3D`. Se abre antes de que
  llegue el jugador, así que nunca le cierra el paso y el test de accesibilidad
  (`station_access_test`) sigue viendo el hueco libre.
- **Colocación**: 26 puertas en las 17 habitaciones de `scenes/rooms/` (26 huecos
  reales) y 3 en el módulo central (`scenes/habitat_decor.tscn`: norte, oeste y
  este). Todas bajo el nodo `Walls` de su sala, centradas en el hueco del panel
  `Wall_With_Door_Grey` (hueco real: **1,39 m de ancho × 2,06 m de alto**,
  medido sobre el `.glb` del pack). Transform de instancia: escala
  `(1.6, 2.0, 1.0)` y `y = 1.0` (la hoja apoya en el suelo y llega al dintel).
- **Nombre de las mallas de la puerta**: `Wall With Door Grey_A` / `_B`. El test
  de colisiones agrupa las mallas por el nombre del nodo de malla, así que con
  ese nombre la puerta cae en el mismo grupo que el panel del pack y su solape
  (intencionado: la puerta va dentro del hueco) no se reporta como error.
- **Verificación**: script temporal (ya eliminado) comprobó en las 18 escenas que
  las 46 puertas están centradas en su panel y apoyan en el suelo, y que en el
  hábitat las 20 puertas montadas abren y cierran con el jugador cerca/lejos.
  Suite de 9 pruebas en verde.

### Hito 15 — Taller del Rover, puertas a medida y carnet con foto (2026-11-14, rama `feat/rover-puertas-carnet`)

- **Taller del Rover** (`scenes/rover_workshop.tscn`, `scripts/rover_workshop.gd`):
  ensamblaje del Perseverance (modelo oficial NASA 3D Resources dividido en 16
  piezas, `ai_assets/models/perseverance/`). Modos guiado y evaluación; la
  evaluación con 2+ estrellas sube el carnet a nivel 2. Datos de cada pieza
  (material, importancia, instrumentos, fuentes) en `piezas_perseverance.json`
  → `resources/rover_perseverance.tres`. Las 6 ruedas también sueltas en `ruedas/`.
- **Puertas corredizas** `SlidingDoor` (`scenes/doors/auto_door.tscn` y
  `restricted_door.tscn`, distintas de `DoorAnim`): `@tool`, tamaño ajustable en
  el Inspector (ancho/alto/grosor, apertura arriba o de lado). La restringida pide
  carnet de nivel 2 en el lector (tecla E). Script de Blender a medida en
  `tools/blender/`.
- **Carnet** (`AstronautCard`, `scenes/card_editor.tscn`): avatar o foto real
  (cabina con cámara `CameraServer`, cuenta 3-2-1, casco opcional, o subir foto).
  Foto solo en `user://carnet_foto.png`.
- Pruebas: `doors_test`, `rover_workshop_test`.

### Hito 16 — Menú "Nasa Space 2", Biblioteca y Simulación de despegue (2026-11-14)

- **Menú nuevo** con los sprites del paquete "Nasa Space 2"
  (`ai_assets/ui/menu/`, posiciones en `resources/menu_posiciones_1280x720.json`):
  JUGAR (abre el panel "Menú de juego"), BIBLIOTECA, SALIR y "Mi carnet".
  Panel: Base lunar (`main.tscn`), Armado del rover (taller), Simulación de
  despegue y Exploración lunar (desactivada, "Próximamente": `LEVEL_EXPLORATION = ""`).
  Todo dentro de `%Screen` (1280 × 720 centrado). Botones = `TextureButton` con
  variantes hover/pressed/disabled generadas a partir del PNG.
- **Biblioteca** (`scenes/biblioteca.tscn`, `scripts/library.gd`, `class_name Library`):
  9 libros (Básico / Intermedio / Avanzado) desde `resources/biblioteca/catalogo.json`,
  creados a partir de `%BookTemplate` en las posiciones de la maqueta. Lector de
  libro abierto: 3 dobles páginas (portada | pág. 1, pág. 2 | pág. 3, fuentes | fin),
  Anterior/Siguiente, flechas del teclado y Escape. Al terminar algunos libros
  ofrecen "Practicar" (rover → taller, despegue → simulación).
- **Simulación de despegue del Apolo 8** (`scenes/simulacion_despegue.tscn`,
  `scripts/launch_simulation.gd`, `class_name LaunchSimulation`): cabina con 4
  vistas (Q/E o flechas), ventanas transparentes (`ai_assets/apolo8/cabina_*.png`)
  con el cielo de `resources/shaders/cielo_despegue.gdshader` detrás (tapadas
  hasta soltar la torre de escape; azul → negro → estrellas → borde de la Tierra).
  Saturno V por piezas (`ai_assets/apolo8/etapas/`) que se sueltan. Altura,
  velocidad y horas de cada maniobra reales de la tabla de ascenso NASA SP-4029
  (`resources/apolo8/ascenso.json`). El reloj espera la orden del jugador en cada
  maniobra; si tarda más de `late_limit_real` la "computadora" la hace (error).
  Estrellas por errores. `step(delta)` permite probar sin tiempo real.
- Pruebas nuevas: `library_test`, `launch_simulation_test`; `menu_test` reescrito.

### Hito 17 — Simulación de despegue en 3D y paquete "Nasa Space 2" completo (2026-11-14)

- **Despegue 3D** (`scenes/simulacion_despegue_3d.tscn`, `scripts/launch_simulation_3d.gd`,
  `class_name LaunchSimulation3D extends LaunchSimulation`): reutiliza toda la lógica
  y la interfaz de la versión 2D (reloj, maniobras, errores, estrellas, telemetría
  real) mediante ganchos (`_update_visuals`, `_on_stage_dropped`, `_on_reset`,
  `_on_stage_jolt`, `_set_view`). El menú abre esta versión; la 2D sigue en
  `MainMenu.LAUNCH_SCENE_2D`.
- **Mundo 3D**: el cohete queda en el origen y el mundo se mueve. `%EarthPivot`
  baja `R + 7,6 m + altura real` y gira `alcance/R` (alcance real de SP-4029).
  Cohete vertical hasta 12 s y luego inclinado según `inclinacion_deg` (aproximada).
  Saturno V oficial (NASA 3D Resources) en 6 piezas a escala real
  (`ai_assets/models/saturno_v/`); al soltarse cada pieza se `reparent` a `%World`
  y cae. Fuego (`fuego_motor.gdshader`, conos aditivos) solo en la etapa que empuja;
  la S-IC se enciende a T−6,6 s. Humo `CPUParticles3D` con `local_coords`.
- **Cámaras**: exterior (`%ExteriorPivot`, arrastrar con el ratón, rueda = zoom) y
  cabina (`%CockpitCamera`, tecla C). **Importante (renderer gl_compatibility):**
  con `far` = 20 000 km no se dibuja nada; se usa `far = 4 000 000` y `near = 0.5`.
- **Cabina 3D**: 4 `QuadMesh` con `panel_cabina.gdshader` y las fotos del paquete;
  el vidrio transparente deja ver el mundo 3D; `covered` tapa las ventanas hasta
  soltar la torre de escape.
- **Paquete completo**: originales en `ai_assets/nasa_space_2/` y guía archivo por
  archivo en `docs/GUIA_NASA_SPACE_2.md`. Textos de los libros en
  `resources/biblioteca/libros/*.md`.
- Prueba nueva: `launch_simulation_3d_test`.

## 3. ¿Cómo se hizo?


### Arquitectura

```
scenes/main.tscn  (Node3D + mission_controller.gd)
├── Habitat       → instancia de scenes/habitat.tscn
│   ├── WorldEnvironment + SunLight + FillLight
│   ├── Floor / WallBack / WallFront / WallLeft / WallRight  (StaticBody3D + CollisionShape3D)
│   ├── StationPlatform → scenes/station_platform.tscn (bloque de 84 × 160 m + pasarela + exterior KayKit)
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

### Materiales aplicados por script (cristal y regolita reservada)

Cambiar a mano cientos de `material_override` en el `.tscn` es frágil, así que
dos scripts de un solo propósito hacen el trabajo al arrancar:

| Script | Nodo | Qué hace |
|--------|------|----------|
| `scripts/regolith_floor.gd` (`RegolithFloor`) | `StationInterior` de `habitat_decor.tscn` | **Desactivado** (`enabled = false` desde el Hito 12): no toca el suelo. Si se activa, recorre `Floor`/`FloorTiles` y pone la regolita de `floor_material` (triplanar de mundo) |
| `scripts/window_glass.gd` (`WindowGlass`) | `Walls` de `habitat_decor.tscn` | Sustituye solo las superficies de material "... Glass" por cristal transparente |

Ambos siguen el mismo patrón: `@export var enabled` para volver al estado
original del pack, `@export var <material>` para cambiar el material sin tocar
código, un contador `get_applied_*_count()` para las pruebas y un `print` único en
`_ready()` para verificar en el log.

### 4. ¿Qué hay que hacer?

### Pendiente inmediato (siguiente hito)

0. **Exploración lunar**: crear su escena y asignarla en `MainMenu.LEVEL_EXPLORATION`
   (el botón se activa solo). **Probar la cámara del carnet** en el equipo de la
   demo (Windows); si no hay cámara, queda "Subir una foto".

1. ~~**Textura del cubo de la estación**~~ → **resuelto en el Hito 12**: el
   bloque base usa un material sólido sin texturas
   (`resources/station_platform_material.tres`) y la regolita quedó reservada
   para el futuro nivel marciano. Si se quiere detalle en la plataforma, crear un
   `.tres` nuevo (nada de regolitas en el nivel lunar actual).
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
13. **Dos huecos de puerta de `room_quarters` sin paso real**: los paneles
    `Wall_South_5` (ala este) y `Wall_South_6` (ala oeste) son huecos de puerta
    visual, pero su pared sigue siendo maciza en `Collision` (no están partidos
    en dos tramos). Ahora tienen puerta animada (Hito 14), pero el paso sigue
    cerrado: hay que partir su colisión como en el resto de salas si van a
    conectar con otra habitación.

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
17. **`tests/room_collision_test.gd` no está comprobando nada**: usa
    `mesh_instance.visible_in_tree`, que es una propiedad de `CanvasItem`
    (2D). En `MeshInstance3D` (3D) lanza `SCRIPT ERROR: Invalid access to
    property or key 'visible_in_tree'` y la malla nunca llega a la lista, así
    que el test sale en verde sin detectar ningún solape. En 3D la propiedad
    equivalente es `visible`. Hay que corregirlo y volver a pasar el test: puede
    destapar solapes reales en las habitaciones.

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

### Pipeline de texturas IA (`tools/process_ai_textures.py`)

1. Generar las imágenes crudas con la API de Layer (`LAYER_API_KEY`) en una
   carpeta temporal; **nunca** dentro del proyecto sin procesar.
2. `python tools/process_ai_textures.py --raw <carpeta> --out ai_assets/textures`
   - recorta 8 px del borde (artefactos del generador),
   - hace los suelos repetibles con **fundido cruzado circular**
     (`O = A·I + (1−A)·desplazada(I)`, banda del 20 %); el mosaico especular
     también cierra sin costura pero deja cráteres en rombo,
   - deriva las normales con Sobel circular (convención OpenGL, +Y arriba),
   - guarda en **WebP** (cielo q95, albedo q90, normales q92).
3. Tras el primer `--headless --import`, comprobar que cada `.webp.import` tenga
   `compress/mode = 0`, `detect_3d/compress_to = 0` y `mipmaps/generate = true`.
   Si `detect_3d` vale 1, Godot recomprime la textura a VRAM al usarla en 3D y
   aparecen bloques.
4. Los recursos (`resources/*.tres`) referencian `res://ai_assets/textures/...`.

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

### Hito 18 — Escala uniforme de puertas AutoDoor (2026-11-14)

- Todas las puertas `AutoDoor` en las 17 habitaciones de `scenes/rooms/` han sido escaladas a **X: 1.145, Y: 1.369, Z: 1.0**, coincidiendo con la escala de referencia de `IMG_sala_del_generador.tscn`.
- Se modificaron **20 puertas** en 16 escenas (`IMG_sala_de_mando`, `IMG_cuartos`, `IMG_criotanque`, `IMG_enfermeria`, `IMG_sala_del_orrery`, `room_cafeteria`, `room_briefing`, `IMG_vestibulo`, `room_storage`, `IMG_sala_de_reuniones`, `room_hydroponics`, `room_medbay`, `room_generator`, `room_oxigeno`, `room_control`, `room_quarters`).
- Las 4 puertas con rotación (puertas en paredes este/oeste/norte: `room_briefing` Door_West_2, `IMG_vestibulo` Door_East_2, `room_medbay` Door_East_2, `room_quarters` Door_South_5 y Door_South_6) mantuvieron su rotación aplicando la escala sobre la matriz de rotación existente.
- No se modificó ningún otro nodo ni propiedad.

---
*Actualizado: 2026-11-14 — Hito 18 (escala uniforme de puertas AutoDoor) completado.*
