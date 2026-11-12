class_name RepairGauge
extends Control

## Barra de presión del minijuego de oxígeno.
##
## Se dibuja a mano con `_draw()` para poder representar la zona buena y la
## aguja sin montar una jerarquía de nodos para cada pieza.

var _needle: float = 0.5
var _target_center: float = 0.5
var _target_width: float = 0.16
var _flash: float = 0.0
var _flash_color: Color = Color(0, 0, 0, 0)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

## Actualiza la posición de la aguja y de la zona buena.
func set_state(needle: float, target_center: float, target_width: float) -> void:
	_needle = needle
	_target_center = target_center
	_target_width = target_width
	queue_redraw()

## Destello verde: pulsación acertada.
func flash_hit() -> void:
	_flash = 1.0
	_flash_color = Color(0.35, 0.95, 0.5, 0.5)
	queue_redraw()

## Destello rojo: pulsación fallida.
func flash_miss() -> void:
	_flash = 1.0
	_flash_color = Color(0.95, 0.35, 0.3, 0.5)
	queue_redraw()

func _process(delta: float) -> void:
	if _flash <= 0.0:
		return
	_flash = maxf(0.0, _flash - delta * 2.5)
	queue_redraw()

func _draw() -> void:
	var track: Rect2 = Rect2(Vector2.ZERO, size)
	# Fondo de la barra.
	draw_rect(track, Color(0.07, 0.09, 0.15, 0.95))
	# Zona buena (verde).
	var zone: Rect2 = Rect2(
		Vector2((_target_center - _target_width * 0.5) * size.x, 0.0),
		Vector2(_target_width * size.x, size.y))
	draw_rect(zone, Color(0.25, 0.8, 0.45, 0.45))
	# Marco.
	draw_rect(track, Color(0.35, 0.55, 0.8, 0.8), false, 2.0)
	# Aguja.
	var needle_x: float = _needle * size.x
	draw_line(Vector2(needle_x, 0.0), Vector2(needle_x, size.y), Color(1.0, 0.85, 0.25), 4.0)
	# Destello del último intento.
	if _flash > 0.0:
		var flash: Color = _flash_color
		flash.a *= _flash
		draw_rect(track, flash)
