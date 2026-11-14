class_name RegolithFloor
extends Node3D

## Aplica un material de regolita a todas las baldosas del suelo del hábitat.
##
## DESACTIVADO POR DEFECTO desde el Hito 12: el suelo del hábitat debe mostrar
## el material original del pack Molten Maps, sin texturas de regolita lunar ni
## marciana. En `scenes/habitat_decor.tscn` el nodo `StationInterior` lleva
## `enabled = false`, así que este script no toca nada al arrancar.
##
## Por qué existe igualmente: el pack modela el suelo como mallas independientes
## (una por baldosa) con su propio material, de modo que cambiar 257 nodos a
## mano sería tedioso y frágil. Si en el futuro se quiere un suelo de regolita
## (nivel lunar o marciano), basta con asignar un material a `floor_material` y
## poner `enabled = true` en el nodo `StationInterior`.
##
## OJO: este script sustituye el material de TODO lo que cuelga de los nodos
## `Floor` / `FloorTiles`, incluidas las franjas de peligro (`Hazard_Floor_1`),
## que por eso pierden su textura de rayas. Es otra razón para dejarlo apagado.

## Material que se aplica al suelo. Si es `null`, no se hace nada.
@export var floor_material: Material
## Permite desactivar el cambio de material y dejar el suelo original.
@export var enabled: bool = true

## Nombres de los nodos que agrupan las baldosas del suelo.
const FLOOR_CONTAINERS: Array[StringName] = [&"FloorTiles", &"Floor"]

## Grupo que reciben las mallas modificadas (lo usan los tests).
const APPLIED_GROUP: StringName = &"regolith_floor"

var _applied_meshes: int = 0

func _ready() -> void:
	# Los hijos (y las salas instanciadas) ya están listos cuando corre este
	# `_ready`, así que el recorrido encuentra todas las baldosas.
	if not enabled or floor_material == null:
		return
	for container: Node in _find_floor_containers(self):
		_apply_to_subtree(container)
	if _applied_meshes > 0:
		print("[Regolita] Material aplicado a %d mallas de suelo." % _applied_meshes)

## Número de mallas a las que se cambió el material (0 si está desactivado).
func get_applied_mesh_count() -> int:
	return _applied_meshes

# --- Métodos privados ---

## Devuelve todos los nodos contenedores de suelo del subárbol.
func _find_floor_containers(node: Node) -> Array[Node]:
	var found: Array[Node] = []
	if node.name in FLOOR_CONTAINERS:
		found.append(node)
	for child: Node in node.get_children():
		found.append_array(_find_floor_containers(child))
	return found

## Aplica el material a todas las mallas del contenedor.
func _apply_to_subtree(node: Node) -> void:
	var mesh_instance: MeshInstance3D = node as MeshInstance3D
	if mesh_instance != null and mesh_instance.mesh != null:
		mesh_instance.material_override = floor_material
		mesh_instance.add_to_group(APPLIED_GROUP)
		_applied_meshes += 1
	for child: Node in node.get_children():
		_apply_to_subtree(child)
