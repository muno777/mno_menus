extends MnoMenu
tool


func tick(should_read_inputs: bool = true) -> void:
	.tick(should_read_inputs)
	
	$MnoLabel.modulate = Color(1, 1, 1, min(1.3 + sin(mno_master.exist_timer / 10.0), 1.0))
	
	if should_read_inputs:
		for i in range(In.FOOTER):
			if in_pressed(MnoInput.DEVICE_ALL, i):
				mno_master.push_menu(load("res://demo_game/main_menu.tscn").instance())
				mno_master.play_sound(load("res://addons/mno_menus/button_themes/_sounds/clicked.wav"))
				return
