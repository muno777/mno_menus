# An object to render a button prompt to instruct the player what button to press to achieve a
# certain action.
# Note that these are NOT used for the button prompts at the bottom of the screen; those are drawn
# directly by MnoMaster.
tool
extends MnoTextRenderer
class_name MnoButtonPrompt, "res://addons/mno_menus/icons/mno_button_prompt.png"


# The input that it displays.
var input: int = In.UI_CONFIRM
# Whether or not it should play the "button pressed" animation.
export var respond_to_press: bool = true
# If this is the child of a Sprite (e.g. a MnoSelectable), this determines whether or not the
# button prompt will inherit the offset property.
# So if this is the child of a MnoSelectable, setting this to true will have it move with the
# hovered/clicked animations.
export var inherit_offset: bool = true
# Whether or not the prompt is enabled.
# Disabled = greyed out and plays a different animation.
# Useful for actions that the player is currently locked-out from performing.
export var enabled: bool = true
# The color of the button shape.
export var button_color: Color = MnoConfig.GREYED_OUT_COLOR
# The text color.
export var text_color: Color = Color.white
# The text color when disabled.
export var disabled_color: Color = MnoConfig.GREYED_OUT_COLOR
# The alignment of the button prompt.
export(MnoSelectableTheme.HAlign) var h_align: int = MnoSelectableTheme.HAlign.LEFT


# Overrides this function to make it not happen anymore.
func draw_normal_text() -> void:
	pass


# Draws the thingy using MnoMaster's func.
func _draw() -> void:
	var prompt_font: Font = MnoConfig.get_font(MnoConfig.Fonts.m5x7)
	var prompt_input_name: String = ""
	var buffer_amt: int = 0
	if Engine.editor_hint:
		prompt_input_name = In.get_script_constant_map().keys()[In.get_script_constant_map().values().find(input)]
	else:
		var h: Array = mno_master.get_input_display_info(input)
		prompt_input_name = h[0]
		if respond_to_press:
			buffer_amt = h[1]
	var real_offset: Vector2 = offset
	if inherit_offset && get_parent() != null && "offset" in get_parent():
		real_offset += get_parent().offset
	MnoMaster.draw_button_prompt(self, [label_text, prompt_input_name, buffer_amt], prompt_font, real_offset, h_align,
			enabled, button_color, text_color if enabled else disabled_color)


# Custom sorter for use below.
class MyCustomSorter:
	static func sort_ascending(a, b):
		if In.get_script_constant_map()[a] < In.get_script_constant_map()[b]:
			return true
		return false


# The rest of this file is just manually exporting variables (for more control over formatting/etc).
# This is an "advanced" version of using the export keyword... and it's a pain too.

func _get_property_list() -> Array:
	var ret: Array = []
	
	var enum_arr: Array = In.get_script_constant_map().keys()
	enum_arr.sort_custom(MyCustomSorter, "sort_ascending")
	
	ret.append({
		name = "Input",
		type = TYPE_INT,
		hint = PROPERTY_HINT_ENUM,
		hint_string = PoolStringArray(enum_arr).join(",").replace(", ", ",").capitalize().replace("Ui_", "UI "),
	})

	return ret


func _set(property: String, value) -> bool:
	match property:
		"Input":
			input = value
			return true
	return false


func _get(property: String):
	match property:
		"Input":
			return input
	return null
