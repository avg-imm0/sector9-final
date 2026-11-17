class_name SlotsDialog
extends Control

## Save/load overlay used by both the title screen and pause menu.

signal closed

var _title: Label
var _list: SaveSlotsList
var _status: Label
var _mode := "load"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()
	visible = false


func open(mode: String) -> void:
	_mode = mode
	_title.text = "СОХРАНИТЬ ИГРУ" if mode == "save" else "ЗАГРУЗИТЬ ИГРУ"
	_status.text = ""
	_list.set_mode(mode)
	visible = true
	move_to_front()


func close_dialog() -> void:
	if not visible:
		return
	visible = false
	closed.emit()


func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.008, 0.01, 0.012, 0.84)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	var panel := Control.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -350.0
	panel.offset_right = 350.0
	panel.offset_top = -292.0
	panel.offset_bottom = 292.0
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel)

	var ink := InkPanel.new()
	ink.accent = UITheme.RED
	ink.paper_alpha = 0.1
	ink.seed_value = 77
	ink.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_child(ink)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 22)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	box.add_child(header)

	var bar := ColorRect.new()
	bar.color = UITheme.RED_BRIGHT
	bar.custom_minimum_size = Vector2(4, 20)
	header.add_child(bar)

	_title = UITheme.label("СОХРАНЕНИЯ", 24, UITheme.TEXT, UITheme.FONT_SIGN)
	header.add_child(_title)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)

	header.add_child(UITheme.label("SECTOR 9", 9, UITheme.MUTED))

	box.add_child(UITheme.body_label(
		"Автосохранение создаётся после включения света и после разговора с Гришей. Ручные слоты можно перезаписывать.",
		14,
		UITheme.MUTED
	))

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)

	_list = SaveSlotsList.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_list)
	_list.load_requested.connect(_on_load_requested)
	_list.save_requested.connect(_on_save_requested)

	_status = UITheme.label("", 11, UITheme.GREEN)
	box.add_child(_status)

	var footer := HBoxContainer.new()
	box.add_child(footer)

	var spacer2 := Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(spacer2)

	var close_button := UITheme.paper_button("ЗАКРЫТЬ", 12)
	close_button.custom_minimum_size = Vector2(170, 38)
	close_button.pressed.connect(close_dialog)
	footer.add_child(close_button)


func _on_load_requested(slot: int) -> void:
	if not SaveGame.load_from_slot(slot):
		_status.text = "СЛОТ ПУСТ"
		return
	visible = false
	get_tree().paused = false
	GameState.ui_blocked = false
	closed.emit()
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_save_requested(slot: int) -> void:
	if SaveGame.save_to_slot(slot):
		_status.text = "СОХРАНЕНО В СЛОТ %d" % slot
		_list.refresh()
	else:
		_status.text = "НЕ УДАЛОСЬ СОХРАНИТЬ"


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.physical_keycode == KEY_ESCAPE:
			close_dialog()
			get_viewport().set_input_as_handled()
