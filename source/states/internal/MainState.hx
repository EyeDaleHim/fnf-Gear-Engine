package states.internal;

class MainState extends FlxState
{
    public function new()
    {
        super();
        FlxG.fixedTimestep = true;
    }

    override function create()
    {
        Transition.instance.transitionOut();
    }
}