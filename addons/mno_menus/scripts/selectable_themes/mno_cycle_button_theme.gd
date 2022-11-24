# A specialized MnoSelectableTheme for MnoCycleButtons.
tool
extends MnoSelectableTheme
class_name MnoCycleButtonTheme, "res://addons/mno_menus/icons/mno_cycle_button.png"


# The font used for the smaller option text.
export(MnoConfig.Fonts) var option_font: int = MnoConfig.Fonts.m5x7
# The extra height added to the main label's position.
export var label_y_offset: int = 0
# The extra height added to the option text's position.
export var option_y_offset: int = 0

