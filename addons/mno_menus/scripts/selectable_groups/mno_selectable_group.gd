tool
extends Mno2D
class_name MnoSelectableGroup, "res://addons/mno_menus/icons/mno_selectable_group.png"
func get_class() -> String: return "MnoSelectableGroup"
# Contains MnoSelectables inside a game menu.
# This could be a column, for example.


enum ScrollingTypes {
	NONE,
	HORIZONTAL,
	VERTICAL,
	BOTH,
}


var selectables: Array = []
onready var mno_master: MnoMaster = Mno.get_mno_master(self)
export var allows_wrapping: bool = true
export var initial_selectable: NodePath = ""
export(Array, NodePath) var allowed_outside_groups: Array = []
export var can_be_selected: bool = true
export var hover_visible_selectable: NodePath = ""
export var hover_visible_fade: bool = false
export(ScrollingTypes) var scrolling_type: int = ScrollingTypes.NONE
export var scroll_margin: int = 48
export(Array, NodePath) var scroll_reset_objs: Array = []
onready var orig_position: Vector2 = global_position


func get_hover_visible_selectable() -> MnoSelectable:
	var ret: MnoSelectable = get_node_or_null(hover_visible_selectable)
	return ret


func _ready() -> void:
	if Engine.editor_hint:
		return
	
	recursive_search(self)
#	for cur in get_children():
#		if cur is MnoSelectable:
#			selectables.push_back(cur)
	
	sort_selectables()


func recursive_search(cur) -> void:
	if cur is get_script() && cur != self:
		return
	if cur is MnoSelectable:
		selectables.push_back(cur)
	for c in cur.get_children():
		recursive_search(c)


func is_hidden() -> bool:
	if get_hover_visible_selectable() == null:
		return false
	return get_hover_visible_selectable().state == MnoSelectable.States.IDLE || get_hover_visible_selectable().state == MnoSelectable.States.DISABLED


func sort_selectables() -> void:
	pass


func tick(hovered_selectables: Array = []) -> void:
	if scrolling_type:
		var hori: bool = scrolling_type == ScrollingTypes.HORIZONTAL
		var vert: bool = scrolling_type == ScrollingTypes.VERTICAL
		if scrolling_type == ScrollingTypes.BOTH:
			hori = true
			vert = true
		for s in selectables:
			if hovered_selectables.has(s):
				var pos: Vector2 = s.global_position
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
						dist = global_position - orig_position
				global_position -= dist * 0.5
	
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


func process_inputs() -> void:
	pass


func get_initially_selected_element() -> MnoSelectable:
	if get_node_or_null(initial_selectable) is MnoSelectable:
		var h: MnoSelectable = get_node(initial_selectable)
		return h
	if selectables.empty():
		return null
	return selectables[0]


func permitted_outside_groups(cursor: MnoCursor) -> Array:
	var ret: Array = []
	for g in allowed_outside_groups:
		ret.push_back(get_node_or_null(g))
	return ret


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
