class_name In

enum {
	HEADER,
	GAMEPLAY_HEADER,
	
	# Buttons
	
	ATTACK,
	SPECIAL,
	JUMP,
	SHIELD,
	TAUNT,
	
	# L Stick
	
	LEFT,
	RIGHT,
	UP,
	DOWN,
	HORIZONTAL,
	VERTICAL,
	
	# C Stick
	
	C_LEFT,
	C_RIGHT,
	C_UP,
	C_DOWN,
	C_HORIZONTAL,
	C_VERTICAL,
	
	GAMEPLAY_FOOTER,
	
	# UI (NOT for use with any inputs that affect gameplay, aside from pausing and stuff. NOT replay safe.)
	
	UI_HEADER,
	
	UI_HORIZONTAL,
	UI_VERTICAL,
	UI_LEFT,
	UI_RIGHT,
	UI_UP,
	UI_DOWN,
	UI_CONFIRM,
	UI_CANCEL,
	UI_PAUSE,
	UI_OPTION_A,	# context-sensitive menus
	UI_OPTION_B,	# context-sensitive menus
	UI_PAGE_L,
	UI_PAGE_R,
	
	UI_FOOTER,
	
	FOOTER,
}
