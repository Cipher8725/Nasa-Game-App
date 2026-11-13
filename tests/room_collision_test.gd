extends Node

## Test de colocación de los módulos de habitación (`scenes/rooms/`).
##
## Comprueba que:
##  - Cada módulo carga y tiene la estructura mínima (suelo, paredes, luces,
##    colisión).
##  - Ningún mueble se solapa de forma significativa con otro (AABB).
##
## Se ignoran:
##  - Las copias del mismo asset (baldosas y paneles repetidos).
##  - Los grupos "Floor" y "Ceiling": son las superficies de apoyo.

## Volumen mínimo (m³) para considerar que un solape es un error real.
const MIN_OVERLAP_VOLUME: float = 0.05

## Módulos que se validan.
const ROOMS: PackedStringArray = [
	"res://scenes/rooms/room_cafeteria.tscn",
	"res://scenes/rooms/room_quarters.tscn",
	"res://scenes/rooms/room_generator.tscn",
	"res://scenes/rooms/room_control.tscn",
	"res://scenes/rooms/room_hydroponics.tscn",
	"res://scenes/rooms/room_medbay.tscn",
	"res://scenes/rooms/room_briefing.tscn",
	"res://scenes/rooms/room_storage.tscn",
	"res://scenes/rooms/corridor_module.tscn",
	# Módulos recreados a partir de las referencias de assets/IMG
	"res://scenes/rooms/IMG_vestibulo.tscn",
	"res://scenes/rooms/IMG_sala_de_mando.tscn",
	"res://scenes/rooms/IMG_sala_del_generador.tscn",
	"res://scenes/rooms/IMG_enfermeria.tscn",
	"res://scenes/rooms/IMG_criotanque.tscn",
	"res://scenes/rooms/IMG_cuartos.tscn",
	"res://scenes/rooms/IMG_sala_de_reuniones.tscn",
	"res://scenes/rooms/IMG_sala_del_orrery.tscn",
]

## Subárboles que no participan en la comprobación de solapes.
## El pasillo es una única pieza que ya incluye suelo, paredes y techo: su
## AABB engloba todo el módulo y marcaría solapes falsos con sus props.
const IGNORED_PATH_PARTS: PackedStringArray = ["Shell"]

var _failures: int = 0

func _ready() -> void:
	await get_tree().process_frame
	_run()

func _run() -> void:
	for room_path: String in ROOMS:
		await _check_room(room_path)
	print("=== RESULTADO HABITACIONES: %s ===" % ("TODO OK" if _failures == 0 else "%d FALLOS" % _failures))
	get_tree().quit(_failures)

## Valida un módulo: estructura y solapes.
func _check_room(room_path: String) -> void:
	var room_name: String = room_path.get_file().get_basename()
	var packed: PackedScene = load(room_path) as PackedScene
	if packed == null:
		_fail("  [FALLO] %s: no se pudo cargar" % room_name, true)
		return
	var instance: Node = packed.instantiate()
	add_child(instance)
	await get_tree().process_frame

	# Estructura mínima del módulo.
	_fail("  [FALLO] %s: sin nodo Lights" % room_name, instance.get_node_or_null("Lights") == null)
	_fail("  [FALLO] %s: sin nodo Props" % room_name, instance.get_node_or_null("Props") == null)
	var has_shell: bool = instance.get_node_or_null("Shell") != null
	_fail("  [FALLO] %s: sin nodo Floor" % room_name,
		instance.get_node_or_null("Floor") == null and not has_shell)
	_fail("  [FALLO] %s: sin nodo Walls" % room_name,
		instance.get_node_or_null("Walls") == null and not has_shell)
	var collision: StaticBody3D = instance.get_node_or_null("Collision") as StaticBody3D
	_fail("  [FALLO] %s: sin nodo Collision" % room_name, collision == null)
	if collision != null:
		_fail("  [FALLO] %s: la colisión no tiene formas" % room_name, collision.get_child_count() == 0)

	# Solapes entre mallas.
	var meshes: Array[Dictionary] = []
	_collect(instance, instance, meshes)
	var overlaps: Array[String] = []
	var checked: int = 0
	for i: int in range(meshes.size()):
		for j: int in range(i + 1, meshes.size()):
			var a: Dictionary = meshes[i]
			var b: Dictionary = meshes[j]
			if String(a["group"]) == String(b["group"]):
				continue
			if _is_ignored_group(String(a["group"])) or _is_ignored_group(String(b["group"])):
				continue
			checked += 1
			var intersection: AABB = a["aabb"].intersection(b["aabb"])
			if intersection.get_volume() >= MIN_OVERLAP_VOLUME:
				overlaps.append("%s <-> %s (%.3f m3)" % [
					a["name"], b["name"], intersection.get_volume()])
	print("  %s: %d mallas, %d pares comprobados" % [room_name, meshes.size(), checked])
	for overlap: String in overlaps:
		print("    SOLAPE: ", overlap)
	_fail("  [FALLO] %s: %d solapes" % [room_name, overlaps.size()], not overlaps.is_empty())
	if overlaps.is_empty():
		print("  [OK]    %s: sin solapes" % room_name)

	instance.queue_free()
	await get_tree().process_frame

## Grupos que no se comparan: son las superficies de apoyo.
func _is_ignored_group(group: String) -> bool:
	return group == "Floor" or group == "Ceiling"

## Recorre la jerarquía acumulando AABBs en coordenadas globales.
func _collect(node: Node, root: Node, meshes: Array[Dictionary]) -> void:
	for child: Node in node.get_children():
		if child is MeshInstance3D:
			var mesh_instance: MeshInstance3D = child as MeshInstance3D
			var mesh: Mesh = mesh_instance.mesh
			if mesh != null and not _is_ignored_path(String(mesh_instance.get_path())):
				meshes.append({
					"name": String(mesh_instance.get_path()).replace(String(root.get_path()) + "/", ""),
					"aabb": mesh_instance.global_transform * mesh.get_aabb(),
					"group": _group_of(mesh_instance),
				})
		_collect(child, root, meshes)

## ¿La ruta pertenece a un subárbol excluido del test?
func _is_ignored_path(path: String) -> bool:
	for part: String in IGNORED_PATH_PARTS:
		if path.contains(part):
			return true
	return false

## Agrupa por nombre base para no comparar copias del mismo asset entre sí.
func _group_of(node: MeshInstance3D) -> String:
	var path: String = String(node.get_path())
	if path.contains("/Floor/"):
		return "Floor"
	if path.contains("/Ceiling/"):
		return "Ceiling"
	var parts: PackedStringArray = String(node.name).split("_")
	if parts.size() > 1:
		return "_".join(parts.slice(0, parts.size() - 1))
	return String(node.name)

## Registra una comprobación y cuenta el fallo si no se cumple.
func _fail(label: String, failed: bool) -> void:
	if failed:
		print(label)
		_failures += 1
