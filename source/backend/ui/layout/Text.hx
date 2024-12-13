package backend.ui.layout;

import backend.ui.layout.Container;

class Text extends Container
{
	public var textObject:FlxText;

	public var text(get, set):String;

	public function new(x:Float = 0, y:Float = 0, fieldWidth:Float = 0, ?text:String, size:Int = 8, embeddedFont:Bool = true)
	{
		textObject = new FlxText(x, y, fieldWidth, text, size, embeddedFont);

		super(x, y, textObject.width.floor(), textObject.height.floor());
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (textObject.exists && textObject.active)
			textObject.update(elapsed);
	}

	override function draw()
	{
		if (textObject.exists && textObject.visible)
		{
			@:privateAccess
			textObject.regenGraphic();

			loadGraphic(textObject.graphic);
			super.draw();
		}
	}

	override function initialize()
	{
		moves = false;
		acceptsChildren = false;
	}

	override public function setPosition(x = 0.0, y = 0.0):Void
	{
		textObject.setPosition(x, y);
		return super.setPosition(x, y);
	}

	override function set_x(value:Float):Float
	{
		textObject.x = value;
		return super.set_x(value);
	}

	override function set_y(value:Float):Float
	{
		textObject.y = value;
		return super.set_y(value);
	}

	function get_text():String
	{
		return textObject.text;
	}

	function set_text(text:String):String
	{
		textObject.text = text;
		setSize(textObject.width, textObject.height);
		return textObject.text;
	}
}
