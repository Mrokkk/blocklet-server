module core_temp;

import std.conv : to;
import std.string: strip;
import std.format : format;
import std.algorithm : map, filter;
import std.file : readText, dirEntries, SpanMode;

import formatter : block_layout;
import blocklet : blocklet, event;

class core_temp : blocklet {

    void call(block_layout f) {
        f.add_value("%(%d%| %)".format(
            dirEntries("/sys/class/thermal/",
            "thermal_zone{0,1,2,3,4,5,6,7,8,9,10,11,12}", SpanMode.depth, false)
                .filter!(a => (a.name ~ "/type").readText().strip() == "acpitz")
                .map!(a => (a.name ~ "/temp").readText().strip().to!int / 1000)));
    }

    void handle_event(event) {
    }

}
