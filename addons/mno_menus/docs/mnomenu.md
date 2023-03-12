# MnoMenu

Extends: [Mno2D](mno2d.md)

The root node of a menu scene pushed to MnoMaster's menu stack. To make a menu, make a scene out of this and add MnoSelectableGroups as children.

# Properties

`int num_cursors` The number of [MnoCursor](mnocursor.md)s that the menu should create and use at runtime. Should usually be 1, but set to a higher number to allow multiple players to navigate the menu separately. To make the cursors appear, add a [MnoCursorRenderer](mnocursorrenderer.md) for each cursor, as a child of the menu.

`bool input_passthrough` Whether or not input data should propagate past this menu. Set to true if, when a player presses a button in this menu, it should take effect in a prior menu or in the game itself (e.g. character can jump while this menu is open).

`bool draw_center_helper` Whether or not to draw some lines in the editor as a placement guide.

`int transition_type` The animation used when this menu is opened or closed.

`bool has_selectables` Whether or not the menu has any [MnoSelectable](mnoselectable.md)s that can be clicked. Controls whether or not the button prompt for this is drawn.

`bool back_button` Whether or not you can press the back button to pop this menu.  Controls whether or not the button prompt for this is drawn.