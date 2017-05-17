module disk_usage;

import std.stdio;
import std.conv : to;
import std.math : abs;
import std.format : format;

import event : event;
import blocklet : blocklet;
import formatter : formatter;
import utils : human_readable_size;

struct stat_fs {
    ulong f_type;    /* Type of filesystem (see below) */
    ulong f_bsize;   /* Optimal transfer block size */
    ulong f_blocks;  /* Total data blocks in filesystem */
    ulong f_bfree;   /* Free blocks in filesystem */
    ulong f_bavail;  /* Free blocks available to
                            unprivileged user */
    ulong f_files;   /* Total file nodes in filesystem */
    ulong f_ffree;   /* Free file nodes in filesystem */
    ulong f_fsid;    /* Filesystem ID */
    ulong f_namelen; /* Maximum length of filenames */
    ulong f_frsize;  /* Fragment size (since Linux 2.6) */
    ulong f_flags;   /* Mount flags of filesystem
                            (since Linux 2.6.36) */
};

extern (C) int statfs(const char *path, stat_fs *buf);

class disk_usage : blocklet {

    void call(formatter f) {
        auto data = new stat_fs;
        statfs("/", data);
        f.add_value(human_readable_size((data.f_bavail * data.f_bsize / 1024).to!float));
    }

    void handle_event(event) {
    }

}
