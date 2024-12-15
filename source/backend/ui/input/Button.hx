package backend.ui.input;

import backend.ui.layout.Box;
import backend.ui.layout.Text;

class Button extends Box
{
	public var pressCallback:FlxSignal;
	public var holdCallback:FlxSignal;
	public var hoverCallback:FlxSignal;
	public var releaseCallback:FlxSignal;

	public var originalColor:FlxColor = 0xFFFFFFFF;
	public var pressColor:FlxColor = 0xFFA5A5A5;
	public var hoverColor:FlxColor = 0xFFE6E6E6;

	public var textOnly:Bool = false;

	public var text(get, set):String;

	public var buttonText:Text;

	public function new(?x:Float = 0.0, ?y:Float = 0.0, width:Int = 24, height:Int = 24, ?cornerSize:Int = 4, ?quality:Int = 1, ?text:String)
	{
		super(x, y, width, height, cornerSize, quality);

		if (text != null)
			this.text = text;

		pressCallback = new FlxSignal();
		holdCallback = new FlxSignal();
		hoverCallback = new FlxSignal();
		releaseCallback = new FlxSignal();
	}

	private var isHovered:Bool = false;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (buttonText != null && text.length > 0)
			buttonText.update(elapsed);

		if (mouseOverlaps(camera))
		{
			if (!isHovered)
			{
				isHovered = true;
				onHover();
			}

			if (FlxG.mouse.justReleased)
				onRelease();

			if (FlxG.mouse.pressed)
			{
				onHold();
				if (FlxG.mouse.justPressed)
					onPress();
			}
		}
		else
		{
			isHovered = false;
			color = originalColor;
		}
	}

	public function onPress():Void
	{
		pressCallback.dispatch();
		color = pressColor;
	}

	public function onHold():Void
	{
		holdCallback.dispatch();
	}

	public function onRelease():Void
	{
		releaseCallback.dispatch();
		color = hoverColor;
	}

	public function onHover():Void
	{
		hoverCallback.dispatch();
		color = hoverColor;
	}

	override public function draw()
	{
		if (!textOnly)
			super.draw();
		if (buttonText != null && text.length > 0)
			buttonText.draw();
	}

	private function createText():Void
	{
		buttonText = new Text();
		buttonText.parent = this;
		buttonText.color = FlxColor.BLACK;
	}

	function get_text():String
	{
		if (buttonText == null)
			return "";

		return buttonText.text;
	}

	function set_text(newText:String):String
	{
		if (buttonText == null)
			createText();

		buttonText.text = newText;

		if (cornerSize == 0)
			makeGraphic(buttonText.width.floor(), buttonText.height.floor(), FlxColor.WHITE);
		else if (cornerGraphics.defaultCorner == null
			&& cornerGraphics.topLeft == null
			&& cornerGraphics.topRight == null
			&& cornerGraphics.bottomLeft == null
			&& cornerGraphics.bottomRight == null)
			makeGraphic(24, 24, FlxColor.WHITE);
		else
			setSize(buttonText.width, buttonText.height);

		return newText;
	}
}
