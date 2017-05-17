module uptime;

import std.array : split;
import std.file : readText;
import std.format : format;
import std.conv : to, roundTo;

import event : event;
import config : config;
import formatter : formatter;

string uptime_handler(event ev, config c) {
    auto uptime = "/proc/uptime".readText().split()[0].to!float().roundTo!int();
    auto hours = uptime / 3600;
    auto minutes = (uptime % 3600) / 60;
    auto f = new formatter(c.color("uptime"));
    if (c.show_label("uptime")) {
        f.add_label("UPTIME");
    }
    return f.add_value("%02dh%02d".format(hours, minutes)).get();
}
