module mem_usage;

import std.conv : to;
import std.math : abs;
import std.array : split;
import std.file : readText;
import std.format : format;
import std.regex : regex, matchAll;

import formatter;
import config : PORT, TEMPLATE, powerline_look;

string human_readable_size(float num, string suffix="B") {
    foreach (unit; ["", "Mi", "Gi", "Ti"]) {
        if (abs(num) < 1024.0) {
            return "%3.1f%s%s".format(num, unit, suffix);
        }
        num /= 1024.0;
    }
    return "%.1f%s%s".format(num, "Pi", suffix);
}

string mem_usage_handler() {
    auto meminfo = "/proc/meminfo".readText();
    auto memtotal = meminfo.matchAll(regex("MemTotal.*")).hit().split()[1].to!float();
    auto memfree = meminfo.matchAll(regex("MemFree.*")).hit().split()[1].to!float();
    //auto memavail = meminfo.matchAll(regex("MemAvaila.*")).hit().split()[1].to!float();
    auto buffers = meminfo.matchAll(regex("Buffers.*")).hit().split()[1].to!float();
    auto cached = meminfo.matchAll(regex("Cached.*")).hit().split()[1].to!float();
    auto f = new formatter("#2d8659");
    return f.add_label("MEM_USAGE").add_value(human_readable_size(memfree))
                                   .add_value(human_readable_size(cached))
                                   .add_value(human_readable_size(buffers))
                                   .add_value(human_readable_size(memtotal))
                                   .get();
}
