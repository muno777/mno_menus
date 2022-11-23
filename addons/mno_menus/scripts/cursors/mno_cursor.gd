tool
extends Mno2D
class_name MnoCursor, "res://addons/mno_menus/icons/mno_cursor.png"
func get_class() -> String: return "MnoCursor"
# Selects selectables in a menu.


var hovered_selectable: MnoSelectable = null
var previous_hovered_selectable: MnoSelectable = null
const ALL_INPUTS: int = 1000
var input_slot: int = -1 # -1 means this cursor uses all controllers + keyboard
var active: bool = false
var should_become_active: bool = false
onready var mno_master: MnoMaster = Mno.get_mno_master(self)


func tick() -> void:
	if should_become_active:
		active = true
		should_become_active = false


func get_cursors_on_same_selectable() -> Array:
	var ret: Array = []
	for c in mno_master.get_current_menu().cursors:
		if c.active && c.hovered_selectable == hovered_selectable:
			ret.push_back(c)
	return ret


func become_active(dummy_arg: int = 0) -> void:
	if active:
		return
	should_become_active = true
	for i in range(In.UI_HEADER, In.UI_FOOTER):
		mno_master.in_clear(input_slot, i)
		mno_master.in_eat(input_slot, i)
