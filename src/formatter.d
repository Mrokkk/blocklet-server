module formatter;

import std.conv : to;
import std.format : format;
import std.typecons : Tuple, tuple;

enum modifiers {
    none,
    small_font,
    bold
}

enum colors {
    normal,
    white,
    yellow,
    red,
    brown
}

class block_layout {

    struct layout_element {
        string value;
        modifiers[] mods;
        colors color;
    }

    private layout_element[] elements_;

    block_layout add_title(string title) {
        elements_ ~= layout_element(title, [modifiers.bold], colors.normal);
        return this;
    }

    block_layout add_label(string label) {
        elements_ ~= layout_element(label, [modifiers.small_font], colors.normal);
        return this;
    }

    block_layout add_value(string label) {
        elements_ ~= layout_element(label, [], colors.normal);
        return this;
    }

    @property
    layout_element[] get() {
        return elements_;
    }

}

class formatter {

    private string string_;
    private string default_color_;

    this(string c) {
        default_color_ = c;
        string_ = "| <span color=\"%s\">".format(c);
    }

    this(block_layout layout, string default_color) {
        default_color_ = default_color;
        string_ = "| <span color=\"%s\">".format(default_color_);
        foreach (elem; layout.get) {
            add_value(elem.value, elem.mods);
        }
    }

    string color_to_string(colors c, string default_color = "") {
        switch (c) {
            case colors.normal:
                return default_color;
            default:
                return to!string(c);
        }
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
            else if (mod == modifiers.bold) {
                value_string = "<b>" ~ value_string ~ "</b>";
            }
        }
        string_ ~= value_string ~ " ";
        return this;
    }

    @property
    string get() {
        return string_ ~ "</span>";
    }

    unittest {
        import dunit.ng;
        auto f = new formatter("color");
        f.get.assertEquals("| <span color=\"color\"></span>");
        f.add_label("LABEL");
        f.get.assertEquals("| <span color=\"color\"><b>LABEL</b> </span>");
    }

}
