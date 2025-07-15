module mem;

import formatter : block_layout;
import blocklet : blocklet, event;
import utils : human_readable_size;

class mem : blocklet
{
    void call(block_layout f)
    {
        version (FreeBSD)
        {
            import freebsd : readSysctl;

            struct VmStat
            {
                // All values are in KiB
                ulong free;
                ulong cached;
                ulong total;
            };

            VmStat vmstat()
            {
                VmStat stat;

                auto pageSize = "vm.stats.vm.v_page_size".readSysctl!uint;
                auto total = "vm.stats.vm.v_page_count".readSysctl!ulong;
                auto active = "vm.stats.vm.v_active_count".readSysctl!ulong;
                auto inactive = "vm.stats.vm.v_inactive_count".readSysctl!ulong;
                auto cached = "vm.stats.vm.v_cache_count".readSysctl!ulong;
                auto free = "vm.stats.vm.v_free_count".readSysctl!ulong;
                auto wired = "vm.stats.vm.v_wire_count".readSysctl!ulong;

                stat.free = free * pageSize / 1024;
                stat.cached = (inactive + cached + wired) * pageSize / 1024;
                stat.total = total * pageSize / 1024;

                return stat;
            }

            auto stat = vmstat();
            f.add_label("FREE").add_value(human_readable_size(stat.free))
             .add_label("CACHE").add_value(human_readable_size(stat.cached))
             .add_label("TOTAL").add_value(human_readable_size(stat.total));
        }
        else
        {
            import std.conv : to;
            import std.array : split;
            import std.file : readText;
            import std.regex : regex, matchAll;

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
    }

    void handle_event(event)
    {
    }
}
