package objects;

// class for lerping
class AtlasTextGroup extends FlxTypedGroup<AtlasText>
{
	public var range:FlxPoint = FlxPoint.get(20, 120);
	public var selected:Int = 0;

	public var selectedText(get, never):AtlasText;

	private var _startX:Float = 0.0;

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
				if (i == 0)
					_startX = text.x;

				text.ID = i;

				add(text);

				if (factory != null)
					factory(text);

				i++;
			}
		}
	}

	override public function update(elapsed:Float)
	{
		forEach((text) ->
		{
			var lerpValue:Float = FlxMath.bound(Math.exp(-elapsed * 9.6), 0, 1);

			text.x = FlxMath.lerp(((text.ID - selected) * range.x) + _startX, text.x, lerpValue);
			text.y = FlxMath.lerp(((text.ID - selected) * 1.3 * range.y) + ((FlxG.height / 2) - (text.height / 2)), text.y, lerpValue);
		});

		super.update(elapsed);
	}

	function get_selectedText():AtlasText
	{
		return members[selected];
	}
}
