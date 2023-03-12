# MnoCursorTheme

Extends: Resource

A resource that defines a visual theme for a [MnoCursorRenderer](mnocursorrenderer.md).

# Properties

`Vector2 margin` The distance for each corner from the edge of the [MnoSelectable](mnoselectable.md) the cursor is looking at. Bigger number = tighter cursor.

`Vector2 offset_scale` The amount to multiply each corner's distance from the center by. Bigger number = looser cursor.

`Vector2 overload_offset` The amount that each corner gets shifted if more than one [MnoCursor](mnocursor.md) is looking at the same selectable. This gets added to `margin`, with the effect multiplied by a greater amount depending on the number of cursors that got to that selectable first. Each subsequent cursor is offset more and more.

`bool show_when_mouse_free` Whether or not to still render the sprites when a mouse is being used and the mouse is not hovering over anything.

## Per State

`Texture sprite_(DIRECTION)` The texture used for each corner of the cursor.

`int frames` The number of hframes in the sprites.

`int frame_duration` How long each frame should last during the animation.

`Vector2 extra_margin` The value added to `margin` during this state.

`Vector2 offset_scale` The value `offset_scale` is multiplied by during this state.