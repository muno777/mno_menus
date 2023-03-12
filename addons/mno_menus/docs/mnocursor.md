# MnoCursor

Extends: [Mno2D](mno2d.md)

The invisible cursor object that moves around a [MnoMenu](mnomenu.md), jumping between [MnoSelectable](mnoselectable.md)s.

The cursor graphics are handled by [MnoCursorRenderer](mnocursorrenderer.md).

# Properties

`MnoSelectable hovered_selectable` The [MnoSelectable](mnoselectable.md) the cursor is looking at.

`int input_slot` The cursor's device slot (see [MnoInput](mnoinput.md)).

`bool active` Whether or not the cursor is currently active. An inactive cursor becomes active when a button or direction is pressed.

# Methods

`Array get_cursors_on_same_selectable()` Returns a list of cursors which are looking at the same [MnoSelectable](mnoselectable.md) as this one.

`void become_active(int _dummy_arg = 0)` Activates the cursor. The dummy arg is there for signal purposes.