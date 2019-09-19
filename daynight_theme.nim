import times
import json
import os
import strformat
import strutils

type 
    Time = ref object
        hour: range[0..23]
        minute: range[0..59]
        second: range[0..60]
    Config = ref object
        day_theme: string
        day_shell_theme: string
        night_theme: string
        night_shell_theme: string
        day_unite_buttons: string
        night_unite_buttons: string
        day_icons: string
        night_icons: string
        edge_day_night: Time
        edge_night_day: Time


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

let EDGE_DAY_NIGHT = new_time(18, 0, 0)
let EDGE_NIGHT_DAY = new_time(6, 0, 0)

proc new_config(day_theme, night_theme: string): Config =
    result = new(Config)
    result.day_theme = day_theme
    result.night_theme = night_theme
    result.day_shell_theme = ""
    result.night_shell_theme = ""
    result.day_unite_buttons = ""
    result.night_unite_buttons = ""
    result.day_icons = ""
    result.night_icons = ""
    

proc read_config(): Config =
    let path = os.getEnv("HOME") & "/.config/daynight_theme.json"
    let config = json.parseFile(path)
    assert config.kind == JObject, path & " is not a javascript object"
    result = new_config(config["day_theme"].getStr,
                        config["night_theme"].getStr)
    if config.contains("day_shell_theme"):
        result.day_shell_theme = config["day_shell_theme"].getStr
    if config.contains("night_shell_theme"):
        result.night_shell_theme = config["night_shell_theme"].getStr    
    if config.contains("edge_day_night"):
        result.edge_day_night = config["edge_day_night"].getStr.to_time
    else:
        result.edge_day_night = EDGE_DAY_NIGHT
    if config.contains("edge_night_day"):
        result.edge_night_day = config["edge_night_day"].getStr.to_time
    else:
        result.edge_night_day = EDGE_NIGHT_DAY
    if config.contains("night_unite_buttons"):
        result.night_unite_buttons = config["night_unite_buttons"].getStr
    if config.contains("day_unite_buttons"):
        result.day_unite_buttons = config["day_unite_buttons"].getStr
    if config.contains("day_icons"):
        result.day_icons = config["day_icons"].getStr
    if config.contains("night_icons"):
        result.night_icons = config["night_icons"].getStr
    

proc cmd_set_icon_theme(theme: string): string =
    fmt"gsettings set org.gnome.desktop.interface icon-theme '{theme}'"    

proc cmd_set_shell_theme(theme: string): string =
    fmt"gsettings set org.gnome.shell.extensions.user-theme name '{theme}'"

proc cmd_set_theme(theme: string): string =
    fmt"gsettings set org.gnome.desktop.interface gtk-theme '{theme}'"

proc cmd_set_unite_theme(theme: string): string =
    fmt"""dconf write "/org/gnome/shell/extensions/unite/window-buttons-theme" "'{theme}'" """

proc set_night_theme(config: Config) =
    var _  = os.execShellCmd(cmd_set_theme(config.night_theme))
    if config.night_shell_theme.len > 0:
        var _ = os.execShellCmd(cmd_set_shell_theme(config.night_shell_theme))
    if config.night_unite_buttons.len > 0:
        var _ = os.execShellCmd(cmd_set_unite_theme(config.night_unite_buttons))
    if config.night_icons.len > 0:
        var _ = os.execShellCmd(cmd_set_icon_theme(config.night_icons))


proc set_day_theme(config: Config) = 
    var _  = os.execShellCmd(cmd_set_theme(config.day_theme))
    if config.day_shell_theme.len > 0:
        var _ = os.execShellCmd(cmd_set_shell_theme(config.day_shell_theme))
    if config.day_unite_buttons.len > 0:
        var _ = os.execShellCmd(cmd_set_unite_theme(config.day_unite_buttons))
    if config.day_icons.len > 0:
        var _ = os.execShellCmd(cmd_set_icon_theme(config.day_icons))
    

proc check_time() =
    let config = read_config()
    while true:
        let curr_time = now().getClockStr().to_time()
        if curr_time < config.edge_night_day:
            set_night_theme(config)
            sleep(1000 * (config.edge_night_day - curr_time))
        elif curr_time > config.edge_night_day and curr_time < config.edge_day_night:
            set_day_theme(config)
            sleep(1000 * (config.edge_day_night - curr_time))
        else:
            set_night_theme(config)
            sleep(1000 * (config.edge_night_day - curr_time))

check_time()
