module uptime;

import std.format : format;
import core.time : MonoTime, convClockFreq;

import formatter : block_layout;
import blocklet : blocklet, event;

class uptime : blocklet
{
    void call(block_layout f)
    {
        auto monoTime = MonoTime().currTime;
        auto mono = convClockFreq(monoTime.ticks, monoTime.ticksPerSecond, 1);
        f.add_value("%02uh%02u".format(mono / 3600, (mono % 3600) / 60));
    }

    void handle_event(event)
    {
    }
}
