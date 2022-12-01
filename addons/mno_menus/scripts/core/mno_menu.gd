# The root node of a menu scene pushed to MnoMaster's menu stack.
# To make a menu, make a scene out of this and add MnoSelectableGroups as children!
tool
extends Mno2D
class_name MnoMenu, "res://addons/mno_menus/icons/mno_menu.png"


# Array of MnoSelectableGroups. Populated onready with a recursive children search.
var selectable_groups: Array = []
# Array of MnoTextRenderers (MnoSelectable inherits from this). Populated onready with a recursive
# children search.
var text_renderers: Array = []
# Array of MnoCursors created onready.
var cursors: Array = []
# Array of MnoCursorRenderers. Populated onready with a recursive children search.
var cursor_renderers: Array = []
# MnoMaster reference. 
onready var mno_master: MnoMaster = Mno.get_mno_master(self)


# Number of cursors that the menu should spawn in.
# For a multiplayer menu (e.g. character select), set to >1.
export var num_cursors: int = 1
# Whether or not input data should propagate past this menu.
# Set to true if, when a player presses a button in this menu, it should take effect in a prior
# menu or in the game itself (e.g. character can jump while this menu is open).
export var input_passthrough: bool = false
# Only takes effect in the editor. Draws a couple of lines to help you center UI elements.
# Won't work unless your inherited script is a tool script!
export var draw_center_helper: bool = true setget set_draw_center_helper
# Animation for opening / closing this menu.
export(MnoMaster.TransitionTypes) var transition_type: int = MnoMaster.TransitionTypes.FADE
# Whether or not it has any buttons you can click with In.UI_CONFIRM.
# Determines whether it should draw the button prompt for this.
export var has_selectables: bool = true
# Whether or not you can press back to go back to the previous menu.
# Determines whether it should draw the button prompt for this.
export var back_button: bool = true


func set_draw_center_helper(value: bool) -> void:
	draw_center_helper = value
	update()


func _ready() -> void:
	# Needs to show behind the parent, so that MnoMaster can render stuff.
	if Engine.editor_hint:
		show_behind_parent = true
		return
	
	# Spawns cursors and sets their slots accordingly.
	# Note that if num_cursors is 1, the cursor will be active right away and read ALL controllers.
	# If > 1, cursors will be inactive until an input on their controller is pressed.
	for i in range(num_cursors):
		var c: MnoCursor = MnoCursor.new()
		add_child(c)
		cursors.push_back(c)
		if num_cursors > 1:
			c.input_slot = i
			mno_master.controllers[i].connect("input_pressed", c, "become_active")
		else:
			c.become_active()
	
	recursive_search(self)


# Looks thru children, grandchildren, great-grandchildren, etc to populate some arrays.
func recursive_search(cur) -> void:
	if cur is MnoSelectableGroup:
		register_selectable_group(cur)
	elif cur is MnoTextRenderer:
		register_text_renderer(cur)
	elif cur is MnoCursorRenderer:
		register_cursor_renderer(cur)
	for c in cur.get_children():
		recursive_search(c)


# Add a MnoSelectableGroup to the list.
# If you spawn one in thru code, pass it thru this func to make everything work properly.
func register_selectable_group(group: MnoSelectableGroup) -> void:
	selectable_groups.push_back(group)
	group.mno_menu = self
	for s in group.selectables:
		s.mno_menu = self


# Add a MnoTextRenderer (e.g. MnoSelectable, MnoButton, MnoLabel, MnoButtonPrompt) to the list.
# If you spawn one in thru code, pass it thru this func to make everything work properly.
# NOTE: For a MnoSelectable you also need to call MnoSelectableGroup.register_selectable(it).
func register_text_renderer(text: MnoTextRenderer) -> void:
	text_renderers.push_back(text)
	text.mno_menu = self


# Add a MnoCursorRenderer to the list.
# If you spawn one in thru code, pass it thru this func to make everything work properly.
func register_cursor_renderer(cur: MnoCursorRenderer) -> void:
	cursor_renderers.push_back(cur)
	cur.mno_menu = self
	if cur.cursor_num < num_cursors:
		cur.cursor = cursors[cur.cursor_num]


func tick(should_read_inputs: bool = true) -> void:
	var hovered_selectables: Array = []
	# Loops thru cursors and finds which selectables they're hovering.
	for c in cursors:
		var cr: MnoCursorRenderer = null
		for r in cursor_renderers:
			if r.cursor == c:
				cr = r
		for g in selectable_groups:
			if g.is_hidden() && c.hovered_selectable in g.selectables:
				c.hovered_selectable = null
		if c.hovered_selectable == null && !(cr != null && cr.mouse_taken_over):
			for g in selectable_groups:
				if !g.is_hidden() && g.can_be_selected:
					c.hovered_selectable = g.get_initially_selected_element()
					if c.hovered_selectable != null:
						c.hovered_selectable.slide_direction = Vector2.ZERO
		
		# Input logic.
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
	
	# Ticks everything.
	for g in selectable_groups:
		g.tick(hovered_selectables)
		if should_read_inputs:
			g.process_inputs()
	for t in text_renderers:
		t.tick()
	for c in cursor_renderers:
		c.tick()
	
	# Back button input.
	if should_read_inputs && back_button:
		var pressed: bool = false
		pressed = in_pressed(MnoInput.DEVICE_ALL, In.UI_CANCEL, false, true)
		if pressed && mno_master.get_current_menu() == self:
			mno_master.pop_menu()
			mno_master.play_sound(mno_master.back_sound)


# Plays the animation and sound effect for a selectable being hovered.
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


# Returns an array of button prompts that should appear on this menu.
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


# Returns the *menu-specific* button prompts.
# Override this to add custom button prompts at the bottom of the screen.
func get_button_prompt_list() -> Array:
	return []


# Finds a selectable in the up/down/left/right direction that the cursor should go to.
# Returns the selectable you gave it if there's no valid neighbor.
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


# Does the actual heavy lifting of finding the selectable in a given direction based on proximity,
# etc.
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
			if abs(selectable.get_menu_position().x - s.get_menu_position().x) > (selectable.get_size().x + s.get_size().x) / 2 - 2:
				continue
			if abs(selectable.get_menu_position().y - s.get_menu_position().y) < 8:
				continue
			if (selectable.get_menu_position().y - s.get_menu_position().y) * (-1 if mult_negative else 1) > 0:
				wrapping = true
		else:
			if abs(selectable.get_menu_position().y - s.get_menu_position().y) > (selectable.get_size().y + s.get_size().y) / 2 - 2:
				continue
			if abs(selectable.get_menu_position().x - s.get_menu_position().x) < 8:
				continue
			if (selectable.get_menu_position().x - s.get_menu_position().x) * (-1 if mult_negative else 1) > 0:
				wrapping = true
		if wrapping:
			# TODO: make this consider button width/height for closeness?
			if (furthest_fit == selectable || (selectable.get_menu_position() - s.get_menu_position()).length() >
					(selectable.get_menu_position() - furthest_fit.get_menu_position()).length()):
				furthest_fit = s
		else:
			# TODO: make this consider button width/height for closeness?
			if (nearest_fit == selectable || (selectable.get_menu_position() - s.get_menu_position()).length() <
					(selectable.get_menu_position() - nearest_fit.get_menu_position()).length()):
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


# Input Checking Functions: see MnoMaster for general documentation.

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
