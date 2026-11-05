extends Interactable

@export var dialogue_id := "note"


func interact() -> void:
	Dialogue.start(dialogue_id)
