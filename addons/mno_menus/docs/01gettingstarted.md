# Getting Started

This guide will help you get on your feet with the plugin and create your first menu!

# Adding MnoMaster

In your game's main scene, create a [MnoMaster](mnomaster.md) as a child of the root node.

# Your First Menu

Create a new scene with a [MnoMenu](mnomenu.md) as the root node. Add a [MnoSelectableGroup](mnoselectablegroup.md) as a child, then add some [MnoSelectable](mnoselectable.md)s (or things that extend it, such as [MnoButton](mnobutton.md)s) as children of that group. You've created a menu! Go ahead and save the scene.

To try it out, set the MnoMaster's `starting_menu` to the menu scene you just saved, then run the game to enjoy the menuing goodness.

# Your Second Menu

Create a new menu the same way as you did before. Save it as its own scene.

Now, go into your first menu and create a new MnoButton (or use an existing one). Set its `click_action` to Push Menu, and its `pushed_menu` to the second menu scene you just saved.

Run the game, and you should find that clicking that button causes the second menu to be opened! Then you can press back to go back to the first menu.

# Your First Custom Theme

You can create custom graphics, animations, and sound effects for your menu objects.

To do this, first create a [MnoSelectableTheme](mnoselectabletheme.md) resource in your game's files.

Then, open `config.gd`. Add an entry to the `SelectableThemes` enum. You can uncomment the `MY_COOL_THEME` line and then rename it as an easy example. Then, add a section to the `get_selectable_theme()` function. Again, you can uncomment the `MY_COOL_THEME` example, but make sure to replace the path inside `preload()` to match the resource file you saved earlier. Also, if you changed `MY_COOL_THEME` to a different name earlier, do it here too.

Restart Godot. Then, your new theme will appear as an option in the dropdown when editing the `theme` property of a MnoSelectable!

Follow similar steps to create custom cursor themes and fonts. Also, poke around the rest of `config.gd` to edit some global parameters and the default controller map.

# What's Next

Poke around the example project to learn other things like tabs, scrolling menus, getting controller inputs, and more! You can do it!