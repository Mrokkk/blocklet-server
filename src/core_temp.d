module core_temp;

import std.conv : to;
import std.format : format;
import std.algorithm : map;
import std.string: strip, toUpper;
import std.file : readText, dirEntries, SpanMode;

import event : event;
import config : config;
import blocklet : blocklet;
import formatter : formatter;

class core_temp : blocklet {

    private config config_;
    immutable private string name_ = "core_temp";

    this(config c) {
        config_ = c;
    }

    string name() {
        return name_;
    }

    string call(event) {
        auto f = new formatter(config_.color("core_temp"));
        if (config_.show_label(name_)) {
            f.add_label(name_.toUpper);
        }
        return f.add_value("%(%d\xc2\xb0C%| %)".format(
            dirEntries("/sys/devices/platform/coretemp.0/hwmon/",
            "temp{2,3,4,5,6,7,8,9}_input", SpanMode.depth, false)
                .map!(a => a.name.readText().strip().to!int / 1000))).get;
    }

}
