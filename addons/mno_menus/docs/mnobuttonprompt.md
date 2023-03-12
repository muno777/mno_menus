# MnoButtonPrompt

Extends: [MnoTextRenderer](mnotextrenderer.md)

A button prompt that displays onscreen.

Note: The button prompts at the bottom of the screen during menus are not handled by this class. They're drawn directly by [MnoMaster](mnomaster.md).

# Properties

`int input` The input to be displayed.

`bool respond_to_press` Whether or not to play the animation when the button is pressed.

`bool inherit_offset` If this node is the child of a Sprite (or Sprite-extending node), this variable determines whether or not the button prompt will inherit the parent's `offset`.

`bool enabled` Whether or not the prompt is enabled. If disabled, it will have a different appearance.

`Color button_color` The color of the button shape.

`Color text_color` The color of the text.

`Color disabled_color` The color of the text, when disabled.

`MnoSelectableTheme.HAlign h_align` The horizontal alignment of the button prompt.