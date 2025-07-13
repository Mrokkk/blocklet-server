module cpu;

import std.range : zip;
import std.array : empty;
import std.file : readText;
import std.format : format;
import std.datetime : msecs;
import std.conv : to, roundTo;
import std.array : split, join;
import std.typecons : tuple, Tuple;
import std.regex : regex, matchAll;
import std.algorithm : map, count, sum;
import core.thread : Thread;
import core.sync.mutex : Mutex;

import blocklet : blocklet, event;
import formatter : block_layout, colors;

shared(float[]) global_usage;

shared(Mutex) mtx;

class cpu : blocklet
{
    this()
    {
        mtx = new shared Mutex();
        thread_ = new Thread(&cpu_usage_thread).start();
    }

    void call(block_layout f)
    {
        mtx.lock_nothrow();
        auto usage = global_usage;
        mtx.unlock_nothrow();
        if (usage.empty)
        {
            f.add_value("not ready yet");
            return;
        }
        foreach (val; usage)
        {
            colors color = colors.normal;
            if (val > 80)
            {
                color = colors.red;
            }
            else if (val > 50)
            {
                color = colors.yellow;
            }
            f.add_value("%3.0f".format(val), color);
        }
    }

    void handle_event(event)
    {
    }

    private Thread thread_;
}

void cpu_usage_thread()
{
    auto get_core_times()
    {
        version (FreeBSD)
        {
            import core.sys.freebsd.sys.sysctl : sysctlbyname;

            ulong[128] values;
            size_t len = values.sizeof;
            ulong[] idles, total;

            if (sysctlbyname("kern.cp_times", &values, &len, null, 0))
            {
                return tuple(idles, total);
            }

            auto cpus = len / ulong.sizeof / 5;

            for (ulong i = 0; i < cpus; ++i)
            {
                auto off = i * 5;
                total ~= sum(values[off .. off + 5]);
                idles ~= values[i * 5 + 4];
            }

            return tuple(idles, total);
        }
        else
        {
            auto values = "/proc/stat".readText()[1 .. $].matchAll(regex("cpu.*"))
                .map!(a => a.hit().split()[1 .. $].map!(a => a.to!int));
            ulong[] idles, total;
            foreach (core_data; values)
            {
                total ~= sum(core_data);
                idles ~= core_data[3] + core_data[4];
            }
            return tuple(idles, total);
        }
    }

    while (1)
    {
        auto start = get_core_times();
        Thread.sleep(2000.msecs);
        auto end = get_core_times();
        float[] usage;
        foreach (idle_start, idle_end, total_start, total_end; zip(start[0], end[0], start[1], end[1]))
        {
            auto idle = (idle_end - idle_start).to!float;
            auto total = (total_end - total_start).to!float;
            usage ~= (1000 * (total - idle) / total) / 10;
        }
        mtx.lock_nothrow();
        global_usage = cast(shared(float[]))usage;
        mtx.unlock_nothrow();
    }
}
