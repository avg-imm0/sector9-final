class_name InkPanel
extends Control

## A grunge panel drawn in code. Dark mode is used for dialogue/breakers,
## paper mode for portraits and paper scraps. No nine-patch assets required.

const PAPER := preload("res://assets/textures/paper.jpg")

@export var accent := Color(0.66, 0.12, 0.1, 1.0)
@export var paper_alpha := 0.16
@export var seed_value := 11
@export var draw_shadow := true
@export var paper_mode := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	var rect := Rect2(Vector2(2, 2), size - Vector2(4, 4))
	if draw_shadow:
		draw_rect(Rect2(Vector2(9, 11), size - Vector2(4, 4)), Color(0, 0, 0, 0.46))

	if paper_mode:
		_draw_paper(rect)
	else:
		_draw_ink(rect)

	if paper_mode:
		_draw_rough_border(rect, Color(0.17, 0.14, 0.11, 0.62), 1.4, seed_value)
		_draw_rough_border(rect.grow(-5.0), Color(0.35, 0.3, 0.23, 0.45), 0.7, seed_value + 3)
		_draw_tape()
	else:
		_draw_rough_border(rect, Color(0.78, 0.74, 0.64, 0.5), 1.2, seed_value)
		_draw_rough_border(rect.grow(-5.0), Color(accent.r, accent.g, accent.b, 0.35), 0.8, seed_value + 3)
		# Left accent bar and corner ticks.
		draw_rect(Rect2(0, 10, 3, size.y - 20), Color(accent.r, accent.g, accent.b, 0.9))
		draw_line(Vector2(0, 0), Vector2(28, 0), Color(accent.r, accent.g, accent.b, 0.75), 2.0)
		draw_line(Vector2(0, 0), Vector2(0, 28), Color(accent.r, accent.g, accent.b, 0.75), 2.0)
		draw_line(Vector2(size.x, size.y), Vector2(size.x - 24, size.y), Color(accent.r, accent.g, accent.b, 0.35), 1.0)
		draw_line(Vector2(size.x, size.y), Vector2(size.x, size.y - 24), Color(accent.r, accent.g, accent.b, 0.35), 1.0)


func _draw_ink(rect: Rect2) -> void:
	draw_rect(rect, Color(0.032, 0.039, 0.047, 0.97))
	draw_texture_rect(PAPER, rect, true, Color(1, 1, 1, paper_alpha))

	# Dark stains so the panel does not read as a flat rectangle.
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in 7:
		var p := Vector2(
			rng.randf_range(rect.position.x + 20.0, rect.end.x - 20.0),
			rng.randf_range(rect.position.y + 20.0, rect.end.y - 20.0)
		)
		var radius := rng.randf_range(18.0, 80.0)
		draw_circle(p, radius, Color(0.0, 0.0, 0.0, rng.randf_range(0.03, 0.09)))
	for i in 3:
		var p := Vector2(
			rng.randf_range(rect.position.x + 40.0, rect.end.x - 40.0),
			rng.randf_range(rect.position.y + 40.0, rect.end.y - 40.0)
		)
		draw_circle(p, rng.randf_range(40.0, 110.0), Color(0.22, 0.08, 0.06, 0.035))


func _draw_paper(rect: Rect2) -> void:
	draw_rect(rect, Color(0.79, 0.75, 0.65, 0.99))
	draw_texture_rect(PAPER, rect, true, Color(1, 1, 1, 0.42))

	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value + 41
	for i in 9:
		var p := Vector2(
			rng.randf_range(rect.position.x + 12.0, rect.end.x - 12.0),
			rng.randf_range(rect.position.y + 12.0, rect.end.y - 12.0)
		)
		draw_circle(p, rng.randf_range(6.0, 46.0), Color(0.32, 0.23, 0.13, rng.randf_range(0.015, 0.055)))
	# A few ink flecks and scratches.
	for i in 5:
		var start := Vector2(
			rng.randf_range(rect.position.x + 14.0, rect.end.x - 30.0),
			rng.randf_range(rect.position.y + 14.0, rect.end.y - 14.0)
		)
		draw_line(start, start + Vector2(rng.randf_range(6.0, 30.0), rng.randf_range(-3.0, 3.0)), Color(0.16, 0.13, 0.1, 0.16), 0.8)


func _draw_tape() -> void:
	var tape := Color(0.87, 0.83, 0.71, 0.42)
	draw_set_transform(Vector2(16, 6), -0.32, Vector2.ONE)
	draw_rect(Rect2(-26, -7, 52, 16), tape)
	draw_set_transform(Vector2(size.x - 14, 8), 0.28, Vector2.ONE)
	draw_rect(Rect2(-26, -7, 52, 16), tape)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_rough_border(rect: Rect2, color: Color, width: float, seed_offset: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value + seed_offset
	var points := PackedVector2Array()
	var steps := 18

	for i in steps + 1:
		var t := float(i) / float(steps)
		points.append(Vector2(lerpf(rect.position.x, rect.end.x, t), rect.position.y + rng.randf_range(-1.6, 1.6)))
	for i in steps + 1:
		var t := float(i) / float(steps)
		points.append(Vector2(rect.end.x + rng.randf_range(-1.6, 1.6), lerpf(rect.position.y, rect.end.y, t)))
	for i in steps + 1:
		var t := float(i) / float(steps)
		points.append(Vector2(lerpf(rect.end.x, rect.position.x, t), rect.end.y + rng.randf_range(-1.6, 1.6)))
	for i in steps + 1:
		var t := float(i) / float(steps)
		points.append(Vector2(rect.position.x + rng.randf_range(-1.6, 1.6), lerpf(rect.end.y, rect.position.y, t)))

	draw_polyline(points, color, width, true)
