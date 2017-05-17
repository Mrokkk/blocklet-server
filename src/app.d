import core.thread : Thread;

import std.conv : to;
import std.array : split;
import std.stdio : writeln;
import std.path : expandTilde;
import vibe.d : listenTCP, runEventLoop, disableDefaultSignalHandlers;

import event : event;
import config : PORT, config;

import blocklet : blocklet;
import uptime : uptime;
import datetime : datetime;
import core_temp : core_temp;
import mem_usage : mem_usage;
import disk_usage : disk_usage;
import cpu_usage : cpu_usage_thread, cpu_usage;

blocklet[string] blocklets;

void main() {
    auto conf = new config("config.json");
    blocklets["uptime"] = new uptime(conf);
    blocklets["datetime"] = new datetime(conf);
    blocklets["cpu_usage"] = new cpu_usage(conf);
    blocklets["core_temp"] = new core_temp(conf);
    blocklets["mem_usage"] = new mem_usage(conf);
    blocklets["disk_usage"] = new disk_usage(conf);
    disableDefaultSignalHandlers();
    auto server = listenTCP(PORT, (conn) {
        conn.waitForData();
        auto data = new ubyte[conn.leastSize];
        conn.read(data);
        auto splitted = (cast(string) data).split();
        try {
            auto fn = blocklets[splitted[0]];
            auto ev = 0;
            if (splitted.length > 1) {
                ev = splitted[1].to!int;
            }
            conn.write(fn.call(cast(event) ev));
        }
        catch(Exception e) {
            conn.write("No blocklet!");
        }
        conn.finalize();
    }, "0.0.0.0");
    runEventLoop();
}
