module config;

import std.conv;
import std.stdio;
import std.file : readText;
import std.json : JSONValue, parseJSON;

ushort PORT = 20000;

class config {

    private JSONValue json_;

    this(string path) {
        json_ = path.readText().parseJSON();
    }

    bool show_label(string block_name) {
        return json_["blocks"][block_name]["show_label"].to!string == "true";
    }

    string color(string block_name) {
        return json_["blocks"][block_name]["color"].str;
    }

}
