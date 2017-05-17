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
import config : config;
import blocklet : blocklet;
import formatter : formatter;

shared(float[]) global_usage;

class cpu_usage : blocklet {

    Thread thread_;
    private config config_;
    immutable private string name_ = "cpu_usage";

    this(config c) {
        config_ = c;
        thread_ = new Thread(&cpu_usage_thread).start();
    }

    string name() {
        return name_;
    }

    string call(event) {
        thread_enterCriticalRegion();
        auto usage = global_usage;
        thread_exitCriticalRegion();
        auto default_color = config_.color(name_);
        auto f = new formatter(default_color);
        if (config_.show_label(name_)) {
            f.add_label("CPU_USAGE");
        }
        foreach (val; usage) {
            if (val > 80) {
                f.set_color("red").add_value("% 6.2f".format(val)).set_color(default_color);
            }
            else if (val > 50) {
                f.set_color("yellow").add_value("% 6.2f".format(val)).set_color(default_color);
            }
            else {
                f.add_value("% 6.2f".format(val));
            }
        }
        return f.get;
    }

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
