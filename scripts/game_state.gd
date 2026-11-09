extends Node

## Small global state for the vertical slice.

signal objective_changed(text: String)
signal power_restored
signal key_received

var power_on := false
var has_key := false
var ending_seen := false
var ui_blocked := false
var objective := "Поговорить со сторожем"


func set_objective(text: String) -> void:
	if objective == text:
		return
	objective = text
	objective_changed.emit(text)


func restore_power() -> void:
	if power_on:
		return
	power_on = true
	power_restored.emit()


func give_key() -> void:
	if has_key:
		return
	has_key = true
	key_received.emit()
