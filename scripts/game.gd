extends Node2D

## Root scene controller. UI screens consume Escape while they are open,
## so this only fires for unhandled presses and closes the game.


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var key_event := event as InputEventKey
	if key_event.pressed and not key_event.echo and key_event.physical_keycode == KEY_ESCAPE:
		get_tree().quit()
