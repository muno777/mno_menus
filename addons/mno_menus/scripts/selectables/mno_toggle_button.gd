tool
extends MnoButton
class_name MnoToggleButton, "res://addons/mno_menus/icons/mno_toggle_button.png"


export var on: bool = false


func _ready() -> void:
	if Engine.editor_hint && theme == MnoConfig.SelectableThemes.PLAIN_MEDIUM:
		set_theme(MnoConfig.SelectableThemes.PLAIN_TOGGLE)


func click() -> void:
	.click()
	
	if !enabled:
		return
	
	on = !on


func _draw() -> void:
	if on && get_current_theme() is MnoToggleButtonTheme:
		draw_texture(get_current_theme().checked_sprite, offset - get_current_theme().checked_sprite.get_size() / 2)
