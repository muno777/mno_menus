tool
extends MnoSelectableTheme
class_name MnoSliderButtonTheme, "res://addons/mno_menus/icons/mno_slider_button.png"


export(MnoConfig.Fonts) var value_font: int = MnoConfig.Fonts.m5x7
export(MnoConfig.Fonts) var value_font_selected: int = MnoConfig.Fonts.m6x11
export var label_y_offset: int = 0
export var bar_y_offset: int = 0
export var bar_height: int = 2
export var bar_width: int = 16
export var empty_color: Color = Color("424367")
export var full_color: Color = Color.white
export var value_y_offset: int = 0
export var value_y_offset_selected: int = 0
export var arrow_sprite: Texture = null
export var tick_sound: AudioStream = null
export var cancel_sound: AudioStream = null
#export var selected_value_sprite: Texture = null
