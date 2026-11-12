extends Node

## Test de interacción: comprueba que el jugador detecta las consolas cercanas
## (Area3D ↔ Area3D) y que la acción "interact" repara el recurso correcto.

func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	_run()

func _run() -> void:
	var failures: int = 0
	var game: GameManager = GameManager.get_instance()
	failures += _check("Instancia del gestor disponible", game != null)
	if game == null:
		get_tree().quit(1)
		return

	var main_scene: Node = get_tree().current_scene.get_node_or_null("Main")
	var player: HabitatPlayer = main_scene.get_node_or_null("Player") as HabitatPlayer
	failures += _check("Jugador instanciado", player != null)
	if player == null:
		get_tree().quit(1)
		return

	# --- Detección de consola cercana ---
	# Se coloca al jugador frente a la consola de oxígeno.
	var oxygen_console: ResourceConsole = null
	for node: Node in main_scene.get_node("Habitat").get_children():
		var console: ResourceConsole = node as ResourceConsole
		if console != null and console.resource_type == GameManager.RESOURCE_OXYGEN:
			oxygen_console = console
			break
	failures += _check("Consola de oxígeno encontrada", oxygen_console != null)
	if oxygen_console == null:
		get_tree().quit(1)
		return

	# Se agota el oxígeno para que la reparación sea observable.
	game.consume_resource(GameManager.RESOURCE_OXYGEN, 50.0)
	var level_before: float = game.get_resource_level(GameManager.RESOURCE_OXYGEN)

	# Se teletransporta el jugador junto a la consola.
	player.global_position = oxygen_console.global_position + Vector3(0, 0, 1.2)

	# Se espera a que el Area3D registre la entrada.
	var detected: bool = false
	for _i: int in range(60):
		await get_tree().process_frame
		if player.get_consoles_in_range().has(oxygen_console):
			detected = true
			break
	failures += _check("El jugador detecta la consola cercana", detected)

	# --- Reparación mediante la acción "interact" ---
	# Se simula la pulsación de la tecla de interacción.
	var input_event: InputEventKey = InputEventKey.new()
	input_event.physical_keycode = KEY_E
	input_event.pressed = true
	Input.parse_input_event(input_event)

	for _i: int in range(10):
		await get_tree().process_frame

	var level_after: float = game.get_resource_level(GameManager.RESOURCE_OXYGEN)
	failures += _check("La reparación aumenta el recurso (%.0f -> %.0f)" % [level_before, level_after], level_after > level_before)

	# Se comprueba que el recurso reparado es el de la consola, no otro.
	var energy_level: float = game.get_resource_level(GameManager.RESOURCE_ENERGY)
	failures += _check("La reparación no afecta a otros recursos", is_equal_approx(energy_level, 100.0))

	# --- Salida del área ---
	player.global_position = Vector3(0, 0, 6)
	var exited: bool = false
	for _i: int in range(60):
		await get_tree().process_frame
		if not player.get_consoles_in_range().has(oxygen_console):
			exited = true
			break
	failures += _check("El jugador deja de detectar la consola al alejarse", exited)

	print("=== RESULTADO INTERACCION: %s ===" % ("TODO OK" if failures == 0 else "%d FALLOS" % failures))
	get_tree().quit(0 if failures == 0 else 1)

func _check(label: String, condition: bool) -> int:
	if condition:
		print("  [OK]   ", label)
		return 0
	print("  [FALLO] ", label)
	return 1
