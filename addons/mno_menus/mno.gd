tool
extends EditorPlugin
class_name Mno


func _enter_tree():
	pass


func _exit_tree():
	pass


static func get_mno_master(obj: Node) -> MnoMaster:
	if obj == null:
		return null
	if Engine.editor_hint || obj.get_tree().get_nodes_in_group("mno_master") == []:
		return null
	return obj.get_tree().get_nodes_in_group("mno_master")[0]
