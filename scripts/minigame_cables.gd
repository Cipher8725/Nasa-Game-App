class_name CableRepairMinigame
extends RepairMinigame

## Minijuego de reparación de la energía: conectar cables.
##
## A la izquierda hay cuatro cables de colores distintos y a la derecha cuatro
## conectores desordenados. El jugador pulsa un cable y después el conector
## que lleva su misma letra. Cada acierto enciende una línea; un error cuesta
## tiempo y presión.

## Número de cables que hay que conectar.
const CABLE_COUNT: int = 4

## Color, letra y nombre de cada cable.
const CABLE_STYLE: Array[Dictionary] = [
	{"color": Color(0.90, 0.25, 0.25), "letter": "A", "name": "ROJO"},
	{"color": Color(0.25, 0.55, 0.95), "letter": "B", "name": "AZUL"},
	{"color": Color(0.30, 0.85, 0.40), "letter": "C", "name": "VERDE"},
	{"color": Color(0.95, 0.80, 0.25), "letter": "D", "name": "AMARILLO"},
]

## Segundos que se restan por una conexión incorrecta.
@export var wrong_time_penalty: float = 2.0
## Progreso que se pierde por una conexión incorrecta.
@export var wrong_progress_penalty: float = 0.1
## Segundos que se ganan por cada conexión correcta.
@export var correct_time_bonus: float = 1.0

@onready var _wire_layer: CableWireLayer = %WireLayer
@onready var _title: Label = %TitleLabel

var _cable_buttons: Array[Button] = []
var _socket_buttons: Array[Button] = []
var _socket_order: Array[int] = [0, 1, 2, 3]
var _connected: Array[bool] = [false, false, false, false]
var _selected_cable: int = -1

func _ready() -> void:
	super._ready()
	_cable_buttons = [%CableA as Button, %CableB as Button, %CableC as Button, %CableD as Button]
	_socket_buttons = [%SocketA as Button, %SocketB as Button, %SocketC as Button, %SocketD as Button]
	for index: int in range(CABLE_COUNT):
		_cable_buttons[index].pressed.connect(press_cable.bind(index))
		_socket_buttons[index].pressed.connect(press_socket.bind(index))

func _setup() -> void:
	_title.text = "REPARACIÓN DE ENERGÍA"
	_shuffle_sockets()
	_set_status("Selecciona un cable y después su conector.")

func _update_visuals(_delta: float) -> void:
	pass

# --- API pública ---

## Selecciona un cable (índice 0..3). Un segundo clic lo deselecciona.
func press_cable(index: int) -> void:
	if not is_running() or index < 0 or index >= CABLE_COUNT:
		return
	if _connected[index]:
		return
	_selected_cable = index
	for i: int in range(CABLE_COUNT):
		_cable_buttons[i].modulate = Color(1.6, 1.6, 1.6) if i == index else Color(1, 1, 1)
	_set_status("Cable %s seleccionado: busca su conector." % String(CABLE_STYLE[index]["letter"]))

## Pulsa un conector (índice 0..3) y comprueba si corresponde al cable elegido.
func press_socket(index: int) -> void:
	if not is_running() or index < 0 or index >= CABLE_COUNT:
		return
	# Un conector ya usado no se puede volver a conectar.
	if _connected[_socket_order[index]]:
		return
	if _selected_cable < 0:
		_set_status("Primero selecciona un cable.")
		return
	if _socket_order[index] == _selected_cable:
		_connect_cable(_selected_cable, index)
	else:
		_fail_connection()

## Orden de los conectores: `get_socket_order()[posicion]` es el cable que
## le corresponde al conector de esa posición.
func get_socket_order() -> Array[int]:
	var copy: Array[int] = []
	for cable_index: int in _socket_order:
		copy.append(cable_index)
	return copy

## Número de cables ya conectados.
func get_connected_count() -> int:
	var total: int = 0
	for done: bool in _connected:
		if done:
			total += 1
	return total

## Cable seleccionado actualmente (-1 si no hay ninguno).
func get_selected_cable() -> int:
	return _selected_cable

# --- Métodos privados ---

## Baraja los conectores y reinicia el estado de las líneas.
func _shuffle_sockets() -> void:
	_socket_order = [0, 1, 2, 3]
	_socket_order.shuffle()
	_connected = [false, false, false, false]
	_selected_cable = -1
	for position: int in range(CABLE_COUNT):
		var cable_index: int = _socket_order[position]
		_socket_buttons[position].text = String(CABLE_STYLE[cable_index]["letter"])
		_socket_buttons[position].disabled = false
		_socket_buttons[position].modulate = Color(1, 1, 1)
		_cable_buttons[cable_index].disabled = false
		_cable_buttons[cable_index].modulate = Color(1, 1, 1)
	_wire_layer.clear_connections()

## Conexión correcta: enciende la línea y suma progreso.
func _connect_cable(cable_index: int, socket_index: int) -> void:
	_connected[cable_index] = true
	# No se desactiva el botón: el estilo "disabled" del tema ocultaría el color
	# del cable. La conexión ya usada se ignora en `press_cable`/`press_socket`.
	_cable_buttons[cable_index].modulate = Color(1.35, 1.8, 1.35)
	_socket_buttons[socket_index].modulate = Color(0.75, 1.7, 0.85)
	_selected_cable = -1
	set_progress(get_progress() + 1.0 / float(CABLE_COUNT))
	add_time(correct_time_bonus)
	_refresh_wires()
	_set_status("¡Línea %s conectada!  (%d%%)" % [
		String(CABLE_STYLE[cable_index]["letter"]), roundi(get_progress() * 100.0)])
	if get_progress() >= 1.0:
		_succeed("Circuito eléctrico restablecido.")

## Conexión incorrecta: penaliza el tiempo y la presión.
func _fail_connection() -> void:
	_selected_cable = -1
	for i: int in range(CABLE_COUNT):
		_cable_buttons[i].modulate = Color(1, 1, 1)
	set_progress(maxf(0.0, get_progress() - wrong_progress_penalty))
	remove_time(wrong_time_penalty)
	_set_status("¡Conexión incorrecta!  -%.1f s" % wrong_time_penalty)

## Redibuja las líneas de los cables ya conectados.
func _refresh_wires() -> void:
	var connections: Array[Dictionary] = []
	for cable_index: int in range(CABLE_COUNT):
		if not _connected[cable_index]:
			continue
		var socket_position: int = _socket_order.find(cable_index)
		if socket_position < 0:
			continue
		connections.append({
			"from": _edge_point(_cable_buttons[cable_index], true),
			"to": _edge_point(_socket_buttons[socket_position], false),
			"color": CABLE_STYLE[cable_index]["color"],
		})
	_wire_layer.set_connections(connections)

## Calcula el punto de salida de un cable o de entrada de un conector,
## en coordenadas locales de la capa de cables.
func _edge_point(button: Button, from_cable: bool) -> Vector2:
	var inverse: Transform2D = _wire_layer.get_global_transform().affine_inverse()
	var center: Vector2 = inverse * button.get_global_rect().get_center()
	var half_width: float = button.size.x * 0.5
	var offset: float = half_width if from_cable else -half_width
	return Vector2(center.x + offset, center.y)
