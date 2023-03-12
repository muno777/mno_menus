# MnoCycleButton

Extends: [MnoButton](mnobutton.md)

A special MnoButton for selecting from a list of preset options.

# Properties

`bool uses_option_a_b` Whether or not the player can use the inputs `In.UI_OPTION_A` and `In.UI_OPTION_B` to scroll through the list. This also causes button prompts to be rendered.

`Color button_color` The color for the button prompts, if the above option is enabled.

`Array[String] options` The list of options.

`int on` The index of the current value.