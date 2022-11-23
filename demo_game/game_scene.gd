extends Node2D


var vel_y: int = 0
onready var orig_pos_y: int = $Icon.position.y
onready var mno_master: MnoMaster = Mno.get_mno_master(self)
onready var game_master: GameMaster = null if get_tree().get_nodes_in_group("game_master") == [] else get_tree().get_nodes_in_group("game_master")[0]


func _physics_process(_delta: float) -> void:
	if mno_master.get_num_menus():
		return
	
	if mno_master.in_pressed(MnoInput.DEVICE_ALL, In.UI_PAUSE):
		mno_master.push_menu(load("res://demo_game/pause_menu.tscn").instance())
		mno_master.play_sound(load("res://addons/mno_menus/button_themes/_sounds/tick.wav"))
		return
	
	$MnoButtonPrompt.tick()
	$MnoButtonPrompt2.tick()
	
	var can_jump: bool = ($Icon.position.y >= orig_pos_y) || game_master.get_option(GameMaster.Options.ALLOW_AIR_JUMP) 
	if can_jump && mno_master.in_pressed(MnoInput.DEVICE_ALL, In.JUMP, false, true, true):
		vel_y = -13
		$AudioStreamPlayer.play()
	
	$Icon.position.y = min($Icon.position.y - orig_pos_y + vel_y, 0) + orig_pos_y
	
	vel_y = int(min(vel_y + 1, 10))
	
	if vel_y > 0 && $Icon.position.y - orig_pos_y == 0:
		vel_y = 0
	
	var vel_amt: float = clamp(vel_y / -10.0, 0, 1)
	$Icon.scale = Vector2(
		1 - vel_amt / 6,
		1 + vel_amt / 6
	)
