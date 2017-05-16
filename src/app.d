import core.thread : Thread;

import std.stdio;
import std.conv : to;
import uptime : uptime_handler;
import std.array : split;
import vibe.d : listenTCP, runEventLoop, disableDefaultSignalHandlers;

import event : event;
import config : PORT;

import datetime : datetime_handler;
import core_temp : core_temp_handler;
import mem_usage : mem_usage_handler;
import disk_usage : disk_usage_handler;
import cpu_usage : cpu_usage_handler, cpu_usage_thread;

string function(event)[string] handlers;
string function(event) bad_block = (event) {
    throw new Exception("");
};

void main() {
    handlers["uptime"] = &uptime_handler;
    handlers["datetime"] = &datetime_handler;
    handlers["cpu_usage"] = &cpu_usage_handler;
    handlers["core_temp"] = &core_temp_handler;
    handlers["mem_usage"] = &mem_usage_handler;
    handlers["disk_usage"] = &disk_usage_handler;
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
            conn.write(fn(cast(event) ev));
        }
        catch(Exception e) {
        writeln(e);
            conn.write("No blocklet!");
        }
        conn.finalize();
    }, "0.0.0.0");
    runEventLoop();
}
