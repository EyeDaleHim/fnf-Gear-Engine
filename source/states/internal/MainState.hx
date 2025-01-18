package states.internal;

class MainState extends FlxState
{
    public static var debugMode:Bool = #if debug true #else false #end;

    public var conductor(get, never):Conductor;

    function get_conductor():Conductor
        return Conductor.instance;

    public function new()
    {
        super();
        FlxG.fixedTimestep = false;
    }

    override function create()
    {
        Transition.instance.transitionOut();
    }

    override public function update(elapsed:Float)
    {
        if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.O)
        {
            debugMode = !debugMode;
            trace('debug mode is $debugMode!');
        }

        super.update(elapsed);
    }

    override function startOutro(onOutroComplete:Void->Void)
    {
        Transition.instance.transitionIn(onOutroComplete);
    }
}