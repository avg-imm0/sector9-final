extends Node

## Renders a few frames and dumps screenshots to user:// for visual review.
## Run without --headless:
##   godot --path . res://tests/screenshot_test.tscn

var _main: Node


func _ready() -> void:
	SaveGame.autosave_enabled = false
	var menu: Node = load("res://scenes/main_menu.tscn").instantiate()
	add_child(menu)
	await get_tree().create_timer(1.2).timeout
	await _capture("menu")
	menu.call("open_settings")
	await get_tree().create_timer(0.3).timeout
	await _capture("settings")
	menu.call("close_overlays")
	await get_tree().process_frame
	menu.call("open_load")
	await get_tree().create_timer(0.3).timeout
	await _capture("saves")
	menu.queue_free()
	await get_tree().process_frame

	_main = load("res://scenes/main.tscn").instantiate()
	add_child(_main)
	Input.warp_mouse(Vector2(700, 250))
	await get_tree().create_timer(1.2).timeout

	_main.get_node("HUD").visible = false
	await _capture("menu_bg")
	_main.get_node("HUD").visible = true

	await _capture("world")

	var pause: Node = _main.get_node("PauseMenu")
	pause.open()
	await get_tree().create_timer(0.3).timeout
	await _capture("pause")
	pause.close()
	await get_tree().create_timer(0.2).timeout

	Dialogue.start("intro")
	Dialogue._advance()
	Dialogue._advance()
	Dialogue._advance()
	Dialogue._advance()
	Dialogue._advance()
	await get_tree().create_timer(0.45).timeout
	await _capture("dialogue")

	Dialogue.close()
	var panel: Node = _main.get_node("World/Panel")
	panel.interact()
	await get_tree().create_timer(0.3).timeout
	await _capture("puzzle")

	panel._press(2)
	panel._press(3)
	panel._press(1)
	await get_tree().create_timer(1.7).timeout
	await _capture("powered")

	var ending: Node = _main.get_node("Ending")
	ending.show_ending()
	await get_tree().create_timer(0.6).timeout
	await _capture("ending")

	ending.hide_ending()
	ending.show_ending("release")
	await get_tree().create_timer(0.6).timeout
	await _capture("ending_release")

	get_tree().quit()


func _capture(shot_name: String) -> void:
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var path := "user://%s.png" % shot_name
	var error := image.save_png(path)
	print("SHOT %s -> %s (error=%d)" % [shot_name, ProjectSettings.globalize_path(path), error])
