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

## 3. ¿Cómo se hizo?

### Arquitectura

```
scenes/main.tscn  (Node3D + mission_controller.gd)
├── Habitat       → instancia de scenes/habitat.tscn
│   ├── Floor / WallBack / WallFront / WallLeft / WallRight  (StaticBody3D + MeshInstance3D + CollisionShape3D)
│   ├── ConsoleOxygen / ConsoleEnergy / ConsoleWater / ConsoleStructure → instancias de scenes/console.tscn
│   ├── WorldEnvironment (Sky + ProceduralSkyMaterial)
│   └── DirectionalLight3D
├── Player        → instancia de scenes/player.tscn (CharacterBody3D)
├── EmergencySystem → instancia de scenes/emergency_system.tscn (Node + Timer)
└── UILayer (CanvasLayer)
    └── HUD       → instancia de scenes/hud.tscn (Control)
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

1. **Audio**: alarmas de recurso crítico, impacto de emergencia y confirmación
   de reparación. Usar `AudioStreamPlayer` definido en las escenas.
2. **Assets finales del jugador**: el astronauta sigue siendo una cápsula
   (`CapsuleMesh`). KayKit no incluye personajes; habría que generarlo con
   Meshy (`MESHY_API_KEY` disponible) o buscar un pack CC0 con astronautas.
3. **Niveles adicionales**: segunda misión con distinta dificultad y más
   consolas, cargando una `MissionConfig` distinta.
4. **Remoto Git**: crear el repositorio en GitHub y añadirlo como `origin`
   (`git remote add origin <url>` + `git push -u origin main`). Pendiente de
   decisión del arquitecto: el repositorio debe ser **privado** mientras
   contengan assets con licencias restrictivas.

### Pendiente secundario

5. **Entrada de guardado/carga en el HUD**: botones `F5` (guardar) y `F9`
   (cargar) con la API `save_game` / `load_game` ya implementada.
6. **Sonido y música ambiental** del hábitat.
7. **Tutorial**: cartel inicial que explique los controles (WASD, ratón, `E`, `R`).
8. **Estadísticas de sesión**: tiempo total y misiones completadas, ya
   disponibles vía `get_missions_completed()`.
9. **Exportación**: crear `export_presets.cfg` para Windows/Linux.

### Deuda técnica conocida

10. `scripts/mission_hud.gd` actualiza cronómetro y puntuación cada fotograma en
    `_process`. Es aceptable, pero puede pasar a 10 Hz igual que los recursos.
11. La skill `godot-console` menciona `--check-only` con `--script`; ese modo no
    registra Autoloads, así que solo sirve para scripts sin dependencias de
    Autoload (o usando `get_instance()`).
12. Los modelos `.glb` de Molten Maps referencian sus texturas PNG por UID:
    **cada `.glb` debe guardarse junto a su PNG** (mismo nombre base). Si se
    copia solo el `.glb`, Godot avisa y el material queda sin textura.

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
- **Packs de terceros**: solo se versiona lo que el juego usa, en
  `res://ai_assets/`. El resto va a la boveda externa
  (`nasa-asset-vault/`), por licencia y por tamaño.
- **Verificar el clon** tras cambios en la estructura del repo:
  ```powershell
  git clone --no-hardlinks . <destino-temporal>
  # comprobar que llegan las skills, los .uid y los assets (LFS)
  ```

---
*Actualizado: 2026-11-12 — Hito 4 (control de versiones y assets 3D) completado.*
