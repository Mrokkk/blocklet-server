module battery;

import std.format : format;
import std.typecons : tuple;

import blocklet : Blocklet, Event;
import formatter : BlockLayout, Colors;

private enum State
{
    charged,
    charging,
    discharging,
}

class Battery : Blocklet
{
    override void call(BlockLayout f)
    {
        const auto battery = getBatteryState();

        auto color = Colors.normal;

        switch (battery.state)
        {
            case State.charging:
                f.addValue("\u2191", Colors.green); // Arrow up
                break;
            case State.discharging:
                f.addValue("\u2193", Colors.brown); // Arrow down
                if (battery.val < 15)
                {
                    color = Colors.red;
                }
                else if (battery.val < 30)
                {
                    color = Colors.yellow;
                }
                break;
            default:
                break;
        }

        f.addValue("%d".format(battery.val), color);
    }
}

version (FreeBSD)
{

import freebsd : readSysctl;

// Reference:
// https://man.freebsd.org/cgi/man.cgi?acpi_battery

private enum
{
    ACPI_BATT_STAT_DISCHARG = 1,
    ACPI_BATT_STAT_CHARGING = 2,
    ACPI_BATT_STAT_CRITICAL = 4,
}

private auto getBatteryState()
{
    const auto val = "hw.acpi.battery.life".readSysctl!uint;
    const auto state = "hw.acpi.battery.state".readSysctl!uint;

    State s;
    switch (state)
    {
        case ACPI_BATT_STAT_DISCHARG, ACPI_BATT_STAT_CRITICAL:
            s = State.discharging;
            break;
        case ACPI_BATT_STAT_CHARGING:
            s = State.charging;
            break;
        default:
            s = State.charged;
            break;
    }

    return tuple!("val", "state")(val, s);
}

} // FreeBSD

version (linux)
{

import std.conv : to;
import std.array : split;
import std.string: strip;
import std.algorithm : map;
import std.file : readText, dirEntries, SpanMode;

private auto getBatteryState()
{
    uint sum = 0;
    uint count = 0;
    State s = State.charged;

    foreach (const dirEntry; dirEntries("/sys/class/power_supply/", "BAT[0-12]", SpanMode.depth, false))
    {
        const auto val = (dirEntry.name ~ "/capacity").readText.strip.to!uint;
        const auto state = (dirEntry.name ~ "/status").readText.strip;
        count++;
        sum += val;

        if (state == "Discharging")
        {
            s = State.discharging;
        }
        else if (state == "Charging" && s != State.discharging)
        {
            s = State.charging;
        }
    }

    return tuple!("val", "state")(sum / count, s);
}

} // linux
