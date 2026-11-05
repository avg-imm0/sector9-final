extends Node2D

## Procedural art pass: asphalt, concrete blocks, windows, puddles, cables,
## graffiti, pipes and other set dressing. Everything is drawn in code.

const WORLD := Vector2(1600, 1000)
const FONT_SIGN: Font = preload("res://assets/fonts/Oswald.ttf")
const FONT_BODY: Font = preload("res://assets/fonts/EBGaramond.ttf")

var _asphalt: NoiseTexture2D
var _concrete: NoiseTexture2D
var _metal: NoiseTexture2D
var _font: Font


func _ready() -> void:
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	_asphalt = _make_noise(
		0.06, 256,
		Color(0.27, 0.3, 0.36),
		Color(0.42, 0.46, 0.53)
	)
	_concrete = _make_noise(
		0.04, 256,
		Color(0.34, 0.36, 0.42),
		Color(0.55, 0.58, 0.64)
	)
	_metal = _make_noise(
		0.16, 128,
		Color(0.3, 0.34, 0.39),
		Color(0.58, 0.62, 0.68)
	)
	_font = FONT_SIGN
	queue_redraw()
	await get_tree().create_timer(0.25).timeout
	queue_redraw()


func _make_noise(frequency: float, size: int, low: Color, high: Color) -> NoiseTexture2D:
	var noise := FastNoiseLite.new()
	noise.frequency = frequency
	noise.fractal_octaves = 3
	noise.fractal_gain = 0.5
	var ramp := Gradient.new()
	ramp.set_color(0, low)
	ramp.set_color(1, high)
	var texture := NoiseTexture2D.new()
	texture.width = size
	texture.height = size
	texture.seamless = true
	texture.color_ramp = ramp
	texture.noise = noise
	return texture


func _draw() -> void:
	_draw_ground()
	_draw_buildings()
	_draw_sidewalks()
	_draw_windows()
	_draw_wall_details()
	_draw_wall_pipes()
	_draw_posters()
	_draw_fence()
	_draw_ground_marks()
	_draw_wet_stains()
	_draw_puddles()
	_draw_reflections()
	_draw_splashes()
	_draw_cables()
	_draw_graffiti()
	_draw_lamp_poles()
	_draw_debris()


func _draw_ground() -> void:
	draw_texture_rect(_asphalt, Rect2(0, 0, 1600, 1000), true)
	draw_rect(Rect2(0, 0, 1600, 1000), Color(0.02, 0.04, 0.07, 0.16))


func _draw_buildings() -> void:
	var top := Rect2(0, 0, 1600, 140)
	draw_texture_rect(_concrete, top, true)
	draw_rect(top, Color(0.02, 0.03, 0.04, 0.2))

	var left := Rect2(0, 0, 240, 1000)
	draw_texture_rect(_concrete, left, true, Color(0.94, 0.96, 1.0))
	draw_rect(left, Color(0.02, 0.03, 0.05, 0.24))

	var right := Rect2(1360, 0, 240, 1000)
	draw_texture_rect(_concrete, right, true, Color(0.9, 0.92, 0.98))
	draw_rect(right, Color(0.02, 0.03, 0.05, 0.26))

	draw_line(Vector2(240, 140), Vector2(240, 1000), Color(0.03, 0.04, 0.06, 0.95), 5.0)
	draw_line(Vector2(1360, 140), Vector2(1360, 1000), Color(0.03, 0.04, 0.06, 0.95), 5.0)
	draw_line(Vector2(0, 140), Vector2(1600, 140), Color(0.03, 0.04, 0.06, 0.95), 5.0)
	# Uneven ink line just inside the edges.
	draw_line(Vector2(244, 148), Vector2(244, 988), Color(0.38, 0.42, 0.45, 0.12), 1.2)
	draw_line(Vector2(1356, 148), Vector2(1356, 988), Color(0.44, 0.47, 0.5, 0.1), 1.2)
	draw_line(Vector2(252, 146), Vector2(1348, 146), Color(0.42, 0.46, 0.5, 0.1), 1.2)


func _draw_sidewalks() -> void:
	draw_texture_rect(_concrete, Rect2(240, 140, 1120, 64), true, Color(1.05, 1.05, 1.1))
	draw_texture_rect(_concrete, Rect2(240, 140, 54, 810), true, Color(0.98, 0.98, 1.04))
	draw_texture_rect(_concrete, Rect2(1306, 140, 54, 810), true, Color(0.98, 0.98, 1.04))
	draw_texture_rect(_concrete, Rect2(560, 380, 480, 120), true, Color(1.08, 1.08, 1.12))

	draw_rect(Rect2(560, 380, 480, 120), Color(0.02, 0.03, 0.04, 0.12))
	draw_line(Vector2(240, 204), Vector2(1360, 204), Color(0.02, 0.03, 0.04, 0.6), 2.0)
	draw_line(Vector2(294, 204), Vector2(294, 950), Color(0.02, 0.03, 0.04, 0.5), 2.0)
	draw_line(Vector2(1306, 204), Vector2(1306, 950), Color(0.02, 0.03, 0.04, 0.5), 2.0)

	for x in range(320, 1320, 120):
		draw_line(Vector2(x, 140), Vector2(x, 204), Color(0.02, 0.03, 0.04, 0.4), 1.0)
	for y in range(260, 950, 110):
		draw_line(Vector2(240, y), Vector2(294, y), Color(0.02, 0.03, 0.04, 0.35), 1.0)
		draw_line(Vector2(1306, y), Vector2(1360, y), Color(0.02, 0.03, 0.04, 0.35), 1.0)


func _draw_windows() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 771

	for x in range(300, 1330, 128):
		_draw_window(Rect2(x, 44, 52, 58), rng)

	for y in range(250, 880, 108):
		_draw_window(Rect2(64, y, 54, 56), rng)
		_draw_window(Rect2(1392, y + 12, 54, 56), rng)

	for i in 5:
		var x := rng.randf_range(310, 1280)
		draw_rect(Rect2(x, 168, 34, 16), Color(0.09, 0.1, 0.12))
		draw_rect(Rect2(x + 3, 170, 28, 5), Color(0.02, 0.03, 0.04))


func _draw_window(rect: Rect2, rng: RandomNumberGenerator) -> void:
	draw_rect(rect.grow(3.0), Color(0.02, 0.03, 0.04))
	var lit := rng.randf() < 0.34
	var color := Color(0.02, 0.04, 0.06)
	if lit:
		color = Color(1.0, 0.72, 0.4) if rng.randf() < 0.65 else Color(0.45, 0.8, 1.0)
		draw_rect(rect.grow(12.0), Color(color.r, color.g, color.b, 0.06))
	draw_rect(rect, color)
	draw_line(Vector2(rect.position.x + rect.size.x * 0.5, rect.position.y), Vector2(rect.position.x + rect.size.x * 0.5, rect.end.y), Color(0.02, 0.03, 0.04, 0.9), 2.0)
	draw_line(Vector2(rect.position.x, rect.position.y + rect.size.y * 0.5), Vector2(rect.end.x, rect.position.y + rect.size.y * 0.5), Color(0.02, 0.03, 0.04, 0.7), 1.0)


func _draw_wall_details() -> void:
	draw_line(Vector2(206, 160), Vector2(206, 930), Color(0.11, 0.12, 0.14), 6.0)
	draw_line(Vector2(1394, 160), Vector2(1394, 930), Color(0.11, 0.12, 0.14), 6.0)
	for y in range(220, 930, 90):
		draw_line(Vector2(206, y), Vector2(230, y), Color(0.08, 0.09, 0.11), 4.0)
		draw_line(Vector2(1370, y), Vector2(1394, y), Color(0.08, 0.09, 0.11), 4.0)

	draw_rect(Rect2(176, 720, 44, 92), Color(0.03, 0.04, 0.05))
	draw_rect(Rect2(180, 724, 36, 84), Color(0.08, 0.09, 0.1))
	draw_rect(Rect2(1440, 690, 42, 86), Color(0.03, 0.04, 0.05))
	draw_rect(Rect2(1444, 694, 34, 78), Color(0.07, 0.08, 0.09))


func _draw_wall_pipes() -> void:
	# Horizontal service pipe under the top windows.
	draw_line(Vector2(260, 122), Vector2(1340, 122), Color(0.075, 0.085, 0.095), 7.0)
	draw_line(Vector2(260, 119), Vector2(1340, 119), Color(0.3, 0.33, 0.36, 0.5), 1.6)
	for x in range(292, 1340, 108):
		draw_rect(Rect2(x, 116, 5, 12), Color(0.03, 0.04, 0.05))
	# A thin second line with a valve.
	draw_line(Vector2(260, 131), Vector2(900, 131), Color(0.12, 0.13, 0.15), 2.4)
	draw_circle(Vector2(940, 127), 6.0, Color(0.07, 0.08, 0.09))
	draw_line(Vector2(934, 127), Vector2(946, 127), Color(0.32, 0.34, 0.36), 2.0)

	for x in [188.0, 196.0, 202.0]:
		draw_line(Vector2(x, 180), Vector2(x, 930), Color(0.07, 0.08, 0.09), 2.2)
	for y in range(260, 900, 130):
		draw_line(Vector2(186, y), Vector2(206, y), Color(0.16, 0.17, 0.19), 2.0)

	_ac_unit(Vector2(402, 106), 64, 32)
	_ac_unit(Vector2(1162, 104), 74, 36)

	# Leaking pipe stains.
	for x in [540.0, 860.0, 1240.0]:
		draw_line(Vector2(x, 134), Vector2(x + 3, 206), Color(0.06, 0.1, 0.12, 0.32), 3.0)
		draw_circle(Vector2(x + 3, 206), 3.0, Color(0.06, 0.1, 0.12, 0.3))


func _ac_unit(pos: Vector2, width: float, height: float) -> void:
	draw_rect(Rect2(pos + Vector2(2, 3), Vector2(width, height)), Color(0, 0, 0, 0.3))
	draw_rect(Rect2(pos, Vector2(width, height)), Color(0.19, 0.21, 0.22))
	draw_rect(Rect2(pos + Vector2(2, 2), Vector2(width - 4, height - 4)), Color(0.27, 0.29, 0.3))
	draw_rect(Rect2(pos, Vector2(width, height)), Color(0.04, 0.05, 0.06), false, 2.0)
	var fan_center := pos + Vector2(width - 17, height * 0.5)
	draw_circle(fan_center, 11.0, Color(0.05, 0.06, 0.07))
	draw_arc(fan_center, 8.5, 0.0, TAU, 18, Color(0.36, 0.38, 0.39), 1.2, true)
	for blade in 3:
		var angle := blade * TAU / 3.0
		draw_line(fan_center, fan_center + Vector2(cos(angle), sin(angle)) * 8.0, Color(0.34, 0.36, 0.37, 0.75), 1.4)
	for i in 4:
		draw_line(pos + Vector2(6, 5 + i * 5), pos + Vector2(width - 34, 5 + i * 5), Color(0.13, 0.14, 0.15, 0.8), 1.2)
	# Condensation drip and stain running down the wall.
	var drip_x := pos.x + 12
	draw_line(Vector2(drip_x, pos.y + height), Vector2(drip_x + 2, pos.y + height + 90), Color(0.1, 0.16, 0.18, 0.34), 2.4)
	draw_circle(Vector2(drip_x + 2, pos.y + height + 90), 4.0, Color(0.1, 0.16, 0.18, 0.25))


func _draw_posters() -> void:
	_wall_poster(Vector2(214, 338), -PI * 0.5, 46, 64, "ХЛЕБ", "С 7 УТРА", Color(0.62, 0.57, 0.46, 0.42))
	_wall_poster(Vector2(214, 742), -PI * 0.5, 42, 58, "РЕМОНТ", "ОБУВИ", Color(0.55, 0.52, 0.44, 0.34))
	_wall_poster(Vector2(1386, 582), -PI * 0.5, 44, 60, "24 Ч", "БЕЗ СНА", Color(0.64, 0.55, 0.44, 0.4))
	_wall_poster(Vector2(1386, 806), -PI * 0.5, 38, 50, "НЕТ", "СВЕТА", Color(0.48, 0.35, 0.28, 0.34))


func _wall_poster(center: Vector2, rotation: float, width: float, height: float, title: String, subtitle: String, tint: Color) -> void:
	draw_set_transform(center, rotation, Vector2.ONE)
	draw_rect(Rect2(-width * 0.5 + 2, -height * 0.5 + 3, width, height), Color(0, 0, 0, 0.25))
	draw_rect(Rect2(-width * 0.5, -height * 0.5, width, height), tint)
	draw_rect(Rect2(-width * 0.5, -height * 0.5, width, height), Color(0.2, 0.17, 0.13, 0.28), false, 1.0)
	draw_string(FONT_SIGN, Vector2(-width * 0.5 + 4, -height * 0.5 + 15), title, HORIZONTAL_ALIGNMENT_LEFT, width - 8, 9, Color(0.13, 0.11, 0.09, 0.72))
	draw_string(FONT_BODY, Vector2(-width * 0.5 + 4, -height * 0.5 + 26), subtitle, HORIZONTAL_ALIGNMENT_LEFT, width - 8, 7, Color(0.15, 0.12, 0.1, 0.58))
	# Torn bottom corner.
	draw_colored_polygon(PackedVector2Array([
		Vector2(width * 0.5 - 12, height * 0.5),
		Vector2(width * 0.5, height * 0.5),
		Vector2(width * 0.5, height * 0.5 - 10)
	]), Color(0.15, 0.17, 0.19, 0.22))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_fence() -> void:
	draw_rect(Rect2(240, 950, 1120, 50), Color(0.035, 0.045, 0.055))
	for x in range(246, 1360, 24):
		draw_line(Vector2(x, 955), Vector2(x, 996), Color(0.22, 0.25, 0.29), 3.0)
	draw_line(Vector2(240, 958), Vector2(1360, 958), Color(0.32, 0.35, 0.4), 4.0)
	draw_line(Vector2(240, 992), Vector2(1360, 992), Color(0.12, 0.14, 0.17), 5.0)
	draw_line(Vector2(240, 950), Vector2(1360, 950), Color(0.03, 0.04, 0.05), 3.0)


func _draw_ground_marks() -> void:
	for x in range(300, 1320, 200):
		draw_line(Vector2(x, 204), Vector2(x, 950), Color(0.0, 0.0, 0.0, 0.16), 1.0)
	for y in range(240, 950, 180):
		draw_line(Vector2(294, y), Vector2(1306, y), Color(0.0, 0.0, 0.0, 0.14), 1.0)

	for i in range(0, 940, 28):
		var color := Color(0.82, 0.66, 0.18, 0.55) if (i / 28) % 2 == 0 else Color(0.03, 0.03, 0.04, 0.8)
		draw_rect(Rect2(330 + i, 588, 14, 5), color)

	draw_circle(Vector2(700, 830), 34.0, Color(0.035, 0.045, 0.055))
	draw_arc(Vector2(700, 830), 28.0, 0.0, TAU, 32, Color(0.22, 0.25, 0.28), 2.0, true)
	draw_line(Vector2(678, 830), Vector2(722, 830), Color(0.12, 0.14, 0.16), 2.0)
	draw_line(Vector2(700, 812), Vector2(700, 848), Color(0.12, 0.14, 0.16), 2.0)

	var rng := RandomNumberGenerator.new()
	rng.seed = 1502
	for i in 14:
		var p := Vector2(rng.randf_range(310.0, 1290.0), rng.randf_range(230.0, 930.0))
		for s in 5:
			var q := p + Vector2(rng.randf_range(-34.0, 34.0), rng.randf_range(-34.0, 34.0))
			draw_line(p, q, Color(0.01, 0.015, 0.02, 0.55), 1.0, true)
			p = q


func _draw_wet_stains() -> void:
	_stain(Vector2(420, 268), Vector2(220, 58), 17, Color(0.02, 0.035, 0.05, 0.32))
	_stain(Vector2(880, 236), Vector2(280, 46), 23, Color(0.02, 0.035, 0.05, 0.26))
	_stain(Vector2(1150, 420), Vector2(150, 54), 29, Color(0.02, 0.04, 0.05, 0.3))
	_stain(Vector2(330, 860), Vector2(180, 70), 31, Color(0.02, 0.03, 0.045, 0.28))
	_stain(Vector2(1200, 900), Vector2(160, 62), 37, Color(0.02, 0.03, 0.045, 0.3))


func _stain(center: Vector2, size: Vector2, seed_value: int, color: Color) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var points := PackedVector2Array()
	for i in 24:
		var angle := TAU * i / 24.0
		var radius := 1.0 + rng.randf_range(-0.3, 0.3)
		points.append(center + Vector2(cos(angle) * size.x * 0.5 * radius, sin(angle) * size.y * 0.5 * radius))
	draw_colored_polygon(points, color)


func _draw_puddles() -> void:
	_puddle(Vector2(640, 690), Vector2(260, 110), 4)
	_puddle(Vector2(1080, 760), Vector2(200, 90), 7)
	_puddle(Vector2(920, 900), Vector2(280, 120), 11)
	_puddle(Vector2(1080, 520), Vector2(150, 70), 15)
	_puddle(Vector2(390, 700), Vector2(120, 60), 19)


func _puddle(center: Vector2, size: Vector2, seed_value: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var points := PackedVector2Array()
	var count := 28
	for i in count:
		var angle := TAU * i / count
		var radius := 1.0 + rng.randf_range(-0.16, 0.16)
		points.append(center + Vector2(cos(angle) * size.x * 0.5 * radius, sin(angle) * size.y * 0.5 * radius))

	draw_colored_polygon(points, Color(0.035, 0.075, 0.11, 0.62))
	var rim := points.duplicate()
	rim.append(points[0])
	draw_polyline(rim, Color(0.35, 0.65, 0.78, 0.28), 1.5, true)

	for i in 3:
		var y := center.y - size.y * 0.25 + i * size.y * 0.22
		var color := Color(0.35, 0.9, 1.0, 0.14) if i % 2 == 0 else Color(1.0, 0.3, 0.65, 0.12)
		draw_line(Vector2(center.x - size.x * 0.28, y), Vector2(center.x + size.x * 0.22, y), color, 2.5, true)


func _draw_reflections() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 4401

	# Kiosk sign bleeding into the wet asphalt.
	for i in 12:
		var x := 690.0 + i * 20.0 + rng.randf_range(-4.0, 4.0)
		var length := rng.randf_range(55.0, 125.0)
		var color := Color(1.0, 0.24, 0.5, rng.randf_range(0.035, 0.09))
		draw_line(Vector2(x, 402.0), Vector2(x + rng.randf_range(-4.0, 4.0), 402.0 + length), color, rng.randf_range(1.5, 4.0))
	for i in 8:
		var x := rng.randf_range(660.0, 950.0)
		var y := rng.randf_range(410.0, 510.0)
		draw_line(Vector2(x, y), Vector2(x + rng.randf_range(10.0, 34.0), y), Color(1.0, 0.35, 0.6, 0.07), 1.5)

	# Left wall bar sign.
	for i in 7:
		var y := 760.0 + i * 18.0 + rng.randf_range(-5.0, 5.0)
		draw_line(Vector2(248.0, y), Vector2(248.0 + rng.randf_range(24.0, 58.0), y + rng.randf_range(-3.0, 3.0)), Color(0.95, 0.2, 0.45, rng.randf_range(0.03, 0.075)), rng.randf_range(1.5, 3.5))

	# Right wall cyan sign.
	for i in 8:
		var y := 586.0 + i * 16.0 + rng.randf_range(-4.0, 4.0)
		draw_line(Vector2(1296.0, y), Vector2(1296.0 - rng.randf_range(20.0, 54.0), y + rng.randf_range(-2.0, 2.0)), Color(0.35, 0.82, 1.0, rng.randf_range(0.025, 0.06)), rng.randf_range(1.4, 3.0))

	# Street lamp reflections.
	for i in 6:
		var x := 452.0 + i * 9.0 + rng.randf_range(-2.0, 2.0)
		draw_line(Vector2(x, 742.0), Vector2(x, 742.0 + rng.randf_range(40.0, 90.0)), Color(1.0, 0.73, 0.42, rng.randf_range(0.025, 0.06)), rng.randf_range(1.4, 3.0))
	for i in 5:
		var x := 1210.0 + i * 10.0 + rng.randf_range(-2.0, 2.0)
		draw_line(Vector2(x, 706.0), Vector2(x, 706.0 + rng.randf_range(34.0, 76.0)), Color(1.0, 0.69, 0.4, rng.randf_range(0.025, 0.05)), rng.randf_range(1.2, 2.8))

	# Broken horizontal glints.
	for i in 18:
		var p := Vector2(rng.randf_range(320.0, 1290.0), rng.randf_range(260.0, 930.0))
		var length := rng.randf_range(4.0, 18.0)
		draw_line(p, p + Vector2(length, 0), Color(0.55, 0.8, 0.9, rng.randf_range(0.015, 0.05)), 1.0)


func _draw_splashes() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 9107
	for i in 80:
		var p := Vector2(rng.randf_range(305.0, 1295.0), rng.randf_range(220.0, 935.0))
		var radius := rng.randf_range(1.0, 4.0)
		draw_arc(p, radius, 0.0, TAU, 10, Color(0.65, 0.82, 0.9, rng.randf_range(0.06, 0.16)), 1.0, true)
	for center: Vector2 in [Vector2(640, 690), Vector2(1080, 760), Vector2(920, 900), Vector2(1080, 520), Vector2(390, 700)]:
		for i in 5:
			var p: Vector2 = center + Vector2(rng.randf_range(-70.0, 70.0), rng.randf_range(-28.0, 28.0))
			draw_arc(p, rng.randf_range(1.5, 5.0), 0.0, TAU, 12, Color(0.7, 0.86, 0.95, 0.16), 1.2, true)


func _draw_cables() -> void:
	for cable in 2:
		var base_y := 172.0 + cable * 24.0
		var points := PackedVector2Array()
		for i in 33:
			var t := i / 32.0
			points.append(Vector2(lerpf(240.0, 1360.0, t), base_y + sin(t * PI) * 38.0))
		draw_polyline(points, Color(0.008, 0.01, 0.014, 0.9), 3.0, true)


func _draw_graffiti() -> void:
	draw_set_transform(Vector2(234, 640), -PI * 0.5, Vector2.ONE)
	draw_string(_font, Vector2.ZERO, "ХЛЕБ", HORIZONTAL_ALIGNMENT_LEFT, -1, 44, Color(0.9, 0.22, 0.55, 0.42))
	draw_set_transform(Vector2(1362, 820), -PI * 0.5, Vector2.ONE)
	draw_string(_font, Vector2.ZERO, "НЕТ СИГНАЛА", HORIZONTAL_ALIGNMENT_LEFT, -1, 32, Color(0.35, 0.85, 1.0, 0.32))
	draw_set_transform(Vector2(1000, 118), 0.0, Vector2.ONE)
	draw_string(_font, Vector2.ZERO, "СЕКТОР 9", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color(0.75, 0.78, 0.82, 0.24))
	draw_set_transform(Vector2(560, 920), 0.0, Vector2.ONE)
	draw_string(FONT_BODY, Vector2.ZERO, "здесь был электрик", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.72, 0.68, 0.58, 0.22))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_lamp_poles() -> void:
	_lamp_pole(Vector2(430, 760))
	_lamp_pole(Vector2(1190, 720))


func _lamp_pole(base: Vector2) -> void:
	var top := base + Vector2(0, -190)
	var head := top + Vector2(42, 0)
	draw_line(base, top, Color(0.055, 0.065, 0.075), 5.0)
	draw_line(top, head, Color(0.055, 0.065, 0.075), 4.0)
	draw_circle(head, 9.0, Color(0.08, 0.09, 0.11))
	draw_circle(head, 6.0, Color(1.0, 0.8, 0.45, 0.85))
	draw_circle(base, 10.0, Color(0.07, 0.08, 0.09))


func _draw_debris() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 333
	for i in 22:
		var pos := Vector2(rng.randf_range(1060.0, 1230.0), rng.randf_range(540.0, 680.0))
		var width := rng.randf_range(3.0, 11.0)
		draw_rect(Rect2(pos, Vector2(width, rng.randf_range(2.0, 5.0))), Color(0.08, 0.09, 0.1, 0.75))
	for i in 9:
		var pos := Vector2(rng.randf_range(360.0, 520.0), rng.randf_range(640.0, 740.0))
		draw_circle(pos, rng.randf_range(2.0, 5.0), Color(0.1, 0.1, 0.11, 0.7))
