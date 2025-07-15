module utils;

import std.format : format;
import std.math : abs;

string humanReadableSize(float num) @safe
{
    foreach (const unit; ["", "K", "M", "G", "T"])
    {
        if (abs(num) < 1024.0)
        {
            return "%3.1f%s".format(num, unit);
        }
        num /= 1024.0;
    }
    return "%.1f%s".format(num, "P");
}

/// Can convert sizes in kB to human readable forms
unittest
{
    import dunit;
    humanReadableSize(1024.0).assertEquals("1.0K");
    humanReadableSize(2050.0).assertEquals("2.0K");
    humanReadableSize(128).assertEquals("128");
    humanReadableSize(1024*1024).assertEquals("1.0M");
    humanReadableSize(1024*1024*1024).assertEquals("1.0G");
    humanReadableSize(1024*1024*1024*1024).assertEquals("1.0T");
    humanReadableSize(1024*1024*1024*1024*1024).assertEquals("1.0P");
}
