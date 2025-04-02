module mem_usage;

import std.conv : to;
import std.array : split;
import std.file : readText;
import std.regex : regex, matchAll;

import blocklet : blocklet, event;
import utils : human_readable_size;
import formatter : block_layout;

class mem_usage : blocklet
{
    void call(block_layout f)
    {
        auto meminfo = "/proc/meminfo".readText();
        auto memtotal = meminfo.matchAll(regex("MemTotal.*")).hit().split()[1].to!float;
        auto memfree = meminfo.matchAll(regex("MemFree.*")).hit().split()[1].to!float;
        auto buffers = meminfo.matchAll(regex("Buffers.*")).hit().split()[1].to!float;
        auto cached = meminfo.matchAll(regex("Cached.*")).hit().split()[1].to!float;
        f.add_label("FREE").add_value(human_readable_size(memfree))
         .add_label("CACHE").add_value(human_readable_size(cached))
         .add_label("BUFF").add_value(human_readable_size(buffers))
         .add_label("TOTAL").add_value(human_readable_size(memtotal));
    }

    void handle_event(event)
    {
    }
}
