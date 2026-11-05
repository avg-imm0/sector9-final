extends CanvasLayer

@onready var objective: Label = $Objective
@onready var controls: Label = $Controls


func _ready() -> void:
	GameState.objective_changed.connect(_on_objective_changed)
	_apply_objective(GameState.objective, false)


func _process(_delta: float) -> void:
	controls.visible = not Dialogue.is_open and not GameState.ui_blocked


func _on_objective_changed(text: String) -> void:
	_apply_objective(text, true)


func _apply_objective(text: String, animate: bool) -> void:
	objective.text = "> " + text
	if not animate:
		return
	objective.modulate = Color(1, 1, 1, 0)
	var tween := create_tween()
	tween.tween_property(objective, "modulate", Color(1, 1, 1, 1), 0.35)
