module datetime;

import std.format : format;
import std.datetime : msecs, Clock;

import formatter;
import config : PORT, TEMPLATE, powerline_look;

string datetime_handler() {
    auto current_time = Clock.currTime();
    if (powerline_look) {
        return "<span color=\"#00ccff\"></span><span background=\"#00ccff\"><span color=\"#0d0d0d\"><b>DATETIME</b></span></span> %s, %d %s %d, %02d:%02d:%02d".format(
            current_time.dayOfWeek, current_time.day, current_time.month,
            current_time.year, current_time.hour, current_time.minute,
            current_time.second);
    }
    else {
        auto f = new formatter("#00ccff");
        return f.add_label("DATETIME").add_value("%s, %d %s %d, %02d:%02d:%02d".format(
            current_time.dayOfWeek, current_time.day, current_time.month,
            current_time.year, current_time.hour, current_time.minute,
            current_time.second)).get();
    }
}
