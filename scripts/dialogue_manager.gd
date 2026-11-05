extends Node

## Dialogue system: JSON-driven lines, typewriter text, paper-strip choices and
## a hand-drawn portrait card. Autoloaded as "Dialogue".

signal dialogue_started
signal dialogue_finished

const DATA_PATH := "res://data/dialogue.json"
const CHARS_PER_SECOND := 46.0

var is_open := false
var current_id := ""
var last_finished_id := ""

var _data: Dictionary = {}
var _lines := PackedStringArray()
var _choices: Array = []
var _line_index := 0
var _speaker := ""
var _typing := false
var _visible_chars := 0.0
var _total_chars := 0
var _choices_shown := false
var _portraits: Dictionary = {}
var _reveal_tween: Tween

var _root: Control
var _panel: Control
var _content: MarginContainer
var _portrait_card: Control
var _portrait_image: TextureRect
var _portrait_name: Label
var _portrait_stamp: Label
var _speaker_label: Label
var _text_label: Label
var _choice_box: VBoxContainer
var _hint_label: Label


func _ready() -> void:
	_load_data()
	_build_ui()


func _load_data() -> void:
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("Dialogue: cannot open %s" % DATA_PATH)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		_data = parsed
	else:
		push_error("Dialogue: invalid JSON in %s" % DATA_PATH)


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.name = "DialogueLayer"
	layer.layer = 10
	add_child(layer)

	_root = Control.new()
	_root.name = "DialogueRoot"
	_root.anchor_right = 1.0
	_root.anchor_bottom = 1.0
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.visible = false
	layer.add_child(_root)

	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.3)
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(dim)

	_panel = Control.new()
	_panel.name = "PaperDialoguePanel"
	_panel.anchor_left = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_top = 1.0
	_panel.anchor_bottom = 1.0
	_panel.offset_left = -548.0
	_panel.offset_right = 548.0
	_panel.offset_top = -388.0
	_panel.offset_bottom = -24.0
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(_panel)

	var background := InkPanel.new()
	background.name = "Ink"
	background.accent = UITheme.RED
	background.paper_alpha = 0.11
	background.seed_value = 7
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0
	_panel.add_child(background)

	_content = MarginContainer.new()
	_content.anchor_right = 1.0
	_content.anchor_bottom = 1.0
	_content.add_theme_constant_override("margin_left", 34)
	_content.add_theme_constant_override("margin_right", 408)
	_content.add_theme_constant_override("margin_top", 24)
	_content.add_theme_constant_override("margin_bottom", 18)
	_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(_content)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content.add_child(box)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(header)

	var red_bar := ColorRect.new()
	red_bar.color = UITheme.RED_BRIGHT
	red_bar.custom_minimum_size = Vector2(3, 17)
	red_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(red_bar)

	_speaker_label = UITheme.label("", 15, UITheme.TEXT)
	_speaker_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	header.add_child(_speaker_label)

	_text_label = Label.new()
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text_label.custom_minimum_size = Vector2(0, 96)
	_text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_text_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_text_label.add_theme_font_override("font", UITheme.FONT_BODY)
	_text_label.add_theme_font_size_override("font_size", 23)
	_text_label.add_theme_color_override("font_color", UITheme.TEXT)
	_text_label.add_theme_constant_override("line_spacing", 4)
	_text_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.65))
	_text_label.add_theme_constant_override("shadow_offset_x", 1)
	_text_label.add_theme_constant_override("shadow_offset_y", 2)
	box.add_child(_text_label)

	_choice_box = VBoxContainer.new()
	_choice_box.add_theme_constant_override("separation", 6)
	_choice_box.mouse_filter = Control.MOUSE_FILTER_PASS
	box.add_child(_choice_box)

	_hint_label = UITheme.label("", 11, UITheme.MUTED)
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_hint_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(_hint_label)

	_build_portrait_card()


func _build_portrait_card() -> void:
	_portrait_card = Control.new()
	_portrait_card.name = "PortraitCard"
	_portrait_card.anchor_left = 1.0
	_portrait_card.anchor_right = 1.0
	_portrait_card.anchor_top = 1.0
	_portrait_card.anchor_bottom = 1.0
	_portrait_card.offset_left = -380.0
	_portrait_card.offset_right = -40.0
	_portrait_card.offset_top = -520.0
	_portrait_card.offset_bottom = -24.0
	_portrait_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_portrait_card.z_index = 2
	_root.add_child(_portrait_card)

	var card := InkPanel.new()
	card.name = "Paper"
	card.paper_mode = true
	card.accent = UITheme.RED
	card.seed_value = 23
	card.anchor_right = 1.0
	card.anchor_bottom = 1.0
	_portrait_card.add_child(card)

	_portrait_image = TextureRect.new()
	_portrait_image.name = "InkPortrait"
	_portrait_image.anchor_right = 1.0
	_portrait_image.anchor_bottom = 1.0
	_portrait_image.offset_left = 14.0
	_portrait_image.offset_top = 16.0
	_portrait_image.offset_right = -14.0
	_portrait_image.offset_bottom = -68.0
	_portrait_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait_image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_portrait_image.modulate = Color(0.16, 0.12, 0.09, 0.94)
	_portrait_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_portrait_card.add_child(_portrait_image)

	var grain := TextureRect.new()
	grain.name = "Grain"
	grain.texture = UITheme.PAPER
	grain.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	grain.stretch_mode = TextureRect.STRETCH_SCALE
	grain.anchor_right = 1.0
	grain.anchor_bottom = 1.0
	grain.offset_left = 14.0
	grain.offset_top = 16.0
	grain.offset_right = -14.0
	grain.offset_bottom = -68.0
	grain.self_modulate = Color(1, 1, 1, 0.2)
	grain.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	grain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_portrait_card.add_child(grain)

	var divider := ColorRect.new()
	divider.color = Color(0.24, 0.19, 0.14, 0.55)
	divider.anchor_right = 1.0
	divider.anchor_top = 1.0
	divider.anchor_bottom = 1.0
	divider.offset_left = 16.0
	divider.offset_top = -56.0
	divider.offset_right = -16.0
	divider.offset_bottom = -54.0
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_portrait_card.add_child(divider)

	_portrait_name = UITheme.label("", 13, UITheme.PAPER_INK)
	_portrait_name.anchor_right = 1.0
	_portrait_name.anchor_top = 1.0
	_portrait_name.anchor_bottom = 1.0
	_portrait_name.offset_left = 18.0
	_portrait_name.offset_top = -50.0
	_portrait_name.offset_right = -18.0
	_portrait_name.offset_bottom = -26.0
	_portrait_name.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0))
	_portrait_name.add_theme_constant_override("outline_size", 0)
	_portrait_card.add_child(_portrait_name)

	_portrait_stamp = UITheme.label("SECTOR 9 / FILE", 9, Color(0.48, 0.17, 0.13, 0.65))
	_portrait_stamp.anchor_right = 1.0
	_portrait_stamp.offset_left = 18.0
	_portrait_stamp.offset_top = 10.0
	_portrait_stamp.offset_right = -18.0
	_portrait_stamp.offset_bottom = 26.0
	_portrait_stamp.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_portrait_stamp.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0))
	_portrait_stamp.add_theme_constant_override("outline_size", 0)
	_portrait_card.add_child(_portrait_stamp)


func start(dialogue_id: String) -> void:
	var node: Variant = _data.get(dialogue_id)
	if not node is Dictionary:
		push_warning("Dialogue: unknown id '%s'" % dialogue_id)
		return

	var raw_lines: Variant = node.get("lines", [])
	var raw_choices: Variant = node.get("choices", [])
	_lines = PackedStringArray(raw_lines) if raw_lines is Array else PackedStringArray()
	_choices = raw_choices if raw_choices is Array else []
	_speaker = str(node.get("speaker", "???"))
	if _lines.is_empty():
		_lines = PackedStringArray([""])

	is_open = true
	current_id = dialogue_id
	_line_index = 0
	_choices_shown = false
	_clear_choices()
	_speaker_label.text = _speaker.to_upper()
	_text_label.text = ""
	_hint_label.text = ""
	_apply_portrait(str(node.get("portrait", "")))
	_root.visible = true
	_animate_in()
	_show_line()
	dialogue_started.emit()


func _apply_portrait(portrait_key: String) -> void:
	var has_portrait := not portrait_key.is_empty()
	_portrait_card.visible = has_portrait
	_content.add_theme_constant_override("margin_right", 408 if has_portrait else 34)
	if not has_portrait:
		return

	var texture: Texture2D = _portraits.get(portrait_key, null)
	if texture == null:
		var path := "res://assets/portraits/%s.png" % portrait_key
		if ResourceLoader.exists(path):
			texture = load(path)
		_portraits[portrait_key] = texture
	_portrait_image.texture = texture
	if texture == null:
		_portrait_card.visible = false
		_content.add_theme_constant_override("margin_right", 34)
		return

	var short_name := _speaker.split(" · ")[0]
	_portrait_name.text = short_name.to_upper()
	_portrait_stamp.text = "SECTOR 9 / FILE %02d" % (abs(hash(portrait_key)) % 90 + 10)


func _animate_in() -> void:
	if _reveal_tween != null and _reveal_tween.is_valid():
		_reveal_tween.kill()
	_panel.modulate = Color(1, 1, 1, 0)
	if _portrait_card.visible:
		_portrait_card.modulate = Color(1, 1, 1, 0)
	_reveal_tween = create_tween().set_parallel(true)
	_reveal_tween.tween_property(_panel, "modulate", Color(1, 1, 1, 1), 0.18)
	if _portrait_card.visible:
		_reveal_tween.tween_property(_portrait_card, "modulate", Color(1, 1, 1, 1), 0.26).set_delay(0.05)


func close() -> void:
	if not is_open:
		return
	is_open = false
	last_finished_id = current_id
	current_id = ""
	_typing = false
	_root.visible = false
	_clear_choices()
	dialogue_finished.emit()


func _show_line() -> void:
	_text_label.text = _lines[_line_index]
	_total_chars = _text_label.text.length()
	_visible_chars = 0.0
	_text_label.visible_characters = 0
	_typing = true
	_hint_label.text = "E / ПРОБЕЛ — ДАЛЕЕ"


func _process(delta: float) -> void:
	if not is_open or not _typing:
		return
	var before := int(_visible_chars)
	_visible_chars = minf(_visible_chars + CHARS_PER_SECOND * delta, float(_total_chars))
	_text_label.visible_characters = int(_visible_chars)
	if int(_visible_chars) / 3 != before / 3:
		Audio.play_type_tick()
	if _visible_chars >= float(_total_chars):
		_finish_typing()


func _finish_typing() -> void:
	_typing = false
	_text_label.visible_characters = -1
	if _line_index >= _lines.size() - 1:
		if _choices.is_empty():
			_hint_label.text = "E / ПРОБЕЛ — ЗАКРЫТЬ"
		else:
			_show_choices()


func _advance() -> void:
	if _typing:
		_finish_typing()
		return
	if _choices_shown:
		return
	if _line_index < _lines.size() - 1:
		_line_index += 1
		_show_line()
	elif _choices.is_empty():
		close()


func _show_choices() -> void:
	_choices_shown = true
	_clear_choices()
	for i in _choices.size():
		var choice: Variant = _choices[i]
		if not choice is Dictionary:
			continue
		var button := UITheme.choice_button("%d.  %s" % [i + 1, str(choice.get("text", "..."))], 18)
		button.pressed.connect(_on_choice_pressed.bind(i))
		_choice_box.add_child(button)
	_hint_label.text = "1–4 — ВЫБОР · ESC — ВЫЙТИ"


func _clear_choices() -> void:
	for child in _choice_box.get_children():
		_choice_box.remove_child(child)
		child.queue_free()


func _on_choice_pressed(index: int) -> void:
	if index < 0 or index >= _choices.size():
		return
	var choice: Variant = _choices[index]
	var next_id := ""
	if choice is Dictionary:
		next_id = str(choice.get("next", ""))
	if next_id.is_empty():
		close()
	else:
		start(next_id)


func _input(event: InputEvent) -> void:
	if not is_open:
		return
	if not (event is InputEventKey):
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	var key := key_event.physical_keycode
	if key == KEY_ESCAPE:
		close()
	elif key >= KEY_1 and key <= KEY_4 and _choices_shown:
		var index := key - KEY_1
		if index < _choices.size():
			_on_choice_pressed(index)
	elif key == KEY_E or key == KEY_SPACE or key == KEY_ENTER or key == KEY_KP_ENTER:
		_advance()
	else:
		return
	get_viewport().set_input_as_handled()
