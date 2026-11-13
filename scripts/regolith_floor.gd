class_name RegolithFloor
extends Node3D

## Aplica el material de regolita a todas las baldosas del suelo del hábitat.
##
## El pack Molten Maps modela el suelo como mallas independientes (una por
## baldosa) con su propio material. Cambiar 25 nodos por sala sería tedioso y
## frágil, así que este script recorre los nodos que agrupan el suelo (`Floor` y
## `FloorTiles`) de todo el subárbol —incluidas las salas instanciadas— y les
## asigna `floor_material` como `material_override`.
##
## El material usa proyección triplanar en espacio de mundo, de modo que la
## textura es continua entre baldosas y entre salas.
##
## Para volver al suelo original del pack basta con desmarcar `enabled` (o
## vaciar `floor_material`) en el nodo `StationInterior` de
## `scenes/habitat_decor.tscn`.

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
