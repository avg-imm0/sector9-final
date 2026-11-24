extends Interactable

## Backroom door behind the kiosk. It needs power and the key from Grisha.
## The monitor inside ends the chapter with one of two final choices.

@onready var sprite: Sprite2D = $Sprite
@onready var led: Sprite2D = $Led

var _awaiting_ending := false
var _glow: Sprite2D


func _setup() -> void:
	Dialogue.dialogue_finished.connect(_on_dialogue_finished)
	Dialogue.dialogue_started.connect(_on_dialogue_started)
	# Soft light spilling around the door once the sector has power.
	_glow = Sprite2D.new()
	_glow.texture = preload("res://assets/textures/glow.svg")
	_glow.position = Vector2(0, 10)
	_glow.scale = Vector2(0.95, 0.75)
	_glow.z_index = -2
	_glow.modulate = Color(1, 1, 1, 0)
	add_child(_glow)


func _update(delta: float) -> void:
	if GameState.power_on:
		led.modulate = Color(0.45, 1.0, 0.55, 0.75 + sin(_time * 3.0) * 0.2)
		sprite.modulate = Color(1.0, 1.0, 1.0)
		_glow.modulate = Color(0.35, 1.0, 0.6, 0.3 + sin(_time * 2.2) * 0.08)
	else:
		led.modulate = Color(0.9, 0.2, 0.15, 0.35)
		sprite.modulate = Color(0.78, 0.8, 0.84)
		_glow.modulate = Color(1, 0.4, 0.3, 0)

	if GameState.has_key and can_interact():
		prompt_text = "E — открыть подсобку"
	else:
		prompt_text = "E — осмотреть дверь"
	prompt.text = prompt_text


func interact() -> void:
	if not GameState.power_on:
		Dialogue.start("backroom_locked")
		return
	if not GameState.has_key:
		Dialogue.start("backroom_no_key")
		return
	_awaiting_ending = true
	Audio.play_breaker()
	Dialogue.start("backroom")


func _on_dialogue_started() -> void:
	if Dialogue.current_id != "monitor":
		return
	GameState.chapter = "Подсобка"
	GameState.story_flags["monitor_seen"] = true
	GameState.set_objective("Решить судьбу сектора")
	Audio.play_static()


func _on_dialogue_finished() -> void:
	if not _awaiting_ending:
		return
	var last := Dialogue.last_finished_id
	_awaiting_ending = false
	if last != "final_keep" and last != "final_release":
		return
	var ending := get_tree().get_first_node_in_group("ending")
	if ending != null:
		ending.call("show_ending", "keep" if last == "final_keep" else "release")
