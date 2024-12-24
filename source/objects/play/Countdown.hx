package objects.play;

class Countdown extends FlxTypedGroup<FlxSprite>
{
	// Assets.image(graphicPath)
	public static final graphicPath:String = 'ui/game/countdown/';
	public static final soundPath:String = 'sfx/countdown/';

	public var graphicList:Array<String> = ["", "two", "one", "go"];
	public var soundList:Array<String> = ["three", "two", "one", "go"];

	public var tweenManager:FlxTweenManager;
	public var timerManager:FlxTimerManager;

	private var list:Array<FlxSprite> = [];

	public function new(tweenManager:FlxTweenManager, timerManager:FlxTimerManager, ?graphicList:Array<String>, ?soundList:Array<String>)
	{
		super();

		this.graphicList = graphicList ?? this.graphicList;
		this.soundList = soundList ?? this.soundList;

		var len:Int = Math.max(this.graphicList.length, this.soundList.length).floor();

		for (i in 0...len)
		{
			var graphic:String = this.graphicList[i];
			var sound:String = this.soundList[i];

			if (graphic?.length > 0)
			{
				var spr:FlxSprite = new FlxSprite();
				spr.loadGraphic(Assets.image(graphicPath + graphic));
				spr.scale.set(0.8, 0.8);
				spr.updateHitbox();
				spr.screenCenter();

				spr.kill();
				add(spr);
				list[i] = spr;
			}

			Assets.sound(soundPath + sound);
		}
	}

	public function start(interval:Float = 0.5, ?finishCallback:Void->Void)
	{
		timerManager ??= FlxTimer.globalManager;
		tweenManager ??= FlxTween.globalManager;

		var playSound:Int->Void = (index:Int) ->
		{
			if (soundList[index] != null && soundList[index].length > 0)
				FlxG.sound.play(Assets.sound(soundPath + soundList[index]));
		};

		var playGraphic:Int->Void = (index:Int) ->
		{
			var spr:FlxSprite = list[index];

			if (spr != null)
			{
				spr.revive();
				spr.alpha = 1.0;
				tweenManager.tween(spr, {alpha: 0.0}, interval, {ease: FlxEase.cubeInOut});
			}
		};

		var len:Int = Math.max(graphicList.length, soundList.length).floor() + 1;
		var tmr = FlxTimer.loop(interval, (index:Int) ->
		{
			if (index == len)
			{
				if (finishCallback != null)
					finishCallback();
			}
			else
			{
				playSound(index - 1);
				playGraphic(index - 1);
			}
		}, len);
		tmr.manager = timerManager;
	}
}
