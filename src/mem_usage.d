module mem_usage;

import std.conv : to;
import std.math : abs;
import std.array : split;
import std.file : readText;
import std.format : format;
import std.regex : regex, matchAll;

import formatter;
import event : event;
import config : PORT, TEMPLATE, powerline_look;

string human_readable_size(float num) {
    foreach (unit; ["", "M", "G", "T"]) {
        if (abs(num) < 1024.0) {
            return "%3.1f%s".format(num, unit);
        }
        num /= 1024.0;
    }
    return "%.1f%s".format(num, "Pi");
}

string mem_usage_handler(event) {
    auto meminfo = "/proc/meminfo".readText();
    auto memtotal = meminfo.matchAll(regex("MemTotal.*")).hit().split()[1].to!float;
    auto memfree = meminfo.matchAll(regex("MemFree.*")).hit().split()[1].to!float;
    auto buffers = meminfo.matchAll(regex("Buffers.*")).hit().split()[1].to!float;
    auto cached = meminfo.matchAll(regex("Cached.*")).hit().split()[1].to!float;
    auto f = new formatter("#2d8659");
    return f.add_label("MEM_USAGE")
            .add_value("FREE", [modifiers.small_font]).add_value(human_readable_size(memfree))
            .add_value("CACHE", [modifiers.small_font]).add_value(human_readable_size(cached))
            .add_value("BUFF", [modifiers.small_font]).add_value(human_readable_size(buffers))
            .add_value("TOTAL", [modifiers.small_font]).add_value(human_readable_size(memtotal))
            .get;
}
