# MnoSliderButtonTheme

Extends: [MnoSelectableTheme](mnoselectabletheme.md)

A specialized MnoSelectableTheme for [MnoSliderButton](mnosliderbutton.md)s.

# Properties

`int value_font` The index of the font used for the number.

`int value_font_selected` The index of the font used for the number in edit mode.

`int label_y_offset` The extra height added to the main label's position.

`int bar_y_offset` The extra height added to the bar's position.

`int bar_height, bar_width` The size of the bar.

`Color empty_color, full_color` The color used for the empty and full portions of the bar.

`int value_y_offset` The extra height added to the number's position.

`int value_y_offset_selected` The extra height added to the number's position in edit mode.

`Texture arrow_sprite` The sprite used for the arrows during edit mode. The texture is for the right arrow, and it's flipped for the left arrow.

`AudioStream tick_sound` The sound that plays when the value is changed.

`AudioStream cancel_sound` The sound that plays when edit mode is canceled;