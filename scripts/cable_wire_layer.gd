class_name CableWireLayer
extends Control

## Capa de dibujo de los cables del minijuego de energía.
##
## Recibe las conexiones realizadas y dibuja una línea por cada cable unido.
## Está detrás de los botones para que las líneas parezcan salir de ellos.

var _connections: Array[Dictionary] = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

## Sustituye el conjunto de líneas dibujadas.
func set_connections(connections: Array[Dictionary]) -> void:
	_connections = connections
	queue_redraw()

## Borra todas las líneas.
func clear_connections() -> void:
	_connections.clear()
	queue_redraw()

func _draw() -> void:
	for connection: Dictionary in _connections:
		var from: Vector2 = connection["from"]
		var to: Vector2 = connection["to"]
		var color: Color = connection["color"]
		draw_line(from, to, color, 4.0)
		draw_circle(from, 5.0, color)
		draw_circle(to, 5.0, color)
