package backend.ui.layout;

import backend.ui.layout.Container;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText.FlxTextBorderStyle;

class Text extends Container
{
	public var textObject:FlxText;

	public var font(get, set):String;
	public var text(get, set):String;

	public function new(x:Float = 0, y:Float = 0, fieldWidth:Float = 0, ?text:String, size:Int = 8, embeddedFont:Bool = true)
	{
		textObject = new FlxText(x, y, fieldWidth, text, size, embeddedFont);

		super(x, y, textObject.width.floor(), textObject.height.floor());

		updateTextGraphic();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (textObject.exists && textObject.active)
			textObject.update(elapsed);
	}

	override function initialize()
	{
		moves = false;
		acceptsChildren = false;
	}

	public function setFormat(?font:String, size:Int = 8, color:FlxColor = FlxColor.WHITE, ?alignment:FlxTextAlign, ?borderStyle:FlxTextBorderStyle,
		borderColor:FlxColor = FlxColor.TRANSPARENT, embeddedFont:Bool = true):Void
	{
		textObject.setFormat(font, size, color, alignment, borderStyle, borderColor, embeddedFont);
		updateTextGraphic();
	}

	function get_text():String
	{
		return textObject.text;
	}

	function set_text(text:String):String
	{
		textObject.text = text;
		updateTextGraphic();
		setSize(textObject.width, textObject.height);
		return textObject.text;
	}

	function get_font():String
	{
		return textObject.font;
	}

	function set_font(value:String):String
	{
		textObject.font = value;

		updateTextGraphic();
		return value;
	}

	function updateTextGraphic():Void
	{
		@:privateAccess
		textObject.regenGraphic();
		loadGraphic(textObject.graphic);
	}
}
