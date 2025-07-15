module disk;

import std.conv : to;
import std.format : format;

import blocklet : Blocklet, Event;
import formatter : BlockLayout;
import utils : humanReadableSize;

class Disk : Blocklet
{
    override void call(BlockLayout f)
    {
        f.addLabel("FREE")
         .addValue(humanReadableSize(getFreeSpace()));
    }
}

version (FreeBSD)
{

import core.sys.freebsd.sys.mount;

private ulong getFreeSpace()
{
    auto data = new statfs_t;
    statfs("/", data);
    return data.f_bavail * data.f_bsize;
}

} // FreeBSD

version (linux)
{

import core.sys.posix.sys.statvfs;

private ulong getFreeSpace()
{
    auto data = new statvfs_t;
    statvfs("/", data);
    return data.f_bfree * data.f_bsize;
}

} // linux
