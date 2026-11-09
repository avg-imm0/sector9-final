extends Interactable

## Backroom door behind the kiosk. It needs power and the key from Grisha.
## Finishing the final dialogue hands control to the ending card.

@onready var sprite: Sprite2D = $Sprite
@onready var led: Sprite2D = $Led

var _awaiting_ending := false


func _setup() -> void:
	Dialogue.dialogue_finished.connect(_on_dialogue_finished)


func _update(delta: float) -> void:
	if GameState.power_on:
		led.modulate = Color(0.45, 1.0, 0.55, 0.75 + sin(_time * 3.0) * 0.2)
		sprite.modulate = Color(1.0, 1.0, 1.0)
	else:
		led.modulate = Color(0.9, 0.2, 0.15, 0.35)
		sprite.modulate = Color(0.78, 0.8, 0.84)

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


func _on_dialogue_finished() -> void:
	if not _awaiting_ending:
		return
	_awaiting_ending = false
	var ending := get_tree().get_first_node_in_group("ending")
	if ending != null:
		ending.call("show_ending")
