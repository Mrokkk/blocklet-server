import core.thread : Thread;

import std.conv : to;
import std.array : split;
import std.stdio : writeln;
import std.path : expandTilde;
import vibe.d : listenTCP, runEventLoop, disableDefaultSignalHandlers;

import event : event;
import config : PORT, config;

import ifaces : ifaces_handler;
import uptime : uptime_handler;
import datetime : datetime_handler;
import core_temp : core_temp_handler;
import mem_usage : mem_usage_handler;
import disk_usage : disk_usage_handler;
import cpu_usage : cpu_usage_handler, cpu_usage_thread;

string function(event, config)[string] handlers;
string function(event, config) bad_block = (event, config) {
    throw new Exception("No such block");
};

void main() {
    handlers["uptime"] = &uptime_handler;
    handlers["datetime"] = &datetime_handler;
    handlers["cpu_usage"] = &cpu_usage_handler;
    handlers["core_temp"] = &core_temp_handler;
    handlers["mem_usage"] = &mem_usage_handler;
    handlers["disk_usage"] = &disk_usage_handler;
    handlers["ifaces"] = &ifaces_handler;
    auto conf = new config("config.json");
    auto th = new Thread(&cpu_usage_thread).start();
    disableDefaultSignalHandlers();
    auto server = listenTCP(PORT, (conn) {
        conn.waitForData();
        auto data = new ubyte[conn.leastSize];
        conn.read(data);
        auto splitted = (cast(string) data).split();
        try {
            auto fn = handlers.get(splitted[0], bad_block);
            auto ev = 0;
            if (splitted.length > 1) {
                ev = splitted[1].to!int;
            }
            conn.write(fn(cast(event) ev, conf));
        }
        catch(Exception e) {
            conn.write("No blocklet!");
        }
        conn.finalize();
    }, "0.0.0.0");
    runEventLoop();
}
