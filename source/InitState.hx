package;

class InitState extends FlxState
{
    override function create()
    {
        #if MENU
        #else
        FlxG.switchState(()->new PageState('menu'));
        #end
    }
}