extends MnoMenu
tool


onready var game_master: GameMaster = null if get_tree().get_nodes_in_group("game_master") == [] else get_tree().get_nodes_in_group("game_master")[0]


func _ready() -> void:
	var _dummy = $MnoSelectableGroup/MnoButton2.connect("clicked", self, "_on_MnoButton2_clicked")


func _on_MnoButton2_clicked(_cursor: MnoCursor) -> void:
	var arr: Array = [
		"res://demo_game/title_screen.tscn",
		"res://demo_game/main_menu.tscn",
	]
	var arr2: Array = []
	for s in arr:
		arr2.push_back(load(s).instance())
	mno_master.push_menu_array(arr2)
	
	if !mno_master.is_connected("fade_midpoint", game_master, "unload_the_game"):
		var _dummy = mno_master.connect("fade_midpoint", game_master, "unload_the_game")


func tick(_h: bool = true) -> void:
	.tick(_h)
	
	if in_pressed(MnoInput.DEVICE_ALL, In.UI_PAUSE, false, true, true):
		$MnoSelectableGroup/MnoButton.click()
