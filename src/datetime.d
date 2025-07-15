module datetime;

import std.datetime : msecs, Clock;
import std.format : format;

import blocklet : Blocklet, Event;
import formatter : BlockLayout;

class Datetime : Blocklet
{
    override void call(BlockLayout f)
    {
        const auto currentTime = Clock.currTime();
        f.addValue("%s, %d %s %d, %02d:%02d:%02d".format(
            currentTime.dayOfWeek, currentTime.day, currentTime.month,
            currentTime.year, currentTime.hour, currentTime.minute,
            currentTime.second));
    }
}
