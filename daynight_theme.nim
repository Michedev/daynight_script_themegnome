import time
import json
import os
import strformat
import strutils
from times import now, getClockStr



type 
    Command = ref object
        day_value: string
        night_value: string
        set_cmd: (proc(value: string): void)
    Config = ref object
        commands: seq[Command]
        edge_day_night: Time
        edge_night_day: Time

let EDGE_DAY_NIGHT = new_time(18, 0, 0)
let EDGE_NIGHT_DAY = new_time(6, 0, 0)

func new_command(day, night: string, cmd: (proc(value: string): void)): Command =
    result = new(Command)
    result.day_value = day
    result.night_value = night
    result.set_cmd = cmd


proc cmd_set_icon_theme(theme: string): string =
    fmt"gsettings set org.gnome.desktop.interface icon-theme '{theme}'"    

proc cmd_set_shell_theme(theme: string): string =
    fmt"gsettings set org.gnome.shell.extensions.user-theme name '{theme}'"

proc cmd_set_theme(theme: string): string =
    fmt"gsettings set org.gnome.desktop.interface gtk-theme '{theme}'"

proc cmd_set_unite_theme(theme: string): string =
    fmt"""dconf write "/org/gnome/shell/extensions/unite/window-buttons-theme" "'{theme}'" """

proc run_set_icon_theme(theme: string) =
    let _ = os.execShellCmd(cmd_set_icon_theme(theme))    

proc run_set_shell_theme(theme: string) =
    let _ = os.execShellCmd(cmd_set_shell_theme(theme))    

proc run_set_theme(theme: string) =
    let _ = os.execShellCmd(cmd_set_theme(theme))    

proc run_set_unite_theme(theme: string) =
    let _ = os.execShellCmd(cmd_set_unite_theme(theme))    
 

proc new_config(day_theme, night_theme: string): Config =
    result = new(Config)
    result.commands.add new_command(day_theme, night_theme, run_set_theme)

proc read_config(): Config =
    let path = os.getEnv("HOME") & "/.config/daynight_theme.json"
    let config = json.parseFile(path)
    assert config.kind == JObject, path & " is not a javascript object"
    result = new_config(config["day_theme"].getStr,
                        config["night_theme"].getStr)
    if config.contains("day_shell_theme") and config.contains("night_shell_theme"):
        result.commands.add new_command(config["day_shell_theme"].getStr,
                                         config["night_shell_theme"].getStr,
                                         run_set_shell_theme)
    if config.contains("night_unite_buttons") and config.contains("day_unite_buttons"):
        result.commands.add new_command(config["night_unite_buttons"].getStr,
                                           config["day_unite_buttons"].getStr,
                                           run_set_unite_theme)
    if config.contains("day_icons") and config.contains("night_icons"):
        result.commands.add new_command(config["day_icons"].getStr,
                                   config["night_icons"].getStr,
                                   run_set_icon_theme)
    if config.contains("edge_day_night"):
        result.edge_day_night = config["edge_day_night"].getStr.to_time
    else:
        result.edge_day_night = EDGE_DAY_NIGHT
    if config.contains("edge_night_day"):
        result.edge_night_day = config["edge_night_day"].getStr.to_time
    else:
        result.edge_night_day = EDGE_NIGHT_DAY
    
proc set_night_theme(config: Config) =
    for command in config.commands:
        command.set_cmd(command.night_value)


proc set_day_theme(config: Config) = 
    for command in config.commands:
        command.set_cmd(command.day_value)
    

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
