# A special MnoSelectableGroup designer for use with MnoTab to make a tab list of pages.
extends MnoSelectableGroup
class_name MnoTabGroup, "res://addons/mno_menus/icons/mno_tab_group.png"
tool


# The currently selected tab.
var current_tab: MnoSelectable = null
# Whether or not the player can use In.UI_PAGE_L and In.UI_PAGE_R to scroll the tabs.
export var accepts_page_inputs: bool = true


func _ready() -> void:
	if Engine.editor_hint:
		return
	if initial_selectable != "":
		current_tab = get_node_or_null(initial_selectable)
		return
	for s in selectables:
		if current_tab == null || s.get_menu_position().x < current_tab.get_menu_position().x:
			current_tab = s


# Calls the tick() func from MnoSelectableGroup, but for the "hovered_selectables" arg, it passes in
# an array containing the current_tab so that that tab gets hovered.
func tick(hovered_selectables: Array = []) -> void:
	var hovered_tabs: Array = []
	for s in hovered_selectables:
		if s in selectables:
			hovered_tabs.push_back(s)
	if hovered_tabs != []:
		current_tab = hovered_tabs[0]
	.tick([current_tab] if current_tab != null else [])


# Detects page L/R inputs to switch tabs.
func process_inputs() -> void:
	.process_inputs()
	
	if !accepts_page_inputs:
		return
	
	var tab_dir: int = (int(in_pressed(MnoInput.DEVICE_ALL, In.UI_PAGE_R, false, true, true)) -
			int(in_pressed(MnoInput.DEVICE_ALL, In.UI_PAGE_L, false, true, true)))
	
	change_tab(tab_dir)


# Changes the tab either left or right (-1 left, 1 right).
func change_tab(tab_dir: int) -> void:
	if tab_dir == 0:
		return
	
	var new_tab: MnoSelectable = MnoMenu.get_neighbor_of(current_tab, selectables, false, tab_dir == -1, true)
	
	if current_tab != new_tab:
		current_tab = new_tab
		MnoMenu.select_cosmetics(mno_master, new_tab, In.UI_LEFT if tab_dir == -1 else In.UI_RIGHT)
