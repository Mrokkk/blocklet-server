module utils;

import std.math : abs;
import std.format : format;

string human_readable_size(float num) {
    foreach (unit; ["", "M", "G", "T"]) {
        if (abs(num) < 1024.0) {
            return "%3.1f%s".format(num, unit);
        }
        num /= 1024.0;
    }
    return "%.1f%s".format(num, "Pi");
}
