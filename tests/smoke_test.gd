extends Node

## Headless smoke test for the vertical slice.
## Run with:
##   godot --headless --path . res://tests/smoke_test.tscn

var _failures := 0
var _main: Node


func _check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: " + description)
	else:
		_failures += 1
		print("FAIL: " + description)


func _tap_key(code: Key) -> void:
	var press := InputEventKey.new()
	press.physical_keycode = code
	press.keycode = code
	press.pressed = true
	Input.parse_input_event(press)
	await get_tree().process_frame
	var release := InputEventKey.new()
	release.physical_keycode = code
	release.keycode = code
	release.pressed = false
	Input.parse_input_event(release)
	await get_tree().process_frame


func _ready() -> void:
	_main = load("res://scenes/main.tscn").instantiate()
	add_child(_main)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().physics_frame

	_check(GameState.objective == "Поговорить со сторожем", "initial objective")
	_check(not GameState.power_on, "power starts off")

	Dialogue.start("intro")
	_check(Dialogue.is_open and Dialogue.current_id == "intro", "intro dialogue opens")
	Dialogue._advance()
	_check(not Dialogue._typing, "first line finishes typing")
	Dialogue._advance()
	Dialogue._advance()
	Dialogue._advance()
	Dialogue._advance()
	_check(Dialogue._choices_shown, "choices appear after last line")
	Dialogue._on_choice_pressed(0)
	_check(Dialogue.current_id == "who", "choice switches dialogue branch")
	Dialogue.close()
	_check(Dialogue.last_finished_id == "who", "last_finished_id is tracked")
	_check(GameState.objective == "Поговорить со сторожем", "side dialogue does not advance objective")

	await _tap_key(KEY_E)
	_check(Dialogue.is_open and Dialogue.current_id == "intro", "E near NPC opens dialogue")
	await _tap_key(KEY_ESCAPE)
	_check(not Dialogue.is_open, "ESC closes dialogue")
	_check(GameState.objective == "Восстановить питание в щитке", "NPC dialogue advances objective")

	var cat: Node = _main.get_node("World/Cat")
	_check(cat != null, "cat NPC exists in the courtyard")
	cat.interact()
	_check(Dialogue.is_open and Dialogue.current_id == "cat", "cat has a pre-power dialogue")
	Dialogue.close()

	var backroom: Node = _main.get_node("World/Backroom")
	_check(backroom != null, "backroom door exists")
	backroom.interact()
	_check(Dialogue.current_id == "backroom_locked", "backroom is locked without power")
	Dialogue.close()

	var girl: Node = _main.get_node("World/UmbrellaGirl")
	_check(girl != null, "umbrella girl exists in the courtyard")
	girl.interact()
	_check(Dialogue.current_id == "girl", "umbrella girl has a pre-power dialogue")
	Dialogue.close()

	var panel: Node = _main.get_node("World/Panel")
	panel.interact()
	_check(GameState.ui_blocked, "puzzle UI blocks input")
	panel._press(2)
	panel._press(3)
	panel._press(1)
	_check(panel._solved, "correct sequence solves puzzle")
	_check(GameState.power_on, "power is restored")
	_check(GameState.objective == "Вернуться к Грише", "objective changes after puzzle")

	await get_tree().create_timer(1.6).timeout
	_check(not GameState.ui_blocked, "puzzle UI closes after solving")

	var kiosk: Node = _main.get_node("World/Kiosk")
	_check(kiosk.sign_light.energy > 0.5, "kiosk neon turns on")
	_check(kiosk.window_light.energy > 0.3, "kiosk window light turns on")
	_check(kiosk.window_glow.color.a > 0.1, "kiosk window glow turns on")

	await _tap_key(KEY_E)
	_check(Dialogue.current_id == "intro_powered", "powered dialogue is selected")
	await _tap_key(KEY_ESCAPE)
	_check(GameState.objective == "Открыть подсобку за киоском", "Grisha gives the backroom objective")
	_check(GameState.has_key, "Grisha gives the backroom key")

	girl.interact()
	_check(Dialogue.current_id == "girl_powered", "umbrella girl reacts to restored power")
	Dialogue.close()

	var cat_powered_node: Node = _main.get_node("World/Cat")
	_check(cat_powered_node != null, "cat NPC exists in the courtyard")
	cat_powered_node.interact()
	_check(Dialogue.is_open and Dialogue.current_id == "cat_powered", "cat reacts to restored power")
	Dialogue._advance()
	Dialogue._advance()
	Dialogue._advance()
	Dialogue._advance()
	Dialogue._advance()
	_check(Dialogue._choices_shown, "cat dialogue offers choices")
	Dialogue._on_choice_pressed(0)
	_check(Dialogue.current_id == "cat_pet", "petting the cat opens a branch")
	Dialogue.close()
	_check(not Dialogue.is_open, "cat dialogue closes")

	var ending: Node = _main.get_node("Ending")
	backroom.interact()
	_check(Dialogue.current_id == "backroom", "unlocked backroom dialogue opens")
	Dialogue.close()
	_check(ending.visible, "finishing the backroom dialogue shows the ending card")
	_check(GameState.ending_seen and GameState.ui_blocked, "ending card sets the end state")
	_check(GameState.objective == "Срез пройден", "ending card sets the final objective")
	ending.hide_ending()
	_check(not ending.visible and not GameState.ui_blocked, "ending card can be dismissed")

	print("SMOKE RESULT: %d failure(s)" % _failures)
	get_tree().quit(1 if _failures > 0 else 0)
