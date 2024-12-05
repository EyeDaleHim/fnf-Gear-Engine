package objects;

import openfl.display.BlendMode;
import openfl.geom.ColorTransform;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawQuadsItem;
import flixel.math.FlxMatrix;
import flixel.system.FlxAssets.FlxShader;

using flixel.util.FlxColorTransformUtil;

class AtlasText extends FlxObject
{
	static final letterIdentity:EReg = ~/[a-z]*/ig;

	public var bold(default, set):Bool = false;
	public var ignoreLowercase(default, set):Bool = true;
	public var text(default, set):String = "";

	public var spaceWidth(default, set):Int = 32; // by pixel
	public var charWidthPad(default, set):Int = 1;

	public var antialiasing:Bool = false;

	public var animated:Bool = true;
	public var fps:Float = 24.0;

	public var blend:BlendMode;

	public var colorTransform:ColorTransform;

	public var graphic(get, null):FlxGraphic;

	public var shader:FlxShader;

	var _renderList:Array<CharRender> = [];
	var _matrix:FlxMatrix;
	var _atlas:FlxAtlasFrames;

	var _animTimer:Float = 0.0;

	public function new(?x:Float = 0.0, ?y:Float = 0.0, ?text:String = "", fps:Float = 24.0)
	{
		super(x, y, 12, 20);

		this.fps = fps;

		_atlas = Assets.frames('ui/alphabet');

		this.text = text;
	}

	override public function update(elapsed:Float)
	{
		if (animated)
		{
			_animTimer += elapsed * FlxG.animationTimeScale;
			while (_animTimer >= 1 / fps)
			{
				for (render in _renderList)
				{
					if (render.isSpace || render.isNewLine)
						continue;

					render.frameNum = FlxMath.wrap(render.frameNum + 1, 0, render.list.length - 1);
				}
				_animTimer -= 1 / fps;
			}
		}

		super.update(elapsed);
	}

	override public function draw()
	{
		for (camera in cameras)
		{
			var isColored = (colorTransform != null && colorTransform.hasRGBMultipliers());
			var hasColorOffsets:Bool = (colorTransform != null && colorTransform.hasRGBAOffsets());

			var drawItem:FlxDrawQuadsItem = camera.startQuadBatch(graphic, isColored, hasColorOffsets, blend, antialiasing, shader);

			var _size:FlxRect = FlxRect.get();
			var _spaceOffset:Float = 0.0;

			for (render in _renderList)
			{
				if (render.isSpace || render.isNewLine)
				{
					if (render.isSpace)
						_spaceOffset += spaceWidth;
					continue;
				}

				var renderFrame:FlxFrame = render.list[render.frameNum];
				renderFrame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, false, false);

				getScreenPosition(_point, camera);
				_matrix.translate(_point.x, _point.y);

				_matrix.translate(_spaceOffset, 0.0);
				_matrix.translate(_size.width, height - renderFrame.sourceSize.y);

				_size.width += renderFrame.sourceSize.x + charWidthPad;
				_size.height = Math.max(renderFrame.sourceSize.y, _size.height);

				drawItem.addQuad(renderFrame, _matrix, colorTransform);
			}

			_size.put();
		}

		super.draw();
	}

	override private function initVars()
	{
		super.initVars();

		_matrix = new FlxMatrix();
	}

	private function updateTextRender():Void
	{
		_renderList.resize(0);

		for (i in 0...text.length)
		{
			var char:String = text.charAt(i);
			switch (char)
			{
				case ' ':
					_renderList.push({isSpace: true});
				case '\n':
					_renderList.push({isNewLine: true});
				default:
					var isUpperCase:Bool = (char.toUpperCase() == char || ignoreLowercase);
					var outputChar:String = isUpperCase ? char.toUpperCase() : char;

					var charRender:CharRender = {list: [], frameNum: 0};

					if (isUpperCase)
					{
						if (bold)
						{
							var output:String = outputChar;
							output += ' bold char';
							for (i in 0..._atlas.frames.length)
							{
								var frame:FlxFrame = _atlas.frames[i];
								if (frame.name.startsWith(output))
									charRender.list.push(frame);
							}
						}
						else
						{
							var output:String = outputChar;
							output += ' char';
							for (i in 0..._atlas.frames.length)
							{
								var frame:FlxFrame = _atlas.frames[i];
								if (frame.name.startsWith(output))
									charRender.list.push(frame);
							}
						}
					}
					else
					{
						var output:String = char.toLowerCase();
						output += ' char';
						for (i in 0..._atlas.frames.length)
						{
							var frame:FlxFrame = _atlas.frames[i];
							if (frame.name.startsWith(output))
								charRender.list.push(frame);
						}
					}

					_renderList.push(charRender);
			}
		}
	}

	private function calculateLineHeight():Void {}

	private function calculateSize():Void
	{
		setSize(12, 20);

		var positionHelper:Float = 0.0;

		var heightHelper:Float = 0.0;
		var lineHeight:Float = 0.0;

		for (render in _renderList)
		{
			if (render.isNewLine)
			{
				positionHelper = 0.0;
				heightHelper += lineHeight;
				continue;
			}
			if (render.isSpace)
			{
				positionHelper += spaceWidth;
				continue;
			}

			var biggestSize:FlxPoint = FlxPoint.get();
			for (frame in render.list)
				biggestSize.set(Math.max(biggestSize.x, frame.sourceSize.x + charWidthPad), Math.max(biggestSize.y, frame.sourceSize.y));

			positionHelper += biggestSize.x;
			lineHeight = Math.max(lineHeight, biggestSize.y);

			biggestSize.put();
		}

		setSize(positionHelper, heightHelper + lineHeight);
	}

	function get_graphic():FlxGraphic
	{
		return _atlas.parent;
	}

	function set_spaceWidth(value:Int):Int
	{
		this.spaceWidth = value;
		calculateSize();

		return value;
	}

	function set_charWidthPad(value:Int):Int
	{
		this.charWidthPad = value;
		calculateSize();

		return value;
	}

	function set_ignoreLowercase(value:Bool):Bool
	{
		this.ignoreLowercase = value;
		updateTextRender();
		calculateSize();

		return value;
	}

	function set_bold(value:Bool):Bool
	{
		this.bold = value;
		updateTextRender();
		calculateSize();

		return value;
	}

	function set_text(text:String):String
	{
		this.text = text;
		updateTextRender();
		calculateSize();

		return text;
	}
}

typedef CharRender =
{
	var ?list:Array<FlxFrame>;
	var ?frameNum:Int;

	// special cases
	var ?isSpace:Bool;
	var ?isNewLine:Bool;
};
