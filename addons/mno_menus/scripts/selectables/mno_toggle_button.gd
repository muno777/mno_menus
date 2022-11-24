# A special MnoButton that acts like an on/off checkbox.
tool
extends MnoButton
class_name MnoToggleButton, "res://addons/mno_menus/icons/mno_toggle_button.png"


# The current value.
export var on: bool = false


# Sets the theme to a valid one by default.
func _ready() -> void:
	if Engine.editor_hint && theme == MnoConfig.SelectableThemes.PLAIN_MEDIUM:
		set_theme(MnoConfig.SelectableThemes.PLAIN_TOGGLE)


# Toggles it when clicked.
func click() -> void:
	.click()
	
	if !enabled:
		return
	
	on = !on


# Draws the checkbox graphic.
func _draw() -> void:
	if on && get_current_theme() is MnoToggleButtonTheme:
		draw_texture(get_current_theme().checked_sprite, offset - get_current_theme().checked_sprite.get_size() / 2)
