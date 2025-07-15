module temp;

import std.array : empty;
import std.format : format;

import blocklet : Blocklet, Event;
import formatter : BlockLayout;

class Temp : Blocklet
{
    override void call(BlockLayout f)
    {
        const auto temps = getTemperatures();

        if (temps.empty)
        {
            f.addValue("cannot read");
            return;
        }

        foreach (const val; temps)
        {
            f.addValue("%d".format(val));
        }
    }
}

version (FreeBSD)
{

import freebsd : readSysctl;

private uint[] getTemperatures()
{
    uint[] temperatures;

    for (uint i = 0; i < 12; ++i)
    {
        const auto val = "hw.acpi.thermal.tz%d.temperature".format(i).readSysctl!uint;

        if (val == 0)
        {
            break;
        }

        temperatures ~= (val - 2731) / 10;
    }

    return temperatures;
}

} // FreeBSD

version (linux)
{

import std.algorithm : map, filter;
import std.array : array;
import std.conv : to;
import std.file : readText, dirEntries, SpanMode;
import std.string: strip;

private uint[] getTemperatures()
{
    return dirEntries("/sys/class/thermal/", "thermal_zone[0-12]", SpanMode.depth, false)
        .filter!(a => (a.name ~ "/type").readText.strip == "acpitz")
        .map!(a => (a.name ~ "/temp").readText.strip.to!uint / 1000)
        .array;
}

} // linux
