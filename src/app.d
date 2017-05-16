import core.thread : Thread;

import asynchronous : Queue, getEventLoop;

import tcp_protocol : tcp_protocol, handlers;
import uptime : uptime_handler;
import datetime : datetime_handler;
import core_temp : core_temp_handler;
import mem_usage : mem_usage_handler;
import cpu_usage : cpu_usage_handler, cpu_usage_thread;

import config : PORT, TEMPLATE, powerline_look;

void main() {
    handlers["uptime"] = &uptime_handler;
    handlers["datetime"] = &datetime_handler;
    handlers["cpu_usage"] = &cpu_usage_handler;
    handlers["core_temp"] = &core_temp_handler;
    handlers["mem_usage"] = &mem_usage_handler;
    auto th = new Thread(&cpu_usage_thread).start();
    auto loop = getEventLoop;
    auto server = loop.createServer(() => new tcp_protocol, "localhost", PORT);
    loop.runForever;
}
