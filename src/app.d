module app;

import std.conv : to;
import std.array : split;
import std.stdio : writeln;
import std.format : format;
import std.string : toUpper;
import std.path : expandTilde;
import vibe.d : listenTCP, runEventLoop, disableDefaultSignalHandlers,
       TCPConnection, logDebug;

import config : PORT, config;
import blocklet : blocklet, event;
import formatter : formatter, block_layout;

import mem : mem;
import cpu : cpu;
import disk : disk;
import temp : temp;
import uptime : uptime;
import battery : battery;
import datetime : datetime;

void handler(TCPConnection conn, ref config conf, ref blocklet[string] blocklets)
{
    conn.waitForData();
    auto data = new ubyte[conn.leastSize];
    conn.read(data);
    auto splitted = (cast(string) data).split();
    auto blocklet = splitted[0];
    if (!(blocklet in blocklets))
    {
        conn.close();
        return;
    }
    try
    {
        auto fn = blocklets[blocklet];
        logDebug("Blocklet: %s".format(blocklet));
        auto layout = new block_layout();
        if (conf.show_label(blocklet))
        {
            layout.add_title(blocklet.toUpper);
        }
        if (splitted.length > 1)
        {
            auto ev = splitted[1].to!int;
            fn.handle_event(cast(event) ev);
        }
        fn.call(layout);
        auto f = new formatter(layout, conf.color(blocklet));
        conn.write(f.get);
    }
    catch(Exception e)
    {
        writeln(e);
        conn.write("No blocklet!");
    }
    conn.finalize();
}

version(unittest)
{

import dunit;
mixin Main;

}
else
{

void main()
{
    config conf;
    blocklet[string] blocklets;
    conf = new config("~/.blocklets.json".expandTilde);
    blocklets["uptime"] = new uptime;
    blocklets["datetime"] = new datetime;
    blocklets["temp"] = new temp;
    blocklets["mem"] = new mem;
    blocklets["disk"] = new disk;
    blocklets["cpu"] = new cpu;
    blocklets["battery"] = new battery;
    disableDefaultSignalHandlers();
    try
    {
        auto server = listenTCP(PORT, (conn) => handler(conn, conf, blocklets), "0.0.0.0");
        runEventLoop();
    }
    catch (Exception exc)
    {
        writeln("Cannot start server: %s".format(exc.msg));
    }
}

}
