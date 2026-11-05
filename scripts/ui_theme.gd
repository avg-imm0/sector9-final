class_name UITheme
extends RefCounted

## Shared visual language for the vertical slice: ink, wet paper and dried blood.
## Utility keeps the dialogue, breaker UI and HUD on the same palette.

const FONT_BODY: Font = preload("res://assets/fonts/EBGaramond.ttf")
const FONT_MONO: Font = preload("res://assets/fonts/PTMono-Regular.ttf")
const FONT_SIGN: Font = preload("res://assets/fonts/Oswald.ttf")
const PAPER: Texture2D = preload("res://assets/textures/paper.jpg")

const INK := Color(0.042, 0.039, 0.035, 0.97)
const INK_DEEP := Color(0.022, 0.021, 0.02, 0.98)
const TEXT := Color(0.9, 0.87, 0.79, 1.0)
const MUTED := Color(0.61, 0.58, 0.52, 1.0)
const RED := Color(0.66, 0.12, 0.1, 1.0)
const RED_BRIGHT := Color(0.9, 0.24, 0.17, 1.0)
const PAPER_LIGHT := Color(0.86, 0.82, 0.72, 1.0)
const PAPER_DARK := Color(0.66, 0.61, 0.51, 1.0)
const PAPER_INK := Color(0.11, 0.095, 0.08, 1.0)
const GREEN := Color(0.46, 0.78, 0.43, 1.0)
const CYAN := Color(0.46, 0.79, 0.9, 1.0)
const AMBER := Color(0.88, 0.65, 0.3, 1.0)

# Legacy aliases used by a couple of small screens.
const BG := INK


static func panel_style(accent: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = INK
	s.border_color = accent
	s.border_width_left = 4
	s.border_width_top = 1
	s.border_width_right = 1
	s.border_width_bottom = 1
	s.set_corner_radius_all(0)
	s.content_margin_left = 18
	s.content_margin_right = 18
	s.content_margin_top = 14
	s.content_margin_bottom = 14
	return s


static func paper_style(tint: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = tint
	s.border_color = Color(0.24, 0.2, 0.15, 0.9)
	s.border_width_left = 4
	s.border_width_top = 1
	s.border_width_right = 1
	s.border_width_bottom = 1
	s.corner_radius_top_left = 1
	s.corner_radius_top_right = 3
	s.corner_radius_bottom_left = 2
	s.corner_radius_bottom_right = 1
	s.content_margin_left = 16
	s.content_margin_right = 16
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	s.shadow_color = Color(0, 0, 0, 0.35)
	s.shadow_size = 3
	s.shadow_offset = Vector2(2, 3)
	return s


static func button_style(bg: Color, border: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(1)
	s.set_corner_radius_all(0)
	s.content_margin_left = 12
	s.content_margin_right = 12
	s.content_margin_top = 6
	s.content_margin_bottom = 6
	return s


static func label(text: String, font_size: int, color: Color, font: Font = FONT_MONO) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", font)
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	l.add_theme_constant_override("outline_size", 3)
	return l


static func body_label(text: String, font_size: int, color: Color) -> Label:
	var l := label(text, font_size, color, FONT_BODY)
	l.add_theme_constant_override("line_spacing", 3)
	return l


static func choice_button(text: String, font_size: int = 18) -> Button:
	var b := Button.new()
	b.text = text
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.custom_minimum_size = Vector2(0, 42)
	b.add_theme_font_override("font", FONT_BODY)
	b.add_theme_font_size_override("font_size", font_size)
	b.add_theme_color_override("font_color", PAPER_INK)
	b.add_theme_color_override("font_hover_color", Color(0.05, 0.035, 0.02, 1.0))
	b.add_theme_color_override("font_pressed_color", RED)
	b.add_theme_color_override("font_disabled_color", Color(0.3, 0.27, 0.22, 1.0))
	b.add_theme_stylebox_override("normal", paper_style(Color(0.76, 0.71, 0.6, 0.97)))
	b.add_theme_stylebox_override("hover", paper_style(Color(0.92, 0.87, 0.75, 1.0)))
	b.add_theme_stylebox_override("pressed", paper_style(Color(0.66, 0.61, 0.51, 1.0)))
	b.add_theme_stylebox_override("disabled", paper_style(Color(0.44, 0.42, 0.37, 0.82)))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	return b


static func paper_button(text: String, font_size: int = 14) -> Button:
	var b := choice_button(text, font_size)
	b.custom_minimum_size = Vector2(0, 32)
	b.alignment = HORIZONTAL_ALIGNMENT_CENTER
	return b
