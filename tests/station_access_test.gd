extends Node

## Test de accesibilidad de la estación.
##
## Comprueba que:
##  1. Ninguna puerta está tapada por una pared invisible (el bug original:
##     las colisiones del hábitat eran cajas de 20 m que cerraban las puertas).
##  2. Por detrás de cada puerta hay un paso real: el rayo que sale de la
##     puerta tiene que recorrer al menos 8 m antes de chocar con algo.

## Altura a la que se comprueban los pasos (altura del pecho).
const DOOR_HEIGHT: float = 1.2
## Longitud del rayo para comprobar el paso inmediato de una puerta.
const PASSAGE_LENGTH: float = 2.5
## Distancia mínima que debe recorrer el rayo de salida de una puerta.
const MIN_OPEN_LENGTH: float = 8.0
## Longitud máxima del rayo de salida.
const MAX_OPEN_LENGTH: float = 24.0

var _failures: int = 0
var _space: PhysicsDirectSpaceState3D

func _ready() -> void:
	# La física debe haber registrado los cuerpos del primer fotograma.
	for _i: int in range(3):
		await get_tree().physics_frame
	_run()

func _run() -> void:
	printerr("ACC: _run")
	var main: Node = get_tree().current_scene.get_node("Main")
	printerr("ACC: main ok")
	var player: HabitatPlayer = main.get_node("Player") as HabitatPlayer
	printerr("ACC: player=", player)
	_space = player.get_world_3d().direct_space_state
	printerr("ACC: space ok")
	var doors: Array[Dictionary] = _collect_doors(main.get_node("Habitat"))
	printerr("ACC: puertas=", doors.size())
	_failures += _check_passages(doors)
	_failures += _check_openings(doors)

	print("=== RESULTADO ACCESIBILIDAD: %s ===" % ("TODO OK" if _failures == 0 else "%d FALLOS" % _failures))
	get_tree().quit(_failures)

## Cada puerta debe tener el paso libre en las dos direcciones.
func _check_passages(doors: Array[Dictionary]) -> int:
	var failures: int = 0
	for door: Dictionary in doors:
		var position: Vector3 = door["position"]
		var facing: Vector3 = door["facing"]
		for direction: Vector3 in [facing, -facing]:
			var from: Vector3 = position + Vector3(0, DOOR_HEIGHT, 0) + direction * 0.3
			if _ray_hits(from, from + direction * PASSAGE_LENGTH):
				failures += 1
				print("  [FALLO] %s: paso bloqueado hacia (%.1f, %.1f, %.1f)" % [
					door["name"], direction.x, direction.y, direction.z])
	if failures == 0:
		print("  [OK]    todos los pasos de puerta están libres")
	return failures

## Por detrás de cada puerta debe haber un recorrido abierto.
func _check_openings(doors: Array[Dictionary]) -> int:
	var failures: int = 0
	for door: Dictionary in doors:
		var position: Vector3 = door["position"]
		var facing: Vector3 = door["facing"]
		var from: Vector3 = position + Vector3(0, DOOR_HEIGHT, 0) + facing * 0.4
		var result: Dictionary = _ray(from, from + facing * MAX_OPEN_LENGTH)
		var distance: float = MAX_OPEN_LENGTH
		if not result.is_empty():
			distance = position.distance_to(result["position"])
		if distance < MIN_OPEN_LENGTH:
			failures += 1
			var hit: Variant = result.get("collider")
			print("  [FALLO] %s: solo %.1f m abiertos tras la puerta (choca en %s)" % [
				door["name"], distance, str(hit)])
	if failures == 0:
		print("  [OK]    todas las puertas dan a un espacio abierto")
	return failures

## Recorre el árbol con una pila explícita y devuelve las puertas con su
## posición y la dirección hacia la que se sale de su sala.
func _collect_doors(root: Node) -> Array[Dictionary]:
	var doors: Array[Dictionary] = []
	var pending: Array[Node] = [root]
	while not pending.is_empty():
		var node: Node = pending.pop_back()
		for child: Node in node.get_children():
			pending.append(child)
			var n3: Node3D = child as Node3D
			if n3 == null:
				continue
			if not _is_door_model(n3):
				continue
			doors.append({
				"name": String(n3.get_path()),
				"position": n3.global_position,
				"facing": _outward_direction(n3),
			})
	return doors

## Dirección de salida: desde el centro de la sala hacia la puerta.
func _outward_direction(door: Node3D) -> Vector3:
	var room: Node3D = _owning_room(door)
	if room == null:
		return -door.global_transform.basis.z
	var direction: Vector3 = door.global_position - room.global_position
	direction.y = 0.0
	if direction.length_squared() < 0.001:
		return -door.global_transform.basis.z
	return direction.normalized()

## Busca el nodo que contiene las paredes a las que pertenece la puerta.
func _owning_room(door: Node3D) -> Node3D:
	var node: Node = door.get_parent()
	while node != null:
		var n3: Node3D = node as Node3D
		if n3 != null and n3.get_node_or_null("Walls") != null:
			return n3
		node = node.get_parent()
	return null

func _is_door_model(node: Node3D) -> bool:
	for sub: Node in node.get_children():
		if sub is MeshInstance3D:
			var mi: MeshInstance3D = sub as MeshInstance3D
			if mi.mesh != null and mi.mesh.resource_path.contains("Wall_With_Door"):
				return true
	return false

## Lanza un rayo y devuelve el diccionario del impacto (o vacío).
func _ray(from: Vector3, to: Vector3) -> Dictionary:
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1
	query.collide_with_areas = false
	return _space.intersect_ray(query)

## Lanza un rayo y devuelve true si impacta contra algo.
func _ray_hits(from: Vector3, to: Vector3) -> bool:
	return not _ray(from, to).is_empty()
