class_name Habitat
extends Node3D

## Estructura del hábitat espacial.
##
## Expone las consolas de control para que el jugador pueda repararlas.
## La geometría (suelo, paredes, consolas) vive íntegra en `scenes/habitat.tscn`:
## este script solo aporta comportamiento.

@onready var _consoles: Array[ResourceConsole] = _collect_consoles()

func _ready() -> void:
	# Cada consola se registra en el grupo "consoles" para poder localizarlas
	# desde otros sistemas sin acoplar la jerarquía de nodos.
	for console: ResourceConsole in _consoles:
		console.add_to_group("consoles")

## Devuelve todas las consolas del hábitat.
## Se devuelve una copia para evitar que el llamante modifique el estado interno.
func get_consoles() -> Array[ResourceConsole]:
	var copy: Array[ResourceConsole] = []
	for console: ResourceConsole in _consoles:
		copy.append(console)
	return copy

## Recorre la jerarquía en busca de nodos `ResourceConsole`.
func _collect_consoles() -> Array[ResourceConsole]:
	var found: Array[ResourceConsole] = []
	_collect_consoles_recursive(self, found)
	return found

## Búsqueda recursiva de consolas en los hijos de un nodo.
func _collect_consoles_recursive(node: Node, found: Array[ResourceConsole]) -> void:
	for child: Node in node.get_children():
		var console: ResourceConsole = child as ResourceConsole
		if console != null:
			found.append(console)
		_collect_consoles_recursive(child, found)
