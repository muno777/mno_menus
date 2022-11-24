# The invisible cursor object that moves around a MnoMenu, between MnoSelectables.
tool
extends Mno2D
class_name MnoCursor, "res://addons/mno_menus/icons/mno_cursor.png"


# The MnoSelectable it's currently hovering over.
var hovered_selectable: MnoSelectable = null
# The controller it's looking at.
var input_slot: int = MnoInput.DEVICE_ALL
# Whether or not it's currently active.
# Inactive = there are >1 cursors and no button has been pressed yet.
# Deactivating a cursor (setting this to false) might come in handy.
var active: bool = false
# Helper var for activation.
var should_become_active: bool = false
# MnoMaster ref.
onready var mno_master: MnoMaster = Mno.get_mno_master(self)


func tick() -> void:
	if should_become_active:
		active = true
		should_become_active = false


# Returns an array of the MnoCursors which are hovering over the same MnoSelectable as this one.
func get_cursors_on_same_selectable() -> Array:
	var ret: Array = []
	for c in mno_master.get_current_menu().cursors:
		if c.active && c.hovered_selectable == hovered_selectable:
			ret.push_back(c)
	return ret


# Call this to activate an inactive cursor.
# The dummy arg is there to make the signal connection work.
func become_active(_dummy_arg: int = 0) -> void:
	if active:
		return
	should_become_active = true
	for i in range(In.UI_HEADER, In.UI_FOOTER):
		mno_master.in_clear(input_slot, i)
		mno_master.in_eat(input_slot, i)
