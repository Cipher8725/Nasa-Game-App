extends Node

## Test de simulación del bucle de juego.
##
## Comprueba las dos rutas de final de partida:
##  - Ruta de DERROTA: sin reparaciones, un recurso se agota y la misión falla.
##  - Ruta de VICTORIA: reparando a tiempo, se sobrevive el tiempo objetivo.
##
## Nota: con `Engine.time_scale` acelerado, los temporizadores del árbol también se
## aceleran; por eso se espera por fotogramas (polling) y no con `create_timer`.

## Escala temporal para simular minutos de misión en segundos reales.
const TIME_SCALE: float = 40.0
## Límite de fotogramas de espera para no bloquear el test indefinidamente.
const MAX_WAIT_FRAMES: int = 20000

## Instancia del gestor global.
## Se resuelve de forma diferida (dentro de `_run`) porque el inicializador de un
## miembro de clase se ejecuta al construir el nodo, antes de que el Autoload
## haya pasado por su `_ready()`.
var game: GameManager = null

func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	_run()

func _run() -> void:
	var failures: int = 0
	Engine.time_scale = TIME_SCALE
	# El Autoload ya está listo: se resuelve la instancia del gestor.
	game = GameManager.get_instance()
	failures += _check("Instancia del gestor disponible", game != null)
	if game == null:
		print("=== RESULTADO SIMULACION: %d FALLOS ===" % failures)
		get_tree().quit(1)
		return

	# --- Preparación: esperar a que la cuenta atrás termine ---
	var state: GameManager.MissionState = await _wait_for_state([GameManager.MissionState.ACTIVE])
	failures += _check("La misión entra en estado ACTIVE", state == GameManager.MissionState.ACTIVE)

	# El decaimiento debe reducir los recursos con el paso del tiempo.
	var oxygen_before: float = game.get_resource_level(GameManager.RESOURCE_OXYGEN)
	for _i: int in range(30):
		await get_tree().process_frame
	var oxygen_after: float = game.get_resource_level(GameManager.RESOURCE_OXYGEN)
	failures += _check("El oxígeno decae con el tiempo (%.1f -> %.1f)" % [oxygen_before, oxygen_after], oxygen_after < oxygen_before)
	failures += _check("El tiempo de misión avanza", game.get_mission_time() > 0.0)
	failures += _check("La puntuación sube", game.get_score() > 0.0)

	# --- RUTA DE DERROTA: sin reparaciones ---
	var failed: Array[bool] = [false]
	var failure_reason: Array[String] = [""]
	var on_failed: Callable = func(reason: String) -> void:
		failed[0] = true
		failure_reason[0] = reason
	game.mission_failed.connect(on_failed)

	var final_state: GameManager.MissionState = await _wait_for_state([GameManager.MissionState.FAILED, GameManager.MissionState.COMPLETED])
	game.mission_failed.disconnect(on_failed)
	failures += _check("Sin reparaciones la misión termina en FAILED", final_state == GameManager.MissionState.FAILED)
	failures += _check("Se emite la señal mission_failed", failed[0])
	failures += _check("El motivo de derrota es un recurso agotado (%s)" % failure_reason[0], failure_reason[0].contains("Recurso agotado"))

	# --- RUTA DE VICTORIA: reparando a tiempo ---
	game.start_mission()
	var victory_state: GameManager.MissionState = await _wait_for_state([GameManager.MissionState.ACTIVE])
	failures += _check("La segunda misión arranca en ACTIVE", victory_state == GameManager.MissionState.ACTIVE)

	var completed: Array[bool] = [false]
	var final_score: Array[float] = [0.0]
	var on_completed: Callable = func(score: float) -> void:
		completed[0] = true
		final_score[0] = score
	game.mission_completed.connect(on_completed)

	# Simula a un jugador perfecto: repara todos los recursos cada fotograma.
	var victory_state_final: GameManager.MissionState = GameManager.MissionState.ACTIVE
	var frames: int = 0
	while frames < MAX_WAIT_FRAMES:
		await get_tree().process_frame
		frames += 1
		game.restore_resource(GameManager.RESOURCE_OXYGEN, 50.0)
		game.restore_resource(GameManager.RESOURCE_ENERGY, 50.0)
		game.restore_resource(GameManager.RESOURCE_WATER, 50.0)
		game.restore_resource(GameManager.RESOURCE_STRUCTURE, 50.0)
		victory_state_final = game.get_mission_state()
		if victory_state_final == GameManager.MissionState.COMPLETED or victory_state_final == GameManager.MissionState.FAILED:
			break
	game.mission_completed.disconnect(on_completed)

	failures += _check("Con reparaciones la misión se completa por tiempo", victory_state_final == GameManager.MissionState.COMPLETED)
	failures += _check("Se emite la señal mission_completed", completed[0])
	failures += _check("La puntuación final es > 0 (%.0f)" % final_score[0], final_score[0] > 0.0)
	failures += _check("Misiones completadas = 1", game.get_missions_completed() == 1)

	Engine.time_scale = 1.0
	print("=== RESULTADO SIMULACION: %s ===" % ("TODO OK" if failures == 0 else "%d FALLOS" % failures))
	get_tree().quit(0 if failures == 0 else 1)

## Espera a que la misión alcance alguno de los estados indicados (polling por fotogramas).
func _wait_for_state(targets: Array[GameManager.MissionState]) -> GameManager.MissionState:
	var frames: int = 0
	while frames < MAX_WAIT_FRAMES:
		var current: GameManager.MissionState = game.get_mission_state()
		if targets.has(current):
			return current
		await get_tree().process_frame
		frames += 1
	return game.get_mission_state()

func _check(label: String, condition: bool) -> int:
	if condition:
		print("  [OK]   ", label)
		return 0
	print("  [FALLO] ", label)
	return 1
