tool
extends MnoMenu


onready var game_master: GameMaster = null if get_tree().get_nodes_in_group("game_master") == [] else get_tree().get_nodes_in_group("game_master")[0]
onready var options_to_buttons: Dictionary = {
	GameMaster.Options.RESOLUTION: $Graphics/BtnResolution,
	GameMaster.Options.FULLSCREEN: $Graphics/BtnFullscreen,
	GameMaster.Options.VFX_QUALITY: $Graphics/BtnVFXQuality,
	GameMaster.Options.VSYNC: $Graphics/BtnVsync,
	GameMaster.Options.MUSIC: $Audio/BtnMusic,
	GameMaster.Options.SFX: $Audio/BtnSFX,
	GameMaster.Options.EQ: $Audio/BtnEQ,
	GameMaster.Options.VOICES: $Audio/BtnVoices,
	GameMaster.Options.MENUS: $Audio/BtnMenus,
	GameMaster.Options.MONO: $Audio/BtnMono,
	GameMaster.Options.ALLOW_AIR_JUMP: $Gameplay/BtnAllowAirJump,
	GameMaster.Options.COLORBLIND_MODE: $Accessibility/BtnColorblindMode,
}


func _ready() -> void:
	for i in GameMaster.Options.values():
		if i in options_to_buttons:
			options_to_buttons[i].on = game_master.get_option(i)


func tick(should_read_inputs: bool = true) -> void:
	.tick(should_read_inputs)
	
	if should_read_inputs:
		if in_pressed(MnoInput.DEVICE_ALL, In.UI_PAUSE, false, true, true):
			var k: Array = options_to_buttons.keys()
			var v: Array = options_to_buttons.values()
			for i in range(k.size()):
				if v[i].state == MnoSelectable.States.HOVERED || v[i].state == MnoSelectable.States.CLICKED:
					v[i].click()
					v[i].on = game_master.get_default_option(k[i])
	
	for i in GameMaster.Options.values():
		if i in options_to_buttons:
			game_master.set_option(i, options_to_buttons[i].on)


func get_button_prompt_list() -> Array:
	return [
		[In.UI_PAUSE, "Reset Option"],
	]
