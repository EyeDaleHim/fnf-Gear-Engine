package substates.editors;

class ChartConvertSubstate extends MainSubstate
{
    public var background:FlxSprite;

    public function new(list:Array<String>)
    {
        super();

        trace(list);

        close();
        FlxG.state.persistentUpdate = true;
    }
}