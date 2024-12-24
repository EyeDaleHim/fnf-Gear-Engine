package objects.play;

import objects.notes.Strumline;

class PlayField extends FlxGroup
{
    public var tweenManager:FlxTweenManager;
	public var timerManager:FlxTimerManager;

    public var countdown:Countdown;
    public var strumlines:Array<Strumline> = [];

    public function new(?tweenManager:FlxTweenManager, ?timerManager:FlxTimerManager, strums:Int = 2)
    {
        super();

        this.tweenManager = tweenManager;
        this.timerManager;

        countdown = new Countdown(tweenManager, timerManager);
        add(countdown);

        for (i in 0...strums)
        {
            createStrum(4, i, (FlxG.width / 2) * i, 50.0);
        }
    }

    public function createStrum(notes:Int = 4, index:Int, gap:Float, y:Float = 0.0):Void
    {
        var strumline:Strumline = new Strumline(notes, index, gap, y);
        add(strumline);
        strumlines.push(strumline);
    }
}