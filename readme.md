Simple utility to change the gnome shell theme and gtk theme based on current time
In order to use the utility you should define a file called __dynamic_theme.json__ in __~/.config__ with the following fields:
- __day_theme__
- __day_shell_theme__
- __night_theme__
- __night_shell_theme__

Every field is a string and contains the name of the respective theme to apply at the right time of the day

Additionally there are two optional parameters:
- __edge_day_night__
- __edge_night_day__

These two parameters must be in the format "HH:MM:SS" and represent respectively the time edge between day/night and vice-versa. In the script are setted by default at _"18:00:00"_ and _"06:00:00"_