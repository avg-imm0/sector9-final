extends Node

## Central audio: rain beds, distant city, neon hum, footsteps and puzzle SFX.
## Autoloaded as "Audio". Does nothing in headless runs so tests stay quiet.

const RAIN_STREAM: AudioStream = preload("res://assets/audio/rain_loop.wav")
const TRAFFIC_STREAM: AudioStream = preload("res://assets/audio/traffic_hum.wav")
const DRAIN_STREAM: AudioStream = preload("res://assets/audio/drain_loop.wav")
const NEON_STREAM: AudioStream = preload("res://assets/audio/neon_buzz.wav")
const THUNDER_STREAM: AudioStream = preload("res://assets/audio/thunder.wav")
const PASSBY_STREAM: AudioStream = preload("res://assets/audio/footsteps_pass.wav")
const FOOTSTEP_STREAM: AudioStream = preload("res://assets/audio/footstep.wav")
const BREAKER_STREAM: AudioStream = preload("res://assets/audio/breaker.ogg")
const FAIL_STREAM: AudioStream = preload("res://assets/audio/fail.wav")
const POWERUP_STREAM: AudioStream = preload("res://assets/audio/powerup.wav")
const TICK_STREAM: AudioStream = preload("res://assets/audio/tick.wav")

var _enabled := false
var _rng := RandomNumberGenerator.new()
var _thunder_timer := 16.0
var _passby_timer := 34.0
var _neon_volume := -80.0

var _rain: AudioStreamPlayer
var _traffic: AudioStreamPlayer
var _drain: AudioStreamPlayer
var _neon: AudioStreamPlayer
var _thunder: AudioStreamPlayer
var _passby: AudioStreamPlayer
var _footstep: AudioStreamPlayer
var _breaker: AudioStreamPlayer
var _fail: AudioStreamPlayer
var _powerup: AudioStreamPlayer
var _tick: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rng.randomize()
	_enabled = DisplayServer.get_name() != "headless"

	_rain = _make_loop(RAIN_STREAM, -17.0)
	_traffic = _make_loop(TRAFFIC_STREAM, -27.0)
	_drain = _make_loop(DRAIN_STREAM, -31.0)
	_neon = _make_loop(NEON_STREAM, -80.0)
	_thunder = _make_one_shot(THUNDER_STREAM)
	_passby = _make_one_shot(PASSBY_STREAM)
	_footstep = _make_one_shot(FOOTSTEP_STREAM)
	_breaker = _make_one_shot(BREAKER_STREAM)
	_fail = _make_one_shot(FAIL_STREAM)
	_powerup = _make_one_shot(POWERUP_STREAM)
	_tick = _make_one_shot(TICK_STREAM)

	if not _enabled:
		return

	GameState.power_restored.connect(_on_power_restored)
	if GameState.power_on:
		set_power(true, true)
	_thunder_timer = _rng.randf_range(11.0, 22.0)
	_passby_timer = _rng.randf_range(25.0, 48.0)


func _make_loop(stream: AudioStream, volume: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.stream = _looping(stream)
	player.volume_db = volume
	add_child(player)
	if _enabled:
		player.play()
	return player


func _make_one_shot(stream: AudioStream) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = -8.0
	add_child(player)
	return player


func _looping(stream: AudioStream) -> AudioStream:
	if stream is AudioStreamWAV:
		var wav := (stream as AudioStreamWAV).duplicate() as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = 0
		return wav
	return stream


func set_power(on: bool, instant: bool = false) -> void:
	_neon_volume = -22.0 if on else -80.0
	if not _enabled or _neon == null:
		return
	if instant:
		_neon.volume_db = _neon_volume
		return
	var tween := create_tween()
	tween.tween_property(_neon, "volume_db", _neon_volume, 1.2).set_trans(Tween.TRANS_SINE)


func _on_power_restored() -> void:
	set_power(true)


func _process(delta: float) -> void:
	if not _enabled:
		return

	_thunder_timer -= delta
	if _thunder_timer <= 0.0:
		_thunder_timer = _rng.randf_range(22.0, 46.0)
		_thunder.pitch_scale = _rng.randf_range(0.9, 1.08)
		_thunder.volume_db = _rng.randf_range(-18.0, -13.0)
		_thunder.play()

	_passby_timer -= delta
	if _passby_timer <= 0.0:
		_passby_timer = _rng.randf_range(35.0, 65.0)
		_passby.pitch_scale = _rng.randf_range(0.92, 1.04)
		_passby.volume_db = -26.0
		_passby.play()


func play_footstep() -> void:
	if not _enabled:
		return
	_footstep.pitch_scale = _rng.randf_range(0.9, 1.07)
	_footstep.volume_db = _rng.randf_range(-16.0, -12.0)
	_footstep.play()


func play_breaker() -> void:
	if not _enabled:
		return
	_breaker.pitch_scale = _rng.randf_range(0.94, 1.08)
	_breaker.volume_db = -7.0
	_breaker.play()


func play_fail() -> void:
	if not _enabled:
		return
	_fail.volume_db = -6.0
	_fail.play()


func play_power_up() -> void:
	if not _enabled:
		return
	_powerup.volume_db = -7.0
	_powerup.play()


func play_type_tick() -> void:
	if not _enabled:
		return
	_tick.pitch_scale = _rng.randf_range(0.9, 1.18)
	_tick.volume_db = -30.0
	_tick.play()


func play_ui_click() -> void:
	if not _enabled:
		return
	_tick.pitch_scale = 0.78
	_tick.volume_db = -17.0
	_tick.play()
