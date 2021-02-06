module datetime;

import std.format : format;
import std.process : executeShell;
import std.datetime : msecs, Clock;

import formatter : block_layout;
import blocklet : blocklet, event;

class datetime : blocklet {

    void call(block_layout f) {
        auto current_time = Clock.currTime();
        f.add_value("%s, %d %s %d, %02d:%02d:%02d".format(
            current_time.dayOfWeek, current_time.day, current_time.month,
            current_time.year, current_time.hour, current_time.minute,
            current_time.second));
    }

    void handle_event(event ev) {
        switch (ev) {
            case event.right_click: {
                executeShell("gsimplecal");
                break;
            }
            default: break;
        }
    }

}
