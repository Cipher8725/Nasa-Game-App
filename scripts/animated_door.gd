class_name AnimatedDoor
extends StaticBody3D

## Puerta que se abre sola cuando el jugador se acerca y se cierra al alejarse.
##
## La escena `scenes/DoorAnim.tscn` trae las dos hojas, el `AnimationPlayer` y
## la animación "Open". Este script decide cuándo se reproduce y en qué
## sentido: mide la distancia horizontal al jugador (grupo "player") y abre o
## cierra en consecuencia.
##
## El cierre es la misma animación reproducida al revés (velocidad negativa en
## la llamada a `play`). Así no hay dos animaciones que mantener sincronizadas
## y, si el jugador se va justo cuando la puerta se estaba abriendo, la puerta
## sigue su camino sin saltos.
##
## La puerta no lleva colisión: se abre antes de que el jugador llegue, así
## que nunca le cierra el paso (ni bloquea el test de accesibilidad).

## Distancia horizontal (m) a la que el jugador hace que la puerta se abra.
@export_range(0.5, 12.0, 0.1) var open_distance: float = 3.5
## Animación que abre la puerta (y la cierra, reproducida en reversa).
@export var open_animation: StringName = &"Open"

@onready var _animation: AnimationPlayer = %AnimationPlayer

## Estado actual de la puerta: true = abierta, false = cerrada.
var _is_open: bool = false

func _ready() -> void:
	# La puerta arranca cerrada: las hojas ya están en su sitio en la escena.
	_is_open = false

func _process(_delta: float) -> void:
	var player: Node3D = _find_player()
	if player == null:
		return
	# Distancia en horizontal: el jugador siempre está a ras de suelo.
	var offset: Vector3 = player.global_position - global_position
	offset.y = 0.0
	var should_be_open: bool = offset.length() <= open_distance
	# Solo se actúa cuando cambia el estado: reiniciar la animación cada
	# fotograma la dejaría clavada a mitad de camino.
	if should_be_open == _is_open:
		return
	_is_open = should_be_open
	_play(should_be_open)

## Reproduce la animación hacia el lado pedido (abrir o cerrar) sin saltos.
func _play(should_be_open: bool) -> void:
	var animation: Animation = _animation.get_animation(open_animation)
	if animation == null or animation.length <= 0.0:
		return
	# Posición actual dentro de la animación (0 = cerrada, longitud = abierta).
	var position: float = 0.0
	if _animation.current_animation == open_animation:
		position = _animation.current_animation_position
	# La velocidad va en la propia llamada a `play`: en Godot 4.7 hace falta
	# pasarla explícitamente para que la animación vuelva a reproducirse
	# cuando ya había terminado. El sentido negativo la cierra en reversa.
	_animation.play(open_animation, 0.0, 1.0 if should_be_open else -1.0, false)
	_animation.seek(position, true)

## Jugador de la partida, o null si la escena se abre sin jugador (por
## ejemplo, en la previsualización de módulos de `scenes/rooms/`).
func _find_player() -> Node3D:
	if not is_inside_tree():
		return null
	return get_tree().get_first_node_in_group("player") as Node3D
