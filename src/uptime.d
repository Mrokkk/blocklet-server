module uptime;

import std.format : format;
import core.time : MonoTime, convClockFreq;

import formatter : BlockLayout;
import blocklet : Blocklet, Event;

class Uptime : Blocklet
{
    override void call(BlockLayout f)
    {
        const auto monoTime = MonoTime().currTime;
        const auto mono = convClockFreq(monoTime.ticks, monoTime.ticksPerSecond, 1);
        f.addValue("%02uh%02u".format(mono / 3600, (mono % 3600) / 60));
    }
}
