module battery;

import std.conv : to;
import std.string: strip;
import std.format : format;
import std.algorithm : map;
import std.process : executeShell;
import std.file : readText, dirEntries, SpanMode;

import formatter : block_layout, colors;
import blocklet : blocklet, event;

class battery : blocklet {

    void call(block_layout f) {
        int mean = 0;
        int numberOfValues = 0;

        foreach (val; dirEntries(
            "/sys/class/power_supply/", "BAT{0,1}", SpanMode.depth, false)
                .map!(a => (a.name ~ "/capacity").readText().strip().to!int))
        {
            numberOfValues++;
            mean += val;

            colors color = colors.normal;

            if (val < 15) {
                color = colors.red;
            }
            else if (val < 30) {
                color = colors.yellow;
            }
            f.add_value("%d".format(val), color);
        }

        if (mean / numberOfValues <= 5)
        {
            executeShell("notify-send '!!! Low battery !!!' 'Battery level is low' --icon=dialog-information -u critical -c im.error");
        }
    }

    void handle_event(event) {
    }

}
