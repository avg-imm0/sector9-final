extends CanvasLayer

## In-game pause screen with saving, loading and settings.

var _root: Control
var _objective: Label
var _settings_dialog: SettingsDialog
var _slots_dialog: SlotsDialog


func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()
	visible = false


func open() -> void:
	if visible:
		return
	_objective.text = "ЦЕЛЬ: " + GameState.objective
	visible = true
	_root.modulate = Color(1, 1, 1, 0)
	get_tree().paused = true
	GameState.ui_blocked = true
	var tween := create_tween()
	tween.tween_property(_root, "modulate", Color(1, 1, 1, 1), 0.16)


func close() -> void:
	if not visible:
		return
	visible = false
	get_tree().paused = false
	GameState.ui_blocked = false


func _build() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)

	var dim := ColorRect.new()
	dim.color = Color(0.006, 0.008, 0.01, 0.72)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(dim)

	var panel := Control.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -250.0
	panel.offset_right = 250.0
	panel.offset_top = -274.0
	panel.offset_bottom = 274.0
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(panel)

	var ink := InkPanel.new()
	ink.accent = UITheme.RED
	ink.paper_alpha = 0.1
	ink.seed_value = 33
	ink.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_child(ink)

	var fibres := TextureRect.new()
	fibres.texture = UITheme.PAPER
	fibres.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fibres.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fibres.stretch_mode = TextureRect.STRETCH_SCALE
	fibres.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	fibres.modulate = Color(1, 1, 1, 0.05)
	fibres.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(fibres)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	box.add_child(header)

	var bar := ColorRect.new()
	bar.color = UITheme.RED_BRIGHT
	bar.custom_minimum_size = Vector2(4, 20)
	header.add_child(bar)

	header.add_child(UITheme.label("ПАУЗА", 24, UITheme.TEXT, UITheme.FONT_SIGN))

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)

	header.add_child(UITheme.label("СЕКТОР 09", 9, UITheme.MUTED))

	_objective = UITheme.body_label("", 14, UITheme.AMBER)
	_objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_objective)

	var rule := ColorRect.new()
	rule.color = Color(0.66, 0.12, 0.1, 0.55)
	rule.custom_minimum_size = Vector2(0, 1)
	box.add_child(rule)

	_add_button(box, "ПРОДОЛЖИТЬ", close)
	_add_button(box, "СОХРАНИТЬ", _open_save)
	_add_button(box, "ЗАГРУЗИТЬ", _open_load)
	_add_button(box, "НАСТРОЙКИ", _open_settings)

	var grow := Control.new()
	grow.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(grow)

	_add_button(box, "В ГЛАВНОЕ МЕНЮ", _to_main_menu)
	_add_button(box, "ВЫЙТИ ИЗ ИГРЫ", _quit)

	_settings_dialog = SettingsDialog.new()
	add_child(_settings_dialog)

	_slots_dialog = SlotsDialog.new()
	add_child(_slots_dialog)


func _add_button(parent: VBoxContainer, text: String, callback: Callable) -> void:
	var button := UITheme.paper_button(text, 15)
	button.custom_minimum_size = Vector2(0, 40)
	button.pressed.connect(func() -> void:
		Audio.play_ui_click()
		callback.call()
	)
	parent.add_child(button)


func _open_save() -> void:
	_slots_dialog.open("save")


func _open_load() -> void:
	_slots_dialog.open("load")


func _open_settings() -> void:
	_settings_dialog.open()


func _to_main_menu() -> void:
	close()
	GameState.in_run = false
	GameState.ui_blocked = false
	Dialogue.close()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _quit() -> void:
	get_tree().quit()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.physical_keycode == KEY_ESCAPE:
			if _settings_dialog.visible or _slots_dialog.visible:
				return
			close()
			get_viewport().set_input_as_handled()
