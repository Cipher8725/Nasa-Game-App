extends Node

## Test del menú principal.
##
## Comprueba que el menú:
##  * es la escena de arranque del proyecto (`run/main_scene`),
##  * arranca en la pantalla de inicio con el selector de destino cerrado,
##  * abre el selector con "INICIAR MISIÓN" y lo cierra con "VOLVER",
##  * ofrece el nivel de la Luna (ruta válida) y deja Marte desactivado.
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

	# --- Pantalla de inicio ---
	var title: Label = menu.get_node_or_null("Layout/Title") as Label
	failures += _check("El título del juego está presente", title != null and not title.text.is_empty())
	failures += _check("El menú arranca en la pantalla de inicio", not menu.is_level_panel_visible())

	var start_button: Button = menu.get_node("%StartButton") as Button
	var back_button: Button = menu.get_node("%BackButton") as Button
	failures += _check("El botón de inicio está habilitado", start_button != null and not start_button.disabled)

	# --- Selector de destino ---
	start_button.pressed.emit()
	await get_tree().process_frame
	failures += _check("INICIAR MISIÓN abre el selector de destino", menu.is_level_panel_visible())

	var moon_button: Button = menu.get_node("%MoonButton") as Button
	var mars_button: Button = menu.get_node("%MarsButton") as Button
	failures += _check("El nivel de la Luna está disponible", moon_button != null and not moon_button.disabled)
	failures += _check("El nivel de Marte está bloqueado por ahora", mars_button != null and mars_button.disabled)
	failures += _check("El nivel de la Luna apunta a una escena real", ResourceLoader.exists(menu.get_moon_level_path()))
	failures += _check("Solo hay un nivel jugable", not menu.is_mars_available())

	# --- Volver ---
	back_button.pressed.emit()
	await get_tree().process_frame
	failures += _check("VOLVER cierra el selector de destino", not menu.is_level_panel_visible())

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
