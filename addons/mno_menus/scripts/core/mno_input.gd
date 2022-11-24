# Behind-the-scenes object to read a controller's inputs (either keyboard or gamepad).
# MnoMaster spawns in a handful of these, and you can read them with MnoMaster.in_pressed(), etc.
tool
extends Mno2D
class_name MnoInput, "res://addons/mno_menus/icons/mno_input.png"

# Emitted when a button is initially pressed.
# Input = a constant from the In enum.
signal input_pressed(input)

# Const used to check inputs for ALL of the controllers at once.
const DEVICE_ALL = -1
# Value of gamepad_num for the keyboard input reader.
const DEVICE_KEYBOARD = 0
# Can be DEVICE_KEYBOARD or 1, 2, 3, 4, etc for gamepads.
var gamepad_num: int = DEVICE_KEYBOARD
# Multi-dimensional array that holds all button pressed/held data.
var inputs = []
# Value of the left joystick.
var joystick = Vector2(0, 0)
# Value of the right joystick.
var c_stick = Vector2(0, 0)
# Value of the joystick used to control menu actions (usually just the left joystick).
var ui_stick = Vector2(0, 0)
# The current profile, which holds all of the button assignments and other input settings.
var profile: Dictionary = MnoConfig.create_default_profile()
# Handy reference to the current mno_master.
onready var mno_master = Mno.get_mno_master(self)
# Timers for the # Responsible for the mechanic where you can hold a direction and it scrolls
# through menu options really fast.
var ui_hold_timer: int = 0
var tab_hold_timer: int = 0


# Populates inputs array.
func _ready():
	for _i in range(In.FOOTER):
		inputs.append([0, 0])


# Responsible for the mechanic where you can hold a direction and it scrolls through menu options
# really fast.
# Does everything twice, since it happens for PAGE_L and PAGE_R too (w/ separate timers).
func process_ui_hold() -> void:
	var held_uis: Array = []
	var held_tabs: Array = []
	
	# Gets a list of held directions, reset timer if empty.
	for i in [In.UI_UP, In.UI_DOWN, In.UI_LEFT, In.UI_RIGHT]:
		if in_held(i):
			held_uis.push_back(i)
	if held_uis.empty():
		ui_hold_timer = 0
	
	# Gets a list of held directions, reset timer if empty.
	for i in [In.UI_PAGE_L, In.UI_PAGE_R]:
		if in_held(i):
			held_tabs.push_back(i)
	if held_tabs.empty():
		tab_hold_timer = 0
	
	# Repeatedly "presses" the input.
	for i in held_uis:
		if ui_hold_timer > profile.ui_hold_threshold && (ui_hold_timer - profile.ui_hold_threshold) % profile.ui_hold_interval == 0:
			inputs[i][0] = profile.buffer
	
	# Repeatedly "presses" the input.
	for i in held_tabs:
		if tab_hold_timer > profile.ui_hold_threshold && (tab_hold_timer - profile.ui_hold_threshold) % profile.ui_hold_interval == 0:
			inputs[i][0] = profile.buffer
	
	# Increments timers.
	if !held_uis.empty():
		ui_hold_timer += 1
	if !held_tabs.empty():
		tab_hold_timer += 1


func tick() -> void:
	# Processes keyboard inputs.
	if gamepad_num == DEVICE_KEYBOARD:
		for i in range(In.FOOTER):
			if profile.keyboard.has(i):
				process_key(i, profile.keyboard[i])
		
		sync_joysticks_to_buttons()
		process_ui_hold()
		
		return
	
	# Below: processes controller inputs.
	
	joystick = Vector2(
		Input.get_joy_axis(gamepad_num - 1, profile.gamepad[In.HORIZONTAL][0]),
		Input.get_joy_axis(gamepad_num - 1, profile.gamepad[In.VERTICAL][0])
		)
	
	c_stick = Vector2(
		Input.get_joy_axis(gamepad_num - 1, profile.gamepad[In.C_HORIZONTAL][0]),
		Input.get_joy_axis(gamepad_num - 1, profile.gamepad[In.C_VERTICAL][0])
		)
	
	ui_stick = Vector2(
		Input.get_joy_axis(gamepad_num - 1, profile.gamepad[In.UI_HORIZONTAL][0]),
		Input.get_joy_axis(gamepad_num - 1, profile.gamepad[In.UI_VERTICAL][0])
		)
	
	var deadzone = profile.deadzone
	var cardinal_snap = profile.cardinal_snap
	
	if joystick.length() < deadzone:
		joystick = Vector2.ZERO
	
	if c_stick.length() < deadzone:
		c_stick = Vector2.ZERO
	
	if ui_stick.length() < deadzone:
		ui_stick = Vector2.ZERO
	
	if abs(joystick.x) < cardinal_snap:
		joystick.x = 0

	if abs(joystick.y) < cardinal_snap:
		joystick.y = 0

	if abs(c_stick.x) < cardinal_snap:
		c_stick.x = 0

	if abs(c_stick.y) < cardinal_snap:
		c_stick.y = 0

	if abs(ui_stick.x) < cardinal_snap:
		ui_stick.x = 0

	if abs(ui_stick.y) < cardinal_snap:
		ui_stick.y = 0
	
	for i in range(In.FOOTER):
		if profile.gamepad.has(i):
			match(i):
				In.HORIZONTAL, In.VERTICAL, In.C_HORIZONTAL, In.C_VERTICAL, In.UI_HORIZONTAL, In.UI_VERTICAL:
					pass
				_:
					process_button(i, profile.gamepad[i])
	
	if joystick == Vector2.ZERO:
		
		joystick = Vector2(
			-inputs[In.LEFT][1] + inputs[In.RIGHT][1],
			+inputs[In.DOWN][1] - inputs[In.UP][1]
			).normalized()
	
	if c_stick == Vector2.ZERO:
		
		c_stick = Vector2(
			-inputs[In.C_LEFT][1] + inputs[In.C_RIGHT][1],
			+inputs[In.C_DOWN][1] - inputs[In.C_UP][1]
			).normalized()
	
	if ui_stick == Vector2.ZERO:
		
		ui_stick = Vector2(
			-inputs[In.UI_LEFT][1] + inputs[In.UI_RIGHT][1],
			+inputs[In.UI_DOWN][1] - inputs[In.UI_UP][1]
			).normalized()
	
	process_ui_hold()


# If there's no joystick input currently, this will change the joystick input to match the direction
# BUTTONS (e.g. dpad, arrow keys).
func sync_joysticks_to_buttons():
		
	joystick = Vector2(
		-inputs[In.LEFT][1] + inputs[In.RIGHT][1],
		+inputs[In.DOWN][1] - inputs[In.UP][1]
		).normalized()
	
	c_stick = Vector2(
		-inputs[In.C_LEFT][1] + inputs[In.C_RIGHT][1],
		+inputs[In.C_DOWN][1] - inputs[In.C_UP][1]
		).normalized()
	
	ui_stick = Vector2(
		-inputs[In.UI_LEFT][1] + inputs[In.UI_RIGHT][1],
		+inputs[In.UI_DOWN][1] - inputs[In.UI_UP][1]
		).normalized()


# Interfaces with the keyboard.
func process_key(input: int, keys: Array):
	var held: bool = false
	for i in keys:
		if Input.is_key_pressed(i):
			held = true
	
	process_buffering(input, held)


# Interfaces with the gamepad.
func process_button(input: int, buttons: Array):
	
	var held: bool = false
	var held_stick: bool = false
	
	for i in buttons:
		if Input.is_joy_button_pressed(gamepad_num - 1, i):
			held = true
	
	# Takes the joystick inputs and change the directional buttons to match.
	# The reverse of sync_joysticks_to_buttons().
	var tolerance: float = PI * 5/16
	
	match input:
		In.LEFT:
			held_stick = joystick.x < 0 && joystick.angle_to(Vector2.LEFT) < tolerance
		In.RIGHT:
			held_stick = joystick.x > 0 && joystick.angle_to(Vector2.RIGHT) < tolerance
		In.UP:
			held_stick = joystick.y < 0 && joystick.angle_to(Vector2.UP) < tolerance
		In.DOWN:
			held_stick = joystick.y > 0 && joystick.angle_to(Vector2.DOWN) < tolerance
		In.C_LEFT:
			held_stick = c_stick.x < 0 && c_stick.angle_to(Vector2.LEFT) < tolerance
		In.C_RIGHT:
			held_stick = c_stick.x > 0 && c_stick.angle_to(Vector2.RIGHT) < tolerance
		In.C_UP:
			held_stick = c_stick.y < 0 && c_stick.angle_to(Vector2.UP) < tolerance
		In.C_DOWN:
			held_stick = c_stick.y > 0 && c_stick.angle_to(Vector2.DOWN) < tolerance
		In.UI_LEFT:
			held_stick = ui_stick.x < 0 && ui_stick.angle_to(Vector2.LEFT) < tolerance
		In.UI_RIGHT:
			held_stick = ui_stick.x > 0 && ui_stick.angle_to(Vector2.RIGHT) < tolerance
		In.UI_UP:
			held_stick = ui_stick.y < 0 && ui_stick.angle_to(Vector2.UP) < tolerance
		In.UI_DOWN:
			held_stick = ui_stick.y > 0 && ui_stick.angle_to(Vector2.DOWN) < tolerance
	
	process_buffering(input, held || held_stick)


# Takes the "is held or not" bool and update "just pressed" and "being held".
func process_buffering(input: int, held: bool):
	
	# [1] = "is held", [0] = "just got pressed"
	
	if held:
		if !inputs[input][1]:
			inputs[input][1] = 1
			inputs[input][0] = profile.buffer
			emit_signal("input_pressed", input)
	else:
		inputs[input][1] = 0
	if inputs[input][0]:
		inputs[input][0] -= 1


# Checks if an input was just pressed on this controller (including buffer time).
# If clear is true, it will also call in_clear(num).
func in_pressed(num: int, clear: bool = false) -> bool:
	var result: bool = (inputs[num][0] > 1)
	if clear:
		in_clear(num)
	return result


# Gets the remaining buffer time for an input.
# Higher number = more recent press, up to the profile's buffer amount.
# If clear is true, it will also call in_clear(num).
func in_buffer_amt(num: int, clear: bool = false) -> int:
	var result: int = inputs[num][0]
	if clear:
		in_clear(num)
	return result


# Gets whether or not an input is held on this controller.
func in_held(num: int) -> bool:
	return (inputs[num][1] > 0)


# Clears the remaining buffer time for an input.
func in_clear(num: int):
	inputs[num][0] = 0
