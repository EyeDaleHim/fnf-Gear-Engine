package objects;

class Icon extends FlxSprite
{
	public static var gameplayPath:String = "ui/icons";
	public static var freeplayPath:String = "menus/freeplayicons";

	public var changeScale:Bool = false;
	public var targetScale:FlxPoint = FlxPoint.get(1.0, 1.0);
	public var changeScaleSpeed:Float = 1.0;

	public function new(path:String, name:String)
	{
		super();

        changeIcon(path, name);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (changeScale)
		{
			var scaleLerp:Float = FlxMath.bound(elapsed * 9 * changeScaleSpeed, 0, 1);
			scale.set(FlxMath.lerp(scale.x, targetScale.x, scaleLerp), FlxMath.lerp(scale.y, targetScale.y, scaleLerp));
            updateHitbox();
		}
	}

    public function changeIcon(path:String, name:String):Void
    {
        var completePath:String = Path.join([path, name]);

		if (Assets.frames(completePath) == null)
			loadGraphic(Assets.image(completePath));
		else
			frames = Assets.frames(completePath);
    }
}
