extends Control

## Title screen: continue, new game, save slots, settings and quit.

const WORLD_SHOT := "res://assets/textures/menu_bg.png"

var _continue_button: Button
var _autosave_label: Label
var _settings_dialog: SettingsDialog
var _slots_dialog: SlotsDialog


func _ready() -> void:
	GameState.in_run = false
	GameState.ui_blocked = false
	get_tree().paused = false
	Audio.set_power(false, true)
	AppSettings.apply_all()
	_build()
	_refresh_save_state()


func _build() -> void:
	var background := TextureRect.new()
	background.texture = load(WORLD_SHOT)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.modulate = Color(0.62, 0.67, 0.76, 1.0)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var shade := ColorRect.new()
	shade.color = Color(0.006, 0.008, 0.011, 0.52)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var fade := TextureRect.new()
	fade.texture = _left_fade_texture()
	fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fade.stretch_mode = TextureRect.STRETCH_SCALE
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fade)

	var accent_line := ColorRect.new()
	accent_line.color = UITheme.RED
	accent_line.position = Vector2(62, 92)
	accent_line.size = Vector2(3, 356)
	accent_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(accent_line)

	var title_block := VBoxContainer.new()
	title_block.position = Vector2(88, 86)
	title_block.size = Vector2(600, 360)
	title_block.add_theme_constant_override("separation", 0)
	add_child(title_block)

	var sector := UITheme.label("СЕКТОР", 22, UITheme.AMBER, UITheme.FONT_DISPLAY)
	sector.add_theme_constant_override("outline_size", 0)
	title_block.add_child(sector)

	var number := UITheme.label("09", 104, UITheme.TEXT, UITheme.FONT_DISPLAY)
	number.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	number.add_theme_constant_override("outline_size", 8)
	number.custom_minimum_size = Vector2(0, 126)
	title_block.add_child(number)

	var rule := ColorRect.new()
	rule.color = Color(0.66, 0.12, 0.1, 0.8)
	rule.custom_minimum_size = Vector2(250, 2)
	title_block.add_child(rule)

	var chapter := UITheme.label("ПОСЛЕДНЯЯ СМЕНА", 15, UITheme.RED_BRIGHT)
	chapter.add_theme_constant_override("outline_size", 0)
	title_block.add_child(chapter)

	var description := UITheme.body_label(
		"Дождь идёт с двух тысяч девятого. Киоск снова под напряжением, "
		+ "а в подсобке мигает монитор, который знает больше, чем говорит.\n\n"
		+ "Один двор. Одна смена. И выбор, который слышно за пределами сектора.",
		19,
		Color(0.82, 0.8, 0.73, 1.0)
	)
	description.custom_minimum_size = Vector2(500, 0)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_block.add_child(description)

	var menu := VBoxContainer.new()
	menu.position = Vector2(88, 430)
	menu.custom_minimum_size = Vector2(360, 0)
	menu.add_theme_constant_override("separation", 7)
	add_child(menu)

	_continue_button = _menu_button("ПРОДОЛЖИТЬ", 17)
	_continue_button.pressed.connect(_on_continue)
	menu.add_child(_continue_button)

	var new_game := _menu_button("НОВАЯ ИГРА", 17)
	new_game.pressed.connect(_on_new_game)
	menu.add_child(new_game)

	var load_button := _menu_button("ЗАГРУЗИТЬ", 17)
	load_button.pressed.connect(_on_load)
	menu.add_child(load_button)

	var settings_button := _menu_button("НАСТРОЙКИ", 17)
	settings_button.pressed.connect(_on_settings)
	menu.add_child(settings_button)

	var quit_button := _menu_button("ВЫХОД", 17)
	quit_button.pressed.connect(_on_quit)
	menu.add_child(quit_button)

	var status_panel := Control.new()
	status_panel.anchor_left = 1.0
	status_panel.anchor_right = 1.0
	status_panel.anchor_top = 1.0
	status_panel.anchor_bottom = 1.0
	status_panel.offset_left = -372.0
	status_panel.offset_right = -54.0
	status_panel.offset_top = -276.0
	status_panel.offset_bottom = -54.0
	status_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(status_panel)

	var ink := InkPanel.new()
	ink.accent = UITheme.RED
	ink.paper_alpha = 0.09
	ink.seed_value = 19
	ink.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	status_panel.add_child(ink)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	status_panel.add_child(margin)

	var status_box := VBoxContainer.new()
	status_box.add_theme_constant_override("separation", 6)
	margin.add_child(status_box)

	var status_header := HBoxContainer.new()
	status_header.add_theme_constant_override("separation", 8)
	status_box.add_child(status_header)
	status_header.add_child(UITheme.label("СВОДКА", 10, UITheme.AMBER))
	var status_spacer := Control.new()
	status_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_header.add_child(status_spacer)
	status_header.add_child(UITheme.label("03:47", 10, UITheme.MUTED))

	status_box.add_child(_status_line("СЕКТОР", "09 · ДВОР"))
	status_box.add_child(_status_line("ПОГОДА", "ЛИВЕНЬ · +6°C"))
	status_box.add_child(_status_line("СВЯЗЬ С УПРАВОЙ", "НЕТ"))
	status_box.add_child(_status_line("УЗЕЛ", "РАБОТАЕТ"))

	var status_rule := ColorRect.new()
	status_rule.color = Color(0.66, 0.12, 0.1, 0.5)
	status_rule.custom_minimum_size = Vector2(0, 1)
	status_box.add_child(status_rule)

	_autosave_label = UITheme.label("АВТОСОХРАНЕНИЕ: НЕТ", 9, UITheme.MUTED)
	_autosave_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_box.add_child(_autosave_label)

	var footer := UITheme.label("SECTOR 9 · v1.2 · УЧЕБНЫЙ ПРОЕКТ", 9, UITheme.MUTED)
	footer.anchor_top = 1.0
	footer.anchor_bottom = 1.0
	footer.offset_left = 88.0
	footer.offset_top = -32.0
	footer.offset_right = 700.0
	footer.offset_bottom = -14.0
	footer.add_theme_constant_override("outline_size", 0)
	add_child(footer)

	_settings_dialog = SettingsDialog.new()
	add_child(_settings_dialog)

	_slots_dialog = SlotsDialog.new()
	add_child(_slots_dialog)


func _left_fade_texture() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.62, 1.0])
	gradient.colors = PackedColorArray([
		Color(0.006, 0.008, 0.011, 0.97),
		Color(0.006, 0.008, 0.011, 0.82),
		Color(0.006, 0.008, 0.011, 0.0)
	])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 256
	texture.height = 4
	texture.fill_from = Vector2(0.0, 0.0)
	texture.fill_to = Vector2(1.0, 0.0)
	return texture


func _menu_button(text: String, font_size: int) -> Button:
	var button := UITheme.paper_button(text, font_size)
	button.custom_minimum_size = Vector2(360, 40)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_constant_override("outline_size", 0)
	return button


func _status_line(key: String, value: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var key_label := UITheme.label(key, 9, UITheme.MUTED)
	key_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	key_label.add_theme_constant_override("outline_size", 0)
	row.add_child(key_label)
	var value_label := UITheme.label(value, 9, UITheme.TEXT)
	value_label.add_theme_constant_override("outline_size", 0)
	row.add_child(value_label)
	return row


func _refresh_save_state() -> void:
	var has_auto := SaveGame.has_slot(SaveGame.AUTO_SLOT)
	_continue_button.disabled = not has_auto
	if has_auto:
		var meta := SaveGame.metadata(SaveGame.AUTO_SLOT)
		var time_text := str(meta.get("saved_at", "")).replace("T", " ")
		if time_text.length() > 16:
			time_text = time_text.substr(0, 16)
		_autosave_label.text = "АВТОСОХРАНЕНИЕ: %s" % time_text
	else:
		_autosave_label.text = "АВТОСОХРАНЕНИЕ: НЕТ"


func _on_continue() -> void:
	if SaveGame.continue_game():
		Audio.play_ui_click()


func _on_new_game() -> void:
	Audio.play_ui_click()
	SaveGame.new_game()


func _on_load() -> void:
	Audio.play_ui_click()
	_slots_dialog.open("load")


func _on_settings() -> void:
	Audio.play_ui_click()
	_settings_dialog.open()


func _on_quit() -> void:
	Audio.play_ui_click()
	get_tree().quit()


func open_settings() -> void:
	_settings_dialog.open()


func open_load() -> void:
	_slots_dialog.open("load")


func close_overlays() -> void:
	_settings_dialog.close_dialog()
	_slots_dialog.close_dialog()
