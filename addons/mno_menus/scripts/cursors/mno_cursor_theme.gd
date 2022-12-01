# A resource that defines a visual theme for a MnoCursorRenderer.
tool
extends Resource
class_name MnoCursorTheme, "res://addons/mno_menus/icons/mno_cursor_renderer.png"


# These are redundant with MnoCursorRenderer, make sure to copy it back and forth... sorry
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


# Dicts for the various states and their properties.
var idle_state: Dictionary = get_default_dict(States.IDLE)
var clicking_state: Dictionary = get_default_dict(States.CLICKING)

# The distance for each corner from the edge of the MnoSelectable.
# Bigger number = smaller cursor "box".
export var margin: Vector2 = Vector2.ZERO
# The amount to multiply each corner's distance from the center by.
# Bigger number = larger cursor "box".
export var offset_scale: Vector2 = Vector2.ONE
# The amount that each corner gets shifted if >1 cursor highlights the same MnoSelectable.
# Gets added to the margin, by some different multiple for each cursor that overlaps (0, 1, 2, ...).
export var overload_offset: Vector2 = Vector2(-16, 0)
# Whether or not to still render the sprites when a mouse is used and the mouse is not hovering
# anything.
export var show_when_mouse_free: bool = false


# Returns the default dictionary for one of the states.
static func get_default_dict(state: int) -> Dictionary:
	var dict: Dictionary = {
		# The four corner textures: top-left, top-right, bottom-left, bottom-right.
		sprites = [
			null,
			null,
			null,
			null,
		],
		# The number of hframes in the sprite.
		frames = 1,
		# The duration of each animation frame, in game frames (usually 1/60 of a second).
		frame_duration = 3,
		# The value added to margin during this state.
		extra_margin = Vector2.ZERO,
		# The value offset_scale is multiplied by during this state.
		offset_scale = Vector2.ONE,
	}
	return dict


# Returns pairs that can be looped thru.
func get_name_state_pairs() -> Array:
	return [
			["Idle", idle_state],
			["Clicking", clicking_state],
		]


# Used to draw the funny little arrows in the export names.
func get_direction_unicodes() -> Array:
	return [
		"↖",
		"↗",
		"↙",
		"↘ ",
	]


# The rest of this file is just manually exporting variables (for more control over formatting/etc).
# This is an "advanced" version of using the export keyword... and it's a pain too.

func _get_property_list() -> Array:
	var ret: Array = []
	
	for p in get_name_state_pairs():
		for d in get_direction_unicodes():
			ret.append({
				name = p[0] + "/Sprite " + d,
				type = TYPE_OBJECT,
				hint = PROPERTY_HINT_RESOURCE_TYPE,
				hint_string = "Texture",
			})
		ret.append({
			name = p[0] + "/Frames",
			type = TYPE_INT,
		})
		ret.append({
			name = p[0] + "/Frame Duration",
			type = TYPE_INT,
		})
		ret.append({
			name = p[0] + "/Extra Margin",
			type = TYPE_VECTOR2,
		})
		ret.append({
			name = p[0] + "/Offset Scale",
			type = TYPE_VECTOR2,
		})
	
	return ret


func _set(property: String, value) -> bool:
	for p in get_name_state_pairs():
		var d: Dictionary = p[1]
		for i in get_direction_unicodes().size():
			if property.replace(p[0] + "/", "") == "Sprite " + get_direction_unicodes()[i]:
				d.sprites[i] = value
				return true
		match property.replace(p[0] + "/", ""):
			"Frames":
				d.frames = value
				return true
			"Frame Duration":
				d.frame_duration = value
				return true
			"Extra Margin":
				d.extra_margin = value
				return true
			"Offset Scale":
				d.offset_scale = value
				return true
	
	return false


func _get(property: String):
	for p in get_name_state_pairs():
		var d: Dictionary = p[1]
		for i in get_direction_unicodes().size():
			if property.replace(p[0] + "/", "") == "Sprite " + get_direction_unicodes()[i]:
				return d.sprites[i]
		match property.replace(p[0] + "/", ""):
			"Frames":
				return d.frames
			"Frame Duration":
				return d.frame_duration
			"Extra Margin":
				return d.extra_margin
			"Offset Scale":
				return d.offset_scale
	
	return null
