class_name WindowGlass
extends Node3D

## Sustituye el cristal tintado del pack por un cristal casi transparente.
##
## El pack Molten Maps modela cada ventana (`Wall_Glass_Clear.glb`) con dos
## superficies en la misma malla: el marco opaco ("Atlas") y el cristal
## ("Atlas Glass", azul y con alfa 0.45). En el renderizador Compatibility el
## cristal se dibuja con mezcla alfa normal (no hay transmisión), así que el
## resultado era un panel azul opaco: desde dentro no se veía el cielo.
##
## Este script recorre el subárbol, detecta las superficies cuyo material se
## llama "... Glass" y les pone `glass_material` como override. El marco se
## queda intacto.
##
## Para volver al cristal original basta con desmarcar `enabled` en el nodo
## `Walls` de `scenes/habitat_decor.tscn`.

## Material que se aplica a las superficies de cristal. Si es `null` no se hace nada.
@export var glass_material: Material
## Permite desactivar el cambio y dejar el cristal del pack.
@export var enabled: bool = true

## Fragmento que deben contener los nombres de material que son cristal.
const GLASS_NAME_HINT: String = "glass"

## Grupo que reciben las mallas modificadas (lo usan los tests).
const APPLIED_GROUP: StringName = &"window_glass"

var _applied_surfaces: int = 0

func _ready() -> void:
	if not enabled or glass_material == null:
		return
	_applied_surfaces = _apply_to_subtree(self)
	if _applied_surfaces > 0:
		print("[Cristal] Material aplicado a %d superficies." % _applied_surfaces)

## Número de superficies de cristal sustituidas (0 si está desactivado).
func get_applied_surface_count() -> int:
	return _applied_surfaces

# --- Métodos privados ---

## Recorre el subárbol y devuelve cuántas superficies se han sustituido.
func _apply_to_subtree(node: Node) -> int:
	var total: int = 0
	var mesh_instance: MeshInstance3D = node as MeshInstance3D
	if mesh_instance != null and mesh_instance.mesh != null:
		total += _apply_to_surfaces(mesh_instance)
	for child: Node in node.get_children():
		total += _apply_to_subtree(child)
	return total

## Sustituye solo las superficies de cristal de una malla.
func _apply_to_surfaces(mesh_instance: MeshInstance3D) -> int:
	var total: int = 0
	for surface: int in mesh_instance.mesh.get_surface_count():
		var current: Material = mesh_instance.get_active_material(surface)
		if current == null:
			continue
		if not current.resource_name.to_lower().contains(GLASS_NAME_HINT):
			continue
		mesh_instance.set_surface_override_material(surface, glass_material)
		total += 1
	if total > 0:
		mesh_instance.add_to_group(APPLIED_GROUP)
	return total
