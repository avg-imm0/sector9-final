extends Node2D

## Small animated wall neon. Used as decoration, not as UI.

const FONT: Font = preload("res://assets/fonts/Oswald.ttf")
const GLOW: Texture2D = preload("res://assets/textures/glow.svg")

@export var text := "БАР"
@export var neon_color := Color(0.9, 0.2, 0.42, 1.0)
@export var font_size := 34
@export var base_energy := 0.45
@export var tube_width := 0.0
@export var flicker := true

var _time := 0.0
var _dropout := 0.0
var _light: PointLight2D


func _ready() -> void:
	_light = PointLight2D.new()
	_light.texture = GLOW
	_light.color = neon_color
	_light.energy = base_energy
	_light.texture_scale = 1.5
	_light.shadow_enabled = false
	add_child(_light)
	_time = randf() * 10.0
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	if flicker and randf() < 0.007:
		_dropout = randf_range(0.05, 0.2)
	_dropout = maxf(0.0, _dropout - delta * 2.8)
	var pulse := 0.84 + 0.16 * sin(_time * 2.6 + 0.7)
	var alpha := pulse * (1.0 - _dropout)
	modulate.a = alpha
	if _light != null:
		_light.energy = base_energy * alpha
	queue_redraw()


func _draw() -> void:
	var width := FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	for i in 3:
		draw_string_outline(
			FONT, Vector2.ZERO, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size,
			10 + i * 7, Color(neon_color.r, neon_color.g, neon_color.b, 0.055)
		)
	draw_string_outline(FONT, Vector2.ZERO, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 3, Color(0.02, 0.01, 0.02, 0.9))
	draw_string(FONT, Vector2.ZERO, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, neon_color)

	var tube := tube_width if tube_width > 0.0 else width
	draw_line(Vector2(0, 7), Vector2(tube, 7), Color(neon_color.r, neon_color.g, neon_color.b, 0.88), 2.2)
	draw_line(Vector2(0, 7), Vector2(tube, 7), Color(neon_color.r, neon_color.g, neon_color.b, 0.18), 7.0)
