extends Node2D
class_name GameMaster

enum Options {
	RESOLUTION,
	FULLSCREEN,
	VFX_QUALITY,
	VSYNC,
	
	MUSIC,
	SFX,
	EQ,
	VOICES,
	MENUS,
	MONO,
	
	ALLOW_AIR_JUMP,
	
	COLORBLIND_MODE,
}

var game_instance: Node2D = null
onready var mno_master: MnoMaster = Mno.get_mno_master(self)
var options: Dictionary = {}


func get_default_option(idx: int):
	match idx:
		Options.RESOLUTION, Options.VFX_QUALITY, Options.EQ, Options.MUSIC:
			return 0
		Options.SFX, Options.VOICES, Options.MENUS:
			return 5
		Options.FULLSCREEN, Options.VSYNC, Options.MONO, Options.ALLOW_AIR_JUMP, Options.COLORBLIND_MODE:
			return false
	return 0


func get_option(idx: int):
	return options[idx]


func set_option(idx: int, value) -> void:
	options[idx] = value
	match idx:
		Options.RESOLUTION:
			var size: Vector2 = Vector2.ZERO
			match value:
				0:
					size = Vector2(960, 540)
				1:
					size = Vector2(1280, 720)
				2:
					size = Vector2(1920, 1080)
			OS.set_window_size(size)
		Options.FULLSCREEN:
			OS.window_fullscreen = value
		Options.MUSIC:
			set_gain_of("Music", value)
		Options.SFX:
			set_gain_of("SFX", value)
		Options.MENUS:
			set_gain_of("Menus", value)


func set_gain_of(bus_name: String, value: int) -> void:
	if value == 0:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), -72)
		return
	value -= 5
	if bus_name == "Menus":
		value -= 3
	value *= 3
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), value)


func _init() -> void:
	add_to_group("game_master")
	for i in Options.values():
		set_option(i, get_default_option(i))


func load_the_game() -> void:
	game_instance = load("res://demo_game/game_scene.tscn").instance()
	add_child(game_instance)
	game_instance.z_index = -1
	
	if mno_master.is_connected("menu_stack_emptied", self, "load_the_game"):
		mno_master.disconnect("menu_stack_emptied", self, "load_the_game")


func unload_the_game() -> void:
	game_instance.queue_free()
	
	if mno_master.is_connected("fade_midpoint", self, "unload_the_game"):
		mno_master.disconnect("fade_midpoint", self, "unload_the_game")


func _physics_process(_delta: float) -> void:
	$MnoMaster.tick()
