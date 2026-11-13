extends Node

## Test funcional automático: se añade como nodo hijo de la escena principal para
## verificar el comportamiento real del juego (recursos, señales, consola, HUD).
## No se usa `--script` porque ese modo NO registra los Autoloads.

func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	_run_tests()

func _run_tests() -> void:
	var failures: int = 0
	# Instancia del gestor global. Se resuelve de forma diferida porque el
	# inicializador de un miembro de clase se ejecuta antes de que el Autoload
	# haya pasado por su `_ready()`.
	var game: GameManager = GameManager.get_instance()
	failures += _check("Instancia del gestor disponible", game != null)
	if game == null:
		print("=== RESULTADO: %d FALLOS ===" % failures)
		get_tree().quit(1)
		return
	failures += _check("Autoload 'Game' registrado", game != null)
	failures += _check("Configuración cargada", game.config != null)
	failures += _check("Nivel de oxígeno inicial = 100", is_equal_approx(game.get_resource_level(GameManager.RESOURCE_OXYGEN), 100.0))

	# Consolas registradas y reparables.
	var main_scene: Node = get_tree().current_scene.get_node_or_null("Main")
	failures += _check("Escena Main montada", main_scene != null)
	var habitat: Habitat = main_scene.get_node_or_null("Habitat") as Habitat if main_scene != null else null
	failures += _check("Habitat encontrado", habitat != null)
	var console_count: int = 0
	if habitat != null:
		console_count = habitat.get_consoles().size()
	failures += _check("4 consolas registradas (obtenidas: %d)" % console_count, console_count == 4)

	# Restauración de recurso vía consola (primero se consume para tener margen).
	game.consume_resource(GameManager.RESOURCE_OXYGEN, 40.0)
	var restored: float = game.restore_resource(GameManager.RESOURCE_OXYGEN, 30.0)
	failures += _check("restore_resource aplica la cantidad", is_equal_approx(restored, 30.0))
	failures += _check("Oxígeno sube tras restaurar", is_equal_approx(game.get_resource_level(GameManager.RESOURCE_OXYGEN), 90.0))

	# Clamping: no se puede superar el máximo.
	game.restore_resource(GameManager.RESOURCE_OXYGEN, 500.0)
	failures += _check("Clamping al máximo respected", is_equal_approx(game.get_resource_level(GameManager.RESOURCE_OXYGEN), 100.0))

	# Consumo y_percentage.
	game.consume_resource(GameManager.RESOURCE_ENERGY, 50.0)
	failures += _check("Energía baja a 50", is_equal_approx(game.get_resource_level(GameManager.RESOURCE_ENERGY), 50.0))
	failures += _check("Porcentaje de energía = 50", is_equal_approx(game.get_resource_percentage(GameManager.RESOURCE_ENERGY), 50.0))

	# Señal resource_changed debe emitir.
	var signal_fired: Array[bool] = [false]
	var callback: Callable = func(_t: StringName, _c: float, _m: float) -> void:
		signal_fired[0] = true
	game.resource_changed.connect(callback)
	game.consume_resource(GameManager.RESOURCE_WATER, 10.0)
	game.resource_changed.disconnect(callback)
	failures += _check("resource_changed se emite al consumir", signal_fired[0])

	# Transición a estado CRITICAL.
	# Primero se espera a que la misión esté realmente en marcha: durante el
	# BRIEFING los recursos no se consumen y el estado CRITICAL no se aplica.
	await _wait_for_active_mission()
	game.consume_resource(GameManager.RESOURCE_WATER, 85.0)
	failures += _check("Agua entra en estado crítico", game.get_resource_state_is_critical(GameManager.RESOURCE_WATER))
	failures += _check("La misión pasa a estado CRITICAL", game.get_mission_state() == GameManager.MissionState.CRITICAL)

	# Al reparar, el recurso sale de crítico y la misión vuelve a ACTIVE.
	game.restore_resource(GameManager.RESOURCE_WATER, 100.0)
	failures += _check("Reparar saca el recurso de crítico", not game.get_resource_state_is_critical(GameManager.RESOURCE_WATER))
	failures += _check("La misión vuelve de CRITICAL a ACTIVE", game.get_mission_state() == GameManager.MissionState.ACTIVE)

	# Emergencia aplica daño estructural.
	var shield_before: float = game.get_resource_level(GameManager.RESOURCE_SHIELD)
	game.trigger_emergency(GameManager.EMERGENCY_METEOR, 1.0)
	failures += _check("Emergencia meteorito daña el escudo", game.get_resource_level(GameManager.RESOURCE_SHIELD) < shield_before)

	# Guardado y carga.
	# Se toma el valor de referencia en el momento de guardar: durante la misión
	# los recursos decaen, así que un valor fijo no sería estable.
	failures += _check("save_game devuelve true", game.save_game(1))
	failures += _check("has_save_game detecta el archivo", game.has_save_game(1))
	var energy_at_save: float = game.get_resource_level(GameManager.RESOURCE_ENERGY)
	game.consume_resource(GameManager.RESOURCE_ENERGY, 10.0)
	failures += _check("load_game devuelve true", game.load_game(1))
	failures += _check("load_game restaura la energía (%.2f)" % energy_at_save, is_equal_approx(game.get_resource_level(GameManager.RESOURCE_ENERGY), energy_at_save))

	# HUD presente en la escena.
	var hud: MissionHud = main_scene.get_node_or_null("UILayer/HUD") as MissionHud if main_scene != null else null
	failures += _check("HUD instanciado", hud != null)

	# Jugador presente.
	var player: HabitatPlayer = main_scene.get_node_or_null("Player") as HabitatPlayer if main_scene != null else null
	failures += _check("Jugador instanciado", player != null)

	print("=== RESULTADO: %s ===" % ("TODO OK" if failures == 0 else "%d FALLOS" % failures))
	get_tree().quit(0 if failures == 0 else 1)

func _check(label: String, condition: bool) -> int:
	if condition:
		print("  [OK]   ", label)
		return 0
	print("  [FALLO] ", label)
	return 1

## Espera a que la misión termine la cuenta atrás y pase a estado ACTIVE.
func _wait_for_active_mission() -> void:
	var game: GameManager = GameManager.get_instance()
	var frames: int = 0
	while frames < 3000:
		if game != null and game.get_mission_state() == GameManager.MissionState.ACTIVE:
			return
		await get_tree().process_frame
		frames += 1
