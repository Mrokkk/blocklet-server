module tcp_protocol;

import std.conv : to;
import std.stdio : writeln;
import std.format : format;
import asynchronous : Protocol, Queue, Transport, BaseTransport;

string function()[string] handlers;
string function() bad_block = () {
    throw new Exception("");
};

class tcp_protocol : Protocol {

    private Queue!string input_, output_;
    private Transport transport_;

    this(ref Queue!string input, ref Queue!string output) {
        input_ = input;
        output_ = output;
    }

    void dataReceived(const(void)[] data) {
        try {
            auto fn = handlers.get(cast(string) data, bad_block);
            auto output = fn();
            writeln("Sending block: %s".format(cast(string) data));
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
    }

    void connectionMade(BaseTransport transport) {
        this.transport_ = cast(Transport) transport;
    }

    void pauseWriting() {
    }

    void resumeWriting() {
    }

}
