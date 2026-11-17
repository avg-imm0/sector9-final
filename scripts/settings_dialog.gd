class_name SettingsDialog
extends Control

## Volume, fullscreen and typewriter speed. Shared by the title screen and pause menu.

signal closed

var _master_slider: HSlider
var _ambience_slider: HSlider
var _sfx_slider: HSlider
var _speed_slider: HSlider
var _master_value: Label
var _ambience_value: Label
var _sfx_value: Label
var _speed_value: Label
var _fullscreen_check: CheckButton
var _built := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()
	visible = false


func open() -> void:
	if not _built:
		return
	_sync_from_settings()
	visible = true
	move_to_front()


func close_dialog() -> void:
	if not visible:
		return
	visible = false
	closed.emit()


func _build() -> void:
	_built = true

	var dim := ColorRect.new()
	dim.color = Color(0.008, 0.01, 0.012, 0.82)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	var panel := Control.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -320.0
	panel.offset_right = 320.0
	panel.offset_top = -292.0
	panel.offset_bottom = 292.0
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel)

	var ink := InkPanel.new()
	ink.accent = UITheme.RED
	ink.paper_alpha = 0.1
	ink.seed_value = 52
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

	header.add_child(UITheme.label("НАСТРОЙКИ", 24, UITheme.TEXT, UITheme.FONT_SIGN))

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)

	header.add_child(UITheme.label("SECTOR 9", 9, UITheme.MUTED))

	box.add_child(UITheme.body_label("Звук, экран и скорость печати. Изменения сохраняются сразу.", 15, UITheme.MUTED))

	box.add_child(_section("ГРОМКОСТЬ"))
	_master_slider = _add_slider(box, "Общая", 0, 100, 1, _on_master_changed)
	_master_value = _value_label_for(box, _master_slider)
	_ambience_slider = _add_slider(box, "Атмосфера", 0, 100, 1, _on_ambience_changed)
	_ambience_value = _value_label_for(box, _ambience_slider)
	_sfx_slider = _add_slider(box, "Эффекты", 0, 100, 1, _on_sfx_changed)
	_sfx_value = _value_label_for(box, _sfx_slider)

	box.add_child(_section("ИНТЕРФЕЙС"))
	_speed_slider = _add_slider(box, "Скорость текста", 50, 200, 5, _on_speed_changed)
	_speed_value = _value_label_for(box, _speed_slider)

	_fullscreen_check = CheckButton.new()
	_fullscreen_check.text = "Полноэкранный режим"
	_fullscreen_check.add_theme_font_override("font", UITheme.FONT_MONO)
	_fullscreen_check.add_theme_font_size_override("font_size", 13)
	_fullscreen_check.add_theme_color_override("font_color", UITheme.TEXT)
	_fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	box.add_child(_fullscreen_check)

	var grow := Control.new()
	grow.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(grow)

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 10)
	box.add_child(footer)

	var reset_button := UITheme.paper_button("СБРОСИТЬ", 12)
	reset_button.custom_minimum_size = Vector2(150, 38)
	reset_button.pressed.connect(_on_reset)
	footer.add_child(reset_button)

	var spacer2 := Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(spacer2)

	var close_button := UITheme.paper_button("ЗАКРЫТЬ", 12)
	close_button.custom_minimum_size = Vector2(170, 38)
	close_button.pressed.connect(close_dialog)
	footer.add_child(close_button)


func _section(text: String) -> Label:
	var label := UITheme.label(text, 10, UITheme.AMBER)
	label.add_theme_constant_override("outline_size", 0)
	return label


func _add_slider(parent: VBoxContainer, title: String, minimum: float, maximum: float, step: float, callback: Callable) -> HSlider:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	parent.add_child(row)

	var title_label := UITheme.body_label(title, 16, UITheme.TEXT)
	title_label.custom_minimum_size = Vector2(156, 24)
	row.add_child(title_label)

	var slider := HSlider.new()
	slider.min_value = minimum
	slider.max_value = maximum
	slider.step = step
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.custom_minimum_size = Vector2(0, 24)
	slider.add_theme_stylebox_override("slider", _slider_bar(Color(0.16, 0.15, 0.13, 0.95)))
	slider.add_theme_stylebox_override("grabber_area", _slider_bar(UITheme.RED))
	slider.add_theme_stylebox_override("grabber_area_highlight", _slider_bar(UITheme.RED_BRIGHT))
	slider.value_changed.connect(callback)
	row.add_child(slider)
	return slider


func _value_label_for(parent: VBoxContainer, slider: HSlider) -> Label:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	var label := UITheme.label("", 10, UITheme.MUTED)
	label.custom_minimum_size = Vector2(44, 16)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(label)
	label.set_meta("slider", slider)
	return label


func _slider_bar(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(0)
	style.content_margin_top = 3
	style.content_margin_bottom = 3
	return style


func _sync_from_settings() -> void:
	_master_slider.set_value_no_signal(AppSettings.master_volume * 100.0)
	_ambience_slider.set_value_no_signal(AppSettings.ambience_volume * 100.0)
	_sfx_slider.set_value_no_signal(AppSettings.sfx_volume * 100.0)
	_speed_slider.set_value_no_signal(AppSettings.text_speed * 100.0)
	_fullscreen_check.set_pressed_no_signal(AppSettings.fullscreen)
	_update_value_labels()


func _update_value_labels() -> void:
	_master_value.text = "%d%%" % roundi(_master_slider.value)
	_ambience_value.text = "%d%%" % roundi(_ambience_slider.value)
	_sfx_value.text = "%d%%" % roundi(_sfx_slider.value)
	_speed_value.text = "%d%%" % roundi(_speed_slider.value)


func _on_master_changed(value: float) -> void:
	AppSettings.set_master(value / 100.0)
	_update_value_labels()


func _on_ambience_changed(value: float) -> void:
	AppSettings.set_ambience(value / 100.0)
	_update_value_labels()


func _on_sfx_changed(value: float) -> void:
	AppSettings.set_sfx(value / 100.0)
	_update_value_labels()


func _on_speed_changed(value: float) -> void:
	AppSettings.set_text_speed(value / 100.0)
	_update_value_labels()


func _on_fullscreen_toggled(value: bool) -> void:
	AppSettings.set_fullscreen(value)


func _on_reset() -> void:
	AppSettings.reset_defaults()
	_sync_from_settings()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.physical_keycode == KEY_ESCAPE:
			close_dialog()
			get_viewport().set_input_as_handled()
