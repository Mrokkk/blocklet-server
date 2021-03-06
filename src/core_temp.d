module core_temp;

import std.conv : to;
import std.string: strip;
import std.format : format;
import std.algorithm : map;
import std.file : readText, dirEntries, SpanMode;

import formatter : block_layout;
import blocklet : blocklet, event;

class core_temp : blocklet {

    void call(block_layout f) {
        f.add_value("%(%d\xc2\xb0C%| %)".format(
            dirEntries("/sys/devices/platform/coretemp.0/hwmon/",
            "temp{2,3,4,5,6,7,8,9}_input", SpanMode.depth, false)
                .map!(a => a.name.readText().strip().to!int / 1000)));
    }

    void handle_event(event) {
    }

}
