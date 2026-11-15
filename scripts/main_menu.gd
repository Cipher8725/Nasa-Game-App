class_name MainMenu
extends Control

## Menú principal del juego (primera escena al ejecutar).
##
## Diseño "Nasa Space 2": a la izquierda JUGAR, BIBLIOTECA, SALIR y MI CARNET.
## JUGAR abre el panel "Menú de juego" con las cuatro actividades:
##   * Base lunar → la base de la Luna (`scenes/main.tscn`).
##   * Armado del rover → Taller del Rover Perseverance.
##   * Simulación de despegue → lanzamiento del Apolo 8 en un Saturno V.
##   * Exploración lunar → todavía sin escena: se muestra como "Próximamente".
##
## El menú no conoce la lógica de cada actividad: solo cambia de escena.

## Base lunar (la partida principal con GameManager).
const LEVEL_MOON: String = "res://scenes/main.tscn"
## Exploración lunar: vacía mientras no exista su escena.
const LEVEL_EXPLORATION: String = ""
## Taller del Rover: armar y desarmar el rover Perseverance de la NASA.
const WORKSHOP_SCENE: String = "res://scenes/rover_workshop.tscn"
## Pantalla para crear el carnet de astronauta.
const CARD_SCENE: String = "res://scenes/card_editor.tscn"
## Biblioteca de estudio (9 libros en 3 niveles).
const LIBRARY_SCENE: String = "res://scenes/biblioteca.tscn"
## Simulación del despegue del Apolo 8.
const LAUNCH_SCENE: String = "res://scenes/simulacion_despegue_3d.tscn"
## Versión 2D anterior (cabina en fotos), por si la computadora no puede con el 3D.
const LAUNCH_SCENE_2D: String = "res://scenes/simulacion_despegue.tscn"

@onready var _level_panel: Control = %LevelPanel
@onready var _start_button: TextureButton = %StartButton
@onready var _moon_button: TextureButton = %MoonButton
@onready var _exploration_button: TextureButton = %ExplorationButton
@onready var _exploration_soon: Label = %ExplorationSoon

func _ready() -> void:
	# El menú se maneja con el ratón visible (el jugador lo captura al entrar).
	# En modo headless (pruebas) el servidor de pantalla es un mock: se omite.
	if DisplayServer.get_name() != "headless":
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_exploration_button.disabled = LEVEL_EXPLORATION.is_empty()
	_exploration_soon.visible = _exploration_button.disabled
	_hide_level_panel()

func _unhandled_input(event: InputEvent) -> void:
	# Escape cierra el panel "Menú de juego".
	if event.is_action_pressed("ui_cancel") and _level_panel.visible:
		_hide_level_panel()
		get_viewport().set_input_as_handled()

## ¿Está abierto el panel "Menú de juego"?
func is_level_panel_visible() -> bool:
	return _level_panel.visible

## ¿Se puede jugar ya la Exploración lunar?
func is_exploration_available() -> bool:
	return not _exploration_button.disabled

## Ruta de la base lunar (la usa el test del menú).
func get_moon_level_path() -> String:
	return LEVEL_MOON

# --- Botones ---

## JUGAR abre o cierra el panel de actividades.
func _on_start_pressed() -> void:
	if _level_panel.visible:
		_hide_level_panel()
	else:
		_show_level_panel()

func _on_moon_pressed() -> void:
	_load_level(LEVEL_MOON)

func _on_workshop_pressed() -> void:
	_load_level(WORKSHOP_SCENE)

func _on_launch_pressed() -> void:
	_load_level(LAUNCH_SCENE)

func _on_exploration_pressed() -> void:
	_load_level(LEVEL_EXPLORATION)

func _on_library_pressed() -> void:
	_load_level(LIBRARY_SCENE)

func _on_card_pressed() -> void:
	_load_level(CARD_SCENE)

func _on_quit_pressed() -> void:
	get_tree().quit()

# --- Panel ---

func _show_level_panel() -> void:
	_level_panel.visible = true
	_level_panel.modulate.a = 0.0
	create_tween().tween_property(_level_panel, "modulate:a", 1.0, 0.2)
	_moon_button.grab_focus()

func _hide_level_panel() -> void:
	_level_panel.visible = false
	_start_button.grab_focus()

## Cambia a la escena indicada.
func _load_level(path: String) -> void:
	if path.is_empty():
		return
	var error: Error = get_tree().change_scene_to_file(path)
	if error != OK:
		push_error("MainMenu: no se pudo abrir %s (error %d)" % [path, error])
