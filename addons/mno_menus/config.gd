class_name MnoConfig
# Script for the user to configure things about the plugin.


const NUM_CONTROLLERS: int = 4


enum SelectableThemes {
	PLAIN_SMALL,
	PLAIN_MEDIUM,
	PLAIN_LARGE,
	PLAIN_TOGGLE,
	PLAIN_TAB,
	PLAIN_CYCLE,
	PLAIN_SLIDER,
}


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
	return null


enum CursorThemes {
	PLAIN_POINTER,
	PLAIN_CORNERS,
}


static func get_cursor_theme(index: int):
	match index:
		CursorThemes.PLAIN_POINTER:
			return load("res://addons/mno_menus/cursor_themes/plain_pointer/plain_pointer.tres")
		CursorThemes.PLAIN_CORNERS:
			return load("res://addons/mno_menus/cursor_themes/plain_corners/plain_corners.tres")
	return null


enum Fonts {
	m3x6,
	m5x7,
	m6x11,
}


static func get_font(index: int) -> Font:
	match index:
		Fonts.m3x6:
			return preload("res://assets/fonts/m3x6.tres")
		Fonts.m5x7:
			return preload("res://assets/fonts/m5x7.tres")
		Fonts.m6x11:
			return preload("res://assets/fonts/m6x11.tres")
	return null


static func create_default_profile() -> Dictionary:
	return {
		"deadzone": 0.4,
		"cardinal_snap": 0.15,
		
		"ui_hold_threshold": 20,
		"ui_hold_interval": 6,
		
		"gamepad": {
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
			
			In.HORIZONTAL: [JOY_ANALOG_LX],
			In.VERTICAL: [JOY_ANALOG_LY],
			In.C_HORIZONTAL: [JOY_ANALOG_RX],
			In.C_VERTICAL: [JOY_ANALOG_RY],
			
			In.ATTACK: [JOY_DS_A],
			In.SPECIAL: [JOY_DS_B],
			In.JUMP: [JOY_DS_X, JOY_DS_Y],
			In.SHIELD: [JOY_L, JOY_R, JOY_L2, JOY_R2],
			In.TAUNT: [JOY_SELECT],
			
			# Menu
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
		
		"keyboard": {
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

