class_name OxygenRepairMinigame
extends RepairMinigame

## Minijuego de reparación del oxígeno: purga de presión.
##
## Una aguja recorre una barra de presión y el jugador debe pulsar el botón
## (con el ratón o con ESPACIO) mientras la aguja está dentro de la zona verde.
## Cada pulsación acertada llena la presión; fallar cuesta tiempo y presión.

## Presión que gana cada pulsación acertada (fracción de 0.0 a 1.0).
@export var pressure_per_hit: float = 0.25
## Presión que se pierde al fallar.
@export var pressure_per_miss: float = 0.08
## Segundos que se restan al fallar.
@export var miss_time_penalty: float = 1.5
## Segundos que se ganan al acertar.
@export var hit_time_bonus: float = 0.4
## Recorridos de la aguja por segundo.
@export var needle_speed: float = 0.6
## Ancho inicial de la zona buena (fracción de la barra).
@export var target_width: float = 0.16
## Ancho mínimo de la zona buena al avanzar la reparación.
@export var min_target_width: float = 0.07
## Margen respecto a los extremos para colocar la zona buena.
@export var target_margin: float = 0.12

@onready var _gauge: RepairGauge = %Gauge
@onready var _button: Button = %RepairButton
@onready var _title: Label = %TitleLabel

var _needle: float = 0.0
var _direction: float = 1.0
var _target_center: float = 0.5
var _hits: int = 0
var _misses: int = 0

func _ready() -> void:
	super._ready()
	_button.pressed.connect(press_button)
	# El foco del botón desactivado evita que ESPACIO lo active por duplicado.
	_button.focus_mode = Control.FOCUS_NONE
	_randomize_target()

func _setup() -> void:
	_title.text = "REPARACIÓN DE OXÍGENO"
	_set_status("Pulsa el botón cuando la aguja esté en la zona verde.")
	_refresh_hud()

func _update_visuals(delta: float) -> void:
	_needle += _direction * needle_speed * delta
	if _needle >= 1.0:
		_needle = 1.0
		_direction = -1.0
	elif _needle <= 0.0:
		_needle = 0.0
		_direction = 1.0
	_gauge.set_state(_needle, _target_center, target_width)

func _handle_action_input(event: InputEvent) -> void:
	# ESPACIO (y ENTER) hacen lo mismo que el botón.
	if event.is_action_pressed("ui_accept"):
		press_button()
		get_viewport().set_input_as_handled()

## Pulsa el botón de purga. Es la acción principal del minijuego.
func press_button() -> void:
	if not is_running():
		return
	if absf(_needle - _target_center) <= target_width * 0.5:
		_hits += 1
		set_progress(get_progress() + pressure_per_hit)
		add_time(hit_time_bonus)
		_gauge.flash_hit()
		_set_status("¡PULSO CORRECTO!  (%d%%)" % roundi(get_progress() * 100.0))
		_shrink_target()
		if get_progress() >= 1.0:
			_succeed("Sistema de oxígeno restablecido.")
	else:
		_misses += 1
		set_progress(maxf(0.0, get_progress() - pressure_per_miss))
		remove_time(miss_time_penalty)
		_gauge.flash_miss()
		_set_status("¡Fuera de zona!  -%.1f s" % miss_time_penalty)

# --- API pública ---

## Posición actual de la aguja, de 0.0 a 1.0.
func get_needle() -> float:
	return _needle

## Fija la posición de la aguja (usado por las pruebas).
func set_needle(value: float) -> void:
	_needle = clampf(value, 0.0, 1.0)
	_gauge.set_state(_needle, _target_center, target_width)

## Centro de la zona buena, de 0.0 a 1.0.
func get_target_center() -> float:
	return _target_center

## Número de pulsaciones acertadas.
func get_hits() -> int:
	return _hits

## Número de pulsaciones fallidas.
func get_misses() -> int:
	return _misses

# --- Métodos privados ---

## Coloca la zona buena en una posición aleatoria válida.
func _randomize_target() -> void:
	var half: float = target_width * 0.5
	var minimum: float = half + target_margin
	var maximum: float = 1.0 - half - target_margin
	if maximum <= minimum:
		maximum = minimum
	_target_center = randf_range(minimum, maximum)

## La zona buena se estrecha a medida que avanza la reparación.
func _shrink_target() -> void:
	target_width = maxf(min_target_width, target_width - 0.015)
	_randomize_target()
