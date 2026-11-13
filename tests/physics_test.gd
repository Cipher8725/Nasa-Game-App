extends Node

## Test de física del módulo: verifica que las colisiones coinciden con la
## geometría visible.
##
## Motivo: las cajas de colisión de las paredes laterales estaban sin rotar y
## cubrían media habitación (el jugador quedaba atrapado dentro de un sólido).
## Los tests anteriores no lo detectaban porque colocaban al jugador con
## `global_position` en vez de moverlo.

var _failures: int = 0
var _player: HabitatPlayer

func _ready() -> void:
	# Espera a que la física haya registrado los cuerpos del primer fotograma.
	for _i: int in range(3):
		await get_tree().physics_frame
	_run()

func _run() -> void:
	var main: Node = get_node("Main")
	var habitat: Node = main.get_node("Habitat")
	_player = main.get_node("Player") as HabitatPlayer

	_check(habitat != null, "Habitat montado")
	_check(_player != null, "Jugador montado")

	var space: PhysicsDirectSpaceState3D = _player.get_world_3d().direct_space_state

	# 1) El centro de la sala está libre: un rayo horizontal no debe chocar.
	_check(not _ray_hits(space, Vector3(-5, 1, -3), Vector3(5, 1, -3)),
		"El centro de la sala está libre de colisiones")

	# 2) Las cuatro paredes bloquean. Se comprueban en zonas macizas: las
	# puertas (oeste, este y norte) dejan un hueco libre a propósito.
	_check(_ray_hits(space, Vector3(0, 1, 0), Vector3(0, 1, -20)), "Pared trasera bloquea")
	_check(_ray_hits(space, Vector3(4, 1, 0), Vector3(4, 1, 20)), "Pared del ventanal bloquea")
	_check(_ray_hits(space, Vector3(0, 1, 4), Vector3(-20, 1, 4)), "Pared izquierda bloquea")
	_check(_ray_hits(space, Vector3(0, 1, 4), Vector3(20, 1, 4)), "Pared derecha bloquea")

	# 2 bis) Las puertas SÍ dejan pasar: ese es el punto de la ampliación.
	_check(not _ray_hits(space, Vector3(0, 1, 0), Vector3(0, 1, 14)), "La puerta norte deja pasar")
	_check(not _ray_hits(space, Vector3(0, 1, 0), Vector3(-14, 1, 0)), "La puerta oeste deja pasar")
	_check(not _ray_hits(space, Vector3(0, 1, 0), Vector3(14, 1, 0)), "La puerta este deja pasar")

	# 3) El suelo sostiene.
	_check(_ray_hits(space, Vector3(0, 2, 0), Vector3(0, -5, 0)), "El suelo bloquea la caída")

	# 4) El jugador puede moverse por el centro y no puede atravesar la pared.
	_player.global_position = Vector3(0, 0.2, 0)
	await get_tree().physics_frame
	var libre: bool = _player.test_move(_player.global_transform, Vector3(0, 0, -1.5))
	_check(not libre, "El jugador se mueve libremente por el centro")
	var bloqueado: bool = _player.test_move(_player.global_transform, Vector3(0, 0, -9))
	_check(bloqueado, "El jugador no atraviesa la pared trasera")

	# 5) El punto de aparición está libre (no dentro de un props).
	_player.global_position = Vector3(0, 0.2, 4)
	await get_tree().physics_frame
	var salida_bloqueada: bool = _player.test_move(_player.global_transform, Vector3(0, 0, 1))
	_check(not salida_bloqueada, "El punto de aparición está libre")

	print("=== RESULTADO FISICA: %s ===" % ("TODO OK" if _failures == 0 else "FALLOS (%d)" % _failures))
	get_tree().quit(_failures)

## Lanza un rayo y devuelve true si impacta contra algo.
func _ray_hits(space: PhysicsDirectSpaceState3D, from: Vector3, to: Vector3) -> bool:
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1
	query.collide_with_areas = false
	var result: Dictionary = space.intersect_ray(query)
	return not result.is_empty()

## Registra una comprobación y acumula el fallo si no se cumple.
func _check(condition: bool, label: String) -> void:
	if condition:
		print("  [OK]   ", label)
	else:
		print("  [FALLO] ", label)
		_failures += 1
