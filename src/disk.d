module disk;

import std.conv : to;
import std.format : format;

import formatter : block_layout;
import blocklet : blocklet, event;
import utils : human_readable_size;

class disk : blocklet
{
    void call(block_layout f)
    {
        version (FreeBSD)
        {
            import core.sys.freebsd.sys.mount;
            auto data = new statfs_t;
            statfs("/", data);
            f.add_label("FREE")
             .add_value(human_readable_size((data.f_bavail * data.f_bsize / 1024).to!float));
        }
        else
        {
            // TODO
        }
    }

    void handle_event(event)
    {
    }
}
