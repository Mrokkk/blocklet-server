module formatter;

import std.conv : to;
import std.format : format;

class formatter {

    private string string_;

    this(string default_color) {
        string_ = "| <span color=\"%s\">".format(default_color);
    }

    formatter set_color(string color) {
        string_ ~= "</span><span color=\"%s\">".format(color);
        return this;
    }

    formatter add_label(string label) {
        string_ ~= "<b>%s</b> ".format(label);
        return this;
    }

    formatter add_value(T)(T value) {
        string_ ~= value.to!string() ~ " ";
        return this;
    }

    string get() {
        return string_ ~ "</span>";
    }

}
