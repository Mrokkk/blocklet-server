module cpu;

import core.sync.mutex : Mutex;
import core.thread : Thread;
import std.algorithm : map, count, sum;
import std.array : empty;
import std.conv : to;
import std.datetime : msecs;
import std.format : format;
import std.range : zip;
import std.typecons : tuple;

import blocklet : Blocklet, Event;
import formatter : BlockLayout, Colors;

private shared(float[]) globalUsage;
private shared(Mutex) mtx;

class Cpu : Blocklet
{
    this()
    {
        mtx = new shared Mutex();
        thread_ = new Thread(&cpuUsageThread).start();
    }

    override void call(BlockLayout f)
    {
        mtx.lock_nothrow();
        const auto usage = globalUsage.dup;
        mtx.unlock_nothrow();
        if (usage.empty)
        {
            f.addValue("not ready yet");
            return;
        }
        foreach (const val; usage)
        {
            auto color = Colors.normal;
            if (val > 80)
            {
                color = Colors.red;
            }
            else if (val > 50)
            {
                color = Colors.yellow;
            }
            f.addValue("%3.0f".format(val), color);
        }
    }

    private Thread thread_;
}

private void cpuUsageThread()
{
    while (1)
    {
        const auto start = getCoreTimes();
        Thread.sleep(2000.msecs);
        const auto end = getCoreTimes();
        float[] usage;
        foreach (idleStart, idleEnd, totalStart, totalEnd; zip(start.idle, end.idle, start.total, end.total))
        {
            const auto idle = (idleEnd - idleStart).to!float;
            const auto total = (totalEnd - totalStart).to!float;
            usage ~= (1000 * (total - idle) / total) / 10;
        }
        mtx.lock_nothrow();
        globalUsage = cast(shared(float[]))usage;
        mtx.unlock_nothrow();
    }
}

version (FreeBSD)
{

import freebsd : readSysctlArray;

private auto getCoreTimes()
{
    size_t len;
    ulong[] idles, total;

    const auto values = "kern.cp_times".readSysctlArray!(ulong, 128)(len);
    const auto cpus = len / 5;

    for (ulong i = 0; i < cpus; ++i)
    {
        const auto off = i * 5;
        total ~= sum(values[off .. off + 5]);
        idles ~= values[i * 5 + 4];
    }

    return tuple!("idle", "total")(idles, total);
}

} // FreeBSD

version (linux)
{

import std.array : split, join;
import std.file : readText;
import std.regex : regex, matchAll;

private auto getCoreTimes()
{
    auto values = "/proc/stat".readText()[1 .. $]
        .matchAll(regex("cpu.*"))
        .map!(a => a.hit().split()[1 .. $].map!(a => a.to!int));

    ulong[] idles, total;

    foreach (coreData; values)
    {
        total ~= sum(coreData);
        idles ~= coreData[3] + coreData[4];
    }

    return tuple!("idle", "total")(idles, total);
}

} // linux
