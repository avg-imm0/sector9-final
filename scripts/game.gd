extends Node2D

## Root scene controller. Applies a pending save and opens the pause screen.
## Dialogue and the ending card consume Escape while they are open.

@onready var pause_menu: CanvasLayer = $PauseMenu


func _ready() -> void:
	GameState.in_run = true
	GameState.ui_blocked = false
	SaveGame.apply_pending_state()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	if key_event.physical_keycode == KEY_ESCAPE:
		if Dialogue.is_open or GameState.ui_blocked:
			return
		pause_menu.open()
		get_viewport().set_input_as_handled()
