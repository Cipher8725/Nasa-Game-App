class_name RepairMinigameManager
extends CanvasLayer

## Gestor de los minijuegos de reparación.
##
## Cuando el jugador interactúa con una consola cuyo recurso tiene minijuego,
## el gestor abre la interfaz correspondiente por encima de la escena, bloquea
## el control del jugador y, al terminar, aplica la reparación en el
## `GameManager`.
##
## Los recursos sin minijuego (agua, estructura) se reparan al instante como
## hasta ahora; se les puede añadir minijuego más adelante sin tocar este
## script: basta con registrar la escena en `_scene_for()`.

## Ruta de la escena del minijuego de oxígeno (pulsar un botón).
const SCENE_OXYGEN: String = "res://scenes/ui/minigame_oxygen.tscn"
## Ruta de la escena del minijuego de energía (conectar cables).
const SCENE_ENERGY: String = "res://scenes/ui/minigame_cables.tscn"

var _current: RepairMinigame = null

## ¿El recurso indicado tiene minijuego de reparación?
func has_minigame_for(resource_type: StringName) -> bool:
	return _scene_for(resource_type) != ""

## Minijuego abierto actualmente, o null si no hay ninguno.
func get_active_minigame() -> RepairMinigame:
	return _current

## ¿Hay algún minijuego en pantalla?
func is_open() -> bool:
	return _current != null

## Abre el minijuego que corresponde a la consola indicada.
## Devuelve false si el recurso no tiene minijame o si ya hay uno abierto.
func open_minigame(console: ResourceConsole) -> bool:
	if console == null or is_open():
		return false
	var path: String = _scene_for(console.resource_type)
	if path == "":
		return false
	var packed: PackedScene = load(path) as PackedScene
	if packed == null:
		push_error("RepairMinigameManager: no se pudo cargar la escena %s" % path)
		return false
	var instance: RepairMinigame = packed.instantiate() as RepairMinigame
	if instance == null:
		push_error("RepairMinigameManager: %s no es un RepairMinigame" % path)
		return false
	add_child(instance)
	instance.resource_type = console.resource_type
	instance.display_name = console.display_name
	instance.finished.connect(_on_minigame_finished)
	_current = instance
	instance.begin()
	_set_player_input(false)
	return true

# --- Métodos privados ---

## Devuelve la escena del minijuego de un recurso (vacío si no tiene).
func _scene_for(resource_type: StringName) -> String:
	match resource_type:
		GameManager.RESOURCE_OXYGEN:
			return SCENE_OXYGEN
		GameManager.RESOURCE_ENERGY:
			return SCENE_ENERGY
		_:
			return ""

## Aplica el resultado del minijuego y devuelve el control al jugador.
func _on_minigame_finished(success: bool) -> void:
	var instance: RepairMinigame = _current
	_current = null
	var game: GameManager = GameManager.get_instance()
	if instance != null and game != null:
		if success:
			var amount: float = game.restore_resource(
				instance.resource_type, game.config.console_restore_amount)
			_notify_hud("¡REPARACIÓN COMPLETADA: %s (+%.0f)" % [instance.display_name, amount], 3.0)
		else:
			_notify_hud("REPARACIÓN FALLIDA: %s" % instance.display_name, 3.0)
	if instance != null and is_instance_valid(instance):
		instance.queue_free()
	_set_player_input(true)

## Bloquea o libera el control del jugador.
func _set_player_input(enabled: bool) -> void:
	var player: HabitatPlayer = get_tree().get_first_node_in_group("player") as HabitatPlayer
	if player != null:
		player.set_input_enabled(enabled)

## Muestra un aviso en el HUD de la misión.
func _notify_hud(message: String, duration: float) -> void:
	var hud: MissionHud = get_tree().get_first_node_in_group("mission_hud") as MissionHud
	if hud != null:
		hud.show_alert(message, duration)
