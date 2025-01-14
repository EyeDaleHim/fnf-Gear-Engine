package substates;

class PauseSubstate extends MainSubstate
{

    
    public var background:FlxSprite;

    public function new()
    {
        super();

        background = new FlxSprite();
    }
}