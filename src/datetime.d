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
    immutable private string name_ = "datetime";

    this(config c) {
        config_ = c;
    }

    string name() {
        return name_;
    }

    string call(event ev) {
        auto current_time = Clock.currTime();
        if (ev == event.right_click) {
            executeShell("notify-send \"`cal`\"");
        }
        auto f = new formatter(config_.color("datetime"));
        if (config_.show_label("datetime")) {
            f.add_label("DATETIME");
        }
        return f.add_value("%s, %d %s %d, %02d:%02d:%02d".format(
            current_time.dayOfWeek, current_time.day, current_time.month,
            current_time.year, current_time.hour, current_time.minute,
            current_time.second)).get;
    }

}
