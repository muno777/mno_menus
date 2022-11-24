# Just a big enum with all of the input types.
# Feel free to add to this... removing might break some stuff.
# Input names are based on platform fighters ^^;
class_name In

enum {
	HEADER,
	
	# Start of gameplay section.
	GAMEPLAY_HEADER,
	
	# Buttons!
	ATTACK,
	SPECIAL,
	JUMP,
	SHIELD,
	TAUNT,
	
	# Left joystick.
	LEFT,
	RIGHT,
	UP,
	DOWN,
	HORIZONTAL,
	VERTICAL,
	
	# Right joystick.
	C_LEFT,
	C_RIGHT,
	C_UP,
	C_DOWN,
	C_HORIZONTAL,
	C_VERTICAL,
	
	# End of gameplay section.
	GAMEPLAY_FOOTER,
	
	# Beginning of menu section.
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
	UI_OPTION_A,	# Option A and B are for buttons that do various things on menus, like X and Y.
	UI_OPTION_B,	# A should be the "left" one and B should be the "right" one.
	UI_PAGE_L,		# Page L and R are for tabbing through pages, etc.
	UI_PAGE_R,
	
	# End of menu section.
	UI_FOOTER,
	
	FOOTER,
}
