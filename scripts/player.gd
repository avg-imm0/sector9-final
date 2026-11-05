extends CharacterBody2D

@export var walk_speed := 230.0
@export var sprint_speed := 330.0
@export var acceleration := 1800.0
@export var friction := 2200.0

@onready var sprite: Sprite2D = $Sprite
@onready var aim: Node2D = $Aim
@onready var flashlight: PointLight2D = $Aim/Flashlight

var _bob_time := 0.0
var _sprite_base := Vector2.ZERO
var _step_distance := 0.0


func _ready() -> void:
	add_to_group("player")
	_sprite_base = sprite.position


func _physics_process(delta: float) -> void:
	var direction := _read_direction()
	if Dialogue.is_open or GameState.ui_blocked:
		direction = Vector2.ZERO

	var sprinting := Input.is_physical_key_pressed(KEY_SHIFT)
	var speed := sprint_speed if sprinting else walk_speed
	var target := direction * speed
	if direction == Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	else:
		velocity = velocity.move_toward(target, acceleration * delta)

	move_and_slide()
	_update_footsteps(delta, sprinting)
	_update_aim(delta)
	_update_bob(delta, direction.length() > 0.01 and velocity.length() > 8.0)


func _update_footsteps(delta: float, sprinting: bool) -> void:
	if Dialogue.is_open or GameState.ui_blocked:
		return
	var moved := velocity.length() * delta
	if moved < 0.5:
		_step_distance = minf(_step_distance, 32.0)
		return
	_step_distance += moved
	var stride := 112.0 if sprinting else 88.0
	if _step_distance >= stride:
		_step_distance = 0.0
		Audio.play_footstep()


func _read_direction() -> Vector2:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var wasd := Vector2(
		float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)),
		float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W))
	)
	if wasd.length_squared() > 0.01:
		direction = wasd.normalized()
	return direction.limit_length(1.0)


func _update_aim(delta: float) -> void:
	if Dialogue.is_open or GameState.ui_blocked:
		return
	var to_mouse := get_global_mouse_position() - global_position
	if to_mouse.length_squared() < 4.0:
		return
	var angle := to_mouse.angle()
	aim.rotation = angle
	sprite.rotation = lerp_angle(sprite.rotation, angle, 1.0 - exp(-14.0 * delta))


func _update_bob(delta: float, moving: bool) -> void:
	if moving:
		_bob_time += delta * (9.0 if velocity.length() < walk_speed + 10.0 else 12.0)
		sprite.position = _sprite_base + Vector2(0, sin(_bob_time) * 1.3)
	else:
		sprite.position = sprite.position.lerp(_sprite_base, minf(1.0, delta * 8.0))


func _unhandled_input(event: InputEvent) -> void:
	if Dialogue.is_open or GameState.ui_blocked:
		return
	if not (event is InputEventKey):
		return
	var key_event := event as InputEventKey
	if key_event.pressed and not key_event.echo and key_event.physical_keycode == KEY_F:
		flashlight.visible = not flashlight.visible
		get_viewport().set_input_as_handled()
