extends Node

## Small global state for the vertical slice.

signal objective_changed(text: String)
signal power_restored

var power_on := false
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
