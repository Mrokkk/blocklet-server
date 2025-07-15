module freebsd;

version (FreeBSD):

import core.sys.freebsd.sys.sysctl;
import std.string : toStringz;

auto readSysctl(T)(string name)
{
    T value = 0;
    size_t len = value.sizeof;
    sysctlbyname(cast(const char*)name.toStringz(), &value, &len, null, 0);
    return value;
}

auto readSysctlArray(T, size_t count)(string name, ref size_t len)
{
    T[count] values;
    len = values.sizeof;
    sysctlbyname(cast(const char*)name.toStringz(), values.ptr, &len, null, 0);
    len /= T.sizeof;
    return values;
}
