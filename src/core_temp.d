module core_temp;

import std.conv : to;
import std.string: strip;
import std.format : format;
import std.algorithm : map;
import std.file : readText, dirEntries, SpanMode;

import event : event;
import config : config;
import formatter : formatter;

string core_temp_handler(event, config c) {
    auto f = new formatter(c.color("core_temp"));
    if (c.show_label("core_temp")) {
        f.add_label("CORE_TEMP");
    }
    return f.add_value("%(%d\xc2\xb0C%| %)".format(
        dirEntries("/sys/devices/platform/coretemp.0/hwmon/",
        "temp{2,3,4,5,6,7,8,9}_input", SpanMode.depth, false)
            .map!(a => a.name.readText().strip().to!int / 1000))).get;
}
