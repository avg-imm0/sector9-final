extends PointLight2D

@export var base_energy := 1.0
@export var min_factor := 0.72

var _time := 0.0
var _next := 0.0


func _process(delta: float) -> void:
	_time += delta
	if _time < _next:
		return
	_next = _time + randf_range(0.08, 0.6)
	energy = base_energy * randf_range(min_factor, 1.0)
