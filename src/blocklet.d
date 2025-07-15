module blocklet;

import formatter : BlockLayout;

enum Event
{
    none = 0,
    leftClick = 1,
    middleClick = 2,
    rightClick = 3,
    scrollUp = 4,
    scrollDown = 5
}

interface IBlocklet
{
    void call(BlockLayout);
    void handleEvent(Event);
}

class Blocklet : IBlocklet
{
    void call(BlockLayout)
    {
    }

    void handleEvent(Event)
    {
    }
}
