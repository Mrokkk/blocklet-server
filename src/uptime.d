module uptime;

import std.array : split;
import std.file : readText;
import std.format : format;
import std.conv : to, roundTo;

import formatter : formatter;
import blocklet : blocklet, event;

class uptime : blocklet {

    void call(formatter f) {
        auto uptime = "/proc/uptime".readText().split()[0].to!float().roundTo!int();
        auto hours = uptime / 3600;
        auto minutes = (uptime % 3600) / 60;
        f.add_value("%02dh%02d".format(hours, minutes));
    }

    void handle_event(event) {
    }

}
