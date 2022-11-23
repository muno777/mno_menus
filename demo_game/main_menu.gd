extends MnoMenu
tool


onready var game_master: GameMaster = null if get_tree().get_nodes_in_group("game_master") == [] else get_tree().get_nodes_in_group("game_master")[0]


func _ready() -> void:
	var _dummy = $MnoSelectableGroup/Play.connect("clicked", self, "_on_Play_clicked")


func _on_Play_clicked(_cursor: MnoCursor) -> void:
	mno_master.pop_all_menus()
	
	if !mno_master.is_connected("menu_stack_emptied", game_master, "load_the_game"):
		var _dummy = mno_master.connect("menu_stack_emptied", game_master, "load_the_game")
