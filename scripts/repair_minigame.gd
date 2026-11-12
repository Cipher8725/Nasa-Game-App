class_name RepairMinigame
extends Control

## Base común de los minijuegos de reparación.
##
## Un minijuego se abre sobre la consola de un recurso, dispone de un tiempo
## limitado y avisa al `RepairMinigameManager` cuando termina (éxito o
## fracaso). Las subclases implementan la mecánica concreta en
## `_update_visuals()` y `_handle_action_input()`.

## Emitida al terminar el minijuego. `success` indica si se completó la reparación.
signal finished(success: bool)

## Recurso que repara este minijuego.
@export var resource_type: StringName = &""
## Nombre legible del recurso, para los títulos de la interfaz.
@export var display_name: String = ""
## Segundos disponibles para completar el minijuego.
@export var time_limit: float = 20.0
## Segundos que se muestra el resultado antes de cerrar el minijuego.
@export var result_display_time: float = 1.5

var _time_left: float = 20.0
var _progress: float = 0.0
var _running: bool = false
var _finished: bool = false

@onready var _timer_bar: ProgressBar = %TimerBar
@onready var _timer_label: Label = %TimerLabel
@onready var _progress_bar: ProgressBar = %ProgressBar
@onready var _progress_label: Label = %ProgressLabel
@onready var _status_label: Label = %StatusLabel
@onready var _result_panel: Control = %ResultPanel
@onready var _result_title: Label = %ResultTitle
@onready var _result_detail: Label = %ResultDetail

func _ready() -> void:
	_time_left = time_limit
	_result_panel.visible = false
	_refresh_hud()

## Arranca el minijuego. Lo invoca el gestor al abrirlo sobre la consola.
func begin() -> void:
	_running = true
	_finished = false
	_progress = 0.0
	_time_left = time_limit
	visible = true
	_setup()
	_refresh_hud()

func _process(delta: float) -> void:
	if not _running:
		return
	_time_left = maxf(0.0, _time_left - delta)
	if _time_left <= 0.0:
		_fail("Se agotó el tiempo de reparación.")
		return
	_update_visuals(delta)
	_refresh_hud()

func _input(event: InputEvent) -> void:
	if not _running:
		return
	# Escape cancela la reparación en curso.
	if event.is_action_pressed("ui_cancel"):
		_fail("Reparación cancelada por el jugador.")
		get_viewport().set_input_as_handled()
		return
	_handle_action_input(event)

# --- API pública ---

## Progreso de la reparación, de 0.0 a 1.0.
func get_progress() -> float:
	return _progress

## Fija el progreso de la reparación (se mantiene entre 0.0 y 1.0).
func set_progress(value: float) -> void:
	_progress = clampf(value, 0.0, 1.0)

## Tiempo restante, en segundos.
func get_time_left() -> float:
	return _time_left

## Añade tiempo al contador (nunca por encima del límite).
func add_time(seconds: float) -> void:
	_time_left = minf(_time_left + seconds, time_limit)

## Quita tiempo del contador (nunca por debajo de cero).
func remove_time(seconds: float) -> void:
	_time_left = maxf(0.0, _time_left - seconds)

## ¿El minijuego sigue en curso?
func is_running() -> bool:
	return _running

## ¿El minijuego ya terminó?
func is_finished() -> bool:
	return _finished

# --- Puntos de extensión ---

## Preparación específica del minijuego (títulos, objetivos, aleatoriedad).
func _setup() -> void:
	pass

## Lógica visual y de juego que se ejecuta cada fotograma.
func _update_visuals(_delta: float) -> void:
	pass

## Teclas propias del minijuego (la base ya gestiona Escape).
func _handle_action_input(_event: InputEvent) -> void:
	pass

# --- Métodos privados ---

## Muestra un mensaje de estado en la interfaz del minijuego.
func _set_status(message: String) -> void:
	_status_label.text = message

## Refresca barras y etiquetas de la interfaz.
func _refresh_hud() -> void:
	_timer_bar.max_value = time_limit
	_timer_bar.value = _time_left
	_timer_label.text = "%.1f s" % _time_left
	_progress_bar.max_value = 1.0
	_progress_bar.value = _progress
	_progress_label.text = "%d%%" % roundi(_progress * 100.0)

## Termina el minijuego con éxito.
func _succeed(message: String) -> void:
	if _finished:
		return
	_finished = true
	_running = false
	_progress = 1.0
	_show_result(true, message)
	_refresh_hud()
	await get_tree().create_timer(result_display_time).timeout
	finished.emit(true)

## Termina el minijuego con fracaso.
func _fail(message: String) -> void:
	if _finished:
		return
	_finished = true
	_running = false
	_show_result(false, message)
	_refresh_hud()
	await get_tree().create_timer(result_display_time).timeout
	finished.emit(false)

## Muestra el panel de resultado.
func _show_result(success: bool, message: String) -> void:
	_result_panel.visible = true
	if success:
		_result_title.text = "REPARACIÓN COMPLETADA"
		_result_title.modulate = Color(0.45, 0.95, 0.55)
	else:
		_result_title.text = "REPARACIÓN FALLIDA"
		_result_title.modulate = Color(0.95, 0.45, 0.4)
	_result_detail.text = message
