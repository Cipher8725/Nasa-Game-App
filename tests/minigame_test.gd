extends Node

## Test de los minijuegos de reparación.
##
## Comprueba la mecánica del minijuego de oxígeno (pulsar un botón), la del
## minijuego de energía (conectar cables) y la integración con las consolas:
## abrir el minijuego, bloquear el control del jugador y reponer el recurso al
## completarlo.

func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	_run()

func _run() -> void:
	var failures: int = 0
	failures += await _test_oxygen_minigame()
	failures += await _test_cable_minigame()
	failures += await _test_manager_integration()
	print("=== RESULTADO MINIJUEGOS: %s ===" % ("TODO OK" if failures == 0 else "%d FALLOS" % failures))
	get_tree().quit(0 if failures == 0 else 1)

## Minijuego de oxígeno: pulsar el botón dentro de la zona suma presión.
func _test_oxygen_minigame() -> int:
	var failures: int = 0
	var packed: PackedScene = load("res://scenes/ui/minigame_oxygen.tscn") as PackedScene
	var minigame: OxygenRepairMinigame = packed.instantiate() as OxygenRepairMinigame
	failures += _check("Minijuego de oxígeno instanciado", minigame != null)
	if minigame == null:
		return failures
	add_child(minigame)
	minigame.result_display_time = 0.05
	minigame.begin()
	await get_tree().process_frame

	failures += _check("El minijuego arranca en marcha", minigame.is_running())
	failures += _check("El progreso empieza a cero", is_equal_approx(minigame.get_progress(), 0.0))

	# Pulsar fuera de la zona debe fallar y penalizar el tiempo.
	var time_before: float = minigame.get_time_left()
	minigame.set_needle(clampf(minigame.get_target_center() + 0.4, 0.0, 1.0))
	minigame.press_button()
	failures += _check("Pulsar fuera de la zona cuenta como fallo", minigame.get_misses() == 1)
	failures += _check("Fallar resta tiempo", minigame.get_time_left() < time_before)

	# Pulsar dentro de la zona suma presión.
	minigame.set_needle(minigame.get_target_center())
	minigame.press_button()
	failures += _check("Pulsar en la zona cuenta como acierto", minigame.get_hits() == 1)
	failures += _check("Aciertar sube la presión", minigame.get_progress() > 0.0)

	# Al llegar al 100% el minijuego termina con éxito.
	while minigame.is_running() and minigame.get_progress() < 1.0:
		minigame.set_needle(minigame.get_target_center())
		minigame.press_button()
		await get_tree().process_frame
	failures += _check("El minijuego termina al llenar la presión", not minigame.is_running())
	failures += _check("El minijajeo termina con éxito", not minigame.is_finished() or minigame.get_progress() >= 1.0)

	minigame.queue_free()
	return failures

## Minijuego de energía: cada cable debe ir a su conector.
func _test_cable_minigame() -> int:
	var failures: int = 0
	var packed: PackedScene = load("res://scenes/ui/minigame_cables.tscn") as PackedScene
	var minigame: CableRepairMinigame = packed.instantiate() as CableRepairMinigame
	failures += _check("Minijuego de cables instanciado", minigame != null)
	if minigame == null:
		return failures
	add_child(minigame)
	minigame.result_display_time = 0.05
	minigame.begin()
	await get_tree().process_frame

	var order: Array[int] = minigame.get_socket_order()
	failures += _check("Hay cuatro conectores", order.size() == 4)

	# Conectar mal penaliza el tiempo y no enciende ninguna línea.
	var wrong_position: int = -1
	for position: int in range(4):
		if order[position] != 0:
			wrong_position = position
			break
	var time_before: float = minigame.get_time_left()
	minigame.press_cable(0)
	minigame.press_socket(wrong_position)
	failures += _check("Una conexión incorrecta no enciende la línea", minigame.get_connected_count() == 0)
	failures += _check("Una conexión incorrecta penaliza el tiempo", minigame.get_time_left() < time_before)

	# Las cuatro conexiones correctas completan el circuito.
	for cable: int in range(4):
		var position: int = order.find(cable)
		minigame.press_cable(cable)
		minigame.press_socket(position)
	failures += _check("Las cuatro líneas quedan conectadas", minigame.get_connected_count() == 4)
	failures += _check("El circuito llega al 100%", minigame.get_progress() >= 1.0)
	failures += _check("El minijuego de cables termina", not minigame.is_running())

	minigame.queue_free()
	return failures

## Integración: la consola abre su minijuego y repara el recurso al completarlo.
func _test_manager_integration() -> int:
	var failures: int = 0
	var game: GameManager = GameManager.get_instance()
	var main_scene: Node = get_tree().current_scene.get_node_or_null("Main")
	if main_scene == null or game == null:
		failures += _check("Escena principal y gestor disponibles", false)
		return failures

	var manager: RepairMinigameManager = get_tree().get_first_node_in_group("repair_minigames") as RepairMinigameManager
	var player: HabitatPlayer = main_scene.get_node_or_null("Player") as HabitatPlayer
	failures += _check("Gestor de minijuegos disponible", manager != null)
	failures += _check("Jugador disponible", player != null)
	if manager == null or player == null:
		return failures

	failures += _check("El oxígeno tiene minijuego", manager.has_minigame_for(GameManager.RESOURCE_OXYGEN))
	failures += _check("La energía tiene minijuego", manager.has_minigame_for(GameManager.RESOURCE_ENERGY))
	failures += _check("El agua todavía no tiene minijuego", not manager.has_minigame_for(GameManager.RESOURCE_WATER))

	var console: ResourceConsole = _find_console(main_scene, GameManager.RESOURCE_OXYGEN)
	failures += _check("Consola de oxígeno encontrada", console != null)
	if console == null:
		return failures

	game.consume_resource(GameManager.RESOURCE_OXYGEN, 50.0)
	var level_before: float = game.get_resource_level(GameManager.RESOURCE_OXYGEN)

	failures += _check("El gestor abre el minijuego", manager.open_minigame(console))
	failures += _check("El minijuego queda activo", manager.is_open())
	failures += _check("El control del jugador se bloquea", not player.is_input_enabled())
	failures += _check("Abrir el minijuego no repara todavía",
		is_equal_approx(game.get_resource_level(GameManager.RESOURCE_OXYGEN), level_before))

	var minigame: OxygenRepairMinigame = manager.get_active_minigame() as OxygenRepairMinigame
	failures += _check("El minijuego abierto es el de oxígeno", minigame != null)
	if minigame == null:
		return failures
	minigame.result_display_time = 0.05

	# Se completa el minijuego pulsando siempre en la zona buena.
	while minigame.is_running() and minigame.get_progress() < 1.0:
		minigame.set_needle(minigame.get_target_center())
		minigame.press_button()
		await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout

	failures += _check("El minijuego se cierra al terminar", not manager.is_open())
	failures += _check("El control del jugador vuelve", player.is_input_enabled())
	failures += _check("El recurso se repone al completar el minijuego",
		game.get_resource_level(GameManager.RESOURCE_OXYGEN) > level_before)
	return failures

## Localiza una consola por su recurso dentro de la escena principal.
func _find_console(main_scene: Node, resource_type: StringName) -> ResourceConsole:
	var habitat: Node = main_scene.get_node_or_null("Habitat")
	if habitat == null:
		return null
	return _search_console(habitat, resource_type)

## Busca recursivamente una consola por su recurso.
func _search_console(node: Node, resource_type: StringName) -> ResourceConsole:
	for child: Node in node.get_children():
		var console: ResourceConsole = child as ResourceConsole
		if console != null and console.resource_type == resource_type:
			return console
		var found: ResourceConsole = _search_console(child, resource_type)
		if found != null:
			return found
	return null

## Registra una comprobación y devuelve 1 si falla.
func _check(label: String, condition: bool) -> int:
	if condition:
		print("  [OK]   ", label)
		return 0
	print("  [FALLO] ", label)
	return 1
