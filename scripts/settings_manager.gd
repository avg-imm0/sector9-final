extends Node

## User settings: volumes, fullscreen and dialogue text speed.
## Autoloaded as "AppSettings" so both the menu and the pause screen use one source.

const CONFIG_PATH := "user://settings.cfg"
const AMBIENCE_BUS := "Ambience"
const SFX_BUS := "SFX"

var master_volume := 0.85
var ambience_volume := 0.82
var sfx_volume := 0.9
var text_speed := 1.0
var fullscreen := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_bus(AMBIENCE_BUS)
	_ensure_bus(SFX_BUS)
	load_settings()
	apply_all()


func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) != -1:
		return
	AudioServer.add_bus()
	var index := AudioServer.bus_count - 1
	AudioServer.set_bus_name(index, bus_name)
	AudioServer.set_bus_send(index, "Master")


func apply_all() -> void:
	apply_audio()
	apply_display()


func apply_audio() -> void:
	_set_bus_linear("Master", master_volume)
	_set_bus_linear(AMBIENCE_BUS, ambience_volume)
	_set_bus_linear(SFX_BUS, sfx_volume)


func _set_bus_linear(bus_name: String, value: float) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index < 0:
		return
	var clamped := clampf(value, 0.0, 1.0)
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(clamped, 0.0001)))
	AudioServer.set_bus_mute(index, clamped <= 0.001)


func apply_display() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	if DisplayServer.window_get_mode() != mode:
		DisplayServer.window_set_mode(mode)


func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(CONFIG_PATH) != OK:
		return
	master_volume = float(config.get_value("audio", "master", master_volume))
	ambience_volume = float(config.get_value("audio", "ambience", ambience_volume))
	sfx_volume = float(config.get_value("audio", "sfx", sfx_volume))
	text_speed = float(config.get_value("dialogue", "text_speed", text_speed))
	fullscreen = bool(config.get_value("display", "fullscreen", fullscreen))
	text_speed = clampf(text_speed, 0.5, 2.0)


func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "master", master_volume)
	config.set_value("audio", "ambience", ambience_volume)
	config.set_value("audio", "sfx", sfx_volume)
	config.set_value("dialogue", "text_speed", text_speed)
	config.set_value("display", "fullscreen", fullscreen)
	config.save(CONFIG_PATH)


func set_master(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	apply_audio()
	save_settings()


func set_ambience(value: float) -> void:
	ambience_volume = clampf(value, 0.0, 1.0)
	apply_audio()
	save_settings()


func set_sfx(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	apply_audio()
	save_settings()


func set_text_speed(value: float) -> void:
	text_speed = clampf(value, 0.5, 2.0)
	save_settings()


func set_fullscreen(value: bool) -> void:
	fullscreen = value
	apply_display()
	save_settings()


func reset_defaults() -> void:
	master_volume = 0.85
	ambience_volume = 0.82
	sfx_volume = 0.9
	text_speed = 1.0
	fullscreen = false
	apply_all()
	save_settings()
