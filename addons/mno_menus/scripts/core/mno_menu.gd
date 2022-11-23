tool
extends Mno2D
class_name MnoMenu, "res://addons/mno_menus/icons/mno_menu.png"
func get_class() -> String: return "MnoMenu"
# A game menu. Should be used as the root of a 2D scene.


var selectable_groups: Array = []
var text_renderers: Array = []
var cursors: Array = []
var cursor_renderers: Array = [] 
onready var mno_master: MnoMaster = Mno.get_mno_master(self)
export var num_cursors: int = 1
export var input_passthrough: bool = false
export var draw_center_helper: bool = true setget set_draw_center_helper
export(MnoMaster.TransitionTypes) var transition_type: int = MnoMaster.TransitionTypes.FADE
export var has_selectables: bool = true
export var back_button: bool = true


func set_draw_center_helper(value: bool) -> void:
	draw_center_helper = value
	update()


func _ready() -> void:
	if Engine.editor_hint:
		show_behind_parent = true
		return
	
	for i in range(num_cursors):
		var c: MnoCursor = MnoCursor.new()
		add_child(c)
		cursors.push_back(c)
		if num_cursors > 1:
			c.input_slot = i
#			c.active = true # TEMP; remove when "press button to become active" is added
			mno_master.controllers[i].connect("input_pressed", c, "become_active")
		else:
			c.become_active()
	
	recursive_search(self)


func recursive_search(cur) -> void:
	if cur is MnoSelectableGroup:
		selectable_groups.push_back(cur)
	elif cur is MnoTextRenderer:
		text_renderers.push_back(cur)
	elif cur is MnoCursorRenderer:
		cursor_renderers.push_back(cur)
		if cur.cursor_num < num_cursors:
			cur.cursor = cursors[cur.cursor_num]
	for c in cur.get_children():
		recursive_search(c)


func tick(should_read_inputs: bool = true) -> void:
	var hovered_selectables: Array = []
	for c in cursors:
		for g in selectable_groups:
			if g.is_hidden() && c.hovered_selectable in g.selectables:
				c.hovered_selectable = null
		if c.hovered_selectable == null:
			for g in selectable_groups:
				if !g.is_hidden() && g.can_be_selected:
					c.hovered_selectable = g.get_initially_selected_element()
					if c.hovered_selectable != null:
						c.hovered_selectable.slide_direction = Vector2.ZERO
		
		if c.hovered_selectable != null && should_read_inputs:
			c.hovered_selectable.process_inputs(c)
			for d in [In.UI_LEFT, In.UI_RIGHT, In.UI_UP, In.UI_DOWN]:
				var pressed: bool = false
				pressed = in_pressed(c.input_slot, d, false, true)
				if pressed: # if input
					var new_selected: MnoSelectable = move_to_neighbor(c.hovered_selectable, d, c)
					if new_selected != null:
						c.hovered_selectable = new_selected
						new_selected.force_state_update = true
						select_cosmetics(mno_master, new_selected, d)
		
		c.tick()
		
		if c.active && c.hovered_selectable != null && !hovered_selectables.has(c.hovered_selectable):
			hovered_selectables.push_back(c.hovered_selectable)
	for g in selectable_groups:
		g.tick(hovered_selectables)
		if should_read_inputs:
			g.process_inputs()
	for t in text_renderers:
		t.tick()
	for c in cursor_renderers:
		c.tick()
	
	# back button
	if should_read_inputs && back_button:
		var pressed: bool = false
		pressed = in_pressed(MnoInput.DEVICE_ALL, In.UI_CANCEL, false, true)
		if pressed && mno_master.get_current_menu() == self:
			mno_master.pop_menu()
			mno_master.play_sound(mno_master.back_sound)


static func select_cosmetics(mno__master: MnoMaster, selectable: MnoSelectable, dir: int) -> void:
	mno__master.play_sound(selectable.get_current_theme().hovered_state.sound_effect)
	match selectable.get_current_theme().hovered_state.animation_type:
		MnoSelectable.HoveredAnimations.DIRECTIONAL_BOUNCE, MnoSelectable.HoveredAnimations.SLIDE_FROM:
			var v: Vector2 = Vector2.ZERO
			match dir:
				In.UI_LEFT:
					v = Vector2.LEFT
				In.UI_RIGHT:
					v = Vector2.RIGHT
				In.UI_UP:
					v = Vector2.UP
				In.UI_DOWN:
					v = Vector2.DOWN
			if selectable.get_current_theme().hovered_state.animation_type == MnoSelectable.HoveredAnimations.SLIDE_FROM:
				v *= -1
			selectable.slide_direction = v
		MnoSelectable.HoveredAnimations.BOUNCE:
			selectable.slide_direction = Vector2.DOWN


func get_button_prompt_draw_list() -> Array:
	var in_arr: Array = []
	var out_arr: Array = []
	if has_selectables:
		in_arr.push_back([In.UI_CONFIRM, "Select"])
	if back_button:
		in_arr.push_back([In.UI_CANCEL, "Back"])
	in_arr.append_array(get_button_prompt_list())
	for p in in_arr:
		if !mno_master.controllers.empty():
			var added: Array = [p[1]]
			added.append_array(mno_master.get_input_display_info(p[0]))
			out_arr.push_back(added)
	return out_arr


func get_button_prompt_list() -> Array:
	return []


# finds a selectable in the up/down/left/right direction that the cursor should go to.
# returns the selectable you gave it if there's no valid neighbor.
func move_to_neighbor(selectable: MnoSelectable, dir: int, cursor: MnoCursor) -> MnoSelectable:
	if selectable == null:
		return null
	
	var max_dist: int = 64
	var mult_negative: bool = false
	var looking_up_down: bool = false
	var current_group: MnoSelectableGroup = selectable.get_parent() # TODO: change this to a var in MnoSelectable that gets set on _ready ...
	# ... so that this doesn't fail if the selectable is an indirect parent of the group.
	
	match(dir):
		In.UI_RIGHT:
			if selectable.get_neighbor_r() != null && selectable.get_neighbor_r().can_be_selected():
				return selectable.get_neighbor_r()
		In.UI_UP:
			if selectable.get_neighbor_u() != null && selectable.get_neighbor_u().can_be_selected():
				return selectable.get_neighbor_u()
			mult_negative = true
			looking_up_down = true
		In.UI_LEFT:
			if selectable.get_neighbor_l() != null && selectable.get_neighbor_l().can_be_selected():
				return selectable.get_neighbor_l()
			mult_negative = true
		In.UI_DOWN:
			if selectable.get_neighbor_d() != null && selectable.get_neighbor_d().can_be_selected():
				return selectable.get_neighbor_d()
			looking_up_down = true
	
	var selectables_to_check: Array = []
	
	for g in selectable_groups:
		if g.is_hidden():
			continue
		if !g.can_be_selected:
			continue
		if !current_group.permitted_outside_groups(cursor).empty() && !current_group.permitted_outside_groups(cursor).has(g):
			continue
		for s in g.selectables:
			selectables_to_check.push_back(s)
	
	return get_neighbor_of(selectable, selectables_to_check, looking_up_down, mult_negative, current_group.allows_wrapping)


static func get_neighbor_of(selectable: MnoSelectable, selectables_arr: Array, looking_up_down: bool, mult_negative: bool, allow_wrapping: bool) -> MnoSelectable:
	var nearest_fit: MnoSelectable = selectable
	var furthest_fit: MnoSelectable = selectable
	
	for s in selectables_arr:
		if s == selectable:
			continue
		if !s.can_be_selected():
			continue
		var wrapping: bool = false # used to check for looping options, eg pressing up at the top of a list to wrap to the bottom
		if looking_up_down:
			if abs(selectable.global_position.x - s.global_position.x) > (selectable.get_size().x + s.get_size().x) / 2 - 2:
				continue
			if abs(selectable.global_position.y - s.global_position.y) < 8:
				continue
			if (selectable.global_position.y - s.global_position.y) * (-1 if mult_negative else 1) > 0:
				wrapping = true
		else:
			if abs(selectable.global_position.y - s.global_position.y) > (selectable.get_size().y + s.get_size().y) / 2 - 2:
				continue
			if abs(selectable.global_position.x - s.global_position.x) < 8:
				continue
			if (selectable.global_position.x - s.global_position.x) * (-1 if mult_negative else 1) > 0:
				wrapping = true
		if wrapping:
			# TODO: make this consider button width/height for closeness?
			if (furthest_fit == selectable || (selectable.global_position - s.global_position).length() >
					(selectable.global_position - furthest_fit.global_position).length()):
				furthest_fit = s
		else:
			# TODO: make this consider button width/height for closeness?
			if (nearest_fit == selectable || (selectable.global_position - s.global_position).length() <
					(selectable.global_position - nearest_fit.global_position).length()):
				nearest_fit = s
	
	return furthest_fit if nearest_fit == selectable && allow_wrapping else nearest_fit


func _draw() -> void:
	if !Engine.editor_hint:
		return
	if !draw_center_helper:
		return
	var v_size: Vector2 = get_viewport_rect().size
	var line_start: Vector2 = Vector2(v_size.x / 2, 0)
	var line_end: Vector2 = Vector2(v_size.x / 2, v_size.y)
	draw_line(line_start, line_end, Color.red)
	line_start = Vector2(0, v_size.y / 2)
	line_end = Vector2(v_size.x, v_size.y / 2)
	draw_line(line_start, line_end, Color.red)


func in_pressed(controller_num: int, input_num: int, before_propagation: bool = false,
		clear: bool = false, eat: bool = false) -> bool:
	return mno_master.in_pressed(controller_num, input_num, before_propagation, clear, eat)


func in_buffer_amt(controller_num: int, input_num: int, before_propagation: bool = false,
		clear: bool = false, eat: bool = false) -> int:
	return mno_master.in_buffer_amt(controller_num, input_num, before_propagation, clear, eat)


func in_held(controller_num: int, input_num: int, before_propagation: bool = false) -> bool:
	return mno_master.in_held(controller_num, input_num, before_propagation)


func in_clear(controller_num: int, input_num: int) -> void:
	mno_master.in_clear(controller_num, input_num)


func in_eat(controller_num: int, input_num: int) -> void:
	mno_master.in_eat(controller_num, input_num)
