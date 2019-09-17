#### Requirements

To compile this piece of code you have to install nim compiler; you can install following this [link](https://nim-lang.org/install_unix.html)

## What is

Simple utility to change the gnome shell theme and gtk theme based on current time
In order to use the utility you should define a file called __daynight_theme.json__ in __~/.config__ with the following fields:
- _day_theme_
- [_day_shell_theme_]
- _night_theme_
- [_night_shell_theme_]

Every field is a string and contains the name of the respective theme to apply at the right time of the day

Additionally there are two optional parameters:
- _edge_day_night_
- _edge_night_day_

These two parameters must be in the format "HH:MM:SS" and represent respectively the time edge between day/night and vice-versa. In the script are setted by default at _"18:00:00"_ and _"06:00:00"_

##### Unite extension parameters

If you use Unite extension on Gnome you can set other two optional parameters:

- _unite_window_buttons_day_
- _unite_window_buttons_night_

This two parameters change the windows button theme of Unite extension

### Example

A base _daynight_theme.json_ is:

`{"day_theme": "Adwaita", "night_theme": "Adwaita-dark"}`

My personal config is: 

` {"day_theme": "ZorinGreen-Light", "night_theme": "ZorinBlue-Dark", "day_shell_theme": "Canta-light-compact", "night_shell_theme": "Flat-Remix-Dark-fullPanel", "unite_window_buttons_night": "materia-dark", "unite_window_buttons_day": "materia-light"}`