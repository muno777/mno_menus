# MnoCursorRenderer

Extends: [Mno2D](mno2d.md)

The object responsible for drawing a MnoCursor's associated sprite/etc, and calculating its onscreen position.

# Properties

`int cursor_num` The index of the [MnoCursor](mnocursor.md), in [MnoMenu](mnomenu.md).cursors, this renderer is associated with.

`int theme` The index of the [MnoCursorTheme](mnocursortheme.md) used by this renderer.

`bool mouse_support` Whether or not this cursor should respond to mouse input.