class_name MissionHud
extends Control

## HUD de la misión.
##
## El HUD es un observador puro: se conecta a las señales del `GameManager`
## y refleja el estado. Nunca modifica el estado del juego (regla de
## `gameplay.md`: la lógica no referencia a la UI, la UI observa la lógica).

@onready var _oxygen_bar: ProgressBar = %OxygenBar
@onready var _energy_bar: ProgressBar = %EnergyBar
@onready var _water_bar: ProgressBar = %WaterBar
@onready var _shield_bar: ProgressBar = %ShieldBar

@onready var _oxygen_value: Label = %OxygenValue
@onready var _energy_value: Label = %EnergyValue
@onready var _water_value: Label = %WaterValue
@onready var _shield_value: Label = %ShieldValue

@onready var _timer_label: Label = %TimerLabel
@onready var _score_label: Label = %ScoreLabel
@onready var _state_label: Label = %StateLabel
@onready var _alert_label: Label = %AlertLabel
@onready var _result_panel: Control = %ResultPanel
@onready var _result_title: Label = %ResultTitle
@onready var _result_detail: Label = %ResultDetail
@onready var _game: GameManager = GameManager.get_instance()

## Etiquetas legibles de cada recurso vital.
const RESOURCE_LABELS: Dictionary = {
	&"oxygen": "OXÍGENO",
	&"energy": "ENERGÍA",
	&"water": "AGUA",
	&"shield": "ESCUDO RADIOACTIVO",
}

## Colores de la cuenta atrás: normal, aviso (quedan 30 s) y peligro (10 s).
const COLOR_TIMER_NORMAL: Color = Color(0.96, 0.98, 1, 1)
const COLOR_TIMER_WARNING: Color = Color(1, 0.82, 0.35, 1)
const COLOR_TIMER_DANGER: Color = Color(1, 0.45, 0.4, 1)

## Color de la etiqueta de estado según la marcha de la misión. Los niños
## reconocen el estado por el color antes de leerlo.
const STATE_COLORS: Dictionary = {
	GameManager.MissionState.BRIEFING: Color(0.62, 0.76, 0.95),
	GameManager.MissionState.ACTIVE: Color(0.5, 0.93, 0.64),
	GameManager.MissionState.CRITICAL: Color(1, 0.66, 0.32),
	GameManager.MissionState.FAILED: Color(1, 0.45, 0.4),
	GameManager.MissionState.COMPLETED: Color(0.5, 0.93, 0.64),
}

var _alert_time_left: float = 0.0

func _ready() -> void:
	# Conexión a las señales del gestor global (observación, no control).
	_game.resource_changed.connect(_on_resource_changed)
	_game.resource_critical.connect(_on_resource_critical)
	_game.resource_depleted.connect(_on_resource_depleted)
	_game.emergency_triggered.connect(_on_emergency_triggered)
	_game.mission_state_changed.connect(_on_mission_state_changed)
	_game.mission_failed.connect(_on_mission_failed)
	_game.mission_completed.connect(_on_mission_completed)

	_result_panel.visible = false
	_alert_label.visible = false
	_update_timer_display()
	_update_score_display()
	_update_state_display(_game.get_mission_state())

func _process(delta: float) -> void:
	# El HUD solo refresca los indicadores de tiempo y puntuación.
	_update_timer_display()
	_update_score_display()

	if _alert_time_left > 0.0:
		_alert_time_left -= delta
		if _alert_time_left <= 0.0:
			_alert_label.visible = false

# --- Métodos privados ---

## Refleja el valor de un recurso en su barra y su etiqueta.
func _update_resource_bar(bar: ProgressBar, value_label: Label, current: float, maximum: float) -> void:
	bar.max_value = maximum
	bar.value = current
	value_label.text = "%d / %d" % [roundi(current), roundi(maximum)]

## Refresca la cuenta atrás de la misión (tiempo restante).
func _update_timer_display() -> void:
	var remaining: float = maxf(0.0, _game.config.mission_duration - _game.get_mission_time())
	_timer_label.text = _format_time(remaining)

	# El color avisa antes que el número: amarillo a 30 s, rojo a 10 s.
	var color: Color = COLOR_TIMER_NORMAL
	if remaining <= 10.0:
		color = COLOR_TIMER_DANGER
	elif remaining <= 30.0:
		color = COLOR_TIMER_WARNING
	_timer_label.add_theme_color_override("font_color", color)

## Refresca la puntuación de la misión.
func _update_score_display() -> void:
	_score_label.text = "PUNTOS: %d" % roundi(_game.get_score())

## Traduce el estado de misión a un texto comprensible y le da color.
func _update_state_display(state: GameManager.MissionState) -> void:
	match state:
		GameManager.MissionState.BRIEFING:
			_state_label.text = "ESTADO: PREPARANDO"
		GameManager.MissionState.ACTIVE:
			_state_label.text = "ESTADO: EN CURSO"
		GameManager.MissionState.CRITICAL:
			_state_label.text = "ESTADO: CRÍTICO"
		GameManager.MissionState.FAILED:
			_state_label.text = "ESTADO: FALLIDO"
		GameManager.MissionState.COMPLETED:
			_state_label.text = "ESTADO: COMPLETADO"
	var color: Color = STATE_COLORS.get(state, COLOR_TIMER_NORMAL)
	_state_label.add_theme_color_override("font_color", color)

## Convierte segundos a formato mm:ss.
func _format_time(seconds: float) -> String:
	var total_seconds: int = roundi(seconds)
	return "%02d:%02d" % [total_seconds / 60, total_seconds % 60]

# --- Callbacks de señal ---

func _on_resource_changed(resource_type: StringName, current_value: float, max_value: float) -> void:
	match resource_type:
		GameManager.RESOURCE_OXYGEN:
			_update_resource_bar(_oxygen_bar, _oxygen_value, current_value, max_value)
		GameManager.RESOURCE_ENERGY:
			_update_resource_bar(_energy_bar, _energy_value, current_value, max_value)
		GameManager.RESOURCE_WATER:
			_update_resource_bar(_water_bar, _water_value, current_value, max_value)
		GameManager.RESOURCE_SHIELD:
			_update_resource_bar(_shield_bar, _shield_value, current_value, max_value)

func _on_resource_critical(resource_type: StringName) -> void:
	var label: String = String(RESOURCE_LABELS.get(resource_type, resource_type))
	_show_alert("¡%s EN NIVEL CRÍTICO!" % label, 3.0)

func _on_resource_depleted(resource_type: StringName) -> void:
	var label: String = String(RESOURCE_LABELS.get(resource_type, resource_type))
	_show_alert("¡%s AGOTADO!" % label, 4.0)

func _on_emergency_triggered(emergency_type: StringName, severity: float) -> void:
	_show_alert("EMERGENCIA: %s" % emergency_type.to_upper(), 3.0)

func _on_mission_state_changed(new_state: GameManager.MissionState) -> void:
	_update_state_display(new_state)

func _on_mission_failed(reason: String) -> void:
	_result_panel.visible = true
	_result_title.text = "MISIÓN FALLIDA"
	_result_detail.text = "%s\n\nPuntuación: %d" % [reason, roundi(_game.get_score())]

func _on_mission_completed(final_score: float) -> void:
	_result_panel.visible = true
	_result_title.text = "MISIÓN COMPLETADA"
	_result_detail.text = "¡Has sobrevivido al hábitat!\n\nPuntuación final: %d" % roundi(final_score)

## Muestra un mensaje de alerta temporal en pantalla.
func _show_alert(message: String, duration: float) -> void:
	_alert_label.text = message
	_alert_label.visible = true
	_alert_time_left = duration

## Muestra un aviso en el HUD. Uso externo (minijuegos de reparación).
func show_alert(message: String, duration: float = 3.0) -> void:
	_show_alert(message, duration)
