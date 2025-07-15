module app;

import std.array : split;
import std.file : readText;
import std.format : format;
import std.string : toUpper;
import std.path : expandTilde;
import std.stdio : writeln, stdout;
import core.time : seconds, Duration;
import vibe.stream.stdio: StdinStream;
import std.algorithm.searching : canFind;
import std.json : JSONValue, JSONOptions, parseJSON;
import vibe.d : runEventLoop, disableDefaultSignalHandlers, logDebug, setTimer, setLogFile, LogLevel, readLine, runTask;

import mem : mem;
import cpu : cpu;
import disk : disk;
import temp : temp;
import uptime : uptime;
import battery : battery;
import datetime : datetime;
import blocklet : blocklet, event;
import formatter : formatter, block_layout;

version(unittest)
{

import dunit;
mixin Main;

}
else
{

blocklet[string] blocklets;
string[string] cache;
JSONValue config;

void refresh(string[] blockletsToRefresh = null)
{
    auto array = JSONValue.emptyArray;

    foreach (string k, JSONValue v; config["blocks"])
    {
        string text;

        if ((blockletsToRefresh && blockletsToRefresh.canFind(k)) || !(k in cache))
        {
            auto fn = blocklets[k];
            auto layout = new block_layout();

            if (v["show_label"].boolean == true)
            {
                layout.add_title(k.toUpper);
            }

            fn.call(layout);
            auto f = new formatter(layout, v["color"].str);
            text = f.get;
            cache[k] = text;
        }
        else
        {
            text = cache[k];
        }

        auto entry = JSONValue([
            "full_text": text,
            "color": v["color"].str,
            "markup": "pango",
            "name": k
        ]);

        entry["separator"] = false;
        entry["separator_block_width"] = 0;

        array.array ~= entry;
    }

    writeln(",", array.toString(JSONOptions.doNotEscapeSlashes));
    stdout.flush();
}

void error(string msg)
{
    auto array = JSONValue.emptyArray;

    array.array ~= JSONValue([
        "full_text": msg,
        "color": "#ff0000",
        "name": "error"
    ]);

    writeln(",", array.toString(JSONOptions.doNotEscapeSlashes));
    stdout.flush();

    runEventLoop();
}

void main()
{
    auto configFile = "~/.blocklets.json".expandTilde;

    disableDefaultSignalHandlers();

    //setLogFile("~/blocklet.log".expandTilde, LogLevel.debug_);

    writeln("{\"version\":1,\"click_events\":true}");
    writeln("[[]");

    try
    {
        config = configFile
            .readText()
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

    foreach (k, v; intervalToBlocklet)
    {
        foreach (blocklet; v)
        {
            if (blocklet in blocklets)
            {
                continue;
            }
            switch (blocklet)
            {
                case "uptime":
                    blocklets["uptime"] = new uptime;
                    break;
                case "datetime":
                    blocklets["datetime"] = new datetime;
                    break;
                case "temp":
                    blocklets["temp"] = new temp;
                    break;
                case "mem":
                    blocklets["mem"] = new mem;
                    break;
                case "disk":
                    blocklets["disk"] = new disk;
                    break;
                case "cpu":
                    blocklets["cpu"] = new cpu;
                    break;
                case "battery":
                    blocklets["battery"] = new battery;
                    break;
                default:
                    break;
            }
        }
        setTimer(k.seconds, () { refresh(v); }, true);
    }

    refresh();

    auto stream = new StdinStream;

    auto task = () nothrow {
        while (1)
        {
            try
            {
                auto buffer = stream.readLine(512, "\n");
                if (buffer[0] == '[')
                {
                    continue;
                }
                if (buffer[0] == ',')
                {
                    buffer = buffer[1 .. $];
                }
                auto line = cast(string)buffer;
                auto json = line.parseJSON();
                refresh([json["name"].str]);
            }
            catch (Exception e)
            {
                logDebug(e.msg);
            }
        }
    };

    runTask(task);

    runEventLoop();
}

}
