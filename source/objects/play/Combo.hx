package objects.play;

class Combo extends FlxGroup
{
	public static final comboPath:String = 'ui/game/combo';

	public var tweenManager:FlxTweenManager;
	public var timerManager:TimerManager;

	public var comboList:FlxTypedGroup<FlxSprite>;
	public var ratingList:FlxTypedGroup<FlxSprite>;

	public function new(?tweenManager:FlxTweenManager, ?timerManager:TimerManager)
	{
		super();

		this.tweenManager = tweenManager ?? FlxTween.globalManager;
		this.timerManager = timerManager ?? FlxTimer.globalManager;

		comboList = new FlxTypedGroup<FlxSprite>();
		ratingList = new FlxTypedGroup<FlxSprite>();

		add(ratingList);
		add(comboList);
	}

	public function spawnObject(group:FlxTypedGroup<FlxSprite>, graphic:FlxGraphic, x:Float = 0.0, y:Float = 0.0, lifeTime:Float = 2.0,
			fadeTime:Float = 0.5):FlxSprite
	{
		if (group == null)
			return null;

		var obj:FlxSprite = group.recycle(FlxSprite);
		obj.loadGraphic(graphic);
		obj.scale.set(0.7, 0.7);
		obj.updateHitbox();
		obj.velocity.set();
		obj.acceleration.set();
		obj.alpha = 1.0;
		obj.setPosition(x, y);

		timerManager.start(lifeTime, () ->
		{
			tweenManager.tween(obj, {alpha: 0.0}, fadeTime, {
				onComplete: (_) -> 
				{
					obj.kill();
				}
			});
		});

		group.remove(obj, true);
		group.add(obj);

		return obj;
	}
}
