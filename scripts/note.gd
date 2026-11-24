extends Interactable

@export var dialogue_id := "note"

@onready var paper: Sprite2D = $Sprite

var _base_rotation := 0.08


func _setup() -> void:
	_base_rotation = paper.rotation


func _update(_delta: float) -> void:
	# Barely noticeable sway, as if the paper hangs in the damp air.
	paper.rotation = _base_rotation + sin(_time * 0.8) * 0.015


func interact() -> void:
	Dialogue.start(dialogue_id)
