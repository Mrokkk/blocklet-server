module client;

import std.conv;
import std.stdio;
import std.socket;
import std.process : environment;
import std.format : format;

import config;

void main()
{
    writeln("OK");
    auto block_name = environment.get("BLOCK_NAME");
    if (block_name is null)
    {
        writeln("No blocklet name!");
        return;
    }
    auto event_str = environment.get("BLOCK_BUTTON");
    int event = event_str is null ? 0 : event_str.to!int;
    auto sock = new Socket(AddressFamily.INET, SocketType.STREAM);
    ubyte[1024] data;
    try
    {
        sock.connect(new InternetAddress("127.0.0.1", PORT));
        sock.send("%s %d".format(block_name, event));
        sock.receive(data);
    }
    catch (Exception exc)
    {
        writeln(exc.msg);
    }
    writeln(cast(string) data);
}
