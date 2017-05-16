module tcp_protocol;

import std.conv : to;
import std.stdio : writeln;
import std.format : format;
import asynchronous : Protocol, Transport, BaseTransport;

string function()[string] handlers;
string function() bad_block = () {
    throw new Exception("");
};

class tcp_protocol : Protocol {

    private Transport transport_;

    void dataReceived(const(void)[] data) {
        try {
            auto fn = handlers.get(cast(string) data, bad_block);
            auto output = fn();
            //writeln("Sending block: %s".format(cast(string) data));
            this.transport_.write(output);
        }
        catch(Exception e) {
            this.transport_.write("No blocklet!");
        }
    }

    bool eofReceived() {
        return false;
    }

    void connectionLost(Exception exception) {
        this.transport_.writeEof();
        this.transport_.close();
    }

    void connectionMade(BaseTransport transport) {
        this.transport_ = cast(Transport) transport;
    }

    void pauseWriting() {
    }

    void resumeWriting() {
    }

}
