module mem;

import std.typecons : tuple;

import blocklet : Blocklet, Event;
import formatter : BlockLayout;
import utils : humanReadableSize;

class Mem : Blocklet
{
    override void call(BlockLayout f)
    {
        const auto vmStat = getVmStat();

        f.addLabel("FREE").addValue(humanReadableSize(vmStat.free))
         .addLabel("CACHE").addValue(humanReadableSize(vmStat.cache))
         .addLabel("TOTAL").addValue(humanReadableSize(vmStat.total));
    }
}

version (FreeBSD)
{

import freebsd : readSysctl;

private auto getVmStat()
{
    const auto pageSize = "vm.stats.vm.v_page_size".readSysctl!uint;
    const auto total = "vm.stats.vm.v_page_count".readSysctl!ulong;
    const auto inactive = "vm.stats.vm.v_inactive_count".readSysctl!ulong;
    const auto cached = "vm.stats.vm.v_cache_count".readSysctl!ulong;
    const auto free = "vm.stats.vm.v_free_count".readSysctl!ulong;
    const auto wired = "vm.stats.vm.v_wire_count".readSysctl!ulong;
    const auto buf = "vfs.bufspace".readSysctl!ulong;

    return tuple!("total", "free", "cache")(
        total * pageSize,
        free * pageSize,
        (inactive + cached + wired) * pageSize + buf);
}

} // FreeBSD

version (linux)
{

import std.array : split;
import std.conv : to;
import std.file : readText;
import std.regex : regex, matchAll;

private auto getVmStat()
{
    const auto meminfo = "/proc/meminfo".readText();
    const auto total = meminfo.matchAll(regex(`MemTotal.*`)).hit().split[1].to!ulong * 1024;
    const auto free = meminfo.matchAll(regex(`MemFree.*`)).hit().split[1].to!ulong * 1024;
    const auto buf = meminfo.matchAll(regex(`Buffers.*`)).hit().split[1].to!ulong * 1024;
    const auto cache = meminfo.matchAll(regex(`Cached.*`)).hit().split[1].to!ulong * 1024;

    return tuple!("total", "free", "cache")(total, free, buf + cache);
}


} // linux
