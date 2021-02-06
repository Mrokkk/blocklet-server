module battery;

import std.conv : to;
import std.string: strip;
import std.format : format;
import std.algorithm : map;
import std.file : readText, dirEntries, SpanMode;

import formatter : block_layout;
import blocklet : blocklet, event;

class battery : blocklet {

    void call(block_layout f) {
        f.add_value("%(%d%| %)".format(dirEntries(
            "/sys/class/power_supply/", "BAT{0,1}", SpanMode.depth, false)
                .map!(a => (a.name ~ "/capacity").readText().strip().to!int)));
    }

    void handle_event(event) {
    }

}
