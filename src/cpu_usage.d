module cpu_usage;

import std.range : zip;
import std.file : readText;
import std.format : format;
import std.datetime : msecs;
import std.conv : to, roundTo;
import std.array : split, join;
import std.typecons : tuple, Tuple;
import std.regex : regex, matchAll;
import std.algorithm : map, count, sum;
import core.thread : Thread, thread_exitCriticalRegion, thread_enterCriticalRegion;

import event : event;
import formatter : formatter;

shared(float[]) global_usage;

string cpu_usage_handler(event) {
    thread_enterCriticalRegion();
    auto usage = global_usage;
    thread_exitCriticalRegion();
    auto f = new formatter("#2d8659");
    f.add_label("CPU_USAGE");
    foreach (val; usage) {
        if (val > 80) {
            f.set_color("red").add_value("% 6.2f".format(val)).set_color("#2d8659");
        }
        else if (val > 50) {
            f.set_color("yellow").add_value("% 6.2f".format(val)).set_color("#2d8659");
        }
        else {
            f.add_value("% 6.2f".format(val));
        }
    }
    return f.get;
}

void cpu_usage_thread() {

    auto get_core_times() {
        auto values = "/proc/stat".readText()[1 .. $].matchAll(regex("cpu.*"))
            .map!(a => a.hit().split()[1 .. $].map!(a => a.to!int));
        int[] idles, total;
        foreach (core_data; values) {
            total ~= sum(core_data);
            idles ~= core_data[3] + core_data[4];
        }
        return tuple(idles, total);
    }

    while (1) {
        auto start = get_core_times();
        Thread.sleep(2000.msecs);
        auto end = get_core_times();
        float[] usage;
        foreach (idle_start, idle_end, total_start, total_end; zip(start[0], end[0], start[1], end[1])) {
            auto idle = (idle_end - idle_start).to!float;
            auto total = (total_end - total_start).to!float;
            usage ~= (1000 * (total - idle) / total) / 10;
        }
        thread_enterCriticalRegion();
        global_usage = cast(shared(float[]))usage;
        thread_exitCriticalRegion();
    }
}
