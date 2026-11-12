extends Node

## Test de interacción: comprueba que el jugador detecta las consolas cercanas
## (Area3D ↔ Area3D) y que la acción "interact" lanza el minijuego de
## reparación del recurso correspondiente.
##
## El oxígeno y la energía se reparan mediante minijuego; el agua, que aún no
## tiene minijuego, se repara al instante.

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
	var manager: RepairMinigameManager = get_tree().get_first_node_in_group("repair_minigames") as RepairMinigameManager
	failures += _check("Jugador instanciado", player != null)
	failures += _check("Gestor de minijuegos disponible", manager != null)
	if player == null or manager == null:
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

	# --- Interacción con una consola de minijuego (oxígeno) ---
	# Se simula la pulsación de la tecla de interacción.
	var input_event: InputEventKey = InputEventKey.new()
	input_event.physical_keycode = KEY_E
	input_event.pressed = true
	Input.parse_input_event(input_event)

	for _i: int in range(10):
		await get_tree().process_frame

	failures += _check("La interacción abre el minijuego", manager.is_open())
	failures += _check("El minijuego abierto es el de oxígeno",
		manager.get_active_minigame() is OxygenRepairMinigame)
	failures += _check("El control del jugador se bloquea", not player.is_input_enabled())
	failures += _check("El recurso no se repara al abrir el minijuego",
		is_equal_approx(game.get_resource_level(GameManager.RESOURCE_OXYGEN), level_before))

	# Se completa el minijuego para comprobar que repara el recurso.
	var minigame: OxygenRepairMinigame = manager.get_active_minigame() as OxygenRepairMinigame
	if minigame != null:
		minigame.result_display_time = 0.05
		while minigame.is_running() and minigame.get_progress() < 1.0:
			minigame.set_needle(minigame.get_target_center())
			minigame.press_button()
			await get_tree().process_frame
		await get_tree().create_timer(0.4).timeout

	var level_after: float = game.get_resource_level(GameManager.RESOURCE_OXYGEN)
	failures += _check("Completar el minijuego repara el recurso (%.0f -> %.0f)" % [level_before, level_after], level_after > level_before)
	failures += _check("El minijuego se cierra al terminar", not manager.is_open())

	# Se comprueba que el recurso reparado es el de la consola, no otro.
	var energy_level: float = game.get_resource_level(GameManager.RESOURCE_ENERGY)
	failures += _check("La reparación no afecta a otros recursos", is_equal_approx(energy_level, 100.0))

	# --- Consola sin minijuego (agua): se repara al instante ---
	var water_console: ResourceConsole = null
	for node: Node in main_scene.get_node("Habitat").get_children():
		var console: ResourceConsole = node as ResourceConsole
		if console != null and console.resource_type == GameManager.RESOURCE_WATER:
			water_console = console
			break
	failures += _check("Consola de agua encontrada", water_console != null)
	if water_console != null:
		game.consume_resource(GameManager.RESOURCE_WATER, 40.0)
		var water_before: float = game.get_resource_level(GameManager.RESOURCE_WATER)
		player.global_position = water_console.global_position + Vector3(0, 0, 1.2)
		for _i: int in range(30):
			await get_tree().process_frame
		Input.parse_input_event(input_event)
		for _i: int in range(10):
			await get_tree().process_frame
		failures += _check("El agua se repara al instante (sin minijuego)",
			game.get_resource_level(GameManager.RESOURCE_WATER) > water_before)
		failures += _check("El agua no abre ningún minijuego", not manager.is_open())

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
