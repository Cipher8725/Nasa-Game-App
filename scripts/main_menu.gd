class_name MainMenu
extends Control

## Menú principal del juego (primera escena al ejecutar).
##
## Flujo: pantalla de inicio ("INICIAR MISIÓN" / "SALIR") → selector de destino
## con dos niveles → carga de la escena del nivel elegido.
##
## Hoy solo existe el nivel de la Luna (`scenes/main.tscn`). El de Marte está
## visible pero desactivado para que los niños entiendan que hay más contenido
## en camino; para activarlo basta con apuntar `LEVEL_MARS` a su escena.
##
## El menú no conoce la lógica de la misión: solo cambia de escena. Toda la
## partida sigue viviendo en `main.tscn` + `GameManager`.

## Escena del nivel disponible hoy: la base lunar.
const LEVEL_MOON: String = "res://scenes/main.tscn"
## Escena del nivel de Marte. Vacía mientras no exista el mapa.
const LEVEL_MARS: String = ""

@onready var _main_panel: PanelContainer = %MainPanel
@onready var _level_panel: PanelContainer = %LevelPanel
@onready var _start_button: Button = %StartButton
@onready var _moon_button: Button = %MoonButton
@onready var _mars_button: Button = %MarsButton
@onready var _back_button: Button = %BackButton

func _ready() -> void:
	# El menú se maneja con el ratón visible (el jugador lo captura al entrar).
	# En modo headless (pruebas) el servidor de pantalla es un mock: se omite.
	if DisplayServer.get_name() != "headless":
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Un nivel sin escena asignada no se puede elegir.
	_mars_button.disabled = LEVEL_MARS.is_empty()
	_show_main_panel()

func _unhandled_input(event: InputEvent) -> void:
	# Escape vuelve del selector de destino al menú de inicio.
	if event.is_action_pressed("ui_cancel") and _level_panel.visible:
		_show_main_panel()
		get_viewport().set_input_as_handled()

## ¿Está abierto el selector de destino?
func is_level_panel_visible() -> bool:
	return _level_panel.visible

## ¿Se puede jugar ya el nivel de Marte?
func is_mars_available() -> bool:
	return not _mars_button.disabled

## Ruta del nivel lunar (la usa el test del menú).
func get_moon_level_path() -> String:
	return LEVEL_MOON

# --- Botones ---

func _on_start_pressed() -> void:
	_show_level_panel()

func _on_moon_pressed() -> void:
	_load_level(LEVEL_MOON)

func _on_mars_pressed() -> void:
	_load_level(LEVEL_MARS)

func _on_back_pressed() -> void:
	_show_main_panel()

func _on_quit_pressed() -> void:
	get_tree().quit()

# --- Paneles ---

## Muestra la pantalla de inicio y deja el foco en "INICIAR MISIÓN".
func _show_main_panel() -> void:
	_main_panel.visible = true
	_level_panel.visible = false
	_start_button.grab_focus()

## Muestra el selector de destino.
func _show_level_panel() -> void:
	_main_panel.visible = false
	_level_panel.visible = true
	if not _moon_button.disabled:
		_moon_button.grab_focus()
	else:
		_back_button.grab_focus()

## Cambia a la escena del nivel indicado.
func _load_level(path: String) -> void:
	if path.is_empty():
		return
	var error: Error = get_tree().change_scene_to_file(path)
	if error != OK:
		push_error("MainMenu: no se pudo abrir %s (error %d)" % [path, error])
