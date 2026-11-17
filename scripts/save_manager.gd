extends Node

## JSON save slots and autosave. Slot 0 is automatic; slots 1-3 are manual.
## Autoloaded as "SaveGame".

const SAVE_DIR := "user://saves"
const AUTO_SLOT := 0
const FIRST_MANUAL_SLOT := 1
const LAST_MANUAL_SLOT := 3
const SAVE_VERSION := 2

var pending_data: Dictionary = {}
var autosave_enabled := true
var _suppress_autosave := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SAVE_DIR))
	GameState.power_restored.connect(_queue_autosave)
	GameState.key_received.connect(_queue_autosave)


func slot_path(slot: int) -> String:
	return "%s/slot_%d.json" % [SAVE_DIR, slot]


func has_slot(slot: int) -> bool:
	return FileAccess.file_exists(slot_path(slot))


func has_any_save() -> bool:
	for slot in range(AUTO_SLOT, LAST_MANUAL_SLOT + 1):
		if has_slot(slot):
			return true
	return false


func metadata(slot: int) -> Dictionary:
	var data := _read_slot(slot)
	if data.is_empty():
		return {}
	return {
		"slot": slot,
		"saved_at": str(data.get("saved_at", "")),
		"objective": str(data.get("objective", "")),
		"chapter": str(data.get("chapter", "Двор")),
		"power_on": bool(data.get("power_on", false)),
		"ending_seen": bool(data.get("ending_seen", false)),
		"ending_kind": str(data.get("ending_kind", "")),
	}


func save_to_slot(slot: int) -> bool:
	if slot < AUTO_SLOT or slot > LAST_MANUAL_SLOT:
		return false
	if not GameState.in_run:
		return false
	var data := _collect_state()
	var file := FileAccess.open(slot_path(slot), FileAccess.WRITE)
	if file == null:
		push_error("SaveGame: cannot write %s" % slot_path(slot))
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return true


func load_from_slot(slot: int) -> bool:
	var data := _read_slot(slot)
	if data.is_empty():
		return false
	pending_data = data
	GameState.in_run = true
	return true


func apply_pending_state() -> void:
	if pending_data.is_empty():
		return
	var data := pending_data
	pending_data = {}
	_suppress_autosave = true
	GameState.apply_save(data)
	var player := get_tree().get_first_node_in_group("player")
	if player != null and data.get("player", null) is Dictionary:
		var pos: Dictionary = data["player"]
		player.global_position = Vector2(float(pos.get("x", 800.0)), float(pos.get("y", 620.0)))
	GameState.apply_save_ui()
	_suppress_autosave = false


func delete_slot(slot: int) -> void:
	if has_slot(slot):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(slot_path(slot)))


func new_game() -> void:
	pending_data = {}
	GameState.reset()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func continue_game() -> bool:
	if not load_from_slot(AUTO_SLOT):
		return false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	return true


func _collect_state() -> Dictionary:
	var player := get_tree().get_first_node_in_group("player")
	var px := 800.0
	var py := 620.0
	if player is Node2D:
		px = (player as Node2D).global_position.x
		py = (player as Node2D).global_position.y
	return {
		"version": SAVE_VERSION,
		"saved_at": Time.get_datetime_string_from_system(),
		"objective": GameState.objective,
		"chapter": GameState.chapter,
		"power_on": GameState.power_on,
		"has_key": GameState.has_key,
		"ending_seen": GameState.ending_seen,
		"ending_kind": GameState.ending_kind,
		"story_flags": GameState.story_flags.duplicate(true),
		"player": {"x": px, "y": py},
	}


func _read_slot(slot: int) -> Dictionary:
	if not has_slot(slot):
		return {}
	var file := FileAccess.open(slot_path(slot), FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		return {}
	return parsed


func _queue_autosave() -> void:
	if not GameState.in_run:
		return
	if _suppress_autosave or not autosave_enabled or DisplayServer.get_name() == "headless":
		return
	call_deferred("_autosave_now")


func _autosave_now() -> void:
	if not GameState.in_run or _suppress_autosave:
		return
	save_to_slot(AUTO_SLOT)
