extends Interactable

@export var dialogue_id := "intro"

@onready var sprite: Sprite2D = $Sprite

var _in_npc_dialogue := false


func _setup() -> void:
	Dialogue.dialogue_finished.connect(_on_dialogue_finished)


func _update(delta: float) -> void:
	sprite.position.y = sin(_time * 1.6) * 1.2
	if _player != null and can_interact():
		var to_player := _player.global_position - global_position
		if to_player.length_squared() > 4.0:
			sprite.rotation = lerp_angle(sprite.rotation, to_player.angle(), 1.0 - exp(-4.0 * delta))


func interact() -> void:
	_in_npc_dialogue = true
	Dialogue.start("intro_powered" if GameState.power_on else dialogue_id)


func _on_dialogue_finished() -> void:
	if not _in_npc_dialogue:
		return
	_in_npc_dialogue = false
	if GameState.power_on:
		GameState.set_objective("Прототип пройден")
	else:
		GameState.set_objective("Восстановить питание в щитке")
