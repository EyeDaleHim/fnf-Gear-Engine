package objects;

// class for lerping
class AtlasTextGroup extends FlxTypedGroup<AtlasText>
{
	public var range:FlxPoint = FlxPoint.get(20, 120);

	private var _startPositions:Array<FlxPoint> = [];

	public function new(list:Array<String>, ?factory:AtlasText->Void)
	{
		super();

		if (list != null)
		{
			var i:Int = 0;
			for (item in list)
			{
				var text:AtlasText = new AtlasText(90, 320, item);
				text.setPosition(text.x + (range.x * i), text.y + (range.y * i));
				add(text);
				if (factory != null)
					factory(text);

				i++;
			}
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
