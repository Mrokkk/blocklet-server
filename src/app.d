import std.conv : to;
import std.array : split;
import std.stdio : writeln;
import std.file : readText;
import std.datetime : msecs;
import std.functional : toDelegate;

import asynchronous;

void main() {

    auto loop = getEventLoop();

    @Coroutine
    void coro1() {
        auto uptime = to!float("/proc/uptime".readText().split()[0]);
        writeln(uptime);
        auto loop = getEventLoop();
        auto uptime_reader = loop.time;
        loop.callAt(uptime_reader + 20000.msecs, &coro1);
    }

    @Coroutine
    void tcp_server(StreamReader reader, StreamWriter writer) {
        writeln("Hello!");
    }

    auto uptime_reader = ensureFuture(loop, &coro1);
    auto server = loop.startServer((&tcp_server).toDelegate, "localhost", "20000");
    loop.runForever;

}
