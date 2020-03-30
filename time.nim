import strutils

type Time* = ref object
    hour: range[0..23]
    minute: range[0..59]
    second: range[0..60]


proc to_time*(clock: string): Time =
    result = new(Time)
    result.hour = clock[0..1].parseInt()
    result.minute = clock[3..4].parseInt()
    result.second = clock[6..7].parseInt()

proc new_time*(hour, minute, second: int): Time =
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

proc `==`*(a,b: Time): bool =
    a.hour == b.hour and a.minute == b.minute and a.second == b.second

proc `<`*(a,b: Time): bool =
    not(a > b) and not(a == b)

proc `>=`*(a,b: Time): bool =
    not(a < b)

proc `<=`*(a,b: Time): bool =
    not(a > b)

proc `-`*(a,b: Time): int =
    result = (a.hour - b.hour) * 60 * 60 + (a.minute - b.minute) * 60 + (a.second - b.second)
    if result < 0:
        result = 24 * 60 * 60 - result