module formatter;

import std.conv : to;
import std.format : format;

class formatter {

    enum modifiers {
        none,
        small_font
    }

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

    formatter add_value(T)(T value, modifiers[] mods = []) {
        auto value_string = value.to!string;
        foreach (mod; mods) {
            if (mod == modifiers.small_font) {
                value_string = "<small>" ~ value_string ~ "</small>";
            }
        }
        string_ ~= value_string ~ " ";
        return this;
    }

    string get() {
        return string_ ~ "</span>";
    }

}
