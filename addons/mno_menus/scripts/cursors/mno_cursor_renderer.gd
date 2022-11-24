# The object responsible for drawing a MnoCursor's associated sprite/etc, and calculating its
# onscreen position.
tool
extends Mno2D
class_name MnoCursorRenderer, "res://addons/mno_menus/icons/mno_cursor_renderer.png"


# These are redundant with MnoCursorTheme, make sure to copy it back and forth... sorry
enum States {
	IDLE,
	CLICKING,
}
enum HoverAnimations {
	NONE,
}
enum ClickAnimations {
	NONE,
}


# The index of the MnoCursor (in MnoMenu.cursors) this is associated with.
export var cursor_num: int = 0
# The cursor object itself.
var cursor: MnoCursor = null
# The size of the "box" that the 4 corners form.
# Determined by the MnoCursorTheme and the current MnoSelectable.
# This var serves to lerp between different values,
var corner_offset: Vector2 = Vector2.ZERO
# The index of the MnoCursorTheme used; see MnoConfig to add more.
export(MnoConfig.CursorThemes) var theme: int = MnoConfig.CursorThemes.PLAIN_POINTER setget set_theme
# The object for the actual theme.
var theme_obj: MnoCursorTheme = null
# The current state of the rendered cursor.
var state: int = States.IDLE
# The progress in the current state.
var state_timer: int = 0
# MnoMaster ref.
onready var mno_master: MnoMaster = Mno.get_mno_master(self)


func set_theme(value: int) -> void:
	theme = value


func set_state(value: int, skip_start_frames: bool = false) -> void:
	state = value
	state_timer = 0


# Does some state machine logic.
# Checks for a confirm input and sets the state to "clicking" when the button is pressed.
# Also responsible for moving the cursor smoothly between targets.
func tick() -> void:
	if cursor == null || cursor.hovered_selectable == null:
		update()
		return
	
	var t: MnoCursorTheme = get_current_theme()
	var ts: Dictionary = get_current_theme_state()
	
	if mno_master.in_pressed(cursor.input_slot, In.UI_CONFIRM, true, false, false):
		set_state(States.CLICKING)
	
	state_timer += 1
	
	var state_dur: int = ts.frames * ts.frame_duration
	
	match state:
		States.IDLE:
			state_timer = state_timer % state_dur
		States.CLICKING:
			if state_timer >= state_dur:
				set_state(States.IDLE)
	
	var target_pos: Vector2 = cursor.hovered_selectable.get_cursor_pos()
	var target_offset: Vector2 = cursor.hovered_selectable.get_cursor_size()
	target_offset *= t.offset_scale * ts.offset_scale
	target_offset += t.margin + ts.extra_margin + t.overload_offset * max(0, cursor.get_cursors_on_same_selectable().find(cursor))
	global_position = lerp(global_position, target_pos, 0.5)
	corner_offset = lerp(corner_offset, target_offset, 0.5)
	update()


# Draws the 4 corners of the cursor graphic.
func _draw() -> void:
	if bad_cursor():
		return
	var ts: Dictionary = get_current_theme_state()
	for i in range(4):
		if ts.sprites[i] == null:
			continue
		var spr: Texture = ts.sprites[i]
		
		var frames: int = ts.frames
		var frame: int = state_timer / ts.frame_duration
		var frame_width: int = spr.get_size().x / frames
		var rect_offset: int = frame_width * frame
		
		var x_mult: int = 1 if i % 2 else -1
		var y_mult: int = 1 if (i/2) % 2 else -1
		var pos: Vector2 = corner_offset * Vector2(x_mult, y_mult) - spr.get_size() / 2
		
		pos.x += (spr.get_size().x - frame_width) / 2
		
		draw_texture_rect_region(spr, Rect2(pos, Vector2(frame_width, spr.get_size().y)), Rect2(rect_offset, 0, frame_width, spr.get_size().y))


# Returns true if the cursor isn't entirely "valid".
func bad_cursor() -> bool:
	if cursor == null:
		return true
	if !cursor.active:
		return true
	if cursor.hovered_selectable == null:
		return true
	return false


# Gets the current theme, using theme_obj as a "cache" to avoid loading tons of times.
func get_current_theme(reload: bool = false):
	if theme_obj == null || reload:
		theme_obj = MnoConfig.get_cursor_theme(theme)
	return theme_obj


# Gets the current state from the current theme.
func get_current_theme_state(reload: bool = false):
	var h = null
	match state:
		States.IDLE:
			h = get_current_theme(reload).idle_state
		States.CLICKING:
			h = get_current_theme(reload).clicking_state
		_:
			printerr("Cursor theme index not set to a valid value")
			return null
	if h == null:
		printerr("Theme state is null")
	return h
	
