module app;

import std.conv : to;
import std.array : split;
import std.stdio : writeln;
import std.format : format;
import std.string : toUpper;
import std.path : expandTilde;
import vibe.d : listenTCP, runEventLoop, disableDefaultSignalHandlers,
       TCPConnection, logInfo;

import config : PORT, config;
import blocklet : blocklet, event;
import formatter : formatter, block_layout;

import uptime : uptime;
import ifaces : ifaces;
import datetime : datetime;
import core_temp : core_temp;
import mem_usage : mem_usage;
import cpu_usage : cpu_usage;
import disk_usage : disk_usage;

void handler(TCPConnection conn, ref config conf, ref blocklet[string] blocklets) {
    conn.waitForData();
    auto data = new ubyte[conn.leastSize];
    conn.read(data);
    auto splitted = (cast(string) data).split();
    if (!(splitted[0] in blocklets)) {
        conn.close();
        return;
    }
    try {
        auto fn = blocklets[splitted[0]];
        logInfo("Blocklet: %s".format(splitted[0]));
        auto layout = new block_layout();
        if (conf.show_label(splitted[0])) {
            layout.add_title(splitted[0].toUpper);
        }
        if (splitted.length > 1) {
            auto ev = splitted[1].to!int;
            fn.handle_event(cast(event) ev);
        }
        fn.call(layout);
        auto f = new formatter(layout, conf.color(splitted[0]));
        conn.write(f.get);
    }
    catch(Exception e) {
        conn.write("No blocklet!");
    }
    conn.finalize();
}

version(unittest) {

import dunit;
mixin Main;

}
else {

void main() {
    config conf;
    blocklet[string] blocklets;
    conf = new config("~/.blocklets.json".expandTilde);
    blocklets["uptime"] = new uptime;
    blocklets["ifaces"] = new ifaces;
    blocklets["datetime"] = new datetime;
    blocklets["core_temp"] = new core_temp;
    blocklets["mem_usage"] = new mem_usage;
    blocklets["disk_usage"] = new disk_usage;
    blocklets["cpu_usage"] = new cpu_usage;
    disableDefaultSignalHandlers();
    try {
        auto server = listenTCP(PORT, (conn) => handler(conn, conf, blocklets), "0.0.0.0");
        runEventLoop();
    }
    catch (Exception exc) {
        writeln("Cannot start server: %s".format(exc.msg));
    }
}

}
