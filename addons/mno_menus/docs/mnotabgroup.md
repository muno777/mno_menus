# MnoTabGroup

Extends: [MnoSelectableGroup](mnoselectablegroup.md)

A special MnoSelectableGroup designer for use with [MnoTab](mnotab.md) to make a tab list of pages.

# Properties

`bool accepts_page_inputs` Whether or not the player can use In.UI_PAGE_L and In.UI_PAGE_R to scroll the tabs.

# Methods

`void change_tab(int tab_dir)` Changes the tab either left or right. Set `tab_dir` to -1 for left, 1 for right.