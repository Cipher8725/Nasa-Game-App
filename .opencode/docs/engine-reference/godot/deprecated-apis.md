# Godot — Deprecated APIs

Last verified: 2026-11-10 (contra Godot **4.7.2**, binario local)

If an agent suggests any API in the "Deprecated" column, it MUST be replaced
with the "Use Instead" column.

## Nodes & Classes

| Deprecated | Use Instead | Since | Notes |
|------------|-------------|-------|-------|
| `TileMap` | `TileMapLayer` | 4.3 | One node per layer instead of multi-layer node |
| `VisibilityNotifier2D` | `VisibleOnScreenNotifier2D` | 4.0 | Renamed for clarity |
| `VisibilityNotifier3D` | `VisibleOnScreenNotifier3D` | 4.0 | Renamed for clarity |
| `YSort` | `Node2D.y_sort_enabled` | 4.0 | Property on Node2D, not a separate node |
| `Navigation2D` / `Navigation3D` | `NavigationServer2D` / `NavigationServer3D` | 4.0 | Server-based API |
| `EditorSceneFormatImporterFBX` | `EditorSceneFormatImporterFBX2GLTF` | 4.3 | Renamed |

## Methods & Properties

| Deprecated | Use Instead | Since | Notes |
|------------|-------------|-------|-------|
| `yield()` | `await signal` | 4.0 | GDScript 2.0 coroutine syntax |
| `connect("signal", obj, "method")` | `signal.connect(callable)` | 4.0 | Callable-based connections |
| `instance()` | `instantiate()` | 4.0 | Renamed |
| `PackedScene.instance()` | `PackedScene.instantiate()` | 4.0 | Renamed |
| `get_world()` | `get_world_3d()` | 4.0 | Explicit 2D/3D split |
| `OS.get_ticks_msec()` | `Time.get_ticks_msec()` | 4.0 | Time singleton preferred |
| **`OS.get_unix_time()`** | **`Time.get_unix_time_from_system()`** | **4.7** | **VERIFICADO en 4.7.2: `OS.get_unix_time()` ya NO existe. `ClassDB.class_has_method("OS", "get_unix_time", true)` → `false`. Usar siempre `Time.get_unix_time_from_system()`.** |
| `duplicate()` for nested resources | `duplicate_deep()` | 4.5 | Explicit deep copy control |
| `Skeleton3D` signal `bone_pose_updated` | `skeleton_updated` | 4.3 | Renamed |
| `AnimationPlayer.method_call_mode` | `AnimationMixer.callback_mode_method` | 4.3 | Moved to base class |
| `AnimationPlayer.playback_active` | `AnimationMixer.active` | 4.3 | Moved to base class |

### Métodos de `Time` disponibles en 4.7.2 (verificados)

```
Time.get_unix_time_from_system()            # Sustituye a OS.get_unix_time()
Time.get_datetime_dict_from_system()
Time.get_datetime_string_from_system()
Time.get_time_dict_from_system()
Time.get_time_string_from_system()
Time.get_time_zone_from_system()
Time.get_unix_time_from_datetime_dict()
Time.get_unix_time_from_datetime_string()
Time.get_datetime_dict_from_unix_time()
Time.get_date_dict_from_unix_time()
Time.get_time_dict_from_unix_time()
Time.get_datetime_string_from_unix_time()
Time.get_date_string_from_unix_time()
Time.get_time_string_from_unix_time()
```

### Nota sobre `OS` en 4.7.2

`OS` ya **no** expone ningún método de tiempo (`OS.get_unix_time()`,
`OS.get_unix_time_from_system()` y `OS.get_ticks_msec()` no existen o fueron
trasladados). Todo lo relativo a tiempo y zona horaria pasa por el singleton
`Time`. Para `OS.get_ticks_msec()` el sustituto vigente es `Time.get_ticks_msec()`.

## Patterns (Not Just APIs)

| Deprecated Pattern | Use Instead | Why |
|--------------------|-------------|-----|
| String-based `connect()` | Typed signal connections | Type-safe, refactor-friendly |
| `$NodePath` in `_process()` | `@onready var` cached reference | Performance: path lookup every frame |
| Untyped `Array` / `Dictionary` | `Array[Type]`, typed variables | GDScript compiler optimizations |
| `Texture2D` in shader parameters | `Texture` base type | Changed in 4.4 |
| Manual post-process viewport chains | `Compositor` + `CompositorEffect` | Structured post-processing (4.3+) |
| GodotPhysics3D for new projects | Jolt Physics 3D | Default since 4.6; better stability |

## Threading Patterns

| Pattern | Guidance |
|---------|----------|
| Scene tree modification from Thread | Use `call_deferred()` |
| Direct `add_child()` from Thread | ❌ Unsafe - crashes |
| `queue_free()` in physics callback | ✅ Safe - internally deferred |
| Signal emission from Thread | Use `call_deferred("emit_signal", ...)` |
| `await` in Thread | ✅ Safe - handles thread switching |
| Direct node property access from Thread | ⚠️ Caution - use `call_deferred` for scene tree ops |

## Godot 4.7 — Restricciones verificadas en la práctica

1. **Autoloads y el modo `--script`**: al ejecutar el motor con `--script` (el modo
   que usan las herramientas MCP como `godot_operations.gd`), los identificadores
   globales de Autoload **NO se registran**. Un script que use `Game.algo()` falla
   con `Compile Error: Identifier not found: Game`. Solución adoptada en este
   proyecto: publicar `static var instance` en la clase del Autoload y acceder
   mediante `GameManager.get_instance()`, que además busca el nodo en el árbol
   como respaldo.

2. **`ClassDB.class_has_method("Clase", "metodo", true)`** es la forma fiable de
   verificar si una API existe en la versión concreta del motor, en lugar de
   confiar en la documentación o en el conocimiento previo del modelo.
