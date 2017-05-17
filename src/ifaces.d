module ifaces;

import std.stdio;
import std.conv : to;
import std.format : format;
import std.socket;

import event : event;
import config : config;
import formatter : formatter;

struct sockaddr {
    ushort sa_family;
    ubyte[14] sa_data;
}

struct ifaddrs {
    ifaddrs* ifa_next;    /* Next item in list */
    char* ifa_name;    /* Name of interface */
    uint ifa_flags;   /* Flags from SIOCGIFFLAGS */
    sockaddr* ifa_addr;    /* Address of interface */
    sockaddr* ifa_netmask; /* Netmask of interface */
    void* ifa_ifu;
    void* ifa_data;    /* Address-specific data */
};

extern (C) int getifaddrs(ifaddrs **ifap);
extern (C) void freeifaddrs(ifaddrs *ifa);

string ifaces_handler(event, config) {
    ifaddrs* ifaces = null;
    getifaddrs(&ifaces);
    ifaddrs* temp = ifaces;
    while (ifaces.ifa_next != cast(ifaddrs*)0) {
        if (ifaces.ifa_addr.sa_family is AddressFamily.INET) {
            writeln("%s".format(ifaces.ifa_name.to!string));
        }
        ifaces = ifaces.ifa_next;
    }
    freeifaddrs(temp);
    return "";
}
