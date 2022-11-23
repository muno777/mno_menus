tool
extends MnoTextRenderer
class_name MnoLabel, "res://addons/mno_menus/icons/mno_label.png"


export var label_color: Color = Color.white
export(MnoConfig.Fonts) var label_font: int = MnoConfig.Fonts.m6x11
export var has_outline: bool = true
export var has_drop_shadow: bool = true
export(HAlign) var h_align: int = HAlign.CENTER
export(VAlign) var v_align: int = VAlign.MIDDLE


func get_current_theme_state() -> Dictionary:
	var h: Dictionary = MnoSelectableTheme.get_default_dict(MnoSelectableTheme.States.IDLE)
	h.label_outline = has_outline
	h.drop_shadow = has_drop_shadow
	h.label_color = label_color
	return h


func get_h_align() -> int:
	return h_align


func get_v_align() -> int:
	return v_align


func get_label_font() -> Font:
	return MnoConfig.get_font(label_font)
