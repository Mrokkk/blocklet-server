module app;

import core.stdc.stdlib : exit;
import core.time : seconds, Duration;
import std.algorithm.searching : canFind;
import std.array : split;
import std.conv : to;
import std.file : readText;
import std.format : format;
import std.json : JSONValue, JSONOptions, parseJSON;
import std.path : expandTilde;
import std.stdio : writeln, stdout;
import std.string : toUpper, toLower;
import vibe.d : runEventLoop, disableDefaultSignalHandlers, logDebug, setTimer, setLogFile, LogLevel, readLine, runTask;
import vibe.stream.stdio: StdinStream;

import blocklet;
import formatter;
import utils;

version (unittest)
{

import dunit;
mixin Main;

} // unittest
else
{

private Blocklet[string] blocklets;
private string[string] cache;
private JSONValue config;

int main()
{
    const auto configFile = "~/.blocklets.json".expandTilde;

    disableDefaultSignalHandlers();

    setLogFile("~/blocklet.log".expandTilde, LogLevel.debug_);

    auto blockletClasses = getBlockletClasses();

    writeln("{\"version\":1,\"click_events\":true}");
    writeln("[[]");

    try
    {
        config = configFile
            .readText
            .parseJSON(JSONOptions.preserveObjectOrder);
    }
    catch (Exception e)
    {
        error("Error parsing %s: %s".format(configFile, e.msg));
    }

    string[][long] intervalToBlocklet;

    foreach (string k, JSONValue v; config["blocks"])
    {
        intervalToBlocklet[v["interval"].integer] ~= k;
    }

    foreach (interval, blockletNames; intervalToBlocklet)
    {
        foreach (blocklet; blockletNames)
        {
            if (blocklet in blocklets)
            {
                continue;
            }
            if (!(blocklet in blockletClasses))
            {
                error("Unknown blocklet \"%s\"".format(blocklet));
            }

            // Instantiate given Blocklet using its ClassInfo
            blocklets[blocklet] = cast(Blocklet)blockletClasses[blocklet].create();
        }

        // Start time for given set of blocklets sharing the same interval
        setTimer(interval.seconds, () { refresh(blockletNames); }, true);
    }

    blockletClasses.destroy();

    auto task = () nothrow {
        try
        {
            auto stream = new StdinStream;
            while (1)
            {
                auto buffer = stream.readLine(512, "\n");
                // i3bar will always open with single [
                if (buffer[0] == '[')
                {
                    continue;
                }
                // First event will not start with ",", but
                // the others will
                if (buffer[0] == ',')
                {
                    buffer = buffer[1 .. $];
                }
                const auto line = (cast(string)buffer);
                const auto json = line.parseJSON;
                const auto event = cast(Event)json["button"].integer;
                refresh([json["name"].str], event);
            }
        }
        catch (Exception e)
        {
            error("Error: " ~ e.msg);
        }
    };

    refresh();

    runTask(task);

    return runEventLoop();
}

private void error(string msg) nothrow
{
    auto array = JSONValue.emptyArray;

    try
    {
        array.array ~= JSONValue([
            "full_text": msg,
            "color": "#ff0000",
            "name": "error"
        ]);

        writeln(",", array.toString(JSONOptions.doNotEscapeSlashes));
        stdout.flush();
    }
    catch (Exception e)
    {
    }

    exit(runEventLoop());
}

private ClassInfo[string] getBlockletClasses()
{
    ClassInfo[string] info;

    foreach (mod; ModuleInfo)
    {
        foreach (cla; mod.localClasses)
        {
            if (cla.base is Blocklet.classinfo)
            {
                info[cla.name.split(".")[$ - 1].toLower] = cla;
            }
        }
    }

    return info;
}

private void refresh(string[] blockletsToRefresh = null, Event event = Event.none)
{
    auto array = JSONValue.emptyArray;

    foreach (string blockletName, JSONValue v; config["blocks"])
    {
        string text;

        if ((blockletsToRefresh && blockletsToRefresh.canFind(blockletName)) || !(blockletName in cache))
        {
            auto fn = blocklets[blockletName];
            auto layout = new BlockLayout();

            if (v["showLabel"].boolean == true)
            {
                if ("label" in v)
                {
                    layout.addTitle(v["label"].str);
                }
                else
                {
                    layout.addTitle(blockletName.toUpper);
                }
            }

            try
            {
                fn.call(layout);
                if (event != Event.none)
                {
                    fn.handleEvent(event);
                    if ("actions" in v && event.to!string in v["actions"])
                    {
                        executeCommand(v["actions"][event.to!string].str);
                    }
                }
            }
            catch (Exception e)
            {
                layout.addValue("Error: %s".format(e.msg), Colors.red);
            }

            auto f = new Formatter(layout, v["color"].str);
            text = f.get;

            cache[blockletName] = text;
        }
        else
        {
            text = cache[blockletName];
        }

        auto entry = JSONValue([
            "full_text": text,
            "color": v["color"].str,
            "markup": "pango",
            "name": blockletName
        ]);

        entry["separator"] = false;
        entry["separator_block_width"] = 0;

        array.array ~= entry;
    }

    writeln(",", array.toString(JSONOptions.doNotEscapeSlashes));
    stdout.flush();
}

} // !unittest
