import core.thread : Thread;

import std.stdio;
import uptime : uptime_handler;
import datetime : datetime_handler;
import core_temp : core_temp_handler;
import mem_usage : mem_usage_handler;
import cpu_usage : cpu_usage_handler, cpu_usage_thread;

import vibe.d : listenTCP, runEventLoop, disableDefaultSignalHandlers;

import config : PORT, TEMPLATE, powerline_look;

string function()[string] handlers;
string function() bad_block = () {
    throw new Exception("");
};

void main() {
    handlers["uptime"] = &uptime_handler;
    handlers["datetime"] = &datetime_handler;
    handlers["cpu_usage"] = &cpu_usage_handler;
    handlers["core_temp"] = &core_temp_handler;
    handlers["mem_usage"] = &mem_usage_handler;
    auto th = new Thread(&cpu_usage_thread).start();
    disableDefaultSignalHandlers();
    auto server = listenTCP(PORT, (conn) {
        conn.waitForData();
        auto data = new ubyte[conn.leastSize];
        conn.read(data);
        try {
            auto fn = handlers.get(cast(string) data, bad_block);
            conn.write(fn());
        }
        catch(Exception e) {
            conn.write("No blocklet!");
        }
        conn.finalize();
    }, "0.0.0.0");
    runEventLoop();
}
