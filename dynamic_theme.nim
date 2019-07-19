import times
import json
import os
import strformat
import strutils

type 
    Config = ref object
        day_theme: string
        day_shell_theme: string
        night_theme: string
        night_shell_theme: string
    Time = ref object
        hour: range[0..23]
        minute: range[0..59]
        second: range[0..60]

proc to_time(clock: string): Time =
    result = new(Time)
    result.hour = clock[0..1].parseInt()
    result.minute = clock[3..4].parseInt()
    result.second = clock[6..7].parseInt()

proc new_time(hour, minute, second: int): Time =
    result = new(Time)
    result.hour = hour
    result.minute = minute
    result.second = second

proc `>`(a,b: Time): bool =
    if a.hour > b.hour:
        true
    elif a.hour < b.hour:
        false
    else:
        if a.minute > b.minute:
            true
        elif a.minute < b.minute:
            false
        else:
            if a.second > b.second:
                true
            elif a.second < b.second:
                false
            else:
                false

proc `==`(a,b: Time): bool =
    a.hour == b.hour and a.minute == b.minute and a.second == b.second

proc `<`(a,b: Time): bool =
    not(a > b) and not(a == b)

proc `>=`(a,b: Time): bool =
    not(a < b)

proc `<=`(a,b: Time): bool =
    not(a > b)

proc `-`(a,b: Time): int =
    result = (a.hour - b.hour) * 60 * 60 + (a.minute - b.minute) * 60 + (a.second - b.second)
    if result < 0:
        result = 24 * 60 * 60 - result

var EDGE_DAY_NIGHT = new_time(18, 0, 0)
var EDGE_NIGHT_DAY = new_time(6, 0, 0)

proc new_config(day_theme, day_shell_theme, night_theme, night_shell_theme: string): Config =
    result = new(Config)
    result.day_theme = day_theme
    result.day_shell_theme = day_shell_theme
    result.night_theme = night_theme
    result.night_shell_theme = night_shell_theme

proc read_config(): Config =
    let path = os.getEnv("HOME") & "/.config/dynamic_theme.json"
    let config = json.parseFile(path)
    assert config.kind == JObject, path & " is not a javascript object"
    result = new_config(config["day_theme"].getStr,
                        config["day_shell_theme"].getStr,
                        config["night_theme"].getStr,
                        config["night_shell_theme"].getStr)
    if config.contains("edge_day_night"):
        EDGE_DAY_NIGHT = config["edge_day_night"].getStr.to_time
    if config.contains("edge_night_day"):
        EDGE_NIGHT_DAY = config["edge_night_day"].getStr.to_time
    

proc cmd_set_shell_theme(theme: string): string =
    fmt"gsettings set org.gnome.shell.extensions.user-theme name '{theme}'"

proc cmd_set_theme(theme: string): string =
    fmt"gsettings set org.gnome.desktop.interface gtk-theme '{theme}'"

proc set_night_theme(config: Config) =
    var _  = os.execShellCmd(cmd_set_theme(config.night_theme))
    var _ = os.execShellCmd(cmd_set_shell_theme(config.night_shell_theme))

proc set_day_theme(config: Config) = 
    var _  = os.execShellCmd(cmd_set_theme(config.day_theme))
    var _ = os.execShellCmd(cmd_set_shell_theme(config.day_shell_theme))

proc check_time() =
    let config = read_config()
    while true:
        let curr_time = now().getClockStr().to_time()
        if curr_time < EDGE_NIGHT_DAY:
            set_night_theme(config)
            sleep(1000 * (EDGE_NIGHT_DAY - curr_time))
        elif curr_time > EDGE_NIGHT_DAY and curr_time < EDGE_DAY_NIGHT:
            set_day_theme(config)
            sleep(1000 * (EDGE_DAY_NIGHT - curr_time))
        else:
            set_night_theme(config)
            sleep(1000 * (EDGE_NIGHT_DAY - curr_time))

check_time()
