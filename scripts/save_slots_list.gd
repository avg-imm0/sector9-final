class_name SaveSlotsList
extends VBoxContainer

## Reusable list of autosave and manual save slots.
## mode = "load" shows loading only; mode = "save" adds a save button to slots 1-3.

signal load_requested(slot: int)
signal save_requested(slot: int)

var mode := "load"
var include_auto := true


func _ready() -> void:
	add_theme_constant_override("separation", 8)
	refresh()


func set_mode(value: String) -> void:
	mode = value
	if is_inside_tree():
		refresh()


func refresh() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

	var first := SaveGame.AUTO_SLOT if include_auto else SaveGame.FIRST_MANUAL_SLOT
	for slot in range(first, SaveGame.LAST_MANUAL_SLOT + 1):
		_add_slot_row(slot)


func _add_slot_row(slot: int) -> void:
	var data := SaveGame.metadata(slot)
	var has_data := not data.is_empty()

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UITheme.button_style(
		Color(0.075, 0.08, 0.085, 0.94),
		Color(0.3, 0.27, 0.22, 0.7)
	))
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	margin.add_child(row)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 2)
	row.add_child(info)

	var title := UITheme.label(
		"АВТОСОХРАНЕНИЕ" if slot == SaveGame.AUTO_SLOT else "СЛОТ %d" % slot,
		12,
		UITheme.AMBER
	)
	info.add_child(title)

	var detail_text := "Пусто"
	if has_data:
		var time_text := str(data.get("saved_at", "")).replace("T", " ")
		if time_text.length() > 16:
			time_text = time_text.substr(0, 16)
		detail_text = "%s · %s" % [str(data.get("objective", "—")), time_text]
	var detail := UITheme.body_label(detail_text, 15, UITheme.TEXT if has_data else UITheme.MUTED)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(detail)

	if has_data and bool(data.get("ending_seen", false)):
		var end_label := UITheme.label("СРЕЗ ПРОЙДЕН", 9, UITheme.RED_BRIGHT)
		info.add_child(end_label)

	if mode == "save" and slot != SaveGame.AUTO_SLOT:
		var save_button := UITheme.paper_button("СОХРАНИТЬ", 11)
		save_button.custom_minimum_size = Vector2(124, 34)
		save_button.pressed.connect(_on_save.bind(slot))
		row.add_child(save_button)

	var load_button := UITheme.paper_button("ЗАГРУЗИТЬ", 11)
	load_button.custom_minimum_size = Vector2(124, 34)
	load_button.disabled = not has_data
	load_button.pressed.connect(_on_load.bind(slot))
	row.add_child(load_button)


func _on_load(slot: int) -> void:
	Audio.play_ui_click()
	load_requested.emit(slot)


func _on_save(slot: int) -> void:
	Audio.play_ui_click()
	save_requested.emit(slot)
