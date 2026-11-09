extends CanvasLayer

## Final card for the vertical slice. Built in code so it can reuse UITheme
## and the ink/paper panel language without another scene tree dependency.

signal ending_shown
signal ending_dismissed

var _root: Control
var _panel: Control
var _title: Label
var _body: Label
var _stamp: Label
var _return_button: Button
var _quit_button: Button


func _ready() -> void:
	add_to_group("ending")
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	visible = false


func _build_ui() -> void:
	_root = Control.new()
	_root.name = "EndingRoot"
	_root.anchor_right = 1.0
	_root.anchor_bottom = 1.0
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)

	var dim := ColorRect.new()
	dim.color = Color(0.008, 0.01, 0.012, 0.9)
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(dim)

	_panel = Control.new()
	_panel.name = "EndingCard"
	_panel.anchor_left = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_top = 0.5
	_panel.anchor_bottom = 0.5
	_panel.offset_left = -430.0
	_panel.offset_right = 430.0
	_panel.offset_top = -260.0
	_panel.offset_bottom = 260.0
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(_panel)

	var ink := InkPanel.new()
	ink.name = "Ink"
	ink.accent = UITheme.RED
	ink.paper_alpha = 0.1
	ink.seed_value = 91
	ink.anchor_right = 1.0
	ink.anchor_bottom = 1.0
	_panel.add_child(ink)

	var margin := MarginContainer.new()
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.add_theme_constant_override("margin_left", 44)
	margin.add_theme_constant_override("margin_right", 44)
	margin.add_theme_constant_override("margin_top", 34)
	margin.add_theme_constant_override("margin_bottom", 30)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(box)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(header)

	var red_bar := ColorRect.new()
	red_bar.color = UITheme.RED_BRIGHT
	red_bar.custom_minimum_size = Vector2(5, 22)
	red_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(red_bar)

	var kicker := UITheme.label("СЕКТОР 09 // ДВОР // СМЕНА ЗАВЕРШЕНА", 13, UITheme.AMBER)
	kicker.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(kicker)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(spacer)

	_stamp = UITheme.label("ФАЙЛ ЗАКРЫТ", 10, Color(0.5, 0.18, 0.14, 0.8))
	_stamp.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(_stamp)

	_title = UITheme.label("СВЕТ ЕСТЬ", 58, UITheme.TEXT, UITheme.FONT_SIGN)
	_title.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_title.add_theme_constant_override("outline_size", 6)
	box.add_child(_title)

	var rule := ColorRect.new()
	rule.color = Color(0.66, 0.12, 0.1, 0.7)
	rule.custom_minimum_size = Vector2(0, 2)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(rule)

	_body = UITheme.body_label("", 20, UITheme.TEXT)
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.custom_minimum_size = Vector2(0, 150)
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(_body)

	var footer := UITheme.label("СПАСИБО, ЧТО ЗАГЛЯНУЛ В ДЕВЯТЫЙ СЕКТОР.", 11, UITheme.MUTED)
	box.add_child(footer)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 12)
	buttons.mouse_filter = Control.MOUSE_FILTER_PASS
	box.add_child(buttons)

	_return_button = UITheme.paper_button("ВЕРНУТЬСЯ ВО ДВОР", 14)
	_return_button.custom_minimum_size = Vector2(240, 40)
	_return_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_return_button.pressed.connect(hide_ending)
	buttons.add_child(_return_button)

	_quit_button = UITheme.paper_button("ВЫЙТИ ИЗ ИГРЫ", 14)
	_quit_button.custom_minimum_size = Vector2(200, 40)
	_quit_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_quit_button.pressed.connect(_quit)
	buttons.add_child(_quit_button)


func show_ending() -> void:
	if visible:
		return
	GameState.ending_seen = true
	GameState.ui_blocked = true
	GameState.set_objective("Срез пройден")
	Audio.play_ui_click()
	_title.text = "СВЕТ ЕСТЬ"
	_body.text = (
		"Питание восстановлено. Неон киоска гудит, кот-бухгалтер пересчитывает чеки, "
		+ "а Гриша остался сторожить свой кусок бетона от дождя.\n\n"
		+ "Подсобка открыта. Внутри пахнет пылью, чайником и старой проводкой. "
		+ "На столе мигает монитор: «СЕКТОР 9. СМЕНА ПРИНЯТА».\n\n"
		+ "Двор наконец-то работает. Ненадолго — но это уже немало."
	)
	visible = true
	_root.modulate = Color(1, 1, 1, 0)
	_panel.scale = Vector2(0.97, 0.97)
	_panel.pivot_offset = _panel.size * 0.5
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_root, "modulate", Color(1, 1, 1, 1), 0.35)
	tween.tween_property(_panel, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	ending_shown.emit()


func hide_ending() -> void:
	if not visible:
		return
	visible = false
	GameState.ui_blocked = false
	ending_dismissed.emit()


func _quit() -> void:
	get_tree().quit()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if not (event is InputEventKey):
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	if key_event.physical_keycode == KEY_ESCAPE:
		hide_ending()
		get_viewport().set_input_as_handled()
