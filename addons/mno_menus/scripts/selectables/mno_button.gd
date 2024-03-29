# A button that you can click click click to your heart's content.
tool
extends MnoSelectable
class_name MnoButton, "res://addons/mno_menus/icons/mno_button.png"


# Emitted when the button is clicked; cursor is the MnoCursor that clicked it.
signal clicked(cursor)


# The possible actions that can happen when you click the button.
enum ClickActions {
	NONE,
	PUSH_MENU,
	POP_MENU,
	POP_ALL_MENUS,
	MOVE_CURSOR,
	QUIT_GAME,
}

# The action that happens when the button is clicked.
# The clicked signal is always emitted no matter what this is set to.
export(ClickActions) var click_action: int = ClickActions.NONE setget set_click_action
# The menu to push when click_action is set to ClickActions.PUSH_MENU.
var pushed_menu: PackedScene = null
# The menu to pop to when click_action is set to ClickActions.POP_MENU.
var popped_to_menu: PackedScene = null
# The MnoSelectable to move the cursor to when click_action is set to ClickActions.MOVE_CURSOR.
var cursor_target: NodePath = ""
# Timer used for the shake animation when you try to click a disabled button.
var shake_timer: int = 0


func set_click_action(value: int) -> void:
	click_action = value
	property_list_changed_notify()


# Checks for click input. Clicks. Clicky click click click.
func read_inputs() -> void:
	.read_inputs()
	
	if in_pressed(In.UI_CONFIRM, false, true, true) && state != States.LONG_CLICKED:
		click()


# If this returns true, the button will enter the long click state when clicked.
# If false, it'll enter the regular click state.
func should_long_click() -> bool:
	return false


# Does the disabled-click shake animation.
func tick() -> void:
	.tick()
	
	if shake_timer:
		offset.x = 3 * cos(shake_timer * 2)
		offset.y = 2 * cos(shake_timer * 3.48)
		shake_timer -= 1


# Causes the button to be clicked, and handles the click action stuff.
func click() -> void:
	var ts: Dictionary = get_current_theme().clicked_state
	
	if !enabled:
		shake_timer = 10
		mno_master.play_sound(get_current_theme().disabled_state.sound_effect)
		return
	
	set_state(States.LONG_CLICKED if should_long_click() else States.CLICKED)
	emit_signal("clicked", cursor)
	mno_master.play_sound(ts.sound_effect)
	match click_action:
		ClickActions.NONE:
			pass
		ClickActions.PUSH_MENU:
			if pushed_menu == null:
				printerr("Tried to push menu, but pushed_menu was null")
				continue
			mno_master.push_menu(pushed_menu.instance())
		ClickActions.POP_MENU:
			if popped_to_menu == null:
				mno_master.pop_menu()
			else:
				var m_scene: MnoMenu = null
				for m in mno_master.menu_stack:
					if m.get_filename() == popped_to_menu.get_path():
						m_scene = m
				if m_scene == null:
					printerr("Button tried to pop to a menu, but it wasn't in the stack")
					continue
				mno_master.pop_menu(m_scene, true)
		ClickActions.POP_ALL_MENUS:
			mno_master.pop_all_menus()
		ClickActions.MOVE_CURSOR:
			if cursor_target == null:
				printerr("Cursor target is null oh noes")
				continue
			cursor.hovered_selectable = get_node(cursor_target)
		ClickActions.QUIT_GAME:
			mno_master.start_fade()
			yield(mno_master, "fade_midpoint")
			get_tree().quit()


# The rest of this file is just manually exporting variables (for more control over formatting/etc).
# This is an "advanced" version of using the export keyword... and it's a pain too.

func _get_property_list() -> Array:
	var ret: Array = []

	match click_action:
		ClickActions.PUSH_MENU:
			ret.append({
				name = "Pushed Menu",
				type = TYPE_OBJECT,
				hint = PROPERTY_HINT_RESOURCE_TYPE,
				hint_string = "PackedScene",
			})
		ClickActions.POP_MENU:
			ret.append({
				name = "Popped-To Menu",
				type = TYPE_OBJECT,
				hint = PROPERTY_HINT_RESOURCE_TYPE,
				hint_string = "PackedScene",
			})
		ClickActions.MOVE_CURSOR:
			ret.append({
				name = "Cursor Target",
				type = TYPE_NODE_PATH,
				hint = 35,
				hint_string = "MnoSelectable",
			})

	return ret


func _set(property: String, value) -> bool:
	match property:
		"Pushed Menu":
			pushed_menu = value
			return true
		"Popped-To Menu":
			popped_to_menu = value
			return true
		"Cursor Target":
			cursor_target = value
			return true
	return false


func _get(property: String):
	match property:
		"Pushed Menu":
			return pushed_menu
		"Popped-To Menu":
			return popped_to_menu
		"Cursor Target":
			return cursor_target
	return null
