module mem_usage;

import std.conv : to;
import std.array : split;
import std.file : readText;
import std.regex : regex, matchAll;

import event : event;
import config : config;
import blocklet : blocklet;
import utils : human_readable_size;
import formatter : formatter, modifiers;

class mem_usage : blocklet {

    private config config_;

    this(config c) {
        config_ = c;
    }

    void call(formatter f) {
        auto meminfo = "/proc/meminfo".readText();
        auto memtotal = meminfo.matchAll(regex("MemTotal.*")).hit().split()[1].to!float;
        auto memfree = meminfo.matchAll(regex("MemFree.*")).hit().split()[1].to!float;
        auto buffers = meminfo.matchAll(regex("Buffers.*")).hit().split()[1].to!float;
        auto cached = meminfo.matchAll(regex("Cached.*")).hit().split()[1].to!float;
        f.add_value("FREE", [modifiers.small_font]).add_value(human_readable_size(memfree))
            .add_value("CACHE", [modifiers.small_font]).add_value(human_readable_size(cached))
            .add_value("BUFF", [modifiers.small_font]).add_value(human_readable_size(buffers))
            .add_value("TOTAL", [modifiers.small_font]).add_value(human_readable_size(memtotal));
    }

    void handle_event(event) {
    }

}
