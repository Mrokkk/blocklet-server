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

    block_layout add_label(string label, colors color = colors.normal) {
        elements_ ~= layout_element(label, [modifiers.small_font], color);
        return this;
    }

    block_layout add_value(string label, colors color = colors.normal) {
        elements_ ~= layout_element(label, [], color);
        return this;
    }

    @property
    layout_element[] get() {
        return elements_;
    }

    /// Can add elements
    unittest {
        import dunit;
        auto b = new block_layout;
        b.add_title("title");
        b.get.length.assertEquals(1);
        b.get[0].value.assertEquals("title");
        b.get[0].color.assertEquals(colors.normal);
        b.add_label("label");
        b.get.length.assertEquals(2);
        b.get[1].value.assertEquals("label");
        b.get[1].color.assertEquals(colors.normal);
        b.add_value("value");
        b.get.length.assertEquals(3);
        b.get[2].value.assertEquals("value");
        b.get[2].color.assertEquals(colors.normal);
    }

}

class formatter {

    private string string_;
    private string default_color_;

    private this(string c) {
        default_color_ = c;
        string_ = "| <span color=\"%s\">".format(c);
    }

    this(block_layout layout, string default_color) {
        default_color_ = default_color;
        string_ = "| <span color=\"%s\">".format(default_color_);
        foreach (elem; layout.get) {
            if (elem.color != colors.normal) {
                set_color(color_to_string(elem.color));
            }
            add_value(elem.value, elem.mods);
            if (elem.color != colors.normal) {
                set_color(default_color_);
            }
        }
    }

    private static string color_to_string(colors c, string default_color = "") {
        switch (c) {
            case colors.normal:
                return default_color;
            default:
                return to!string(c);
        }
    }

    private formatter set_color(string color) {
        string_ ~= "</span><span color=\"%s\">".format(color);
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

    /// Can add elements
    unittest {
        import dunit;
        auto f = new formatter("color");
        f.get.assertEquals("| <span color=\"color\"></span>");
        f.add_value("val1");
        f.get.assertEquals("| <span color=\"color\">val1 </span>");
        f.add_value("val2");
        f.get.assertEquals("| <span color=\"color\">val1 val2 </span>");
        f.add_value("val3", [modifiers.small_font]);
        f.get.assertEquals("| <span color=\"color\">val1 val2 <small>val3</small> </span>");
        f.add_value("val4", [modifiers.bold]);
        f.get.assertEquals("| <span color=\"color\">val1 val2 <small>val3</small> <b>val4</b> </span>");
    }

    /// color_to_string works
    unittest {
        import dunit;
        color_to_string(colors.normal, "color").assertEquals("color");
        color_to_string(colors.red, "color").assertEquals("red");
        color_to_string(colors.yellow, "color").assertEquals("yellow");
    }

}

/// formatter can parse block_layout
unittest {
    import dunit;
    auto b = new block_layout;
    b.add_title("title").add_label("label").add_value("12");
    auto f = new formatter(b, "def_color");
    f.get.assertEquals("| <span color=\"def_color\"><b>title</b> <small>label</small> 12 </span>");
}
