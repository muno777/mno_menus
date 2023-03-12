# MnoSelectableTheme

Extends: Resource

A resource that defines a visual theme for a [MnoSelectable](mnoselectable.md).

# Properties

`int width, height` The dimensions of the selectable in pixels. Should be set accurately, since it's used for things like neighbor checking and displaying the cursor.

`int label_h_align, label_v_align` The alignment of text.

`bool selectable_when_disabled` Whether or not the selectable can be hovered while it's in the disabled state.

## Per State

`Texture sprite` The texture displayed during this state.

`int frames` The amount of hframes.

`int frame_duration` How long each frame should last during the animation.

`int extra_width, extra_height` How much is added to `width` and `height` during this state.

`int label_font` The index of the label font.

`Color label_color` The color of the label text.

`bool label_outline` Whether or not to draw a text outline.

`Color outline_color` The color of the outline.

`bool drop_shadow` Whether or not to draw a text drop shadow.

`Vector2 anim_offset` The visual offset to the selectable's position during this state.

`int rotation_degrees` The rotation to the selectable during this state.

## Only Specific States

`int transition_frames` How many of the texture's hframes are devoted to the transition to and from this state.

`int animation_type` The type of animation used for this state.

`AudioStream sound_effect` The sound played for this state.