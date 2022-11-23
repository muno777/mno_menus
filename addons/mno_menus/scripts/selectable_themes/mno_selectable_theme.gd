tool
extends Resource
class_name MnoSelectableTheme, "res://addons/mno_menus/icons/mno_selectable.png"
func get_class() -> String: return "MnoSelectableTheme"


var idle_state: Dictionary = get_default_dict(States.IDLE)
var hovered_state: Dictionary = get_default_dict(States.HOVERED)
var clicked_state: Dictionary = get_default_dict(States.CLICKED)
var long_clicked_state: Dictionary = get_default_dict(States.LONG_CLICKED)
var disabled_state: Dictionary = get_default_dict(States.DISABLED)


# redundant w/ MnoTextRenderer sorry
enum HAlign {
	LEFT,
	CENTER,
	RIGHT,
}
enum VAlign {
	TOP,
	MIDDLE,
	BOTTOM,
}


export var width: int = 16
export var height: int = 16
export(HAlign) var label_h_align: int = HAlign.CENTER setget set_label_h_align
export(VAlign) var label_v_align: int = VAlign.MIDDLE setget set_label_v_align
export var selectable_when_disabled: bool = true

func set_label_h_align(value: int) -> void:
	label_h_align = value
	property_list_changed_notify()
func set_label_v_align(value: int) -> void:
	label_v_align = value
	property_list_changed_notify()

# fake exports
var h_align_margin: int = 8
var v_align_margin: int = 8


# these are redundant w/ MnoSelectable sorry
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


static func get_default_dict(state: int) -> Dictionary:
	var dict: Dictionary = {
		sprite = null,
		frames = 1,
		frame_duration = 3,
		extra_width = 0,
		extra_height = 0,
		label_font = MnoConfig.Fonts.m6x11,
		label_color = Color.white,
		label_outline = false,
		outline_color = Color.black,
		drop_shadow = false,
		anim_offset = Vector2.ZERO,
		anim_rotation_degrees = 0,
	}
	match state:
		States.HOVERED, States.LONG_CLICKED:
			dict.transition_frames = 0
			continue
		States.HOVERED, States.CLICKED, States.LONG_CLICKED, States.DISABLED:
			dict.animation_type = 0 # TODO: add anims for trying to click a disabled button
			dict.sound_effect = null
			continue
	return dict


func get_name_state_pairs() -> Array:
	return [
			["Idle", idle_state],
			["Hovered", hovered_state],
			["Clicked", clicked_state],
			["Long Clicked", long_clicked_state],
			["Disabled", disabled_state],
		]


func _get_property_list() -> Array:
	var ret: Array = []
	
	if label_h_align != HAlign.CENTER:
		ret.append({
			name = "H Align Margin",
			type = TYPE_INT,
		})
	
	if label_v_align != VAlign.MIDDLE:
		ret.append({
			name = "V Align Margin",
			type = TYPE_INT,
		})
	
	for p in get_name_state_pairs():
		ret.append({
			name = p[0] + "/Sprite",
			type = TYPE_OBJECT,
			hint = PROPERTY_HINT_RESOURCE_TYPE,
			hint_string = "Texture",
		})
		ret.append({
			name = p[0] + "/Frames",
			type = TYPE_INT,
		})
		if p[1].frames > 1:
			ret.append({
				name = p[0] + "/-Frame Duration",
				type = TYPE_INT,
			})
			if p[0] in ["Hovered", "Long Clicked"]:
				ret.append({
					name = p[0] + "/-Transition Frames",
					type = TYPE_INT,
				})
		ret.append({
			name = p[0] + "/Extra Width",
			type = TYPE_INT,
		})
		ret.append({
			name = p[0] + "/Extra Height",
			type = TYPE_INT,
		})
		ret.append({
			name = p[0] + "/Label Font",
			type = TYPE_INT,
			hint = PROPERTY_HINT_ENUM,
			hint_string = PoolStringArray(MnoConfig.Fonts.keys()).join(",").replace(", ", ","),
		})
		ret.append({
			name = p[0] + "/Label Color",
			type = TYPE_COLOR,
		})
		ret.append({
			name = p[0] + "/Label Outline",
			type = TYPE_BOOL,
		})
		if p[1].label_outline:
			ret.append({
				name = p[0] + "/-Outline Color",
				type = TYPE_COLOR,
			})
			ret.append({
				name = p[0] + "/-Drop Shadow",
				type = TYPE_BOOL,
			})
		if p[0] in ["Hovered", "Clicked", "Long Clicked"]:
			ret.append({
				name = p[0] + "/Animation Type",
				type = TYPE_INT,
				hint = PROPERTY_HINT_ENUM,
				hint_string = PoolStringArray(HoveredAnimations.keys() if p[0] == "Hovered" else ClickedAnimations.keys()).join(",").capitalize().replace(", ", ","),
			})
		if p[0] in ["Hovered", "Clicked", "Long Clicked", "Disabled"]:
			ret.append({
				name = p[0] + "/Sound Effect",
				type = TYPE_OBJECT,
				hint = PROPERTY_HINT_RESOURCE_TYPE,
				hint_string = "AudioStream",
			})
		ret.append({
			name = p[0] + "/Offset",
			type = TYPE_VECTOR2,
		})
		ret.append({
			name = p[0] + "/Rotation Degrees",
			type = TYPE_INT,
		})
	
	return ret


func _set(property: String, value) -> bool:
	match property:
		"H Align Margin":
			h_align_margin = value
			return true
		"V Align Margin":
			v_align_margin = value
			return true
	for p in get_name_state_pairs():
		var d: Dictionary = p[1]
		match property.replace(p[0] + "/", ""):
			"Sprite":
				d.sprite = value
				return true
			"Frames":
				property_list_changed_notify()
				d.frames = value
				return true
			"-Frame Duration":
				d.frame_duration = value
				return true
			"-Transition Frames":
				d.transition_frames = value
				return true
			"Extra Width":
				d.extra_width = value
				return true
			"Extra Height":
				d.extra_height = value
				return true
			"Label Font":
				d.label_font = value
				return true
			"Label Color":
				d.label_color = value
				return true
			"Label Outline":
				property_list_changed_notify()
				d.label_outline = value
				return true
			"-Outline Color":
				d.outline_color = value
				return true
			"-Drop Shadow":
				d.drop_shadow = value
				return true
			"Animation Type":
				d.animation_type = value
				return true
			"Offset":
				d.anim_offset = value
				return true
			"Rotation Degrees":
				d.anim_rotation_degrees = value
				return true
			"Sound Effect":
				d.sound_effect = value
				return true
	
	return false


func _get(property: String):
	match property:
		"H Align Margin":
			return h_align_margin
		"V Align Margin":
			return v_align_margin
	for p in get_name_state_pairs():
		var d: Dictionary = p[1]
		match property.replace(p[0] + "/", ""):
			"Sprite":
				return d.sprite 
			"Frames":
				return d.frames 
			"-Frame Duration":
				return d.frame_duration 
			"-Transition Frames":
				return d.transition_frames 
			"Extra Width":
				return d.extra_width 
			"Extra Height":
				return d.extra_height 
			"Label Font":
				return d.label_font 
			"Label Color":
				return d.label_color 
			"Label Outline":
				return d.label_outline 
			"-Outline Color":
				return d.outline_color 
			"-Drop Shadow":
				return d.drop_shadow 
			"Animation Type":
				return d.animation_type 
			"Offset":
				return d.anim_offset
			"Rotation Degrees":
				return d.anim_rotation_degrees
			"Sound Effect":
				return d.sound_effect 
	
	return null
