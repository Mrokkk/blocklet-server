module uptime;

import std.array : split;
import std.file : readText;
import std.format : format;
import std.conv : to, roundTo;

import event : event;
import formatter : formatter;
import config : PORT, TEMPLATE, powerline_look;

string uptime_handler(event ev) {
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
        auto f = new formatter("#2d8659");
        return f.add_label("UPTIME").add_value("%02dh%02d".format(hours, minutes)).get();
    }
}
