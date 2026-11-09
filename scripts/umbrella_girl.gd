extends Interactable

## The woman with the umbrella. She is pure atmosphere and a soft hint source;
## her dialogue changes once the courtyard has power again.

@onready var sprite: Sprite2D = $Sprite

var _time_local := 0.0


func _update(delta: float) -> void:
	_time_local += delta
	sprite.rotation = sin(_time_local * 0.9) * 0.02
	sprite.position.y = sin(_time_local * 1.2) * 0.7


func interact() -> void:
	Dialogue.start("girl_powered" if GameState.power_on else "girl")
