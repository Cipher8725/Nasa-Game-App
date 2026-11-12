class_name ResourceConsole
extends Area3D

## Consola de control del hábitat.
##
## Cada consola está asociada a un recurso vital (oxígeno, energía, agua o
## estructura). El jugador se acerca y la repara con la acción "interact".
##
## El modelo 3D (`command_console.glb`) y su etiqueta están definidos en
## `scenes/console.tscn`; este script solo aporta el color por recurso.

## Recurso que repara esta consola.
@export var resource_type: StringName = &"oxygen"
## Nombre legible que se muestra en la interfaz.
@export var display_name: String = "OXÍGENO"
## Color representativo del recurso (aplicado a la luz de la consola).
@export var console_color: Color = Color(0.20, 0.60, 0.90)

@onready var _light: OmniLight3D = %ConsoleLight
@onready var _label: Label3D = %ConsoleLabel
@onready var _game: GameManager = GameManager.get_instance()

func _ready() -> void:
	_apply_appearance()

## Repara el recurso de esta consola. Devuelve la cantidad restaurada.
func repair() -> float:
	return _game.restore_resource(resource_type, _game.config.console_restore_amount)

## Aplica el color configurado a la luz de la consola y actualiza su etiqueta.
func _apply_appearance() -> void:
	_light.light_color = console_color
	_label.text = display_name
	_label.modulate = console_color
