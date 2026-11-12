class_name MissionController
extends Node3D

## Controlador raíz de la misión.
##
## Orquesta el arranque de la partida, la cuenta atrás y el reinicio.
## No implementa reglas de juego: delega todo en el `GameManager` (Autoload "Game").

@onready var _game: GameManager = GameManager.get_instance()

func _ready() -> void:
	# El HUD se registra como observador del gestor global.
	_game.mission_failed.connect(_on_mission_failed)
	_game.mission_completed.connect(_on_mission_completed)

	# Pequeña demora para que la cámara se estabilice antes de la cuenta atrás.
	await get_tree().create_timer(0.5).timeout
	_game.start_mission()

func _unhandled_input(event: InputEvent) -> void:
	# Con un minijuego de reparación abierto el reinicio se ignora: el jugador
	# está interactuando con la consola, no reiniciando la partida.
	if _is_minigame_open():
		return
	# Reinicio de la misión con la tecla configurada "restart_mission".
	if event.is_action_pressed("restart_mission"):
		_restart_mission()

## Indica si hay algún minijuego de reparación en pantalla.
func _is_minigame_open() -> bool:
	if not is_inside_tree():
		return false
	var manager: RepairMinigameManager = get_tree().get_first_node_in_group("repair_minigames") as RepairMinigameManager
	return manager != null and manager.is_open()

## Reinicia la partida actual desde el principio.
func _restart_mission() -> void:
	get_tree().reload_current_scene()

# --- Callbacks de señal ---

func _on_mission_failed(_reason: String) -> void:
	# Se libera el ratón para que el jugador pueda interactuar con el HUD.
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_mission_completed(_final_score: float) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
