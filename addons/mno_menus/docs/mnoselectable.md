# MnoSelectable

Extends: [MnoTextRenderer](mnotextrenderer.md)

A selectable object in a game menu - basically a button, but doesn't implement clicking. Should be a child of a [MnoSelectableGroup](mnoselectablegroup.md).

# Properties

`int theme` The index of the selectable's theme.

`bool enabled` Whether or not it's enabled. If false, it'll always be in the disabled state.

`NodePath neighbor_(DIRECTION)` The selectable's neighbor in a given direction. Set these to override what happens when this selectable is highlighted and the player presses in a direction. By default it judges based on relative position.