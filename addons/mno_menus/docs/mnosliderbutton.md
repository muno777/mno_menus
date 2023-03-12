# MnoSliderButton

Extends: [MnoButton](mnobutton.md)

A special button for selecting a number from a range.

# Properties

`float low, high` The range of possible values.

`float on` The current selected value. Set in editor to change where the slider starts initially.

`float step` The amount that the value changes when a direction is pressed.

`bool uses option_a_b` Whether or not the player can use the inputs `In.UI_OPTION_A` and `In.UI_OPTION_B` to move the slider. This also causes button prompts to be rendered.

`Color button_color` The color for the button prompts, if the above option is enabled.