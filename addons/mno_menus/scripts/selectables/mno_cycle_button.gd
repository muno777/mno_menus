# A special MnoButton for selecting from a list of preset options.
tool
extends MnoButton
class_name MnoCycleButton, "res://addons/mno_menus/icons/mno_cycle_button.png"


# Whether or not the player can use In.UI_OPTION_A and In.UI_OPTION_B to quickly scroll thru the
# options, back and forth.
export var uses_option_a_b: bool = false
# The color for the button prompts if the above option is enabled.
export var button_color: Color = MnoConfig.GREYED_OUT_COLOR
# The list of options.
export(Array, String) var options: Array = [
	"A",
	"B",
	"C",
] setget set_options
# The current value.
var on: int = 0
# The direction the option was just changed.
# Used for the cool sliding anim.
var option_change_direction: int = 0


func click() -> void:
	.click()
	
	if !enabled:
		return
	
	option_change_direction = 1
	on += 1
	mod_option()


# Sets the theme to a valid one by default.
func _ready() -> void:
	if Engine.editor_hint && theme <= MnoConfig.SelectableThemes.PLAIN_LARGE:
		set_theme(MnoConfig.SelectableThemes.PLAIN_CYCLE)


# Loops the option if the player reaches one end of the list.
func mod_option() -> void:
	on = posmod(on, options.size())


func read_inputs() -> void:
	.read_inputs()
	
	if !uses_option_a_b:
		return
	
	if in_pressed(In.UI_OPTION_B, false, true):
		click()
	
	if in_pressed(In.UI_OPTION_A, false, true):
		click()
		option_change_direction = -1
		on -= 2
		mod_option()


func get_align_offset() -> Vector2:
	if !(get_current_theme() is MnoCycleButtonTheme):
		printerr("Cycle button has non cycle button theme...")
		return .get_align_offset()
	return .get_align_offset() + Vector2.DOWN * get_current_theme().label_y_offset


# Draws the stuff.
func _draw() -> void:
	var ts = get_current_theme_state()
	
	if !(get_current_theme() is MnoCycleButtonTheme):
		printerr("Cycle button has non cycle button theme...")
		return
	
	var substrs: PoolStringArray = label_text.split("\n")
	var ss: int = substrs.size()
	var label_font: Font = MnoConfig.get_font(get_current_theme().option_font)
	var label_color: Color = ts.label_color
	var should_outline: bool = ts.label_outline
	var outline_color: Color = ts.outline_color
	var should_drop_shadow: bool = ts.drop_shadow
	
	if options == []:
		return
	
	var s: String = options[on]
	
	# get_align_offset() called from inherited, also - instead of +
	var pos: Vector2 = offset - .get_align_offset() + Vector2(0, label_font.get_ascent())
	pos.y += get_current_theme().option_y_offset
	
	var amt: Vector2 = Vector2.ZERO
	if state == States.CLICKED:
		amt.x = max(0, 16 + 48 * lerp(0.0, 1.0, 1 - float(state_timer) / 12)) * option_change_direction
	
	var s_size: Vector2 = label_font.get_string_size(s)
	match get_h_align():
		HAlign.RIGHT: # swapped
			pass
		HAlign.CENTER:
			pos.x -= s_size.x / 2
		HAlign.LEFT: # swapped
			pos.x -= s_size.x
	if should_outline:
		draw_outline(label_font, pos + amt, s, outline_color, should_drop_shadow)
	# TODO: consider separating so all the main text is drawn over all the outlines.
	# may or may not be necessary
	draw_string(label_font, pos + amt, s, label_color)
	
	if amt != Vector2.ZERO:
		s = options[posmod(on - option_change_direction, options.size())]
		if abs(amt.x) < 10:
			label_color.a = 0.5
			outline_color.a = 0.5
		amt.x -= 48 * 3 / 4 * option_change_direction
		if should_outline:
			draw_outline(label_font, pos + amt, s, outline_color, should_drop_shadow)
		# TODO: consider separating so all the main text is drawn over all the outlines.
		# may or may not be necessary
		draw_string(label_font, pos + amt, s, label_color)
	
	# draw button prompts
	
	if !uses_option_a_b || state == States.IDLE || state == States.DISABLED:
		return
	var prompt_font: Font = MnoConfig.get_font(MnoConfig.Fonts.m5x7)
	var buffer_amt: int = 0
	var prompt_input_name: String = ""
	for input in [In.UI_OPTION_A, In.UI_OPTION_B]:
		if Engine.editor_hint:
			prompt_input_name = In.get_script_constant_map().keys()[In.get_script_constant_map().values().find(input)]
		else:
			var h: Array = mno_master.get_input_display_info(input)
			prompt_input_name = h[0]
			buffer_amt = h[1]
		var other_offset: Vector2 = get_size() / 2 - Vector2(6, 4)
		other_offset.x *= (-1 if input == In.UI_OPTION_A else 1)
#		other_offset.y *= -1
		MnoMaster.draw_button_prompt(self, ["", prompt_input_name, buffer_amt], prompt_font, offset + other_offset,
				MnoSelectableTheme.HAlign.RIGHT if input == In.UI_OPTION_A else MnoSelectableTheme.HAlign.LEFT,
				true, button_color, Color.white)


# The rest of this file is just manually exporting variables (for more control over formatting/etc).
# This is an "advanced" version of using the export keyword... and it's a pain too.

func _get_property_list() -> Array:
	var ret: Array = []
	
	ret.append({
		name = "On",
		type = TYPE_INT,
		hint = PROPERTY_HINT_ENUM,
		hint_string = PoolStringArray(options).join(",").replace(", ", ","),
	})

	return ret


func set_options(value: Array) -> void:
	options = value
	on = clamp(on, 0, options.size() - 1)
	property_list_changed_notify()


func _set(property: String, value) -> bool:
	match property:
		"On":
			on = value
			return true
	return false


func _get(property: String):
	match property:
		"On":
			return on
	return null
