module blocklet;

import event : event;
import formatter : formatter;

interface blocklet {
    void call(formatter);
    void handle_event(event);
}
