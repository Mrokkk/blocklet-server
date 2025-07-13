module mem;

import std.conv : to;
import std.array : split;
import std.file : readText;
import std.process : executeShell;
import std.regex : regex, matchAll;

import blocklet : blocklet, event;
import utils : human_readable_size;
import formatter : block_layout;

class mem : blocklet
{
    void call(block_layout f)
    {
        version (FreeBSD)
        {
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

                auto command = executeShell("vmstat -s");

                if (command.status != 0)
                {
                    return stat;
                }

                auto regexes = regex([
                    `([0-9]+)\s*pages active`,
                    `([0-9]+)\s*pages inactive`,
                    `([0-9]+)\s*pages in the laundry queue`,
                    `([0-9]+)\s*pages wired down`,
                    `([0-9]+)\s*pages free[^d]`,
                    `([0-9]+)\s*bytes per page`
                ]);

                auto match = command.output.matchAll(regexes);

                if (!match)
                {
                    return stat;
                }

                auto active = match.front[1].to!ulong;
                match.popFront();
                auto inactive = match.front[1].to!ulong;
                match.popFront();
                auto laundry = match.front[1].to!ulong;
                match.popFront();
                auto wired = match.front[1].to!ulong;
                match.popFront();
                auto free = match.front[1].to!ulong;
                match.popFront();
                auto pageSize = match.front[1].to!ulong;

                stat.free = free * pageSize / 1024;
                stat.cached = (inactive + wired) * pageSize / 1024;
                stat.total = (active + inactive + wired + laundry + free) * pageSize / 1024;

                return stat;
            }

            auto stat = vmstat();
            f.add_label("FREE").add_value(human_readable_size(stat.free))
             .add_label("CACHE").add_value(human_readable_size(stat.cached))
             .add_label("TOTAL").add_value(human_readable_size(stat.total));
        }
        else
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
    }

    void handle_event(event)
    {
    }
}
