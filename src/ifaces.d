module ifaces;

import std.conv : to;
import std.format : format;
import std.socket : AddressFamily;

import formatter : block_layout;
import blocklet : blocklet, event;

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

    private void add_interface(block_layout b, ifaddrs *iface) {
        if (iface.ifa_addr.sa_family != AddressFamily.INET) {
            return;
        }
        auto iface_name = iface.ifa_name.to!string;
        if (iface_name != "lo") {
            b.add_value("%s: %d.%d.%d.%d".format(
                iface.ifa_name.to!string,
                iface.ifa_addr.sa_data[0],
                iface.ifa_addr.sa_data[1],
                iface.ifa_addr.sa_data[2],
                iface.ifa_addr.sa_data[3]));
        }
    }

    void call(block_layout b) {
        ifaddrs* ifaces = null;
        getifaddrs(&ifaces);
        ifaddrs* temp = ifaces;
        while (ifaces.ifa_next != cast(ifaddrs*)0) {
            add_interface(b, ifaces);
            ifaces = ifaces.ifa_next;
        }
        freeifaddrs(temp);
    }

    void handle_event(event) {
    }

}
