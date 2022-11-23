tool
extends MnoTextRenderer
class_name MnoButtonPrompt, "res://addons/mno_menus/icons/mno_button_prompt.png"


var input: int = In.UI_CONFIRM
export var respond_to_press: bool = true
export var inherit_offset: bool = true
export var enabled: bool = true
export var button_color: Color = Color("424367")
export var text_color: Color = Color.white
export var disabled_color: Color = Color("424367")
export(MnoSelectableTheme.HAlign) var h_align: int = MnoSelectableTheme.HAlign.LEFT


func draw_normal_text() -> void:
	pass


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


class MyCustomSorter:
	static func sort_ascending(a, b):
		if In.get_script_constant_map()[a] < In.get_script_constant_map()[b]:
			return true
		return false


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
