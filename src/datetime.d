module datetime;

import std.format : format;
import std.process : executeShell;
import std.datetime : msecs, Clock;

import event : event;
import config : config;
import blocklet : blocklet;
import formatter : formatter, modifiers;

class datetime : blocklet {

    private config config_;

    this(config c) {
        config_ = c;
    }

    void call(formatter f) {
        auto current_time = Clock.currTime();
        f.add_value("%s, %d %s %d, %02d:%02d:%02d".format(
            current_time.dayOfWeek, current_time.day, current_time.month,
            current_time.year, current_time.hour, current_time.minute,
            current_time.second));
    }

    void handle_event(event ev) {
        if (ev == event.right_click) {
            executeShell("notify-send \"`cal`\"");
        }
    }

}
