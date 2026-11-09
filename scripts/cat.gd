extends Interactable

## The accountant cat. A small optional conversation that rewards curiosity
## and reacts to whether the power is back on.

@onready var sprite: Sprite2D = $Sprite

var _tail_time := 0.0


func _update(delta: float) -> void:
	_tail_time += delta
	sprite.rotation = sin(_tail_time * 2.1) * 0.045
	sprite.position.y = sin(_tail_time * 1.4) * 0.8
	if GameState.power_on:
		sprite.modulate = Color(1.0, 0.96, 0.88)
	else:
		sprite.modulate = Color(0.82, 0.84, 0.88)


func interact() -> void:
	Dialogue.start("cat_powered" if GameState.power_on else "cat")
