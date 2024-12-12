package backend.ui.layout;

import backend.ui.internal.UICache;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawQuadsItem;
import openfl.display.BitmapData;

typedef CornerGraphics =
{
	var topLeft:FlxGraphic;
	var topRight:FlxGraphic;

	var bottomLeft:FlxGraphic;
	var bottomRight:FlxGraphic;

	var defaultCorner:FlxGraphic;
};

class Box extends Container
{
	static final cornerNames:Array<String> = [null, 'top_left', 'top_right', 'bottom_left', 'bottom_right'];

	public var quality(default, set):Int = 1;
	public var cornerSize(default, set):Int;

	public var usingComplexCorners(get, never):Bool;

	public var topLeftCornerSize(default, set):Int;
	public var topRightCornerSize(default, set):Int;
	public var bottomLeftCornerSize(default, set):Int;
	public var bottomRightCornerSize(default, set):Int;

	public var cornerGraphics:CornerGraphics = {
		topLeft: null,
		topRight: null,
		bottomLeft: null,
		bottomRight: null,
		defaultCorner: null
	};

	public function new(?x:Float = 0.0, ?y:Float = 0.0, width:Int = 24, height:Int = 24, cornerSize:Int = 4, quality:Int = 1)
	{
		@:bypassAccessor this.quality = quality;
		@:bypassAccessor this.cornerSize = cornerSize;

		super(x, y, width, height);
	}

	override public function initialize():Void
	{
		moves = false;
		updateCorners();
	}

	private function updateCorners(?corner:String):Void
	{
		var clampedCorners:Int = MathUtils.mini(MathUtils.maxi(0, cornerSize), (MathUtils.mini(width, height) / 2).floor()) * quality;

		if (clampedCorners == 0)
		{
			makeGraphic(width.floor(), height.floor(), 0xFFFFFFFF);
		}
		else
		{
			var name:String;

			if (corner == null)
				name = 'sliced_box_${width}_${height}_${quality}_${cornerSize}_${clampedCorners}';
			else
			{
				name = 'sliced_box_${corner}_${width}_${height}_${quality}_${cornerSize}_${clampedCorners}';
			}

			if (UICache.cornerCache.exists(name))
			{
				setCorner(corner, UICache.cornerCache.get(name));
			}
			else
			{
				FlxSpriteUtil.beginDraw(FlxColor.WHITE);
				FlxSpriteUtil.flashGfx.drawRoundRectComplex(0, 0, clampedCorners, clampedCorners, clampedCorners, 0, 0, 0);

				var bmp:BitmapData = new BitmapData(clampedCorners, clampedCorners, FlxColor.TRANSPARENT);
				bmp.draw(FlxSpriteUtil.flashGfxSprite, null, null, null, null, true);

				UICache.cornerCache.set(name, FlxGraphic.fromBitmapData(bmp));

				FlxSpriteUtil.flashGfx.endFill();

				setCorner(corner, UICache.cornerCache.get(name));
			}
			makeGraphic(width.floor(), height.floor(), FlxColor.TRANSPARENT);
		}
	}

	override public function draw()
	{
		if (cornerGraphics.defaultCorner == null
			&& cornerGraphics.topLeft == null
			&& cornerGraphics.topRight == null
			&& cornerGraphics.bottomLeft == null
			&& cornerGraphics.bottomRight == null)
		{
			super.draw();
		}
		else
		{
			if (alpha == 0)
				return;

			for (camera in getCamerasLegacy())
			{
				if (!camera.visible || !camera.exists || !isOnScreen(camera))
					continue;

				var finalPosition:FlxPoint = getTruePosition(_point, camera);
				var defaultCornerSize:FlxPoint = FlxPoint.weak(cornerGraphics.defaultCorner.width / quality, cornerGraphics.defaultCorner.height / quality);
				var whitePixel:FlxFrame = FlxG.bitmap.whitePixel;

				var isColored = (colorTransform != null && colorTransform.hasRGBAMultipliers());
				var hasColorOffsets:Bool = (colorTransform != null && colorTransform.hasRGBAOffsets());

				// we can get away by letting two bodies overlap with each other and no one would notice
				var bodyItem:FlxDrawQuadsItem = camera.startQuadBatch(whitePixel.parent, isColored, hasColorOffsets, blend, antialiasing, shader);

				var useTwoBodies:Bool = (alpha == 1.0);

				if (useTwoBodies)
				{
					whitePixel.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, false, false);
					_matrix.scale((width / whitePixel.sourceSize.x), (height - (defaultCornerSize.y * 2)) / whitePixel.sourceSize.y);
					_matrix.translate(finalPosition.x, finalPosition.y + defaultCornerSize.y);
					bodyItem.addQuad(whitePixel, _matrix, colorTransform);

					whitePixel.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, false, false);
					_matrix.scale((width - (defaultCornerSize.x * 2)) / whitePixel.sourceSize.x, (height / whitePixel.sourceSize.y) * scale.y);
					_matrix.translate(finalPosition.x + defaultCornerSize.x, finalPosition.y);
					bodyItem.addQuad(whitePixel, _matrix, colorTransform);
				}
				else
				{
					whitePixel.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, false, false);
					_matrix.scale(defaultCornerSize.x / whitePixel.sourceSize.x, (height - (defaultCornerSize.y * 2)) / whitePixel.sourceSize.y);

					// left
					_matrix.translate(finalPosition.x, finalPosition.y + defaultCornerSize.y);
					bodyItem.addQuad(whitePixel, _matrix, colorTransform);

					// right
					_matrix.translate(width - defaultCornerSize.x, 0.0);
					bodyItem.addQuad(whitePixel, _matrix, colorTransform);

					whitePixel.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, false, false);
					_matrix.scale((width - (defaultCornerSize.x * 2)) / whitePixel.sourceSize.x, defaultCornerSize.y / whitePixel.sourceSize.y);
					
					// top
					_matrix.translate(finalPosition.x + defaultCornerSize.x, finalPosition.y);
					bodyItem.addQuad(whitePixel, _matrix, colorTransform);

					// bottom
					_matrix.translate(0.0, finalPosition.y - defaultCornerSize.y);
					bodyItem.addQuad(whitePixel, _matrix, colorTransform);

					// center
					whitePixel.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, false, false);
					_matrix.scale((width - (defaultCornerSize.x * 2)) / whitePixel.sourceSize.x,
						(height - (defaultCornerSize.y * 2)) / whitePixel.sourceSize.y);
					_matrix.translate(finalPosition.x + defaultCornerSize.x, finalPosition.y + defaultCornerSize.y);
					bodyItem.addQuad(whitePixel, _matrix, colorTransform);
				}

				if (!usingComplexCorners)
				{
					var cornerQuad:FlxDrawQuadsItem = camera.startQuadBatch(cornerGraphics.defaultCorner, isColored, hasColorOffsets, blend, antialiasing, shader);

					var _corner:FlxFrame = cornerGraphics.defaultCorner.imageFrame.frame;
					_corner.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, false, false);
					_matrix.scale(1 / quality, 1 / quality);
	
					// top-left
					_matrix.translate(finalPosition.x, finalPosition.y);
					cornerQuad.addQuad(_corner, _matrix, colorTransform);
	
					// top-right
					_matrix.setTo(-_matrix.b, _matrix.a, -_matrix.d, _matrix.c, _matrix.tx, _matrix.ty); // rotates by 90 angle, we keep the x and y of the matrix
					_matrix.translate(width, 0.0);
					cornerQuad.addQuad(_corner, _matrix, colorTransform);
	
					// bottom-right
					_matrix.setTo(-_matrix.b, _matrix.a, -_matrix.d, _matrix.c, _matrix.tx, _matrix.ty);
					_matrix.translate(0.0, height);
					cornerQuad.addQuad(_corner, _matrix, colorTransform);
	
					// bottom-left
					_matrix.setTo(-_matrix.b, _matrix.a, -_matrix.d, _matrix.c, _matrix.tx, _matrix.ty);
					_matrix.translate(-width, 0.0);
					cornerQuad.addQuad(_corner, _matrix, colorTransform);
				}
				else
				{

				}
			}

			#if FLX_DEBUG
			if (FlxG.debugger.drawDebug)
				drawDebug();
			#end
		}
	}

	private function getCorner(?corner:String):FlxGraphic
	{
		return switch (corner)
		{
			case 'top_left': cornerGraphics.topLeft;
			case 'top_right': cornerGraphics.topRight;
			case 'bottom_left': cornerGraphics.bottomLeft;
			case 'bottom_right': cornerGraphics.bottomRight;
			default:
				cornerGraphics.defaultCorner;
		}
	}

	private function setCorner(?corner:String, graphic:FlxGraphic):FlxGraphic
	{
		return switch (corner)
		{
			case 'top_left': (cornerGraphics.topLeft = graphic);
			case 'top_right': (cornerGraphics.topRight = graphic);
			case 'bottom_left': (cornerGraphics.bottomLeft = graphic);
			case 'bottom_right': (cornerGraphics.bottomRight = graphic);
			default:
				(cornerGraphics.defaultCorner = graphic);
		}
	}

	function get_usingComplexCorners():Bool
	{
		return (cornerGraphics.topLeft != null || cornerGraphics.topRight != null || cornerGraphics.bottomLeft != null || cornerGraphics.bottomRight != null);
	}

	function set_cornerSize(value:Int):Int
	{
		this.cornerSize = MathUtils.maxi(value, 0);
		updateCorners();
		return value;
	}

	function set_topLeftCornerSize(value:Int):Int
	{
		this.topLeftCornerSize = MathUtils.maxi(value, 0);
		updateCorners('top_left');
		return value;
	}

	function set_topRightCornerSize(value:Int):Int
	{
		this.topRightCornerSize = MathUtils.maxi(value, 0);
		updateCorners('top_right');
		return value;
	}

	function set_bottomLeftCornerSize(value:Int):Int
	{
		this.bottomLeftCornerSize = MathUtils.maxi(value, 0);
		updateCorners('bottom_left');
		return value;
	}

	function set_bottomRightCornerSize(value:Int):Int
	{
		this.bottomRightCornerSize = MathUtils.maxi(value, 0);
		updateCorners('bottom_right');
		return value;
	}

	function set_quality(value:Int):Int
	{
		this.quality = MathUtils.maxi(value, 1);
		updateCorners();
		return value;
	}
}
