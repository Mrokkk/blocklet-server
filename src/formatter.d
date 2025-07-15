module formatter;

import std.conv : to;
import std.format : format;
import std.typecons : Tuple, tuple;

enum Modifiers
{
    none,
    smallFont,
    bold
}

enum Colors
{
    normal,
    white,
    yellow,
    red,
    brown,
    green,
}

class BlockLayout
{
    private struct LayoutElement
    {
        string value;
        Modifiers[] mods;
        Colors color;
    }

    BlockLayout addTitle(string title) nothrow
    {
        elements_ ~= LayoutElement(title, [Modifiers.bold], Colors.normal);
        return this;
    }

    BlockLayout addLabel(string label, Colors color = Colors.normal) nothrow
    {
        elements_ ~= LayoutElement(label, [Modifiers.smallFont], color);
        return this;
    }

    BlockLayout addValue(string label, Colors color = Colors.normal) nothrow
    {
        elements_ ~= LayoutElement(label, [], color);
        return this;
    }

    @property
    LayoutElement[] get() @safe nothrow
    {
        return elements_;
    }

    /// Can add elements
    unittest
    {
        import dunit;
        auto b = new BlockLayout;
        b.addTitle("title");
        b.get.length.assertEquals(1);
        b.get[0].value.assertEquals("title");
        b.get[0].color.assertEquals(Colors.normal);
        b.addLabel("label");
        b.get.length.assertEquals(2);
        b.get[1].value.assertEquals("label");
        b.get[1].color.assertEquals(Colors.normal);
        b.addValue("value");
        b.get.length.assertEquals(3);
        b.get[2].value.assertEquals("value");
        b.get[2].color.assertEquals(Colors.normal);
    }

    private LayoutElement[] elements_;
}

class Formatter
{
    private this(string c)
    {
        defaultColor_ = c;
        string_ = "<span color=\"gray\">|</span> <span color=\"%s\">".format(c);
    }

    this(BlockLayout layout, string defaultColor)
    {
        defaultColor_ = defaultColor;
        string_ = "<span color=\"gray\">|</span> <span color=\"%s\">".format(defaultColor_);
        foreach (elem; layout.get)
        {
            if (elem.color != Colors.normal)
            {
                setColor(colorToString(elem.color));
            }
            addValue(elem.value, elem.mods);
            if (elem.color != Colors.normal)
            {
                setColor(defaultColor_);
            }
        }
    }

    private static string colorToString(Colors c, string defaultColor = "")
    {
        switch (c)
        {
            case Colors.normal:
                return defaultColor;
            default:
                return to!string(c);
        }
    }

    private Formatter setColor(string color)
    {
        string_ ~= "</span><span color=\"%s\">".format(color);
        return this;
    }

    Formatter addValue(T)(T value, Modifiers[] mods = [])
    {
        auto valueString = value.to!string;
        foreach (mod; mods)
        {
            if (mod == Modifiers.smallFont)
            {
                valueString = "<small>" ~ valueString ~ "</small>";
            }
            else if (mod == Modifiers.bold)
            {
                valueString = "<b>" ~ valueString ~ "</b>";
            }
        }
        string_ ~= valueString ~ " ";
        return this;
    }

    @property
    string get() @safe nothrow
    {
        return string_ ~ "</span>";
    }

    /// Can add elements
    unittest
    {
        import dunit;
        auto f = new Formatter("color");
        f.get.assertEquals("<span color=\"gray\">|</span> <span color=\"color\"></span>");
        f.addValue("val1");
        f.get.assertEquals("<span color=\"gray\">|</span> <span color=\"color\">val1 </span>");
        f.addValue("val2");
        f.get.assertEquals("<span color=\"gray\">|</span> <span color=\"color\">val1 val2 </span>");
        f.addValue("val3", [Modifiers.smallFont]);
        f.get.assertEquals("<span color=\"gray\">|</span> <span color=\"color\">val1 val2 <small>val3</small> </span>");
        f.addValue("val4", [Modifiers.bold]);
        f.get.assertEquals("<span color=\"gray\">|</span> <span color=\"color\">val1 val2 <small>val3</small> <b>val4</b> </span>");
    }

    /// colorToString works
    unittest
    {
        import dunit;
        colorToString(Colors.normal, "color").assertEquals("color");
        colorToString(Colors.red, "color").assertEquals("red");
        colorToString(Colors.yellow, "color").assertEquals("yellow");
    }

    private string string_;
    private string defaultColor_;
}

/// Formatter can parse BlockLayout
unittest
{
    import dunit;
    auto b = new BlockLayout;
    b.addTitle("title").addLabel("label").addValue("12");
    auto f = new Formatter(b, "def_color");
    f.get.assertEquals("<span color=\"gray\">|</span> <span color=\"def_color\"><b>title</b> <small>label</small> 12 </span>");
}
