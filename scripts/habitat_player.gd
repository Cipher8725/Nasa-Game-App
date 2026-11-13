class_name HabitatPlayer
extends CharacterBody3D

## Jugador controlable dentro del hábitat.
##
## Usa `CharacterBody3D` con `move_and_slide()` y una **cámara en primera
## persona** montada en la cabeza (nodo `Camera3D` de `scenes/player.tscn`).
## El mouse gira la vista: la guiñada (yaw) rota el cuerpo del jugador y el
## cabeceo (pitch) la cámara. La zona de interacción es un nodo estructural
## definido en la escena (prohibido crearlos en código).

@export_group("Movimiento")
## Velocidad máxima de desplazamiento horizontal (m/s).
@export var move_speed: float = 4.0
## Suavizado de aceleración: mayor valor = respuesta más inmediata.
@export var acceleration: float = 12.0
## Velocidad vertical del salto (m/s).
@export var jump_velocity: float = 4.5
## Gravedad aplicada hacia abajo (m/s²).
@export var gravity: float = 9.8

@export_group("Cámara")
## Sensibilidad del ratón en radianes por píxel.
@export var mouse_sensitivity: float = 0.0025
## Límite inferior del cabeceo (radianes).
@export var min_pitch: float = -1.2
## Límite superior del cabeceo (radianes).
@export var max_pitch: float = 1.0

@export_group("Interacción")
## Radio de detección de consolas (metros).
@export var interaction_radius: float = 2.5

@onready var _camera: Camera3D = %Camera3D
@onready var _interaction_area: Area3D = %InteractionArea
@onready var _interaction_shape: CollisionShape3D = %InteractionShape

## Consolas actualmente dentro del radio de interacción.
var _consoles_in_range: Array[ResourceConsole] = []
var _pitch: float = 0.0
## Indica si el jugador tiene el control (se desactiva al abrir un minijuego).
var _input_enabled: bool = true

func _ready() -> void:
	# El radio de interacción se define en el Inspector, se propaga a la esfera.
	var sphere: SphereShape3D = _interaction_shape.shape as SphereShape3D
	if sphere != null:
		sphere.radius = interaction_radius

	_interaction_area.area_entered.connect(_on_interaction_area_entered)
	_interaction_area.area_exited.connect(_on_interaction_area_exited)

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

## Habilita o deshabilita el control del jugador.
## Los minijuegos de reparación lo llaman para que el ratón quede libre.
func set_input_enabled(enabled: bool) -> void:
	_input_enabled = enabled
	if enabled:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

## ¿El jugador tiene el control habilitado?
func is_input_enabled() -> bool:
	return _input_enabled

func _unhandled_input(event: InputEvent) -> void:
	# `ui_cancel` es la acción por defecto de Escape.
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var motion: InputEventMouseMotion = event as InputEventMouseMotion
		# Guiñada: gira el cuerpo del jugador (y con él la cámara).
		rotate_y(-motion.relative.x * mouse_sensitivity)
		# Cabeceo: gira solo la cámara.
		_pitch = clampf(_pitch - motion.relative.y * mouse_sensitivity, min_pitch, max_pitch)
		_camera.rotation.x = _pitch

func _physics_process(delta: float) -> void:
	# Gravedad: se aplica siempre hacia abajo y se compensa con `is_on_floor()`.
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif velocity.y < 0.0:
		velocity.y = 0.0

	var input_direction: Vector2 = Vector2.ZERO
	if _input_enabled:
		input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var desired_direction: Vector3 = (transform.basis * Vector3(input_direction.x, 0.0, input_direction.y))
	desired_direction.y = 0.0

	if desired_direction.length_squared() > 0.0:
		desired_direction = desired_direction.normalized()
		velocity.x = move_toward(velocity.x, desired_direction.x * move_speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, desired_direction.z * move_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
		velocity.z = move_toward(velocity.z, 0.0, acceleration * delta)

	if _input_enabled and is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	move_and_slide()

func _unhandled_key_input(event: InputEvent) -> void:
	# Interacción con consolas: la tecla configurada repara el recurso.
	# Con un minijuego abierto el control está bloqueado y no se repara nada.
	if not _input_enabled:
		return
	if event.is_action_pressed("interact"):
		_repair_nearest_console()

## Repara el recurso de la consola más cercana dentro del radio de interacción.
## Si el recurso tiene minijuego, se abre en vez de reparar al instante.
func _repair_nearest_console() -> void:
	var target: ResourceConsole = _find_nearest_console()
	if target == null:
		return
	var manager: RepairMinigameManager = _get_minigame_manager()
	if manager != null and manager.has_minigame_for(target.resource_type):
		if manager.open_minigame(target):
			print("[Jugador] Minijuego de reparación abierto: %s" % target.display_name)
			return
	var amount: float = target.repair()
	if amount > 0.0:
		print("[Jugador] Reparación completada en %s (+%.0f)" % [target.display_name, amount])

## Devuelve el gestor de minijuegos (null si la escena no lo tiene).
func _get_minigame_manager() -> RepairMinigameManager:
	if not is_inside_tree():
		return null
	return get_tree().get_first_node_in_group("repair_minigames") as RepairMinigameManager

## Devuelve la consola más cercana al jugador, o null si no hay ninguna.
func _find_nearest_console() -> ResourceConsole:
	var nearest: ResourceConsole = null
	var nearest_distance: float = INF
	for console: ResourceConsole in _consoles_in_range:
		if not is_instance_valid(console):
			continue
		var distance: float = global_position.distance_to(console.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = console
	return nearest

## Consolas detectadas actualmente, para que la UI pueda informar al jugador.
func get_consoles_in_range() -> Array[ResourceConsole]:
	return _consoles_in_range

# --- Callbacks de señal ---

func _on_interaction_area_entered(area: Area3D) -> void:
	var console: ResourceConsole = area as ResourceConsole
	if console == null:
		return
	if not _consoles_in_range.has(console):
		_consoles_in_range.append(console)

func _on_interaction_area_exited(area: Area3D) -> void:
	var console: ResourceConsole = area as ResourceConsole
	if console == null:
		return
	_consoles_in_range.erase(console)
