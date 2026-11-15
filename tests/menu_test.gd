extends Node

## Test del menú principal.
##
## Comprueba que el menú:
##  * es la escena de arranque del proyecto (`run/main_scene`),
##  * sigue el diseño "Nasa Space 2": Jugar, Biblioteca, Salir y Mi carnet,
##  * JUGAR abre y cierra el panel "Menú de juego",
##  * Base lunar, Armado del rover y Simulación de despegue llevan a escenas reales,
##  * Exploración lunar se muestra como "Próximamente".
##
## No pulsa el botón del nivel: cambiaría de escena y terminaría el test.

func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	_run()

func _run() -> void:
	var failures: int = 0

	# --- Escena de arranque ---
	var main_scene: String = str(ProjectSettings.get_setting("application/run/main_scene", ""))
	failures += _check("El juego arranca en el menú principal", main_scene == "res://scenes/main_menu.tscn")
	failures += _check("La escena del menú existe", ResourceLoader.exists(main_scene))

	# --- Instanciación ---
	var packed: PackedScene = load("res://scenes/main_menu.tscn") as PackedScene
	failures += _check("El menú se puede instanciar", packed != null)
	if packed == null:
		_finish(failures)
		return

	var menu: MainMenu = packed.instantiate() as MainMenu
	failures += _check("La escena tiene el script MainMenu", menu != null)
	if menu == null:
		_finish(failures)
		return
	add_child(menu)
	await get_tree().process_frame

	# --- Pantalla de inicio (diseño "Nasa Space 2") ---
	var title: Label = menu.get_node_or_null("%Title") as Label
	failures += _check("El título del juego está presente", title != null and not title.text.is_empty())
	failures += _check("El menú arranca con el panel de juego cerrado", not menu.is_level_panel_visible())
	for button_name: String in ["StartButton", "LibraryButton", "QuitButton", "CardButton"]:
		var b: BaseButton = menu.get_node_or_null("%" + button_name) as BaseButton
		failures += _check("Botón %s presente y activo" % button_name, b != null and not b.disabled)
	var start_button: BaseButton = menu.get_node("%StartButton") as BaseButton
	var start_tex: TextureButton = start_button as TextureButton
	failures += _check("JUGAR usa la imagen del diseño", start_tex != null and start_tex.texture_normal != null)

	# --- Panel "Menú de juego" ---
	start_button.pressed.emit()
	await get_tree().process_frame
	failures += _check("JUGAR abre el panel Menú de juego", menu.is_level_panel_visible())
	for button_name: String in ["MoonButton", "WorkshopButton", "LaunchButton"]:
		var b: BaseButton = menu.get_node_or_null("%" + button_name) as BaseButton
		failures += _check("Actividad %s disponible" % button_name, b != null and not b.disabled)
	failures += _check("Exploración lunar aparece como Próximamente", (menu.get_node("%ExplorationButton") as BaseButton).disabled and not menu.is_exploration_available())
	failures += _check("La base lunar apunta a una escena real", ResourceLoader.exists(menu.get_moon_level_path()))
	for path: String in [MainMenu.WORKSHOP_SCENE, MainMenu.CARD_SCENE, MainMenu.LIBRARY_SCENE, MainMenu.LAUNCH_SCENE]:
		failures += _check("Existe la escena %s" % path, ResourceLoader.exists(path))
	# Las posiciones siguen la maqueta de 1280 x 720.
	var launch_button: Control = menu.get_node("%LaunchButton") as Control
	failures += _check("Simulación de despegue en su posición de la maqueta", launch_button.position.is_equal_approx(Vector2(501, 377)))

	# --- Cerrar ---
	start_button.pressed.emit()
	await get_tree().process_frame
	failures += _check("JUGAR otra vez cierra el panel", not menu.is_level_panel_visible())

	_finish(failures)

func _finish(failures: int) -> void:
	print("=== RESULTADO MENU: %s ===" % ("TODO OK" if failures == 0 else "%d FALLOS" % failures))
	get_tree().quit(0 if failures == 0 else 1)

func _check(label: String, condition: bool) -> int:
	if condition:
		print("  [OK]   ", label)
		return 0
	print("  [FALLO] ", label)
	return 1
