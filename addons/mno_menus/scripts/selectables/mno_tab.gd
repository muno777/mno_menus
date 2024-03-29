# A special MnoSelectable designed for use as a tab.
# Literally just draws the button prompts, otherwise it's nothing special.
extends MnoSelectable
class_name MnoTab, "res://addons/mno_menus/icons/mno_tab.png"
tool


# Whether or not to draw the In.UI_PAGE_L and In.UI_PAGE_R button prompts.
export var draw_tab_controls: bool = true
# The color for the button prompts if the above option is enabled.
export var button_color: Color = MnoConfig.GREYED_OUT_COLOR


# Draws them. Wow.
func _draw() -> void:
	if !draw_tab_controls || state == States.IDLE || state == States.DISABLED:
		return
	var prompt_font: Font = MnoConfig.get_font(MnoConfig.Fonts.m5x7)
	var buffer_amt: int = 0
	var prompt_input_name: String = ""
	for input in [In.UI_PAGE_L, In.UI_PAGE_R]:
		if Engine.editor_hint:
			prompt_input_name = In.get_script_constant_map().keys()[In.get_script_constant_map().values().find(input)]
		else:
			var h: Array = mno_master.get_input_display_info(input)
			prompt_input_name = h[0]
#			buffer_amt = h[1]
		var other_offset: Vector2 = get_size() / 2 - Vector2(6, 4)
		other_offset.x *= (-1 if input == In.UI_PAGE_L else 1)
		other_offset.y *= -1
		MnoMaster.draw_button_prompt(self, ["", prompt_input_name, buffer_amt], prompt_font, offset + other_offset,
				MnoSelectableTheme.HAlign.RIGHT if input == In.UI_PAGE_L else MnoSelectableTheme.HAlign.LEFT,
				true, button_color, Color.white)


func on_mouse_click(_pos: Vector2) -> void:
	if "current_tab" in selectable_group:
		selectable_group.current_tab = self
