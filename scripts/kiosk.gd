extends Node2D

@onready var neon: Label = $Sign/Neon
@onready var sub: Label = $Sign/Sub
@onready var glow: Sprite2D = $SignGlow
@onready var sign_light: PointLight2D = $SignLight
@onready var window_light: PointLight2D = $WindowLight
@onready var window_glow: ColorRect = $WindowGlow


func _ready() -> void:
	_apply_power(GameState.power_on, true)
	GameState.power_restored.connect(_on_power_restored)


func _on_power_restored() -> void:
	_apply_power(true, false)


func _apply_power(on: bool, instant: bool) -> void:
	if not on:
		neon.modulate = Color(1, 1, 1, 0.16)
		sub.modulate = Color(1, 1, 1, 0.1)
		glow.modulate = Color(1, 1, 1, 0)
		sign_light.energy = 0.0
		window_light.energy = 0.0
		window_glow.color = Color(1, 0.55, 0.22, 0)
		return

	if instant:
		neon.modulate = Color(1, 1, 1, 1)
		sub.modulate = Color(1, 1, 1, 0.9)
		glow.modulate = Color(1, 1, 1, 0.85)
		sign_light.energy = 1.1
		window_light.energy = 1.0
		window_glow.color = Color(1, 0.55, 0.22, 0.2)
		return

	var tween := create_tween()
	tween.tween_property(neon, "modulate", Color(1, 1, 1, 0.9), 0.08)
	tween.tween_property(neon, "modulate", Color(1, 1, 1, 0.2), 0.06)
	tween.tween_property(neon, "modulate", Color(1, 1, 1, 1.0), 0.12)
	tween.parallel().tween_property(sub, "modulate", Color(1, 1, 1, 0.9), 0.35)
	tween.parallel().tween_property(glow, "modulate", Color(1, 1, 1, 0.85), 0.5)
	tween.parallel().tween_property(sign_light, "energy", 1.1, 0.5)
	tween.parallel().tween_property(window_light, "energy", 1.0, 0.7)
	tween.parallel().tween_property(window_glow, "color", Color(1, 0.55, 0.22, 0.2), 0.7)
