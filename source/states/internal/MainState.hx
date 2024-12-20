package states.internal;

class MainState extends FlxState
{
    public var conductor(get, never):Conductor;

    function get_conductor():Conductor
        return Conductor.instance;

    public function new()
    {
        super();
        FlxG.fixedTimestep = true;
    }

    override function create()
    {
        Transition.instance.transitionOut();
    }

    override function startOutro(onOutroComplete:Void->Void)
    {
        Transition.instance.transitionIn(onOutroComplete);
    }
}