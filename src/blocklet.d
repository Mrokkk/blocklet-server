module blocklet;

import event : event;

interface blocklet {
    string name();
    string call(event);
}
