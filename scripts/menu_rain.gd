extends Control

## Decorative animated rain on the title screen. Purely visual: it does not
## touch saves, settings, input or any game state.

const RAIN_COUNT := 110
const SPEED := 430.0

var _time := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var rect := get_rect()
	var rng := RandomNumberGenerator.new()
	rng.seed = 4747
	for i in RAIN_COUNT:
		var x := rng.randf_range(0.0, rect.size.x)
		var start_y := rng.randf_range(0.0, rect.size.y)
		var speed := rng.randf_range(0.7, 1.35)
		var y := fmod(start_y + _time * SPEED * speed, rect.size.y + 120.0) - 60.0
		var drop_length := rng.randf_range(9.0, 24.0)
		var color := Color(0.66, 0.82, 0.96, rng.randf_range(0.05, 0.15))
		draw_line(Vector2(x, y), Vector2(x - 2.0, y + drop_length), color, rng.randf_range(1.0, 1.8), true)
