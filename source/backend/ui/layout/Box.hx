package backend.ui.layout;

import backend.ui.internal.UICache;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawQuadsItem;
import openfl.display.BitmapData;
import openfl.geom.ColorTransform;

typedef CornerGraphics =
{
	var topLeft:FlxGraphic;
	var topRight:FlxGraphic;

	var bottomLeft:FlxGraphic;
	var bottomRight:FlxGraphic;

	var defaultCorner:FlxGraphic;
};

// TODO: finish complex rounded box functionality
class Box extends Container
{
	static var whitePixel:FlxGraphic;

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

	public function new(?x:Float = 0.0, ?y:Float = 0.0, width:Float = 24, height:Float = 24, cornerSize:Int = 4, quality:Int = 1)
	{
		@:bypassAccessor this.quality = quality;
		@:bypassAccessor this.cornerSize = cornerSize;

		super(x, y, width, height);
	}

	override public function initialize():Void
	{
		if (whitePixel == null)
			whitePixel = FlxGraphic.fromBitmapData(new BitmapData(1, 1, false));

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
			var name:String = 'sliced_box_${quality * clampedCorners}';

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
				FlxSpriteUtil.flashGfx.endFill();

				var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bmp);
				graphic.destroyOnNoUse = false;
				graphic.incrementUseCount();

				UICache.cornerCache.set(name, graphic);

				setCorner(corner, UICache.cornerCache.get(name));
			}
			makeGraphic(width.floor(), height.floor(), FlxColor.TRANSPARENT);
		}
	}

	private var _redTransform = new ColorTransform(1.0, 0.0, 0.0, 0.6);
	private var _blueTransform = new ColorTransform(0.0, 1.0, 0.0, 0.6);
	private var _greenTransform = new ColorTransform(0.0, 0.0, 1.0, 0.6);
	private var _yellowTransform = new ColorTransform(1.0, 1.0, 0.0, 0.6);

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

				var isColored = (colorTransform != null && colorTransform.hasRGBAMultipliers());
				var hasColorOffsets:Bool = (colorTransform != null && colorTransform.hasRGBAOffsets());

				// we can get away by letting two bodies overlap with each other and no one would notice
				var bodyItem:FlxDrawQuadsItem = camera.startQuadBatch(whitePixel, isColored, hasColorOffsets, blend, antialiasing, shader);

				var useTwoBodies:Bool = alpha == 1.0;
				if (usingComplexCorners)
					useTwoBodies = false;

				// todo: cache all these results later
				if (useTwoBodies)
				{
					whitePixel.imageFrame.frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, false, false);
					_matrix.setMatrixSize(width, height - (defaultCornerSize.y * 2.0));
					_matrix.translate(finalPosition.x, finalPosition.y + defaultCornerSize.y);
					bodyItem.addQuad(whitePixel.imageFrame.frame, _matrix, colorTransform);

					whitePixel.imageFrame.frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, false, false);
					_matrix.setMatrixSize(width - (defaultCornerSize.x * 2.0), height);
					_matrix.translate(finalPosition.x + defaultCornerSize.x, finalPosition.y);
					bodyItem.addQuad(whitePixel.imageFrame.frame, _matrix, colorTransform);
				}
				else
				{
					// left
					whitePixel.imageFrame.frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, false, false);
					var leftSize:FlxRect = FlxRect.get();

					if (cornerGraphics.topLeft == null)
					{
						leftSize.y = defaultCornerSize.y;
						leftSize.width = defaultCornerSize.x;
					}
					else
					{
						leftSize.y = cornerGraphics.topLeft.height;
						leftSize.width = cornerGraphics.topLeft.width;
					}

					if (cornerGraphics.bottomLeft == null)
						leftSize.height = height - defaultCornerSize.y - leftSize.y;
					else
						leftSize.height = height - cornerGraphics.bottomLeft.height - leftSize.y;

					_matrix.setMatrixSize(leftSize.width, leftSize.height);
					_matrix.translate(finalPosition.x, finalPosition.y + leftSize.y);
					bodyItem.addQuad(whitePixel.imageFrame.frame, _matrix, colorTransform);

					// right
					whitePixel.imageFrame.frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, false, false);
					var rightSize:FlxRect = FlxRect.get();

					if (cornerGraphics.topRight == null)
					{
						rightSize.y = defaultCornerSize.y;
						rightSize.width = defaultCornerSize.x;
					}
					else
					{
						rightSize.y = cornerGraphics.topRight.height;
						rightSize.width = cornerGraphics.topRight.width;
					}

					if (cornerGraphics.bottomRight == null)
						rightSize.height = height - defaultCornerSize.y - rightSize.y;
					else
						rightSize.height = height - cornerGraphics.bottomRight.height - rightSize.y;

					_matrix.setMatrixSize(rightSize.width, rightSize.height);
					_matrix.translate(finalPosition.x + width - rightSize.width, finalPosition.y + rightSize.y);
					bodyItem.addQuad(whitePixel.imageFrame.frame, _matrix, colorTransform);

					// top
					whitePixel.imageFrame.frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, false, false);
					var topSize:FlxRect = FlxRect.get();

					if (cornerGraphics.topLeft == null)
					{
						topSize.x = defaultCornerSize.x;
						topSize.height = defaultCornerSize.y;
					}
					else
					{
						topSize.x = cornerGraphics.topLeft.width;
						topSize.height = cornerGraphics.topLeft.height;
					}

					if (cornerGraphics.topRight == null)
						topSize.width = width - defaultCornerSize.x;
					else
						topSize.width = width - cornerGraphics.topRight.width;

					_matrix.setMatrixSize(topSize.width - topSize.x, topSize.height);
					_matrix.translate(finalPosition.x + topSize.x, finalPosition.y);
					bodyItem.addQuad(whitePixel.imageFrame.frame, _matrix, colorTransform);

					// bottom
					whitePixel.imageFrame.frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, false, false);
					var bottomSize:FlxRect = FlxRect.get();

					if (cornerGraphics.bottomLeft == null)
					{
						bottomSize.x = defaultCornerSize.x;
						bottomSize.height = defaultCornerSize.y;
					}
					else
					{
						bottomSize.x = cornerGraphics.bottomLeft.width;
						bottomSize.height = cornerGraphics.bottomLeft.height;
					}

					if (cornerGraphics.bottomRight == null)
						bottomSize.width = width - defaultCornerSize.x - bottomSize.x;
					else
						bottomSize.width = width - cornerGraphics.bottomRight.width - bottomSize.x;

					_matrix.setMatrixSize(bottomSize.width, bottomSize.height);
					_matrix.translate(finalPosition.x + bottomSize.x, finalPosition.y + height - bottomSize.height);
					bodyItem.addQuad(whitePixel.imageFrame.frame, _matrix, colorTransform);

					// center (not finished)
					whitePixel.imageFrame.frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, false, false);
					var centerRect:FlxRect = FlxRect.get();

					centerRect.x = MathUtils.max(defaultCornerSize.x, cornerGraphics.topLeft == null ? 0 : cornerGraphics.topLeft.width);
					centerRect.y = MathUtils.max(defaultCornerSize.y, cornerGraphics.topLeft == null ? 0 : cornerGraphics.topLeft.height);
					centerRect.width = MathUtils.max(width - defaultCornerSize.x - centerRect.x, cornerGraphics.topRight == null ? 0 : cornerGraphics.topRight.width,
						cornerGraphics.bottomRight == null ? 0 : cornerGraphics.bottomRight.width);
					centerRect.height = MathUtils.max(height - defaultCornerSize.y - centerRect.y, cornerGraphics.bottomLeft == null ? 0 : cornerGraphics.bottomLeft.width,
						cornerGraphics.bottomRight == null ? 0 : cornerGraphics.bottomRight.height);

					_matrix.setMatrixSize(centerRect.width, centerRect.height);
					_matrix.translate(finalPosition.x + centerRect.x, finalPosition.y + centerRect.y);
					bodyItem.addQuad(whitePixel.imageFrame.frame, _matrix, colorTransform);
				}

				if (!usingComplexCorners)
				{
					var cornerQuad:FlxDrawQuadsItem = camera.startQuadBatch(cornerGraphics.defaultCorner, isColored, hasColorOffsets, blend, antialiasing,
						shader);

					var _corner:FlxFrame = cornerGraphics.defaultCorner.imageFrame.frame;
					_corner.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, false, false);
					_matrix.scale(1 / quality, 1 / quality);

					// top-left
					_matrix.translate(finalPosition.x, finalPosition.y);
					cornerQuad.addQuad(_corner, _matrix, colorTransform);

					// top-right
					_matrix.setTo(-_matrix.b, _matrix.a, -_matrix.d, _matrix.c, _matrix.tx,
						_matrix.ty); // rotates by 90 angle, we keep the x and y of the matrix
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
					var corners:Array<FlxGraphic>;
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
		if (this.topLeftCornerSize == 0)
			cornerGraphics.topLeft = null;
		else
		updateCorners('top_left');
		return value;
	}

	function set_topRightCornerSize(value:Int):Int
	{
		this.topRightCornerSize = MathUtils.maxi(value, 0);
		if (this.topRightCornerSize == 0)
			cornerGraphics.topRight = null;
		else
		updateCorners('top_right');
		return value;
	}

	function set_bottomLeftCornerSize(value:Int):Int
	{
		this.bottomLeftCornerSize = MathUtils.maxi(value, 0);
		if (this.bottomLeftCornerSize == 0)
			cornerGraphics.bottomLeft = null;
		else
		updateCorners('bottom_left');
		return value;
	}

	function set_bottomRightCornerSize(value:Int):Int
	{
		this.bottomRightCornerSize = MathUtils.maxi(value, 0);
		if (this.bottomRightCornerSize == 0)
			cornerGraphics.bottomRight = null;
		else
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
