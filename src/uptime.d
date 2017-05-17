module uptime;

import std.array : split;
import std.file : readText;
import std.format : format;
import std.conv : to, roundTo;

import event : event;
import formatter : formatter;
import config : powerline_look, config;

string uptime_handler(event ev, config c) {
    if (ev == event.right_click) {
        return "It works!";
    }
    auto uptime = "/proc/uptime".readText().split()[0].to!float().roundTo!int();
    auto hours = uptime / 3600;
    auto minutes = (uptime % 3600) / 60;
    if (powerline_look) {
        return " <span color=\"#cf6a4c\"></span><span background=\"#cf6a4c\"><span color=\"#0d0d0d\"><b>UPTIME</b></span></span> <span color=\"#cf6a4c\">%02dh%02d</span> ".format(hours, minutes);
    }
    else {
        auto f = new formatter(c.color("uptime"));
        if (c.show_label("uptime")) {
            f.add_label("UPTIME");
        }
        return f.add_value("%02dh%02d".format(hours, minutes)).get();
    }
}
