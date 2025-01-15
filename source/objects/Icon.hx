package objects;

class Icon extends FlxSprite
{
	public static var gameplayPath:String = "ui/icons";
	public static var freeplayPath:String = "menus/freeplayicons";

	public var name:String = "";

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
			scale.x -= elapsed * changeScaleSpeed;
			scale.y -= elapsed * changeScaleSpeed;
			scale.set(Math.max(scale.x, targetScale.x), Math.max(scale.y, targetScale.y));
			updateHitbox();
		}
	}

	public function changeIcon(path:String, name:String):Void
	{
		var completePath:String = Path.join([path, name]);

		if (Assets.frames(completePath) == null)
		{
			var graphic:FlxGraphic = Assets.image(completePath);
			loadGraphic(graphic, true, Math.min(graphic.width, graphic.height).floor(), Math.min(graphic.width, graphic.height).floor());
		}
		else
			frames = Assets.frames(completePath);

		this.name = name;
	}
}
