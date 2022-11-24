# A special MnoButton for selecting a number from a range.
tool
extends MnoButton
class_name MnoSliderButton, "res://addons/mno_menus/icons/mno_slider_button.png"


# Lower bound for possible values.
export var low: float = 0
# Upper bound for possible values.
export var high: float = 10
# Current value.
export var on: float = 5 setget set_value
# Current value, but smoothly interpolated when the value changes.
var display_value: float = on
# Amount that the value changes when a direction is pressed.
export var step: float = 1
# Whether or not the player can use In.UI_OPTION_A and In.UI_OPTION_B to quickly scroll thru.
export var uses_option_a_b: bool = false
# The color for the button prompts if the above option is enabled.
export var button_color: Color = Color("424367")
# Timer used for animations.
var click_timer: int = 0
# Value used for when the player presses cancel and the slider returns to its prior value.
var remembered_value: int = on


func get_align_offset() -> Vector2:
	if !(get_current_theme() is MnoSliderButtonTheme):
		printerr("Slider button has non slider button theme...")
		return .get_align_offset()
	return .get_align_offset() + Vector2.DOWN * get_current_theme().label_y_offset


# Sets the theme to a valid one by default.
func _ready() -> void:
	if Engine.editor_hint && theme == MnoConfig.SelectableThemes.PLAIN_MEDIUM:
		set_theme(MnoConfig.SelectableThemes.PLAIN_SLIDER)


func set_value(new_value: float) -> void:
	on = new_value
	if Engine.editor_hint:
		display_value = on


func should_long_click() -> bool:
	return true


func click() -> void:
	.click()
	
	remembered_value = on


# State logic for edit mode.
func tick() -> void:
	.tick()
	
	display_value = lerp(display_value, on, 0.5)
	click_timer -= sign(click_timer)
	
	if state == States.LONG_CLICKED:
		if !should_be_hovered:
			on = remembered_value
			click()
			set_state(States.CLICKED)
			mno_master.play_sound(get_current_theme().cancel_sound)
			return


# All of the input stuff...
func read_inputs() -> void:
	if state == States.LONG_CLICKED:
		if in_pressed(In.UI_CANCEL, false, true, true):
			on = remembered_value
			click()
			set_state(States.CLICKED)
			mno_master.play_sound(get_current_theme().cancel_sound)
			return
			
		if in_pressed(In.UI_CONFIRM, false, true, true):
			click()
			set_state(States.CLICKED)
			return
	
	.read_inputs()
		
	if state == States.LONG_CLICKED:
		var dir: int = int(in_pressed(In.UI_RIGHT, false, true, true)) - int(in_pressed(In.UI_LEFT, false, true, true))
		if dir != 0:
			on += dir * step
			on = clamp(on, low, high)
			click_timer = dir * 5
			mno_master.play_sound(get_current_theme().tick_sound)
		in_eat(In.UI_UP)
		in_eat(In.UI_DOWN)
	
	if !uses_option_a_b || state == States.LONG_CLICKED:
		return
	
	var dir: int = int(in_pressed(In.UI_OPTION_B, false, true, true)) - int(in_pressed(In.UI_OPTION_A, false, true, true))
	if dir != 0:
		on += dir * step
		on = clamp(on, low, high)
		click_timer = dir * 5
		mno_master.play_sound(get_current_theme().tick_sound)


# Draws the bar and the number and such.
func _draw() -> void:
	if uses_option_a_b && state != States.IDLE && state != States.LONG_CLICKED && state != States.DISABLED:
		var prompt_font: Font = MnoConfig.get_font(MnoConfig.Fonts.m5x7)
		var buffer_amt: int = 0
		var prompt_input_name: String = ""
		for input in [In.UI_OPTION_A, In.UI_OPTION_B]:
			if Engine.editor_hint:
				prompt_input_name = In.get_script_constant_map().keys()[In.get_script_constant_map().values().find(input)]
			else:
				var h: Array = mno_master.get_input_display_info(input)
				prompt_input_name = h[0]
				buffer_amt = h[1]
			var other_offset: Vector2 = get_size() / 2 - Vector2(6, 4)
			other_offset.x *= (-1 if input == In.UI_OPTION_A else 1)
	#		other_offset.y *= -1
			MnoMaster.draw_button_prompt(self, ["", prompt_input_name, buffer_amt], prompt_font, offset + other_offset,
					MnoSelectableTheme.HAlign.RIGHT if input == In.UI_OPTION_A else MnoSelectableTheme.HAlign.LEFT,
					true, button_color, Color.white)
	
	var t: MnoSliderButtonTheme = get_current_theme()
	var ts: Dictionary = get_current_theme_state()
	var bar_pos: Vector2 = offset + Vector2.DOWN * t.bar_y_offset - Vector2.RIGHT * t.bar_width / 2
	var edit_mode: bool = state == States.LONG_CLICKED
	var amt: float = float(display_value - low) / (high - low)
	draw_rect(
			Rect2(bar_pos, Vector2(t.bar_width, t.bar_height)),
			t.empty_color)
	draw_rect(
			Rect2(bar_pos, Vector2(t.bar_width * amt, t.bar_height)),
			t.full_color)
	
	var value_font: Font = MnoConfig.get_font(ts.label_font if edit_mode else t.value_font)
#	value_font = MnoConfig.get_font(MnoConfig.Fonts.m6x11)
	var value_offset: Vector2 = Vector2(t.bar_width * (amt - 0.5), t.value_y_offset_selected if edit_mode else t.value_y_offset)
	value_offset.y += abs(click_timer)
	var s_size: Vector2 = value_font.get_string_size(str(on))
	s_size.y = value_font.get_ascent()
	if edit_mode:
		draw_outline(value_font, offset + s_size * Vector2(-0.5, 1) + value_offset, str(on), Color.black)
	draw_string(value_font, offset + s_size * Vector2(-0.5, 1) + value_offset, str(on), t.full_color)
	
	if edit_mode:
		for i in [-1, 1]:
			var arrow_offset: Vector2 = Vector2.DOWN * (abs(click_timer) if sign(click_timer) == i else 0)
			draw_set_transform(value_offset * Vector2(1, 0) + (Vector2.LEFT if i == -1 else Vector2.ZERO), 0.0, Vector2(i, 1))
			draw_texture(t.arrow_sprite, arrow_offset + offset - t.arrow_sprite.get_size() / 2 + Vector2.RIGHT * s_size.x / 2)
	
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
