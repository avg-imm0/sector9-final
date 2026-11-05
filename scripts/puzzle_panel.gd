extends Interactable

## Breaker puzzle: three hand-inked switches, solution 2 -> 3 -> 1.
## The public _press()/_solved/_close_panel() surface is used by the smoke test.

const SOLUTION := [2, 3, 1]
const BOARD_TEX: Texture2D = preload("res://assets/sprites/breaker_board.svg")
const SWITCH_OFF: Texture2D = preload("res://assets/sprites/breaker_switch_off.svg")
const SWITCH_ON: Texture2D = preload("res://assets/sprites/breaker_switch_on.svg")

@onready var led: Sprite2D = $Led

var _layer: CanvasLayer
var _window: Control
var _dim: ColorRect
var _status: Label
var _buttons: Array[TextureButton] = []
var _sequence: Array[int] = []
var _solved := false
var _is_open := false


func _setup() -> void:
	_build_ui()


func _build_ui() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 5
	_layer.visible = false
	add_child(_layer)

	_dim = ColorRect.new()
	_dim.color = Color(0.0, 0.0, 0.0, 0.62)
	_dim.anchor_right = 1.0
	_dim.anchor_bottom = 1.0
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(_dim)

	_window = Control.new()
	_window.name = "BreakerWindow"
	_window.anchor_left = 0.5
	_window.anchor_right = 0.5
	_window.anchor_top = 0.5
	_window.anchor_bottom = 0.5
	_window.offset_left = -500.0
	_window.offset_right = 500.0
	_window.offset_top = -330.0
	_window.offset_bottom = 330.0
	_window.mouse_filter = Control.MOUSE_FILTER_STOP
	_layer.add_child(_window)

	var background := InkPanel.new()
	background.name = "Ink"
	background.accent = UITheme.RED
	background.paper_alpha = 0.11
	background.seed_value = 31
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0
	_window.add_child(background)

	var margin := MarginContainer.new()
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 20)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_window.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(box)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(header)

	var red_bar := ColorRect.new()
	red_bar.color = UITheme.RED_BRIGHT
	red_bar.custom_minimum_size = Vector2(4, 20)
	red_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(red_bar)

	var title := UITheme.label("ЩИТОК ПИТАНИЯ // СЕКТОР 9", 20, UITheme.TEXT)
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(title)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(spacer)

	var close_button := UITheme.paper_button("ЗАКРЫТЬ  [ESC]", 12)
	close_button.custom_minimum_size = Vector2(172, 30)
	close_button.pressed.connect(_close_panel)
	header.add_child(close_button)

	var subtitle := UITheme.label("1 · РЕЗЕРВ      2 · ЛИНИЯ      3 · СВЯЗЬ", 12, UITheme.MUTED)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(subtitle)

	var board_center := CenterContainer.new()
	board_center.custom_minimum_size = Vector2(0, 407)
	board_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(board_center)

	var board := Control.new()
	board.custom_minimum_size = Vector2(860, 407)
	board.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_center.add_child(board)

	var board_texture := TextureRect.new()
	board_texture.texture = BOARD_TEX
	board_texture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	board_texture.stretch_mode = TextureRect.STRETCH_SCALE
	board_texture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	board_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board.add_child(board_texture)

	var switch_x := [145.0, 360.0, 575.0]
	var switch_y := 112.0
	for number: int in [1, 2, 3]:
		var index := number - 1
		var short_label := UITheme.label(str(number), 22, Color(0.94, 0.87, 0.7, 0.95))
		short_label.offset_left = switch_x[index]
		short_label.offset_top = 76.0
		short_label.offset_right = switch_x[index] + 140.0
		short_label.offset_bottom = 104.0
		short_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		short_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
		short_label.add_theme_constant_override("outline_size", 5)
		board.add_child(short_label)

		var button := TextureButton.new()
		button.name = "Switch%d" % number
		button.texture_normal = SWITCH_OFF
		button.texture_hover = SWITCH_OFF
		button.texture_pressed = SWITCH_ON
		button.position = Vector2(switch_x[index], switch_y)
		button.size = Vector2(140, 190)
		button.stretch_mode = TextureButton.STRETCH_SCALE
		button.ignore_texture_size = true
		button.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.pressed.connect(_press.bind(number))
		button.mouse_entered.connect(_on_switch_hover.bind(button, true))
		button.mouse_exited.connect(_on_switch_hover.bind(button, false))
		_buttons.append(button)
		board.add_child(button)

	_status = UITheme.body_label("ОЖИДАНИЕ ВВОДА", 21, UITheme.MUTED)
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_status)

	var hint := UITheme.label("1–3 ИЛИ КЛИК — ПЕРЕКЛЮЧИТЬ · ESC — ЗАКРЫТЬ", 10, UITheme.MUTED)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(hint)


func _on_switch_hover(button: TextureButton, entered: bool) -> void:
	if _solved or button.disabled:
		return
	button.self_modulate = Color(1.12, 1.1, 1.06, 1.0) if entered else Color(1, 1, 1, 1)


func interact() -> void:
	_is_open = true
	GameState.ui_blocked = true
	_sequence.clear()
	_layer.visible = true
	led.modulate = Color(1.0, 0.3, 0.18, 1.0)
	_dim.color = Color(0.0, 0.0, 0.0, 0.62)
	_refresh_switches()

	if _solved:
		_status.text = "ПИТАНИЕ ВОССТАНОВЛЕНО"
		_status.add_theme_color_override("font_color", UITheme.GREEN)
		for button in _buttons:
			button.disabled = true
	else:
		_status.text = "ОЖИДАНИЕ ВВОДА"
		_status.add_theme_color_override("font_color", UITheme.MUTED)
		for button in _buttons:
			button.disabled = false

	_window.modulate = Color(1, 1, 1, 0)
	var tween := create_tween()
	tween.tween_property(_window, "modulate", Color(1, 1, 1, 1), 0.18)


func _close_panel() -> void:
	if not _is_open:
		return
	_is_open = false
	GameState.ui_blocked = false
	_layer.visible = false


func _press(number: int) -> void:
	if _solved or not _is_open:
		return

	Audio.play_breaker()
	_sequence.append(number)
	_refresh_switches()
	_pulse_switch(number)

	for i in _sequence.size():
		if _sequence[i] != SOLUTION[i]:
			_fail()
			return

	if _sequence.size() == SOLUTION.size():
		_solve()
		return

	var parts := PackedStringArray()
	for value in _sequence:
		parts.append(str(value))
	_status.text = "ВВОД: " + " → ".join(parts)
	_status.add_theme_color_override("font_color", UITheme.AMBER)


func _refresh_switches() -> void:
	for i in _buttons.size():
		var number := i + 1
		var on := _solved or _sequence.has(number)
		_buttons[i].texture_normal = SWITCH_ON if on else SWITCH_OFF
		_buttons[i].texture_hover = SWITCH_ON if on else SWITCH_OFF


func _pulse_switch(number: int) -> void:
	if number < 1 or number > _buttons.size():
		return
	var button := _buttons[number - 1]
	button.pivot_offset = button.size * 0.5
	button.scale = Vector2(0.94, 0.94)
	var tween := create_tween()
	tween.tween_property(button, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _fail() -> void:
	_sequence.clear()
	_refresh_switches()
	Audio.play_fail()
	_status.text = "НЕ ТО. КОРОТКОЕ ЗАМЫКАНИЕ."
	_status.add_theme_color_override("font_color", UITheme.RED_BRIGHT)
	led.modulate = Color(1.0, 0.12, 0.08, 1.0)
	var led_tween := create_tween()
	led_tween.tween_property(led, "modulate", Color(1.0, 0.3, 0.18, 1.0), 0.3)
	var flash := create_tween()
	flash.tween_property(_dim, "color", Color(0.22, 0.0, 0.0, 0.75), 0.05)
	flash.tween_property(_dim, "color", Color(0.0, 0.0, 0.0, 0.62), 0.28)


func _solve() -> void:
	_solved = true
	Audio.play_power_up()
	_status.text = "ПИТАНИЕ ВОССТАНОВЛЕНО"
	_status.add_theme_color_override("font_color", UITheme.GREEN)
	led.modulate = Color(0.4, 1.0, 0.5, 1.0)
	_refresh_switches()
	for button in _buttons:
		button.disabled = true

	GameState.restore_power()
	GameState.set_objective("Вернуться к Грише")

	await get_tree().create_timer(1.5).timeout
	if is_inside_tree():
		_close_panel()


func _input(event: InputEvent) -> void:
	if not _is_open:
		return
	if not (event is InputEventKey):
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	var key := key_event.physical_keycode
	if key == KEY_ESCAPE:
		_close_panel()
	elif key >= KEY_1 and key <= KEY_3 and not _solved:
		_press(key - KEY_1 + 1)
	else:
		return
	get_viewport().set_input_as_handled()


func _exit_tree() -> void:
	if _is_open:
		GameState.ui_blocked = false
