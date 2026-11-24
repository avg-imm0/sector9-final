extends Node2D

## Root scene controller. Applies a pending save and opens the pause screen.
## Dialogue and the ending card consume Escape while they are open.

@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var grade: CanvasModulate = $CanvasModulate


func _ready() -> void:
	GameState.in_run = true
	GameState.ui_blocked = false
	SaveGame.apply_pending_state()
	_apply_grade(GameState.power_on, true)
	GameState.power_restored.connect(_on_power_restored)


func _on_power_restored() -> void:
	_apply_grade(true, false)


## Cold, dim courtyard before the power; slightly warmer and brighter after.
func _apply_grade(powered: bool, instant: bool) -> void:
	var target := Color(0.74, 0.77, 0.86, 1.0) if powered else Color(0.68, 0.72, 0.84, 1.0)
	if grade == null:
		return
	if instant:
		grade.color = target
		return
	var tween := create_tween()
	tween.tween_property(grade, "color", target, 1.2)


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
