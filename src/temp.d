module temp;

import std.conv : to;
import std.string: strip;
import std.format : format;
import std.string : toStringz;
import std.array : split, empty;
import std.algorithm : map, filter;
import std.file : readText, dirEntries, SpanMode;

import formatter : block_layout;
import blocklet : blocklet, event;

class temp : blocklet
{
    void call(block_layout f)
    {
        version (FreeBSD)
        {
            import freebsd : readSysctl;
            uint found = 0;

            for (uint i = 0; i < 12; ++i)
            {
                auto val = "hw.acpi.thermal.tz%d.temperature".format(i).readSysctl!uint;

                if (val == 0)
                {
                    break;
                }

                found++;
                f.add_value("%d".format((val - 2731) / 10));
            }

            if (!found)
            {
                f.add_value("no thermal zone");
            }
        }
        else
        {
            f.add_value("%(%d%| %)".format(
                dirEntries("/sys/class/thermal/",
                "thermal_zone{0,1,2,3,4,5,6,7,8,9,10,11,12}", SpanMode.depth, false)
                    .filter!(a => (a.name ~ "/type").readText().strip() == "acpitz")
                    .map!(a => (a.name ~ "/temp").readText().strip().to!int / 1000)));
        }
    }

    void handle_event(event)
    {
    }
}
