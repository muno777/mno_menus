# MnoButton

Extends: [MnoSelectable](mnoselectable.md)

A selectable that can be clicked by the cursor.

# Properties

`int click_action` The action to be performed when the button is clicked.

- None
- Push Menu: Push a menu to the stack, determined by `pushed_menu`.
- Pop Menu: Pop the current menu from the stack, or pop to a menu determined by `popped_menu`.
- Pop All Menus: Pop all menus from the stack, leaving no menus open.
- Move Cursor: Move the cursor to another selectable, determined by `cursor_target`.
- Quit Game: Exit the game.

`PackedScene pushed_menu, popped_to_menu; NodePath cursor_target` Used when `click_action` is set to certain values.

# Methods

`void click()` Causes the button to be clicked, including any behaviors and animations.

# Signals

`clicked(cursor)` Emitted when the button is clicked. The argument is the [MnoCursor](mnocursor.md) used to click the button.