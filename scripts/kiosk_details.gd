extends Node2D

## Purely decorative overlay for the kiosk: glass glints, price tags, grime
## and wear. Kept separate so it never touches interaction or power logic.

func _ready() -> void:
	z_index = 10
	queue_redraw()


func _draw() -> void:
	# Glass reflections: two diagonal soft streaks.
	draw_colored_polygon(PackedVector2Array([
		Vector2(-118, -76), Vector2(-74, -76), Vector2(-16, -6), Vector2(-44, -6)
	]), Color(0.7, 0.85, 0.95, 0.055))
	draw_colored_polygon(PackedVector2Array([
		Vector2(28, -76), Vector2(48, -76), Vector2(96, -6), Vector2(76, -6)
	]), Color(0.7, 0.85, 0.95, 0.035))

	# Shelf edge highlights.
	draw_line(Vector2(-122, -51), Vector2(122, -51), Color(0.55, 0.68, 0.66, 0.18), 1.0)
	draw_line(Vector2(-122, -26), Vector2(122, -26), Color(0.55, 0.68, 0.66, 0.14), 1.0)

	# Tiny handwritten price tags on the goods.
	for p in [Vector2(-108, -70), Vector2(-76, -68), Vector2(26, -71), Vector2(90, -67), Vector2(-94, -20), Vector2(52, -19)]:
		draw_rect(Rect2(p, Vector2(10, 5)), Color(0.84, 0.78, 0.6, 0.72))
		draw_line(p + Vector2(2, 2), p + Vector2(7, 2), Color(0.24, 0.17, 0.1, 0.8), 0.8)

	# Rust marks where the awning meets the body.
	for x in [-166.0, -58.0, 46.0, 168.0]:
		draw_line(Vector2(x, -97), Vector2(x + 2, -80), Color(0.32, 0.15, 0.08, 0.3), 1.6)
		draw_circle(Vector2(x + 2, -80), 2.0, Color(0.32, 0.15, 0.08, 0.22))

	# Grime and scratches on the counter front.
	draw_line(Vector2(-170, 86), Vector2(168, 86), Color(0.05, 0.07, 0.08, 0.35), 2.0)
	for i in 7:
		var x := -150.0 + i * 48.0
		draw_line(Vector2(x, 80), Vector2(x + 22, 80), Color(0.55, 0.6, 0.62, 0.14), 0.8)

	# Faded awning stripes and wear.
	for x in [-184.0, -60.0, 70.0]:
		draw_line(Vector2(x, -114), Vector2(x + 58, -100), Color(0.12, 0.04, 0.05, 0.22), 1.2)
