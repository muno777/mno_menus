# MnoSelectableGroup

Extends: [Mno2D](mno2d.md)

A container for a set of [MnoSelectable](mnoselectable.md)s. Many menus can get by with just one, but for certain behaviors you can use multiple to split up your menu and control things more precisely.

# Properties

`bool allows_wrapping` Whether or not the cursor can wrap from one edge to another. For example, if this is true, then a cursor at the leftmost button can press left to arrive at the rightmost button.

`NodePath initial_selectable` The selectable that the cursor defaults to, for example when the menu is first opened. If left null, it just chooses the first one in the list.

`Array[NodePath] allowed_outside_groups` List of other selectable groups that the cursor can jump to from within this one. If blank, it can jump to any group. If not blank, it's a whitelist: cursors can only jump to groups in the list. To make it so that no groups can be jumped to from within this one, set this property to an array containing only the group itself.

`bool can_be_selected` Whether or not a cursor can come into this group from outside.

`NodePath hover_visible_selectable` A selectable which this group looks to for the hover-visible feature. If you set it to a selectable, this group will be visible when the selectable is hovered, and will disappear if the selectable is not hovered.

`bool hover_visible_fade` Whether or not to use a fade effect for the feature explained above.

`int scrolling_type` The direction, if any, by which the group can scroll.

`Vector2 scroll_area` The area it scrolls within. If a coordinate is negative, then that coordinate is treated as infinite.

`int scroll_margin` The margin from the area edge used by scrolling. How scrolling works is that, if the hovered button is within (`scroll_margin`) pixels of the viewport's edge, the group's position will move to bring the hovered button back onscreen.

`int scroll_snap` The snap amount for scrolling. Makes the scroll position snap to a tile, for example.

`bool draw_scroll_guide` In the editor, whether or not to draw a scroll rectangle guide.

`Array[NodePath] scroll_reset_objs` A list of MnoSelectables that, when hovered, will reset the scrolling to the original position. This overrides the normal scroll logic.

# Methods

`bool is_hidden()` Returns whether or not the group is currently hidden, based on `hover_visible_selectable`. Doesn't consider any other factors.