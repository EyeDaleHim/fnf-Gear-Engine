package states.internal;

class MainSubstate extends FlxSubState
{
    public var conductor(get, never):Conductor;

    function get_conductor():Conductor
        return Conductor.instance;
}