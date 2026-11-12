class_name EmergencySystem
extends Node

## Generador de eventos de emergencia ambiental.
##
## Programa coaliciones aleatorias (micrometeorito, sobrecarga energética,
## caída de presión o fuga de agua) y las aplica sobre el `GameManager`.
## El temporizador es un nodo estructural definido en `scenes/emergency_system.tscn`.

## Tipos de emergencia que el sistema puede generar.
@export var enabled_emergency_types: Array[StringName] = [
	GameManager.EMERGENCY_METEOR,
	GameManager.EMERGENCY_OVERLOAD,
	GameManager.EMERGENCY_PRESSURE,
	GameManager.EMERGENCY_WATER_LEAK,
]

@onready var _timer: Timer = %EmergencyTimer
@onready var _game: GameManager = GameManager.get_instance()

func _ready() -> void:
	_timer.timeout.connect(_on_emergency_timer_timeout)
	_schedule_next_emergency()

## Programa el siguiente evento de emergencia con un intervalo aleatorio.
func _schedule_next_emergency() -> void:
	var config: MissionConfig = _game.config
	var interval: float = randf_range(config.emergency_interval_min, config.emergency_interval_max)
	_timer.wait_time = maxf(interval, 1.0)
	_timer.start()

## Fuerza una emergencia inmediata (usado por eventos scripted o depuración).
func trigger_now(emergency_type: StringName, severity: float) -> void:
	_game.trigger_emergency(emergency_type, severity)

# --- Callbacks de señal ---

func _on_emergency_timer_timeout() -> void:
	# Sin tipos habilitados no hay nada que programar.
	if enabled_emergency_types.is_empty():
		return
	# Las emergencias solo ocurren con la misión en marcha: durante la cuenta
	# atrás o tras el final de la partida el hábitat está en calma.
	var state: GameManager.MissionState = _game.get_mission_state()
	if state != GameManager.MissionState.ACTIVE and state != GameManager.MissionState.CRITICAL:
		return
	var config: MissionConfig = _game.config
	var chosen_type: StringName = enabled_emergency_types[randi() % enabled_emergency_types.size()]
	var severity: float = randf_range(config.emergency_severity_min, config.emergency_severity_max)
	_game.trigger_emergency(chosen_type, severity)
	_schedule_next_emergency()
