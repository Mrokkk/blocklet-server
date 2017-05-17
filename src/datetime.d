module datetime;

import std.format : format;
import std.process : executeShell;
import std.datetime : msecs, Clock;

import event : event;
import config : powerline_look, config;
import formatter : formatter, modifiers;

string datetime_handler(event ev, config c) {
    auto current_time = Clock.currTime();
    if (ev == event.right_click) {
        executeShell("notify-send \"`cal`\"");
    }
    if (powerline_look) {
        return "<span color=\"#00ccff\"></span><span background=\"#00ccff\"><span color=\"#0d0d0d\"><b>DATETIME</b></span></span> %s, %d %s %d, %02d:%02d:%02d".format(
            current_time.dayOfWeek, current_time.day, current_time.month,
            current_time.year, current_time.hour, current_time.minute,
            current_time.second);
    }
    else {
        auto f = new formatter(c.color("datetime"));
        if (c.show_label("datetime")) {
            f.add_label("DATETIME");
        }
        return f.add_value("%s, %d %s %d, %02d:%02d:%02d".format(
            current_time.dayOfWeek, current_time.day, current_time.month,
            current_time.year, current_time.hour, current_time.minute,
            current_time.second)).get;
    }
}
