# Contains a set of MnoSelectables inside a game menu, like a "folder".
# A whole menu could have one of these, but it's often useful to split it up into several.
tool
extends Mno2D
class_name MnoSelectableGroup, "res://addons/mno_menus/icons/mno_selectable_group.png"


# The different ways a MnoSelectableGroup can scroll.
enum ScrollingTypes {
	NONE,
	HORIZONTAL,
	VERTICAL,
	BOTH,
}


# List of MnoSelectables inside the group.
var selectables: Array = []
# MnoMenu ref.
var mno_menu: Mno2D = null setget set_mno_menu
# MnoMaster ref.
onready var mno_master: MnoMaster = Mno.get_mno_master(self)
# Whether or not the cursor can wrap from one side to the other.
# For example, pressing left at the left edge wraps around to the right edge.
export var allows_wrapping: bool = true
# The MnoSelectable the cursor is first highlighted at.
# Usually when the menu is first loaded, but also when you switch tabs etc.
export var initial_selectable: NodePath = ""
# List of other MnoSelectableGroups the cursor can jump to from this one.
# If blank, it can jump to any group.
# If not blank, it's a whitelist: cursors can only jump to groups in the list.
# To make it so no groups can be jumped to, add an entry for this group itself to the list.
export(Array, NodePath) var allowed_outside_groups: Array = []
# Whether or not a cursor can come into this group with direction inputs.
export var can_be_selected: bool = true
# A MnoSelectable which this group looks to for the hover-visible feature.
# If you set it to a selectable, this group will be visible when the selectable is hovered, and will
# disappear if the selectable is not hovered.
export var hover_visible_selectable: NodePath = ""
# Whether or not to add a smooth fade in/out to the above feature.
export var hover_visible_fade: bool = false
# Whether or not this group scrolls, and in which direction.
export(ScrollingTypes) var scrolling_type: int = ScrollingTypes.NONE
# The margin from the screen edge used by scrolling.
# How scrolling works is that, if the hovered button is within [this many] pixels of the viewport's
# edge, the group's position will move to bring the hovered button back onscreen.
export var scroll_margin: int = 48
# A list of MnoSelectables that, when hovered, will reset the scrolling to the original position.
# This overrides the normal scroll logic.
# Recommended to use this for (e.g.) the top item in a vertical scrolling list, to make sure that
# everything lines up when you scroll back to the top.
export(Array, NodePath) var scroll_reset_objs: Array = []
# Tracks the original position of the group, for use in scrolling logic.
onready var orig_position: Vector2 = get_menu_position()


func set_mno_menu(value) -> void:
	mno_menu = value
	orig_position = get_menu_position()


func get_hover_visible_selectable() -> MnoSelectable:
	var ret: MnoSelectable = get_node_or_null(hover_visible_selectable)
	return ret


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


func _ready() -> void:
	if Engine.editor_hint:
		return
	
	recursive_search(self)


# Finds selectables among children, grandchildren, great-grandchildren, etc.
func recursive_search(cur) -> void:
	if cur is get_script() && cur != self:
		return
	if cur is MnoSelectable:
		register_selectable(cur)
	for c in cur.get_children():
		recursive_search(c)


# Add a MnoSelectable to the list.
# If you spawn one in thru code, pass it thru this func to make everything work properly.
func register_selectable(selectable: MnoSelectable) -> void:
	selectables.push_back(selectable)
	selectable.mno_menu = mno_menu


func is_hidden() -> bool:
	if get_hover_visible_selectable() == null:
		return false
	return get_hover_visible_selectable().state == MnoSelectable.States.IDLE || get_hover_visible_selectable().state == MnoSelectable.States.DISABLED


# Handles scrolling logic, ticks selectables, and handles hover-visible logic.
func tick(hovered_selectables: Array = []) -> void:
	if scrolling_type:
		var hori: bool = scrolling_type == ScrollingTypes.HORIZONTAL
		var vert: bool = scrolling_type == ScrollingTypes.VERTICAL
		if scrolling_type == ScrollingTypes.BOTH:
			hori = true
			vert = true
		for s in selectables:
			if hovered_selectables.has(s):
				var pos: Vector2 = s.get_menu_position()
				var margin: Vector2 = s.get_size() / 2
				margin += Vector2.ONE * scroll_margin
				var screen: Vector2 = get_viewport_rect().size
				var dist: Vector2 = Vector2(pos.x - clamp(pos.x, margin.x, screen.x - margin.x),
						pos.y - clamp(pos.y, margin.y, screen.y - margin.y))
				if !hori:
					dist.x = 0
				if !vert:
					dist.y = 0
				for p in scroll_reset_objs:
					if get_node_or_null(p) == s:
						dist = get_menu_position() - orig_position
				set_menu_position(get_menu_position() - dist * 0.5)
	
	for s in selectables:
		s.should_be_hovered = hovered_selectables.has(s)
		s.tick()
	
	if get_hover_visible_selectable() != null:
		var vis: bool = (get_hover_visible_selectable().state != MnoSelectable.States.IDLE)
		if hover_visible_fade:
			modulate.a = lerp(modulate.a, int(vis), 0.5)
			visible = true
		else:
			visible = vis


# Can be overridden by inheriting classes.
func process_inputs() -> void:
	pass


# Gets the element that should be selected at first.
func get_initially_selected_element() -> MnoSelectable:
	if get_node_or_null(initial_selectable) is MnoSelectable:
		var h: MnoSelectable = get_node(initial_selectable)
		return h
	if selectables.empty():
		return null
	return selectables[0]


# Gets the groups that a cursor can get to from this group.
func permitted_outside_groups(cursor: MnoCursor) -> Array:
	var ret: Array = []
	for g in allowed_outside_groups:
		ret.push_back(get_node_or_null(g))
	return ret


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
