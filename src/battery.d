module battery;

import std.format : format;

import formatter : block_layout, colors;
import blocklet : blocklet, event;

class battery : blocklet
{
    void call(block_layout f)
    {
        version (FreeBSD)
        {
            import freebsd : readSysctl;

            auto val = "hw.acpi.battery.life".readSysctl!uint;
            auto state = "hw.acpi.battery.state".readSysctl!uint;

            auto discharging = state == 1;
            auto charging = state == 2;

            auto color = colors.normal;

            if (discharging)
            {
                f.add_label("DIS", colors.brown);
                if (val < 15)
                {
                    color = colors.red;
                }
                else if (val < 30)
                {
                    color = colors.yellow;
                }
            }
            else if (charging)
            {
                f.add_label("CHR");
            }

            f.add_value("%d".format(val), color);
        }
        else
        {
            import std.conv : to;
            import std.array : split;
            import std.string: strip;
            import std.algorithm : map;
            import std.file : readText, dirEntries, SpanMode;

            int mean = 0;
            int numberOfValues = 0;

            foreach (val; dirEntries(
                "/sys/class/power_supply/", "BAT{0,1}", SpanMode.depth, false)
                    .map!(a => (a.name ~ "/capacity").readText().strip().to!int))
            {
                numberOfValues++;
                mean += val;

                auto color = colors.normal;

                if (val < 15)
                {
                    color = colors.red;
                }
                else if (val < 30)
                {
                    color = colors.yellow;
                }
                f.add_value("%d".format(val), color);
            }

            if (mean / numberOfValues <= 5)
            {
                executeShell("notify-send '!!! Low battery !!!' 'Battery level is low' --icon=dialog-information -u critical -c im.error");
            }
        }
    }

    void handle_event(event)
    {
    }
}
