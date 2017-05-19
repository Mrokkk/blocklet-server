module utils;

import std.math : abs;
import std.format : format;

string human_readable_size(float num) {
    foreach (unit; ["K", "M", "G", "T"]) {
        if (abs(num) < 1024.0) {
            return "%3.1f%s".format(num, unit);
        }
        num /= 1024.0;
    }
    return "%.1f%s".format(num, "P");
}

/// Can convert sizes in kB to human readable forms
unittest {
    import dunit;
    human_readable_size(1024.0).assertEquals("1.0M");
    human_readable_size(2050.0).assertEquals("2.0M");
    human_readable_size(128).assertEquals("128.0K");
    human_readable_size(1024*1024).assertEquals("1.0G");
    human_readable_size(1024*1024*1024).assertEquals("1.0T");
}
