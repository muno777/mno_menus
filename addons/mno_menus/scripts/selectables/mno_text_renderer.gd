# The base class for selectables and labels and button prompts and such.
tool
extends Sprite
class_name MnoTextRenderer, "res://addons/mno_menus/icons/mno_text_renderer.png"


# These are redundant with MnoTextRenderer, make sure to copy it back and forth... sorry
enum HAlign {
	LEFT,
	CENTER,
	RIGHT,
}
enum VAlign {
	TOP,
	MIDDLE,
	BOTTOM,
}


# The text.
export(String, MULTILINE) var label_text: String = "Lorem Ipsum" setget set_label_text
# MnoMaster ref.
onready var mno_master: MnoMaster = Mno.get_mno_master(self)
# MnoMenu ref.
var mno_menu: Mno2D = null


# Returns position relative to its MnoMenu.
func get_menu_position() -> Vector2:
	if mno_menu == null:
		return global_position
	return global_position - mno_menu.global_position


# Sets position relative to its MnoMenu.
func set_menu_position(value: Vector2) -> void:
	if mno_menu == null:
		global_position = value
		return
	global_position = value + mno_menu.global_position


func set_label_text(value: String) -> void:
	label_text = value
	if Engine.editor_hint:
		update_visuals_to_match_theme()


# Used by inherited classes.
func update_visuals_to_match_theme() -> void:
	pass


func tick() -> void:
	update()


func _process(delta: float) -> void:
	if Engine.editor_hint:
		update()


# Makes the backend work.
func get_current_theme_state() -> Dictionary:
	return MnoSelectableTheme.get_default_dict(MnoSelectableTheme.States.IDLE)


func get_h_align() -> int:
	return HAlign.CENTER


func get_v_align() -> int:
	return VAlign.MIDDLE


func get_align_offset() -> Vector2:
	return Vector2.ZERO


func _draw() -> void:
	draw_normal_text()


func get_label_font() -> Font:
	return MnoConfig.get_font(get_current_theme_state().label_font)
	

# Draws some text.	
func draw_normal_text() -> void:
	var ts = get_current_theme_state()
	
	var substrs: PoolStringArray = label_text.split("\n")
	var ss: int = substrs.size()
	var label_font: Font = get_label_font()
	var label_color: Color = ts.label_color
	var should_outline: bool = ts.label_outline
	var outline_color: Color = ts.outline_color
	var should_drop_shadow: bool = ts.drop_shadow
	
	for i in range(ss):
		var s: String = substrs[i]
		var pos: Vector2 = offset + get_align_offset() + Vector2(0, label_font.get_ascent())
		var s_size: Vector2 = label_font.get_string_size(s)
		match get_h_align():
			HAlign.LEFT:
				pass
			HAlign.CENTER:
				pos.x -= s_size.x / 2
			HAlign.RIGHT:
				pos.x -= s_size.x
		match get_v_align():
			VAlign.TOP:
				pos.y += round(label_font.get_ascent() * 1.5 * i)
			VAlign.MIDDLE:
				pos.y -= s_size.y / 2
				pos.y += round(label_font.get_ascent() * 1.5 * (i + 0.5 - ss / 2.0))
			VAlign.BOTTOM:
				pos.y += round(label_font.get_ascent() * 1.5 * (i - ss))
		if should_outline:
			draw_outline(label_font, pos, s, outline_color, should_drop_shadow)
		# TODO: consider separating so all the main text is drawn over all the outlines.
		# may or may not be necessary
		draw_string(label_font, pos, s, label_color)


# Draws outlines and drop shadows.
func draw_outline(font: Font, pos: Vector2, text: String,
		color: Color = Color.black, drop_shadow: bool = true) -> void:
	for i in range(-1, 2): # x
		for j in range(-1, 3 if drop_shadow else 2): # y
			if i != 0 || j != 0:
				draw_string(font, pos + Vector2(i, j), text, color)
