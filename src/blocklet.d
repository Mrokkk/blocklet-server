module blocklet;

import formatter : formatter;

enum event {
    none = 0,
    left_click = 1,
    middle_click = 2,
    right_click = 3,
    scroll_up = 4,
    scroll_down = 5
}

interface blocklet {
    void call(formatter);
    void handle_event(event);
}
