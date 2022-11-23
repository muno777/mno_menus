tool
extends Mno2D
class_name MnoMaster, "res://addons/mno_menus/icons/mno_master.png"
func get_class() -> String: return "MnoMaster"
# The master script for the plugin which handles controller inputs and the menu stack.


signal fade_midpoint
signal slide_finished
signal menu_stack_emptied


var exist_timer: int = 0
var menu_stack: Array = []
var controllers: Array = []
var latest_used_controller: MnoInput = null
var inputs: Array = []
var inputs_propagated: Array = []
var inputs_raw: Array = []
const TRANSITION_DELAY: int = 5
const FADE_LENGTH: int = 20 # should be even
var fade_progress: int = FADE_LENGTH / 2 + TRANSITION_DELAY - 1
var slide_progress: int = 0
var slide_direction: Vector2 = Vector2.ZERO
const SLIDE_LENGTH: int = 10
var audio_player: AudioStreamPlayer = null
var last_time_each_input_was_pressed: Array = []

export var starting_menu: PackedScene = null
#export var start_with_fade_in: bool = true
export var draw_button_prompts: bool = true
export var back_sound: AudioStream = null
export var auto_tick: bool = false


enum TransitionTypes {
	NONE,
	FADE,
	SLIDE_LEFT,
	SLIDE_RIGHT,
	SLIDE_TOP,
	SLIDE_BOTTOM,
}


enum InputDisplayBgs {
	NONE,
	SQUARE,
	CIRCLE,
	ROUNDED,
	CUSTOM_IMAGE,
}


func get_input_display_info(input: int) -> Array:
	var controller_obj: MnoInput = get_latest_used_controller()
	var controller_type: String = "keyboard" if controller_obj.gamepad_num == MnoInput.DEVICE_KEYBOARD else "gamepad"
	var button_or_key: int = controller_obj.profile[controller_type][input][0]
	var name: String = get_input_name(button_or_key).to_upper()
	var buffer: int = clamp(7 - exist_timer + last_time_each_input_was_pressed[input], 0, 7)
	return [name, buffer]


func on_controller_input_pressed(input: int, controller: MnoInput) -> void:
	latest_used_controller = controller
	last_time_each_input_was_pressed[input] = exist_timer # used for button prompts


static func get_input_name(input: int) -> String:
	# TODO: add option for xbox vs switch lol
	match input:
		JOY_DS_A:
			return "A"
		JOY_DS_B:
			return "B"
		JOY_DS_X:
			return "X"
		JOY_DS_Y:
			return "Y"
	if input < 32:
		return Input.get_joy_button_string(input)
	return OS.get_scancode_string(input)


func _get_configuration_warning() -> String:
	for c in get_children():
		if c is AudioStreamPlayer:
			return ""
	return "There is no AudioStreamPlayer child, so the menus can't make noise.\nAdd one as a child to enable menu sounds!"


func _init() -> void:
	add_to_group("mno_master")


func _ready() -> void:
	if Engine.editor_hint:
		return
	for i in range(MnoConfig.NUM_CONTROLLERS + 1):
		var c: MnoInput = MnoInput.new()
		add_child(c)
		controllers.push_back(c)
		inputs.push_back(c.inputs)
		c.gamepad_num = i
		c.connect("input_pressed", self, "on_controller_input_pressed", [c])
	latest_used_controller = controllers[0]
	if starting_menu != null:
		push_menu(starting_menu.instance())
	for c in get_children():
		if c is AudioStreamPlayer:
			audio_player = c
	for i in range(In.FOOTER):
		last_time_each_input_was_pressed.push_back(-100)


func get_num_menus() -> int:
	return menu_stack.size()


func get_latest_used_controller() -> MnoInput:
	return latest_used_controller


func _physics_process(delta: float) -> void:
	if Engine.editor_hint:
		return
	if auto_tick:
		tick()


func tick() -> void:
	for c in controllers:
		c.tick()
	
	var menu_stack_inv: Array = menu_stack.duplicate()
	menu_stack_inv.invert()
	
	inputs_propagated = inputs.duplicate(true)
	inputs_raw = inputs.duplicate(true)
	
	for m in menu_stack_inv:
		var should_read_inputs: bool = (fade_progress == 0 && slide_progress == 0)
		m.tick(should_read_inputs)
		if !m.input_passthrough:
			inputs_propagated = []
	
	if fade_progress:
		fade_progress += 1
		if fade_progress - TRANSITION_DELAY == FADE_LENGTH / 2:
			emit_signal("fade_midpoint")
		if fade_progress > FADE_LENGTH + TRANSITION_DELAY:
			fade_progress = 0
#		update()
	
	if slide_progress != 0:
		update_slide_position()
	
	update()
	
	exist_timer += 1


func update_slide_position() -> void:
	slide_progress += sign(slide_progress)
	var real_progress: int = max(abs(slide_progress) - TRANSITION_DELAY, 0)
	var distance: float = ease(real_progress / float(SLIDE_LENGTH), 0.5)
	if sign(slide_progress) == 1.0:
		distance = 1 - distance
	get_current_menu().position = distance * slide_direction * get_viewport_rect().size * 1.25
	if abs(slide_progress) > SLIDE_LENGTH + TRANSITION_DELAY:
		slide_progress = 0
		get_current_menu().position = Vector2.ZERO
		emit_signal("slide_finished")
#			update()


func play_sound(sound: AudioStream) -> void:
	if audio_player == null:
		return
	if sound == null:
		return
	audio_player.stream = sound
	audio_player.play()


func start_fade() -> void:
	fade_progress = 1
	update()


func start_slide(direction: Vector2, out: bool = false) -> void:
	slide_progress = -1 if out else 1
	slide_direction = direction
	update_slide_position()


func get_current_menu() -> Node2D:
	if menu_stack == []:
		return null
	return menu_stack.back()


func push_menu(new_menu) -> void:
	match new_menu.transition_type:
		TransitionTypes.NONE:
			pass
		TransitionTypes.FADE:
			start_fade()
			yield(self, "fade_midpoint")
	add_child(new_menu)
	menu_stack.push_back(new_menu)
	match new_menu.transition_type:
		TransitionTypes.SLIDE_LEFT:
			start_slide(Vector2.LEFT)
		TransitionTypes.SLIDE_RIGHT:
			start_slide(Vector2.RIGHT)
		TransitionTypes.SLIDE_TOP:
			start_slide(Vector2.UP)
		TransitionTypes.SLIDE_BOTTOM:
			start_slide(Vector2.DOWN)


func push_menu_array(new_menus: Array) -> void:
	for m in new_menus:
		push_menu(m)


func pop_menu(menu_target = menu_stack.back(), keep_target: bool = false) -> void:
	if fade_progress || slide_progress: # probably shouldn't be possible while a menu transition happens LOL
		return
	if menu_target == null:
		printerr("Tried to pop from menu stack, but target menu was null")
		return
	if menu_stack.empty():
		printerr("Tried to pop from menu stack, but it was empty")
		return
	if !menu_stack.has(menu_target):
		printerr("Tried to pop ", menu_target, " from menu stack, but it wasn't in the stack")
		return
	
	var reverse_menu_stack: Array = menu_stack.duplicate()
	reverse_menu_stack.invert()
	var keep_checking: bool = true
	var do_transitions: bool = true
	
	for m in reverse_menu_stack:
		if !keep_checking:
			break
		if m == menu_target:
			if !keep_target:
				pop_menu_inner(m, do_transitions)
			keep_checking = false
		else:
			pop_menu_inner(m, do_transitions)
		match menu_stack.back().transition_type:
			TransitionTypes.NONE, TransitionTypes.FADE:
				do_transitions = false
	
	
func pop_menu_inner(menu, do_transition: bool) -> void:
	if do_transition:
		match menu.transition_type:
			TransitionTypes.NONE:
				pass
			TransitionTypes.FADE:
				start_fade()
				yield(self, "fade_midpoint")
			TransitionTypes.SLIDE_LEFT:
				start_slide(Vector2.LEFT, true)
				yield(self, "slide_finished")
			TransitionTypes.SLIDE_RIGHT:
				start_slide(Vector2.RIGHT, true)
				yield(self, "slide_finished")
			TransitionTypes.SLIDE_TOP:
				start_slide(Vector2.UP, true)
				yield(self, "slide_finished")
			TransitionTypes.SLIDE_BOTTOM:
				start_slide(Vector2.DOWN, true)
				yield(self, "slide_finished")
	else:
		start_fade()
		yield(self, "fade_midpoint")
		
	menu_stack.back().queue_free()
	menu_stack.pop_back()
	if menu_stack.empty():
		emit_signal("menu_stack_emptied")


func pop_all_menus() -> void:
	pop_menu(menu_stack.front())


func _draw() -> void:
	if Engine.editor_hint:
		return
	if draw_button_prompts:
		var prompt_font: Font = MnoConfig.get_font(MnoConfig.Fonts.m5x7)
		var prompt_margin: int = 10
		var prompt_pos: Vector2 = Vector2(prompt_margin, get_viewport_rect().size.y - prompt_margin)
		if get_current_menu() != null:
			for p in get_current_menu().get_button_prompt_draw_list():
#				prompt_pos = draw_button_prompt_old(p, prompt_font, prompt_pos)
#				prompt_pos = draw_button_prompt_old_2(p, prompt_font, prompt_pos)
				prompt_pos = draw_button_prompt(self, p, prompt_font, prompt_pos) + Vector2.RIGHT * 9
	var alpha_mult: float = 1.0 if exist_timer < 3 else min(1, lerp(1, 0, abs((max(fade_progress - TRANSITION_DELAY, 0)) - FADE_LENGTH / 2) / float(FADE_LENGTH / 2)))
	draw_rect(get_viewport_rect(), Color(0, 0, 0, 1.5 * alpha_mult))


static func draw_button_prompt(obj: Node2D, str_pair: Array, prompt_font: Font, prompt_pos: Vector2, halign: int = MnoSelectableTheme.HAlign.LEFT,
		is_enabled: bool = true, col: Color = Color("424367"), text_col: Color = Color.white) -> Vector2:
	var b_size: Vector2 = prompt_font.get_string_size(str_pair[1])
	var offset: Vector2 = Vector2.ZERO
	var total_width: int = 4 + b_size.x + (3 if str_pair[0] == "" else 7) + prompt_font.get_string_size(str_pair[0]).x
	var align_offset: int = 0
	match halign:
		MnoSelectableTheme.HAlign.LEFT:
			pass
		MnoSelectableTheme.HAlign.CENTER:
			align_offset = total_width / 2
		MnoSelectableTheme.HAlign.RIGHT:
			align_offset = total_width
	prompt_pos.x -= align_offset
#	obj.draw_rect(Rect2(prompt_pos, Vector2(total_width, 20)), Color.red)
	if str_pair[2]:
		var offset_progress: float = min(1, float(str_pair[2] - 1) / 4)
		var offset_ease: float = ease(1 - offset_progress, 0.5)
		if is_enabled:
			offset.y = 2 * (1 - offset_ease)
			col = Color.white.linear_interpolate(col, offset_ease - 0.5)
		else:
			offset.x = (1 - offset_ease) * 3 * cos(str_pair[2] * 2)
			offset.y = (1 - offset_ease) * 2 * cos(str_pair[2] * 3.48)
	prompt_pos += offset + Vector2.RIGHT * 4
	obj.draw_rect(Rect2(prompt_pos - b_size * Vector2.DOWN + Vector2(-4, 3), b_size + Vector2(7, 0)), Color.black)
	obj.draw_rect(Rect2(prompt_pos - b_size * Vector2.DOWN + Vector2(-3, 2), b_size + Vector2(5, 2)), Color.black)
	obj.draw_rect(Rect2(prompt_pos - b_size * Vector2.DOWN + Vector2(-3, 4), b_size + Vector2(5, -3)), col)
	obj.draw_rect(Rect2(prompt_pos - b_size * Vector2.DOWN + Vector2(-2, 3), b_size + Vector2(3, -1)), col)
	obj.draw_outline(prompt_font, prompt_pos + Vector2.UP, str_pair[1], Color.black, true)
	obj.draw_string(prompt_font, prompt_pos + Vector2.UP, str_pair[1], text_col)
	prompt_pos.x += b_size.x + (3 if str_pair[0] == "" else 7)
	obj.draw_outline(prompt_font, prompt_pos, str_pair[0])
	obj.draw_string(prompt_font, prompt_pos, str_pair[0], text_col)
	prompt_pos.x += prompt_font.get_string_size(str_pair[0]).x
	prompt_pos.x += align_offset
	return prompt_pos - offset


static func draw_button_bg() -> void:
	pass


# draws outlines and drop shadows; redundant w/ MnoSelectable
func draw_outline(font: Font, pos: Vector2, text: String,
		color: Color = Color.black, drop_shadow: bool = true) -> void:
	for i in range(-1, 2): # x
		for j in range(-1, 3 if drop_shadow else 2): # y
			if i != 0 || j != 0:
				draw_string(font, pos + Vector2(i, j), text, color)


func in_pressed(controller_num: int, input_num: int, before_propagation: bool = false,
		clear: bool = false, eat: bool = false) -> bool:
	var arr: Array = inputs_raw if before_propagation else inputs_propagated
	if arr == []:
		return false
	if controller_num == MnoInput.DEVICE_ALL:
		var result: bool = false
		for i in range(MnoConfig.NUM_CONTROLLERS + 1):
			if in_pressed(i, input_num, before_propagation, clear, eat):
				result = true
		return result
	var result: bool = (arr[controller_num][input_num][0] > 1)
	if result:
		if clear:
			in_clear(controller_num, input_num)
		if eat:
			in_eat(controller_num, input_num)
	return result


func in_buffer_amt(controller_num: int, input_num: int, before_propagation: bool = false,
		clear: bool = false, eat: bool = false) -> int:
	var arr: Array = inputs_raw if before_propagation else inputs_propagated
	if arr == []:
		return 0
	if controller_num == MnoInput.DEVICE_ALL:
		var result: int = 0
		for i in range(MnoConfig.NUM_CONTROLLERS + 1):
			result = max(in_buffer_amt(i, input_num, before_propagation, clear, eat), result)
		return result
	var result: int = arr[controller_num][input_num][0]
	if clear:
		in_clear(controller_num, input_num)
	if eat:
		in_eat(controller_num, input_num)
	return result


func in_held(controller_num: int, input_num: int, before_propagation: bool = false) -> bool:
	var arr: Array = inputs_raw if before_propagation else inputs_propagated
	if arr == []:
		return false
	if controller_num == MnoInput.DEVICE_ALL:
		var result: bool = false
		for i in range(MnoConfig.NUM_CONTROLLERS + 1):
			if in_held(i, input_num, before_propagation):
				result = true
		return result
	return (arr[controller_num][input_num][1] > 0)


# clear buffer, affecting the next frame only
func in_clear(controller_num: int, input_num: int, check_correlated: bool = true) -> void:
	if controller_num == MnoInput.DEVICE_ALL:
		for i in range(MnoConfig.NUM_CONTROLLERS + 1):
			in_clear(i, input_num)
		return
	if inputs != []:
		inputs[controller_num][input_num][0] = 0
	if check_correlated:
		for i in get_correlated_inputs(controller_num, input_num):
			in_clear(controller_num, i, false)


# hide input from later propagations
func in_eat(controller_num: int, input_num: int, check_correlated: bool = true) -> void:
	if inputs_propagated == []:
		return
	if controller_num == MnoInput.DEVICE_ALL:
		for i in range(MnoConfig.NUM_CONTROLLERS + 1):
			in_eat(i, input_num)
		return
	inputs_propagated[controller_num][input_num][0] = 0
	inputs_propagated[controller_num][input_num][1] = 0
	if check_correlated:
		for i in get_correlated_inputs(controller_num, input_num):
			in_eat(controller_num, i, false)


func get_correlated_inputs(controller_num: int, input_num: int) -> Array:
	if controller_num > MnoConfig.NUM_CONTROLLERS - 1:
		return []
	var controller: MnoInput = controllers[controller_num]
	var profile: Dictionary = controller.profile
	for a in profile["keyboard" if controller_num == 0 else "gamepad"].correlated:
		if input_num in a:
			return a
	return []
