package utils.helpers;

import flixel.util.FlxTimer.FlxTimerManager;

abstract TimerManager(FlxTimerManager) from FlxTimerManager to FlxTimerManager
{
    public function new()
    {
        this = new FlxTimerManager();
    }
    
	public function start(time:Float, onComplete:() -> Void):FlxTimer
	{
		var tmr = FlxTimer.wait(time, onComplete);
		tmr.manager = this;
		return tmr;
	}

	public function loop(time:Float, onComplete:(loop:Int) -> Void, loops:Int):FlxTimer
	{
		var tmr = FlxTimer.loop(time, onComplete, loops);
		tmr.manager = this;
		return tmr;
	}
}
