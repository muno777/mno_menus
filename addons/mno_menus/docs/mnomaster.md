# MnoMaster

Extends: [Mno2D](mno2d.md)

The man himself. The boss. The big kahuna. The object that watches over all of the plugin's operations. Slap an instance of this into your game's main scene to use this plugin.

# Properties

`PackedScene starting_menu` The [MnoMenu](mnomenu.md) loaded when starting the game.

`bool draw_button_prompts` Whether or not to draw button prompts at the bottom of the screen during menus.

`AudioStream back_sound` The sound played when pressing `In.UI_CANCEL` to go back from a menu.

`bool auto_tick` Whether or not the tick function should be automatically called in `_physics_process()`. Keeping it set to false is recommended if you want to avoid weird order-of-occurrence errors; just call `tick()` on this object. Set to true if you don't care.

`int exist_timer` How long the object has existed.

`Array menu_stack` The stack of menus currently open.

`Array other_menus` A list of other menus, which are not in the stack but still need to be managed. They will be ticked immediately after the menus in `menu_stack` are ticked. This could be useful if you need a menu in another part of your game separate from the stack.

`Array controllers` The list of [MnoInput](mnoinput.md)s.

`MnoInput latest_used_controller` The latest input device to have an input pressed.

`bool switch_procon_input_name_mode` Set this to true, and input names in the plugin will reflect a switch controller's layout instead of xbox.

# Methods

`String get_input_name(int input)` Returns the name of a physical button or key.

`int get_num_menus()` Returns the number of menus in the stack.

`void start_fade()` Begins the fade animation.

`Node2D get_current_menu()` Returns the top menu in the stack.

`void push_menu(new_menu, bool add_child = true)` Pushes `new_menu` to the stack, and adds it as a child if `add_child` is true. This is how you "open" a menu in the game.

`void push_menu_array(Array new_menus)` Pushes lots of menus in a row.

`void pop_menu(menu_target = menu_stack.back(), bool keep_target = false)` With no arguments, pops the top menu from the stack, like hitting the back button to go back to the previous menu. If you specify a `menu_target`, you can pop menus until you reach that target. If `keep_target` is true, if will NOT pop `menu_target` itself.

`void pop_all_menus()` Pops all menus from the stack.

`void add_menu_not_to_stack(new_menu)` Adds `new_menu` to `other_menus`.

`void remove_menu_not_from_stack(menu_to_remove)` Removes `menu_to_remove` from `other_menus`. Call this before freeing the menu.

## Input Check Methods

These are the methods that should be used for raw input checks in your game. Shared arguments:
- `controller_num` is the index in the `controllers` array for the [MnoInput](mnoinput.md) you're checking.
  - Set to `MnoInput.DEVICE_ALL` to check if ANY of the controllers have it.
- If `before_propagation` is true, it'll ignore any prior calls to `in_eat()` and get the "raw" input. Set this to true and you'll get the button inputs before they got "eaten" by menu actions and the like. This should usually be false.
- If `clear` is true, it'll call `in_clear(input_num)` also.
- If `eat` is true, it'll call `in_eat(input_num)` also.
- If `check_correlated` is true, it will run the function for any correlated inputs too; see `MnoConfig` for what "correlated inputs" are.

`bool in_pressed(int controller_num, int input_num, bool before_propagation = false, bool clear = false, bool eat = false)` Checks whether or not the button has just been pressed. The window of time for this to be true depends on the configured buffer.

`int in_buffer_amt(int controller_num, int input_num, bool before_propagation = false, bool clear = false, bool eat = false)` Similar to `in_pressed()`, but returns a number depending on how long ago the button was pressed. Returns 0 if the buffer has expired.

`bool in_held(int controller_num, int input_num, bool before_propagation = false)` Returns whether or not the button is currently being held down.

`void in_clear(int controller_num, int input_num, bool check_correlated = true)` Clears the remaining buffer time for an input, preventing its press from taking effect on subsequent frames (but not the current frame). Use this if the input buffer is causing multiple actions to occur from a single button press.

`void in_eat(int controller_num, int input_num, bool check_correlated = true)` Clears the input, both the press and the hold, in the current propagated inputs, preventing it from taking effect on this frame (but not subsequent frames). Use this if a menu needs to prevent an input from reaching other parts of the game, such as if "confirm" and "jump" share a button.

# Signals

`fade_midpoint` Emitted when the fade animation has finished fading to black and is about to fade back in.

`slide_finished` Emitted when the menu sliding animation completes.

`menu_stack_emptied` Emitted when the last menu is popped from the stack.