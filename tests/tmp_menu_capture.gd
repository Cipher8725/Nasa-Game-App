extends Node

## TEMPORAL: capturas del menú principal y del suelo lunar. Se borra al usar.

const OUT_DIR: String = "C:/Users/Cesar/AppData/Local/Temp/opencode/shots_menu"

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	await _menu()
	await _game()
	print("[captura] listo")
	get_tree().quit(0)

func _menu() -> void:
	var menu: MainMenu = load("res://scenes/main_menu.tscn").instantiate() as MainMenu
	add_child(menu)
	await get_tree().process_frame
	await get_tree().process_frame
	await _shot("menu_01_inicio")

	var start_button: Button = menu.get_node("%StartButton") as Button
	start_button.pressed.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	await _shot("menu_02_niveles")

	menu.queue_free()
	await get_tree().process_frame

func _game() -> void:
	var main_scene: Node = load("res://scenes/main.tscn").instantiate()
	add_child(main_scene)
	await get_tree().process_frame
	await get_tree().process_frame
	var player: Node3D = get_tree().get_first_node_in_group("player") as Node3D
	var camera: Camera3D = player.get_node("Camera3D") as Camera3D
	player.global_position = Vector3(0, 0, 4)
	player.rotation.y = 0.0
	camera.rotation.x = 0.0
	camera.make_current()
	await _shot("menu_03_interior")

	player.rotation.y = 0.0
	camera.rotation.x = -0.85
	await _shot("menu_04_suelo")

func _shot(shot_name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	var path: String = "%s/%s.png" % [OUT_DIR, shot_name]
	image.save_png(path)
	print("[captura] ", path)
	await get_tree().process_frame
