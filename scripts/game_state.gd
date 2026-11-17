extends Node

## Small global state for the vertical slice.

signal objective_changed(text: String)
signal power_restored
signal key_received

var power_on := false
var has_key := false
var ending_seen := false
var ending_kind := ""
var ui_blocked := false
var in_run := false
var objective := "Поговорить со сторожем"
var chapter := "Двор"
var story_flags: Dictionary = {}


func reset() -> void:
	power_on = false
	has_key = false
	ending_seen = false
	ending_kind = ""
	ui_blocked = false
	in_run = false
	objective = "Поговорить со сторожем"
	chapter = "Двор"
	story_flags = {}


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


func apply_save(data: Dictionary) -> void:
	power_on = bool(data.get("power_on", false))
	has_key = bool(data.get("has_key", false))
	ending_seen = bool(data.get("ending_seen", false))
	ending_kind = str(data.get("ending_kind", ""))
	objective = str(data.get("objective", "Поговорить со сторожем"))
	chapter = str(data.get("chapter", "Двор"))
	var flags: Variant = data.get("story_flags", {})
	story_flags = flags.duplicate(true) if flags is Dictionary else {}
	ui_blocked = false


func apply_save_ui() -> void:
	objective_changed.emit(objective)
	if power_on:
		power_restored.emit()
