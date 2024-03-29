# Script for the user to configure things about the plugin.
class_name MnoConfig


# Number of controllers the MnoMaster should keep around.
const NUM_CONTROLLERS: int = 4
# Default color for button prompts and the empty part of a slider button's bar.
const GREYED_OUT_COLOR: Color = Color("424367")


# List of MnoSelectableThemes accessible in the dropdown when editing a MnoSelectable.
# When creating a new theme, add an entry here AND in get_selectable_theme() below.
enum SelectableThemes {
	PLAIN_SMALL,
	PLAIN_MEDIUM,
	PLAIN_LARGE,
	PLAIN_TOGGLE,
	PLAIN_TAB,
	PLAIN_CYCLE,
	PLAIN_SLIDER,
	# MY_COOL_THEME,
}


# Returns the MnoSelectableTheme associated with an enum entry.
# When creating a new theme, add an entry here AND in the enum above.
static func get_selectable_theme(index: int):
	match index:
		SelectableThemes.PLAIN_SMALL:
			return load("res://addons/mno_menus/button_themes/plain_small/plain_small.tres")
		SelectableThemes.PLAIN_MEDIUM:
			return load("res://addons/mno_menus/button_themes/plain_medium/plain_medium.tres")
		SelectableThemes.PLAIN_LARGE:
			return load("res://addons/mno_menus/button_themes/plain_large/plain_large.tres")
		SelectableThemes.PLAIN_TOGGLE:
			return load("res://addons/mno_menus/button_themes/plain_toggle/plain_toggle.tres")
		SelectableThemes.PLAIN_TAB:
			return load("res://addons/mno_menus/button_themes/plain_tab/plain_tab.tres")
		SelectableThemes.PLAIN_CYCLE:
			return load("res://addons/mno_menus/button_themes/plain_cycle/plain_cycle.tres")
		SelectableThemes.PLAIN_SLIDER:
			return load("res://addons/mno_menus/button_themes/plain_slider/plain_slider.tres")
		# SelectableThemes.MY_COOL_THEME:
			# return load("res:// [...] /my_cool_theme.tres")
	return null


# List of MnoCursorThemes accessible in the dropdown when editing a MnoCursor.
# When creating a new theme, add an entry here AND in get_cursor_theme() below.
enum CursorThemes {
	PLAIN_POINTER,
	PLAIN_CORNERS,
	# MY_COOL_THEME,
}


# Returns the MnoCursorTheme associated with an enum entry.
# When creating a new theme, add an entry here AND in the enum above.
static func get_cursor_theme(index: int):
	match index:
		CursorThemes.PLAIN_POINTER:
			return load("res://addons/mno_menus/cursor_themes/plain_pointer/plain_pointer.tres")
		CursorThemes.PLAIN_CORNERS:
			return load("res://addons/mno_menus/cursor_themes/plain_corners/plain_corners.tres")
		# CursorThemes.MY_COOL_THEME:
			# return preload("res:// [...] /my_cool_theme.tres")
	return null


# List of fonts accessible when editing text labels and stuff.
# When adding a new font, add an entry here AND in get_font() below.
enum Fonts {
	m3x6,
	m5x7,
	m6x11,
	# MY_COOL_FONT,
}


# Returns the Font (regular Godot resource) associated with an enum entry.
# When adding a new font, add an entry here AND in the enum above.
static func get_font(index: int) -> Font:
	match index:
		Fonts.m3x6:
			return preload("res://addons/mno_menus/button_themes/_fonts/m3x6.tres")
		Fonts.m5x7:
			return preload("res://addons/mno_menus/button_themes/_fonts/m5x7.tres")
		Fonts.m6x11:
			return preload("res://addons/mno_menus/button_themes/_fonts/m6x11.tres")
		# Fonts.MY_COOL_FONT:
			# return preload("res:// [...] /my_cool_font.tres")
	return null


# Returns the default control scheme used by a MnoInput.
# Edit this to better suit your game!
static func create_default_profile() -> Dictionary:
	return {
		# Deadzone for the analog sticks.
		"deadzone": 0.4,
		# Tolerance for snapping "close enough" inputs to directly up/down/left/right.
		# Higher number = more liberal snapping.
		"cardinal_snap": 0.15,
		
		# These control the mechanic where you can hold a direction in a menu and it scrolls really
		# fast.
		# Threshold = how long you need to hold for it to begin.
		# Interval = how quickly it "mashes" the direction.
		"ui_hold_threshold": 20,
		"ui_hold_interval": 6,
		
		# The amount of input buffer.
		# Input buffer is like "leeway": after the button is pressed, it still counts as "pressed"
		# for X more frames.
		# Makes it so that a jump/etc will still happen if the player presses the button a tiny bit
		# too early.
		"buffer": 8,
		
		# Controller input map.
		"gamepad": {
			# Correlated inputs are groups of inputs that get cleared and eaten together.
			# If In.A and In.B share a group, and you do in_clear(In.A), then it will also call
			# in_clear(B).
			# Same for in_eat(A) and in_eat(B).
			# Intended for when a gameplay action and a UI action share a physical button.
			# For example, in a 3D platformer where "jump" and "talk to NPC" share a button,
			# consider adding those actions to a group.
			# Or if there's a menu where the character can still move around, but certain button
			# presses used for UI should not get passed down to the character's action logic.
			"correlated": [
					# Here, when in_clear(In.UI_UP) is called, in_clear(In.UP) is also cleared.
					# And vice-versa.
					# And same for in_eat().
					[
						In.UI_UP,
						In.UP,
					],
					[
						In.UI_DOWN,
						In.DOWN,
					],
					[
						In.UI_LEFT,
						In.LEFT,
					],
					[
						In.UI_RIGHT,
						In.RIGHT,
					],
					[
						In.UI_OPTION_A,
						In.JUMP,
					],
					[
						In.UI_OPTION_B,
						In.JUMP,
					],
					[
						In.UI_CONFIRM,
						In.ATTACK,
					],
					[
						In.UI_CANCEL,
						In.SPECIAL,
					],
					[
						In.UI_PAGE_L,
						In.SHIELD,
					],
					[
						In.UI_PAGE_R,
						In.SHIELD,
					],
				],
			
			In.UP: [JOY_DPAD_UP],
			In.DOWN: [JOY_DPAD_DOWN],
			In.LEFT: [JOY_DPAD_LEFT],
			In.RIGHT: [JOY_DPAD_RIGHT],
			
			# These "horizontal" and "vertical" bits are where you put the joysticks.
			# Not the up/down/left/right.
			In.HORIZONTAL: [JOY_ANALOG_LX],
			In.VERTICAL: [JOY_ANALOG_LY],
			In.C_HORIZONTAL: [JOY_ANALOG_RX],
			In.C_VERTICAL: [JOY_ANALOG_RY],
			
			In.ATTACK: [JOY_DS_A],
			In.SPECIAL: [JOY_DS_B],
			In.JUMP: [JOY_DS_X, JOY_DS_Y],
			In.SHIELD: [JOY_L, JOY_R, JOY_L2, JOY_R2],
			In.TAUNT: [JOY_SELECT],
			
			# Inputs used in menus.
			In.UI_HORIZONTAL: [JOY_ANALOG_LX],
			In.UI_VERTICAL: [JOY_ANALOG_LY],
			In.UI_UP: [JOY_DPAD_UP],
			In.UI_DOWN: [JOY_DPAD_DOWN],
			In.UI_LEFT: [JOY_DPAD_LEFT],
			In.UI_RIGHT: [JOY_DPAD_RIGHT],
			In.UI_PAUSE: [JOY_START],
			In.UI_CONFIRM: [JOY_DS_A],
			In.UI_CANCEL: [JOY_DS_B],
			In.UI_OPTION_A: [JOY_DS_Y],
			In.UI_OPTION_B: [JOY_DS_X],
			In.UI_PAGE_L: [JOY_L, JOY_L2],
			In.UI_PAGE_R: [JOY_R, JOY_R2],
		},
		
		# Keyboard input map.
		"keyboard": {
			# See above for notes on correlated inputs.
			"correlated": [
					[
						In.UI_UP,
						In.UP,
					],
					[
						In.UI_DOWN,
						In.DOWN,
					],
					[
						In.UI_LEFT,
						In.LEFT,
					],
					[
						In.UI_RIGHT,
						In.RIGHT,
					],
					[
						In.JUMP,
					],
					[
						In.ATTACK,
					],
					[
						In.UI_CONFIRM,
						In.JUMP,
						In.ATTACK,
					],
					[
						In.UI_CANCEL,
						In.SPECIAL,
					],
				],
			
			In.UP: [KEY_UP, KEY_W],
			In.DOWN: [KEY_DOWN, KEY_S],
			In.LEFT: [KEY_LEFT, KEY_A],
			In.RIGHT: [KEY_RIGHT, KEY_D],
			
			# Note that the "horizontal" and "vertical" inputs aren't used... because keyboards
			# don't have joysticks.
			
			In.ATTACK: [KEY_Z],
			In.SPECIAL: [KEY_X],
			In.JUMP: [KEY_SPACE],
			In.SHIELD: [KEY_SHIFT],
			In.TAUNT: [KEY_F],
			
			In.C_UP: [],
			In.C_DOWN: [],
			In.C_LEFT: [],
			In.C_RIGHT: [],
			
			In.UI_UP: [KEY_UP, KEY_W],
			In.UI_DOWN: [KEY_DOWN, KEY_S],
			In.UI_LEFT: [KEY_LEFT, KEY_A],
			In.UI_RIGHT: [KEY_RIGHT, KEY_D],
			In.UI_PAUSE: [KEY_ENTER, KEY_ESCAPE],
			In.UI_CONFIRM: [KEY_Z, KEY_SPACE],
			In.UI_CANCEL: [KEY_X, KEY_BACKSPACE],
			In.UI_OPTION_A: [KEY_C],
			In.UI_OPTION_B: [KEY_V],
			In.UI_PAGE_L: [KEY_Q],
			In.UI_PAGE_R: [KEY_E],
		},
	}

