# The boiler-plate class that tells Godot about the plugin.
tool
#extends EditorPlugin
class_name Mno


func _enter_tree():
	pass


func _exit_tree():
	pass


# Easy access to the active MnoMaster from any script!
static func get_mno_master(obj: Node):
	if obj == null:
		return null
	if Engine.editor_hint || obj.get_tree().get_nodes_in_group("mno_master") == []:
		return null
	return obj.get_tree().get_nodes_in_group("mno_master")[0]
