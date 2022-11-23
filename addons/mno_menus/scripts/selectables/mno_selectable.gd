tool
extends MnoTextRenderer
class_name MnoSelectable, "res://addons/mno_menus/icons/mno_selectable.png"
func get_class() -> String: return "MnoSelectable"
# Selectable object in a game menu.
# Should be contained inside of a MnoSelectableGroup.


# these are redundant w/ MnoSelectableTheme sorry
enum States {
	IDLE,
	HOVERED,
	CLICKED,
	LONG_CLICKED,
	DISABLED,
}
enum HoveredAnimations {
	NONE,
	DIRECTIONAL_BOUNCE,
	BOUNCE,
	SLIDE_FROM,
}
enum ClickedAnimations {
	NONE,
	BOUNCE,
	SQUISH,
	SQUASH,
}


var state_timer: int = 0
var state_part: int = 0 # -1 is entering the state, 1 is exiting the state. for transition frames
var initial_position: Vector2 = position # can't delete this fsr?
var theme_obj = null
var should_be_hovered: bool = false
var cursor: Node2D = null
var slide_direction: Vector2 = Vector2.ZERO
var state_offset: Vector2 = Vector2.ZERO
var state_rotation_degrees: int = 0
var force_state_update: bool = false

export(MnoConfig.SelectableThemes) var theme: int = MnoConfig.SelectableThemes.PLAIN_MEDIUM setget set_theme
var state: int = States.IDLE setget set_state
export var enabled: bool = true setget set_enabled

export var neighbor_l: NodePath = ""
export var neighbor_r: NodePath = ""
export var neighbor_u: NodePath = ""
export var neighbor_d: NodePath = ""


func get_neighbor_l() -> MnoSelectable:
	var h: MnoSelectable = get_node_or_null(neighbor_l)
	return h


func get_neighbor_r() -> MnoSelectable:
	var h: MnoSelectable = get_node_or_null(neighbor_r)
	return h


func get_neighbor_u() -> MnoSelectable:
	var h: MnoSelectable = get_node_or_null(neighbor_u)
	return h


func get_neighbor_d() -> MnoSelectable:
	var h: MnoSelectable = get_node_or_null(neighbor_d)
	return h


func _ready() -> void:
	update_visuals_to_match_theme()


func set_enabled(value: bool) -> void:
	enabled = value
	set_state(States.IDLE if enabled else States.DISABLED)
	update_visuals_to_match_theme()


func can_be_selected() -> bool:
	if !enabled && !get_current_theme().selectable_when_disabled:
		return false
	return true


func set_state(value: int, skip_start_frames: bool = false) -> void:
#	if state == States.IDLE && value == States.HOVERED && !mno_master.fade_progress && !mno_master.slide_progress: # so it doesn't play right when u open a menu
#		mno_master.play_sound(get_current_theme().hovered_state.sound_effect)
	state = value
	state_timer = 0
	state_part = -1 if (state == States.HOVERED || state == States.LONG_CLICKED) && get_current_theme_state().transition_frames > 0 else 0
	offset = Vector2.ZERO
	scale = Vector2.ONE
	update_visuals_to_match_theme()
	frame = 0
	if skip_start_frames && state_part == -1:
		state_part = 0
		frame = get_current_theme_state().transition_frames


func set_theme(value: int) -> void:
	theme = value
	update_visuals_to_match_theme()
	

func update_visuals_to_match_theme() -> void:
	var t = get_current_theme_state(true)
	if t == null:
		printerr("Theme state is null")
		return
	texture = t.sprite
#	texture = null
	hframes = t.frames
#	update()


func get_size() -> Vector2:
	if get_current_theme_state() == null:
		return Vector2.ZERO
	if get_current_theme().width == 0 && get_current_theme().height == 0:
		return texture.get_size()
	return (Vector2(get_current_theme().width, get_current_theme().height) +
			Vector2(get_current_theme_state().extra_width, get_current_theme_state().extra_height))


func get_cursor_size() -> Vector2:
	return get_size() / 2


func get_cursor_pos() -> Vector2:
	return global_position


func get_current_theme(reload: bool = false):
	if theme_obj == null || (Engine.editor_hint && reload):
		theme_obj = MnoConfig.get_selectable_theme(theme)
	return theme_obj


func get_current_theme_state(reload: bool = false):
	var h = null
	match state:
		States.IDLE:
			h = get_current_theme(reload).idle_state
		States.HOVERED:
			h = get_current_theme(reload).hovered_state
		States.CLICKED:
			h = get_current_theme(reload).clicked_state
		States.LONG_CLICKED:
			h = get_current_theme(reload).long_clicked_state
		States.DISABLED:
			h = get_current_theme(reload).disabled_state
		_:
			printerr("Button theme index not set to a valid value")
			return null
	if h == null:
		printerr("Theme state is null")
	return h


func get_h_align() -> int:
	return get_current_theme().label_h_align


func get_v_align() -> int:
	return get_current_theme().label_v_align


func get_align_offset() -> Vector2:
	var ret: Vector2 = Vector2.ZERO
	match get_h_align():
		HAlign.LEFT:
			ret.x = -get_size().x / 2 + get_current_theme().h_align_margin
		HAlign.RIGHT:
			ret.x = get_size().x / 2 - get_current_theme().h_align_margin
	match get_v_align():
		VAlign.TOP:
			ret.y = -get_size().y / 2 + get_current_theme().v_align_margin
		VAlign.BOTTOM:
			ret.y = get_size().y / 2 - get_current_theme().v_align_margin
	return ret


func tick() -> void:
	
	.tick()
	
	var is_disabled = state == States.DISABLED
	
	if enabled && is_disabled:
		set_state(States.HOVERED if should_be_hovered else States.IDLE)
	if !enabled && !is_disabled:
		set_state(States.DISABLED)
	
	# for lerping rotation and offset
	var target_theme: Dictionary = get_current_theme_state()
	
	# note to self: to have animations where the button moves, use Sprite.offset
	
	var s = get_current_theme_state()
	
	offset = Vector2.ZERO
	rotation_degrees = 0
	
	match state:
		States.IDLE, States.DISABLED:
			frame = (state_timer / s.frame_duration) % hframes
			continue
		States.IDLE:
			if should_be_hovered:
				set_state(States.HOVERED)
				continue
		States.HOVERED:
			match state_part:
				-1, 0:
					if !should_be_hovered || force_state_update:
						state_part = 1
						state_timer = 0
			continue
		States.HOVERED, States.LONG_CLICKED:
			match state_part:
				-1:
					frame = state_timer / s.frame_duration
					if slide_direction != Vector2.ZERO && state == States.HOVERED:
						var offset_progress: float = float(state_timer - 1) / (s.transition_frames * s.frame_duration)
						var offset_ease: float = ease(offset_progress, 0.5)
						offset = slide_direction * 10 * (1 - offset_ease)
					if frame >= s.transition_frames:
						state_part = 0
						state_timer = 0
						offset = Vector2.ZERO
						continue
				0:
					frame = s.transition_frames + (state_timer / s.frame_duration) % (hframes - s.transition_frames * 2)
				1:
					frame = ((hframes - s.transition_frames) + (state_timer / s.frame_duration)) % hframes
					
					# messy
					var old_state: int = state
					state = (States.HOVERED if should_be_hovered else States.IDLE)
					target_theme = get_current_theme_state()
					state = old_state
					
					if frame == 0:
						set_state(States.HOVERED if should_be_hovered else States.IDLE)
						frame = hframes - 1
			continue
		States.CLICKED, States.LONG_CLICKED:
			if state == States.LONG_CLICKED && state_part > -1:
				continue
			match get_current_theme_state().animation_type:
				ClickedAnimations.BOUNCE: # TODO: make this last a bit longer?
					var offset_progress: float = min(1, float(state_timer - 1) / 4)
					var offset_ease: float = ease(offset_progress, 0.5)
					offset.y = 8 * (1 - offset_ease)
				ClickedAnimations.SQUISH, ClickedAnimations.SQUASH:
					if state_timer <= 8:
						var amt = lerp(1.0, 1.2, 1 - float(state_timer) / 10)
						scale = Vector2(amt, 1 - (amt - 1))
						if get_current_theme_state().animation_type == ClickedAnimations.SQUISH:
							var h: float = scale.x
							scale.x = scale.y
							scale.y = h
#						offset = Vector2(0, (amt - 1) * 32.0)
					else:
						scale = Vector2.ONE
						offset = Vector2.ZERO
			continue
		States.CLICKED:
			frame = min(state_timer / s.frame_duration, hframes - 1)
			var state_end_time: int = s.frame_duration * (hframes) - 1
			if state_timer >= state_end_time - 5:
				# messy
				var old_state: int = state
				state = (States.HOVERED if should_be_hovered else States.IDLE)
				target_theme = get_current_theme_state()
				state = old_state
			
			if state_timer >= state_end_time:
				set_state(States.HOVERED if should_be_hovered else States.IDLE, true)
	
	state_timer += 1
	force_state_update = false
	
	var lerp_strength: float = 0.5
	state_rotation_degrees = rad2deg(lerp_angle(deg2rad(state_rotation_degrees), deg2rad(target_theme.anim_rotation_degrees), lerp_strength))
	state_offset = lerp(state_offset, target_theme.anim_offset, lerp_strength)
	
	rotation_degrees += state_rotation_degrees
	offset += state_offset


func process_inputs(in_cursor: Node2D) -> void:
	cursor = in_cursor
	if cursor == null:
		return
	read_inputs()


func in_pressed(input_num: int, before_propagation: bool = false,
		clear: bool = false, eat: bool = false) -> bool:
	if cursor == null:
		return false
	return mno_master.in_pressed(cursor.input_slot, input_num, before_propagation, clear, eat)


func in_buffer_amt(input_num: int, before_propagation: bool = false,
		clear: bool = false, eat: bool = false) -> int:
	if cursor == null:
		return 0
	return mno_master.in_buffer_amt(cursor.input_slot, input_num, before_propagation, clear, eat)


func in_held(input_num: int, before_propagation: bool = false) -> bool:
	if cursor == null:
		return false
	return mno_master.in_held(cursor.input_slot, input_num, before_propagation)


func in_clear(input_num: int) -> void:
	if cursor == null:
		return
	mno_master.in_clear(cursor.input_slot, input_num)


func in_eat(input_num: int) -> void:
	if cursor == null:
		return
	mno_master.in_eat(cursor.input_slot, input_num)


func read_inputs() -> void:
	pass
