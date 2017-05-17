import core.thread : Thread;

import std.conv : to;
import std.array : split;
import std.stdio : writeln;
import std.format : format;
import std.string : toUpper;
import std.path : expandTilde;
import vibe.d : listenTCP, runEventLoop, disableDefaultSignalHandlers;

import event : event;
import blocklet : blocklet;
import config : PORT, config;
import formatter : formatter;

import uptime : uptime;
import ifaces : ifaces;
import datetime : datetime;
import core_temp : core_temp;
import mem_usage : mem_usage;
import disk_usage : disk_usage;
import cpu_usage : cpu_usage_thread, cpu_usage;

blocklet[string] blocklets;

void main() {
    auto conf = new config("config.json");
    blocklets["uptime"] = new uptime;
    blocklets["ifaces"] = new ifaces;
    blocklets["datetime"] = new datetime;
    blocklets["core_temp"] = new core_temp;
    blocklets["mem_usage"] = new mem_usage;
    blocklets["disk_usage"] = new disk_usage;
    blocklets["cpu_usage"] = new cpu_usage(conf);
    disableDefaultSignalHandlers();
    auto server = listenTCP(PORT, (conn) {
        conn.waitForData();
        auto data = new ubyte[conn.leastSize];
        conn.read(data);
        auto splitted = (cast(string) data).split();
        try {
            auto fn = blocklets[splitted[0]];
            //writeln("Blocklet: %s".format(splitted[0]));
            auto f = new formatter(conf.color(splitted[0]));
            if (conf.show_label(splitted[0])) {
                f.add_label(splitted[0].toUpper);
            }
            if (splitted.length > 1) {
                auto ev = splitted[1].to!int;
                fn.handle_event(cast(event) ev);
            }
            fn.call(f);
            conn.write(f.get);
        }
        catch(Exception e) {
            conn.write("No blocklet!");
        }
        conn.finalize();
    }, "0.0.0.0");
    runEventLoop();
}
