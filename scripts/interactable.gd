class_name Interactable
extends Node2D

## Shared proximity prompt + "E" interaction logic.
## Scenes must contain a Label named "Prompt" and an Area2D named "Area".

@export var prompt_text := "E — взаимодействовать"
@export var prompt_offset := Vector2(0, -72)

@onready var prompt: Label = $Prompt
@onready var area: Area2D = $Area

var _player: Node2D = null
var _time := 0.0


func _ready() -> void:
	prompt.text = prompt_text
	prompt.position = prompt_offset
	prompt.visible = false
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	_setup()


func _setup() -> void:
	pass


func _update(_delta: float) -> void:
	pass


func _process(delta: float) -> void:
	_time += delta
	_refresh_prompt()
	if prompt.visible:
		prompt.position = Vector2(prompt_offset.x, prompt_offset.y + sin(_time * 2.5) * 2.0)
	_update(delta)


func can_interact() -> bool:
	return not Dialogue.is_open and not GameState.ui_blocked


func _refresh_prompt() -> void:
	prompt.visible = _player != null and can_interact()


func _unhandled_input(event: InputEvent) -> void:
	if _player == null or not can_interact():
		return
	if not (event is InputEventKey):
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	if key_event.physical_keycode == KEY_E:
		interact()
		get_viewport().set_input_as_handled()


func interact() -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player = body
		_refresh_prompt()


func _on_body_exited(body: Node2D) -> void:
	if body == _player:
		_player = null
		prompt.visible = false
