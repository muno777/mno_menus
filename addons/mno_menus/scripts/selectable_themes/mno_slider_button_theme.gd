# A specialized MnoSelectableTheme for MnoSliderButtons.
tool
extends MnoSelectableTheme
class_name MnoSliderButtonTheme, "res://addons/mno_menus/icons/mno_slider_button.png"


# The font used for the number.
export(MnoConfig.Fonts) var value_font: int = MnoConfig.Fonts.m5x7
# The font used for the number after the player presses confirm to edit the value.
export(MnoConfig.Fonts) var value_font_selected: int = MnoConfig.Fonts.m6x11
# The extra height added to the main label's position.
export var label_y_offset: int = 0
# The extra height added to the bar's position.
export var bar_y_offset: int = 0
# The height of the bar.
export var bar_height: int = 2
# The width of the bar.
export var bar_width: int = 16
# The color used for the empty portion of the bar.
export var empty_color: Color = MnoConfig.GREYED_OUT_COLOR
# The color used for the full portion of the bar.
export var full_color: Color = Color.white
# The extra height added to the number's position.
export var value_y_offset: int = 0
# The extra height added to the number's position during edit mode.
export var value_y_offset_selected: int = 0
# The sprite used for the arrows during edit mode.
# The texture is for the right arrow, and it's flipped for the left arrow.
export var arrow_sprite: Texture = null
# The sound that plays when the value is changed.
export var tick_sound: AudioStream = null
# The sound that plays when edit mode is canceled.
export var cancel_sound: AudioStream = null
