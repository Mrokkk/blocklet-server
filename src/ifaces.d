module ifaces;

import std.conv : to;
import std.format : format;
import std.socket : AddressFamily;

import event : event;
import blocklet : blocklet;
import formatter : formatter;

struct sockaddr {
    uint sa_family;
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

class ifaces : blocklet {

    void call(formatter f) {
        ifaddrs* ifaces = null;
        getifaddrs(&ifaces);
        ifaddrs* temp = ifaces;
        while (ifaces.ifa_next != cast(ifaddrs*)0) {
            if (ifaces.ifa_addr.sa_family is AddressFamily.INET) {
                auto iface_name = ifaces.ifa_name.to!string;
                if (iface_name != "lo") {
                    f.add_value("%s: %d.%d.%d.%d".format(
                        ifaces.ifa_name.to!string,
                        ifaces.ifa_addr.sa_data[0],
                        ifaces.ifa_addr.sa_data[1],
                        ifaces.ifa_addr.sa_data[2],
                        ifaces.ifa_addr.sa_data[3]));
                }
            }
            ifaces = ifaces.ifa_next;
        }
        freeifaddrs(temp);
    }

    void handle_event(event) {
    }

}
