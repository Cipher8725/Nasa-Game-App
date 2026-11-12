extends Node

## Test de colisiones de assets: comprueba que los modelos 3D colocados en el
## hábitat no se solapen entre sí de forma significativa.
##
## Se ignoran:
##  - Las copias del mismo asset (tejas, paredes repetidas).
##  - Los contactos con el SUELO: los objetos se apoyan sobre las baldosas y
##    sus AABB intersectan ligeramente la baldosa. Es geometría correcta, no
##    una mala colocación. Solo se comprueba asset↔asset y asset↔pared.
##  - Los contactos de borde (volumen < 0,05 m³).

## Volumen mínimo (m³) para considerar que un solape es un error real.
const MIN_OVERLAP_VOLUME: float = 0.05

var _meshes: Array[Dictionary] = []
var _real_overlaps: Array[String] = []

func _ready() -> void:
	await get_tree().process_frame
	_run()

func _run() -> void:
	var packed: PackedScene = load("res://scenes/habitat.tscn") as PackedScene
	var instance: Node = packed.instantiate()
	add_child(instance)

	_collect(instance, instance)
	print("Mallas en la escena: ", _meshes.size())

	var checked: int = 0
	for i: int in range(_meshes.size()):
		for j: int in range(i + 1, _meshes.size()):
			var a: Dictionary = _meshes[i]
			var b: Dictionary = _meshes[j]
			if String(a["group"]) == String(b["group"]):
				continue
			# El suelo es la base: los objetos se apoyan sobre las baldosas.
			if String(a["group"]) == "Floor" or String(b["group"]) == "Floor":
				continue
			checked += 1
			var intersection: AABB = a["aabb"].intersection(b["aabb"])
			if intersection.get_volume() >= MIN_OVERLAP_VOLUME:
				_real_overlaps.append("%s <-> %s (%.3f m3)" % [
					a["name"], b["name"], intersection.get_volume()])
	print("Pares comprobados: ", checked)
	print("Solapes significativos (>= %.2f m3): %d" % [MIN_OVERLAP_VOLUME, _real_overlaps.size()])
	for overlap: String in _real_overlaps:
		print("  SOLAPE: ", overlap)

	var failures: int = 0
	if _real_overlaps.is_empty():
		print("  [OK]   Ningun asset se solapa con otro")
	else:
		print("  [FALLO] %d assets mal colocados" % _real_overlaps.size())
		failures = 1
	print("=== RESULTADO COLISIONES: %s ===" % ("TODO OK" if failures == 0 else "FALLOS"))
	get_tree().quit(failures)

## Recorre la jerarquia acumulando AABBs en coordenadas globales.
func _collect(node: Node, root: Node) -> void:
	for child: Node in node.get_children():
		if child is MeshInstance3D:
			var mesh_instance: MeshInstance3D = child as MeshInstance3D
			var mesh: Mesh = mesh_instance.mesh
			if mesh != null:
				var path: String = String(mesh_instance.get_path())
				_meshes.append({
					"name": path.replace(String(root.get_path()) + "/", ""),
					"aabb": mesh_instance.global_transform * mesh.get_aabb(),
					"group": _group_of(mesh_instance, path),
				})
		_collect(child, root)

## Agrupa por nombre base para no comparar copias del mismo asset entre si.
## Las baldosas del suelo comparten grupo "Floor" (se apoyan encima los objetos).
func _group_of(node: MeshInstance3D, path: String) -> String:
	# Las baldosas viven bajo el nodo "FloorTiles" de la escena de decoracion.
	if path.contains("FloorTiles"):
		return "Floor"
	var n: String = node.name
	var parts: PackedStringArray = n.split("_")
	if parts.size() > 1:
		return "_".join(parts.slice(0, parts.size() - 1))
	return n
