tool
extends Resource
class_name MnoCursorTheme, "res://addons/mno_menus/icons/mno_cursor_renderer.png"
func get_class() -> String: return "MnoCursorTheme"


# redundant w/ MnoCursorRenderer sorry
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


var idle_state: Dictionary = get_default_dict(States.IDLE)
var clicking_state: Dictionary = get_default_dict(States.CLICKING)


export var margin: Vector2 = Vector2.ZERO
export var offset_scale: Vector2 = Vector2.ONE
export var overload_offset: Vector2 = Vector2(-16, 0)


static func get_default_dict(state: int) -> Dictionary:
	var dict: Dictionary = {
		sprites = [
			null,
			null,
			null,
			null,
		],
		frames = 1,
		frame_duration = 3,
		extra_margin = Vector2.ZERO,
		offset_scale = Vector2.ONE,
	}
	return dict


func get_name_state_pairs() -> Array:
	return [
			["Idle", idle_state],
			["Clicking", clicking_state],
		]


func get_direction_unicodes() -> Array:
	return [
		"↖",
		"↗",
		"↙",
		"↘ ",
	]


# https://stackoverflow.com/questions/71175503/how-to-add-array-with-hint-and-hint-string
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
