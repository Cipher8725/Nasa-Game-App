class_name GameManager
extends Node

## Gestor global de la misión (registrado como Autoload con el nombre "Game").
##
## Responsabilidades:
## - Mantener el estado de los recursos vitales (oxígeno, energía, agua, estructura).
## - Emitir señales para que la UI y el mundo observen el estado (nunca al revés).
## - Controlar la máquina de estados de la misión.
## - Persistir y recuperar partidas guardadas.
##
## Nota de nomenclatura: la clase se llama `GameManager` y el Autoload se registra
## como "Game". Godot prohíbe que un `class_name` coincida con el nombre de un
## Autoload (error "hides an autoload singleton"), de ahí la separación.

# --- Señales de estado de recursos vitales ---

## Emitida cada vez que cambia el valor de un recurso.
signal resource_changed(resource_type: StringName, current_value: float, max_value: float)
## Emitida UNA vez cuando un recurso entra en zona crítica (transición de borde).
signal resource_critical(resource_type: StringName)
## Emitida UNA vez cuando un recurso se agota por completo (transición de borde).
signal resource_depleted(resource_type: StringName)
## Emitida cuando el jugador repara un recurso mediante una consola.
signal resource_restored(resource_type: StringName, amount: float)

# --- Señales de eventos de misión ---

## Emitida cuando ocurre una emergencia ambiental.
signal emergency_triggered(emergency_type: StringName, severity: float)
## Emitida en cada cambio de estado de la misión.
signal mission_state_changed(new_state: MissionState)
## Emitida cuando la misión termina en derrota.
signal mission_failed(reason: String)
## Emitida cuando la misión se completa con éxito.
signal mission_completed(final_score: float)

# --- Constantes ---

## Estados posibles de la misión.
enum MissionState {
	BRIEFING, ## Cuenta atrás inicial, el juego aún no consume recursos.
	ACTIVE, ## Misión en curso: los recursos decaen.
	CRITICAL, ## Misión en curso con al menos un recurso crítico.
	FAILED, ## Derrota: la misión terminó mal.
	COMPLETED, ## Victoria: se sobrevivió el tiempo objetivo.
}

const RESOURCE_OXYGEN: StringName = &"oxygen"
const RESOURCE_ENERGY: StringName = &"energy"
const RESOURCE_WATER: StringName = &"water"
const RESOURCE_STRUCTURE: StringName = &"structure"

const EMERGENCY_METEOR: StringName = &"micrometeorito"
const EMERGENCY_OVERLOAD: StringName = &"sobrecarga_energia"
const EMERGENCY_PRESSURE: StringName = &"caida_presion"
const EMERGENCY_WATER_LEAK: StringName = &"fuga_agua"

const SAVE_PATH_FORMAT: String = "user://nasa_save_%d.json"

## Frecuencia (Hz) con la que se notifican los cambios de recurso a la UI.
const NOTIFICATION_HZ: float = 10.0

# --- Configuración ---

## Configuración data-driven de la misión. Si es nula se carga la de por defecto.
@export var config: MissionConfig

## Referencia estática al Autoload.
##
## Permite acceder al gestor desde cualquier contexto (incluidos los scripts de
## herramientas que se ejecutan con `--script`, donde los identificadores globales
## de Autoload NO están registrados). El Autoload se registra con el nombre "Game"
## porque Godot prohíbe que un `class_name` coincida con el nombre de un Autoload.
static var instance: GameManager = null

# --- Estado público ---

var _state: MissionState = MissionState.BRIEFING
var _levels: Dictionary = {}
var _maxima: Dictionary = {}
var _critical_latched: Dictionary = {}
var _depleted_latched: Dictionary = {}
var _elapsed_mission_time: float = 0.0
var _score: float = 0.0
var _missions_completed: int = 0
var _notification_accumulator: float = 0.0

func _ready() -> void:
	# Se publica la instancia estática para que otros scripts puedan acceder al
	# gestor sin depender del identificador global del Autoload.
	instance = self

	# La configuración debe existir antes de inicializar los recursos.
	if config == null:
		config = load("res://resources/default_mission.tres") as MissionConfig
	if config == null:
		push_error("GameManager: no se encontró la configuración de misión.")
		return
	_reset_resources()

## Devuelve la instancia activa del gestor, o null si todavía no se ha inicializado.
##
## Es una consulta segura: si la variable estática aún no se ha publicado (porque
## el Autoload no ha pasado por su `_ready()`), se busca el nodo del Autoload en
## el árbol de escena.
static func get_instance() -> GameManager:
	if instance != null:
		return instance
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null(^"Game") as GameManager

# --- Bucle principal ---

func _physics_process(delta: float) -> void:
	# El decaimiento usa delta (regla de gameplay.md: nada de lógica dependiente del framerate).
	match _state:
		MissionState.ACTIVE, MissionState.CRITICAL:
			_apply_decay(delta)
			_elapsed_mission_time += delta
			_score += config.score_per_second * delta
			_accumulate_notifications(delta)
			_check_mission_objectives()
		_:
			pass

# --- API pública de misión ---

## Inicia la cuenta atrás y luego la fase activa de la mission.
func start_mission() -> void:
	_reset_resources()
	_elapsed_mission_time = 0.0
	_score = 0.0
	_set_state(MissionState.BRIEFING)
	await get_tree().create_timer(config.briefing_duration).timeout
	if _state != MissionState.BRIEFING:
		return
	_set_state(MissionState.ACTIVE)

## Estado actual de la misión.
func get_mission_state() -> MissionState:
	return _state

## Tiempo transcurrido dentro de la fase activa, en segundos.
func get_mission_time() -> float:
	return _elapsed_mission_time

## Puntuación acumulada de la misión en curso.
func get_score() -> float:
	return _score

## Número de misiones completadas con éxito en esta sesión.
func get_missions_completed() -> int:
	return _missions_completed

## Termina la misión en derrota con el motivo indicado.
func fail_mission(reason: String) -> void:
	if _state == MissionState.FAILED or _state == MissionState.COMPLETED:
		return
	_set_state(MissionState.FAILED)
	mission_failed.emit(reason)

# --- API pública de recursos ---

## Nivel actual de un recurso vital.
func get_resource_level(resource_type: StringName) -> float:
	return float(_levels.get(resource_type, 0.0))

## Capacidad máxima de un recurso vital.
func get_resource_max(resource_type: StringName) -> float:
	return float(_maxima.get(resource_type, 0.0))

## Nivel de un recurso expresado como porcentaje (0.0 - 100.0).
func get_resource_percentage(resource_type: StringName) -> float:
	var maximum: float = get_resource_max(resource_type)
	if maximum <= 0.0:
		return 0.0
	return (get_resource_level(resource_type) / maximum) * 100.0

## Indica si un recurso está actualmente en zona crítica.
func get_resource_state_is_critical(resource_type: StringName) -> bool:
	return bool(_critical_latched.get(resource_type, false))

## Restaura un recurso (reparación de consola). Devuelve la cantidad realmente aplicada.
func restore_resource(resource_type: StringName, amount: float) -> float:
	if amount <= 0.0:
		return 0.0
	var maximum: float = get_resource_max(resource_type)
	var current: float = get_resource_level(resource_type)
	var applied: float = minf(amount, maximum - current)
	if applied <= 0.0:
		return 0.0
	_levels[resource_type] = current + applied
	_evaluate_resource_state(resource_type)
	_emit_resource_changed(resource_type)
	resource_restored.emit(resource_type, applied)
	return applied

## Consume un recurso de forma deliberada (acción del jugador).
func consume_resource(resource_type: StringName, amount: float) -> void:
	if amount <= 0.0:
		return
	_levels[resource_type] = maxf(0.0, get_resource_level(resource_type) - amount)
	_evaluate_resource_state(resource_type)
	_emit_resource_changed(resource_type)

## Aplica el efecto de una emergencia ambiental sobre los recursos.
func trigger_emergency(emergency_type: StringName, severity: float) -> void:
	var clamped_severity: float = clampf(severity, 0.0, 1.0)
	match emergency_type:
		EMERGENCY_METEOR:
			_apply_damage(RESOURCE_STRUCTURE, clamped_severity * 10.0)
		EMERGENCY_OVERLOAD:
			_apply_damage(RESOURCE_ENERGY, clamped_severity * 15.0)
		EMERGENCY_PRESSURE:
			_apply_damage(RESOURCE_OXYGEN, clamped_severity * 20.0)
		EMERGENCY_WATER_LEAK:
			_apply_damage(RESOURCE_WATER, clamped_severity * 12.0)
		_:
			push_warning("GameManager: tipo de emergencia desconocido: %s" % emergency_type)
			return
	emergency_triggered.emit(emergency_type, clamped_severity)

# --- Persistencia ---

## Guarda la partida actual en un espacio numerado. Devuelve true si se escribió.
func save_game(slot: int) -> bool:
	var file: FileAccess = FileAccess.open(SAVE_PATH_FORMAT % slot, FileAccess.WRITE)
	if file == null:
		push_error("GameManager: no se pudo abrir el archivo de guardado (slot %d)." % slot)
		return false
	var data: Dictionary = {
		"version": 1,
		"timestamp": Time.get_unix_time_from_system(),
		"state": _state,
		"elapsed_mission_time": _elapsed_mission_time,
		"score": _score,
		"missions_completed": _missions_completed,
		"resources": _levels.duplicate(),
	}
	file.store_string(JSON.stringify(data))
	file.close()
	return true

## Carga una partida guardada. Devuelve true si se aplicó correctamente.
func load_game(slot: int) -> bool:
	var path: String = SAVE_PATH_FORMAT % slot
	if not FileAccess.file_exists(path):
		return false
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("GameManager: no se pudo leer el archivo de guardado (slot %d)." % slot)
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("GameManager: el archivo de guardado está corrupto (slot %d)." % slot)
		return false
	var data: Dictionary = parsed
	var saved_resources: Dictionary = data.get("resources", {})
	for resource_type: StringName in _levels.keys():
		if saved_resources.has(resource_type):
			_levels[resource_type] = float(saved_resources[resource_type])
	_elapsed_mission_time = float(data.get("elapsed_mission_time", 0.0))
	_score = float(data.get("score", 0.0))
	_missions_completed = int(data.get("missions_completed", 0))
	_set_state(MissionState.ACTIVE)
	for resource_type: StringName in _levels.keys():
		_evaluate_resource_state(resource_type)
		_emit_resource_changed(resource_type)
	return true

## Indica si existe una partida guardada en el espacio indicado.
func has_save_game(slot: int) -> bool:
	return FileAccess.file_exists(SAVE_PATH_FORMAT % slot)

# --- Métodos privados ---

## Reinicia los cuatro recursos a su capacidad máxima.
func _reset_resources() -> void:
	_maxima = {
		RESOURCE_OXYGEN: config.max_oxygen,
		RESOURCE_ENERGY: config.max_energy,
		RESOURCE_WATER: config.max_water,
		RESOURCE_STRUCTURE: config.max_structure,
	}
	_levels = _maxima.duplicate()
	_critical_latched = {}
	_depleted_latched = {}
	_notification_accumulator = 0.0

## Aplica el decaimiento continuo de los cuatro recursos.
func _apply_decay(delta: float) -> void:
	_decay_resource(RESOURCE_OXYGEN, config.oxygen_decay_rate, delta)
	_decay_resource(RESOURCE_ENERGY, config.energy_decay_rate, delta)
	_decay_resource(RESOURCE_WATER, config.water_decay_rate, delta)
	_decay_resource(RESOURCE_STRUCTURE, config.structure_decay_rate, delta)

## Aplica el decaimiento de un recurso concreto.
func _decay_resource(resource_type: StringName, rate: float, delta: float) -> void:
	if rate <= 0.0:
		return
	var maximum: float = get_resource_max(resource_type)
	_levels[resource_type] = clampf(get_resource_level(resource_type) - (rate * delta), 0.0, maximum)

## Acumula tiempo y notifica los cambios a la UI a frecuencia limitada.
func _accumulate_notifications(delta: float) -> void:
	_notification_accumulator += delta
	var interval: float = 1.0 / NOTIFICATION_HZ
	if _notification_accumulator < interval:
		return
	_notification_accumulator = 0.0
	for resource_type: StringName in _levels.keys():
		_evaluate_resource_state(resource_type)
		_emit_resource_changed(resource_type)

## Resta cantidad a un recurso y emite la señal de cambio correspondiente.
func _apply_damage(resource_type: StringName, amount: float) -> void:
	var maximum: float = get_resource_max(resource_type)
	_levels[resource_type] = clampf(get_resource_level(resource_type) - amount, 0.0, maximum)
	_evaluate_resource_state(resource_type)
	_emit_resource_changed(resource_type)

## Emite la señal de cambio de un recurso.
func _emit_resource_changed(resource_type: StringName) -> void:
	resource_changed.emit(resource_type, get_resource_level(resource_type), get_resource_max(resource_type))

## Evalúa las transiciones de borde (crítico / agotado) de un recurso.
func _evaluate_resource_state(resource_type: StringName) -> void:
	var value: float = get_resource_level(resource_type)
	# El umbral crítico es un porcentaje, se traduce a unidades del recurso actual.
	var critical_limit: float = get_resource_max(resource_type) * (config.critical_threshold / 100.0)

	var is_critical: bool = value <= critical_limit and value > 0.0
	if is_critical and not bool(_critical_latched.get(resource_type, false)):
		_critical_latched[resource_type] = true
		resource_critical.emit(resource_type)
		_enter_critical_state()
	elif not is_critical:
		_critical_latched[resource_type] = false
		_exit_critical_state()

	if value <= 0.0:
		if not bool(_depleted_latched.get(resource_type, false)):
			_depleted_latched[resource_type] = true
			resource_depleted.emit(resource_type)
			fail_mission("Recurso agotado: %s" % resource_type)

## Cambia el estado de la misión y notifica a los observadores.
func _set_state(new_state: MissionState) -> void:
	if _state == new_state:
		return
	_state = new_state
	mission_state_changed.emit(new_state)

## Promueve la misión a estado CRITICAL cuando algún recurso entra en zona crítica.
func _enter_critical_state() -> void:
	if _state == MissionState.ACTIVE:
		_set_state(MissionState.CRITICAL)

## Devuelve la misión a estado ACTIVE cuando ningún recurso sigue en zona crítica.
func _exit_critical_state() -> void:
	if _state != MissionState.CRITICAL:
		return
	for resource_type: StringName in _levels.keys():
		if bool(_critical_latched.get(resource_type, false)):
			return
	_set_state(MissionState.ACTIVE)

## Evalúa la victoria por tiempo y la derrota por recursos agotados.
func _check_mission_objectives() -> void:
	if _elapsed_mission_time >= config.mission_duration:
		_complete_mission()

## Calcula la puntuación final y marca la misión como completada.
func _complete_mission() -> void:
	if _state == MissionState.FAILED or _state == MissionState.COMPLETED:
		return
	var remaining: float = 0.0
	for resource_type: StringName in _levels.keys():
		remaining += get_resource_percentage(resource_type) / 100.0
	var final_score: float = _score + (remaining * config.score_per_remaining_resource)
	_score = final_score
	_missions_completed += 1
	_set_state(MissionState.COMPLETED)
	mission_completed.emit(final_score)
