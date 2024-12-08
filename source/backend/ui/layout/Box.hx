package backend.ui.layout;

import backend.ui.internal.UICache;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawQuadsItem;
import openfl.display.BitmapData;

class Box extends Container
{
	public var cornerSize(default, set):Int;
	public var cornerGraphic:FlxGraphic;

	public function new(?x:Float = 0.0, ?y:Float = 0.0, width:Int = 24, height:Int = 24, cornerSize:Int = 4)
	{
		@:bypassAccessor this.cornerSize = cornerSize;

		super(x, y, width, height);
	}

	override public function initialize():Void
	{
		moves = false;
		updateCorners();
	}

	private function updateCorners():Void
	{
		var clampedCorners:Int = MathUtils.mini(MathUtils.maxi(0, cornerSize), (MathUtils.mini(width, height) / 2).floor());

		if (clampedCorners == 0)
		{
			makeGraphic(width.floor(), height.floor(), 0xFFFFFFFF);
		}
		else
		{
			var name:String = 'sliced_box_${width}_${height}_${cornerSize}_${clampedCorners}';
			var graph:FlxGraphic = null;
			if (UICache.cornerCache.exists(name))
				cornerGraphic = UICache.cornerCache.get(name);
			else
			{
				FlxSpriteUtil.beginDraw(FlxColor.WHITE);
				FlxSpriteUtil.flashGfx.drawRoundRectComplex(0, 0, clampedCorners, clampedCorners, clampedCorners, 0, 0, 0);

				var bmp:BitmapData = new BitmapData(clampedCorners, clampedCorners, FlxColor.TRANSPARENT);
				bmp.draw(FlxSpriteUtil.flashGfxSprite, null, null, null, null, true);

				UICache.cornerCache.set(name, FlxGraphic.fromBitmapData(bmp));

				FlxSpriteUtil.flashGfx.endFill();

				cornerGraphic = UICache.cornerCache.get(name);
			}
			makeGraphic(width.floor(), height.floor(), FlxColor.TRANSPARENT);
		}
	}

	override public function draw()
	{
		if (cornerGraphic == null)
			super.draw();
		else
		{
			if (alpha == 0)
				return;

			for (camera in getCamerasLegacy())
			{
				if (!camera.visible || !camera.exists || !isOnScreen(camera))
					continue;

				var finalPosition:FlxPoint = getTruePosition(_point, camera);
				var cornerSize:FlxPoint = FlxPoint.weak(cornerGraphic.width, cornerGraphic.height);
				var whitePixel:FlxFrame = FlxG.bitmap.whitePixel;

				var isColored = (colorTransform != null && colorTransform.hasRGBAMultipliers());
				var hasColorOffsets:Bool = (colorTransform != null && colorTransform.hasRGBAOffsets());

				// we can get away by letting two bodies overlap with each other and no one would notice
				var bodyItem:FlxDrawQuadsItem = camera.startQuadBatch(whitePixel.parent, isColored, hasColorOffsets, blend, antialiasing, shader);

				if (alpha == 1.0)
				{
					whitePixel.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, false, false);
					_matrix.scale(width / whitePixel.sourceSize.x, (height - ((cornerSize.y * scale.y) * 2)) / whitePixel.sourceSize.y);
					_matrix.translate(finalPosition.x, finalPosition.y + (cornerSize.y * scale.y));

					bodyItem.addQuad(whitePixel, _matrix, colorTransform);

					whitePixel.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, false, false);
					_matrix.scale((width - ((cornerSize.x * scale.x) * 2)) / whitePixel.sourceSize.x, height / whitePixel.sourceSize.y);
					_matrix.translate(finalPosition.x + (cornerSize.x * scale.x), finalPosition.y);

					bodyItem.addQuad(whitePixel, _matrix, colorTransform);
				}
				else
				{
                    whitePixel.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, false, false);
                    _matrix.scale(cornerSize.x / whitePixel.sourceSize.x, (height - ((cornerSize.y * scale.y) * 2)) / whitePixel.sourceSize.y);

                    // left
					_matrix.translate(finalPosition.x, finalPosition.y + (cornerSize.y * scale.y));
					bodyItem.addQuad(whitePixel, _matrix, colorTransform);

                    // right
					_matrix.translate(width - cornerSize.x, 0.0);
					bodyItem.addQuad(whitePixel, _matrix, colorTransform);

                    whitePixel.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, false, false);
                    _matrix.scale((width - ((cornerSize.x * scale.x) * 2)) / whitePixel.sourceSize.x, cornerSize.y / whitePixel.sourceSize.y);

                    // top
                    _matrix.translate(finalPosition.x + cornerSize.x, finalPosition.y);
                    bodyItem.addQuad(whitePixel, _matrix, colorTransform);

                    // bottom
                    _matrix.translate(0.0, finalPosition.y - cornerSize.y);
                    bodyItem.addQuad(whitePixel, _matrix, colorTransform);

                    // center
                    whitePixel.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, false, false);
                    _matrix.scale((width - ((cornerSize.x * scale.x) * 2)) / whitePixel.sourceSize.x, (height - ((cornerSize.y * scale.y) * 2)) / whitePixel.sourceSize.y);
                    _matrix.translate(finalPosition.x + (cornerSize.x * scale.x), finalPosition.y + (cornerSize.y * scale.y));
                    bodyItem.addQuad(whitePixel, _matrix, colorTransform);
				}

				var cornerQuad:FlxDrawQuadsItem = camera.startQuadBatch(cornerGraphic, isColored, hasColorOffsets, blend, antialiasing, shader);

				var _corner:FlxFrame = cornerGraphic.imageFrame.frame;
				_corner.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, false, false);
				_matrix.scale(scale.x, scale.y);

				// top-left
				_matrix.translate(finalPosition.x, finalPosition.y);
				cornerQuad.addQuad(_corner, _matrix, colorTransform);

				// top-right
				_matrix.setTo(-_matrix.b, _matrix.a, -_matrix.d, _matrix.c, _matrix.tx, _matrix.ty); // rotates by 90 angle, we keep the x and y of the matrix
				_matrix.translate(width * scale.x, 0.0);
				cornerQuad.addQuad(_corner, _matrix, colorTransform);

				// bottom-right
				_matrix.setTo(-_matrix.b, _matrix.a, -_matrix.d, _matrix.c, _matrix.tx, _matrix.ty);
				_matrix.translate(0.0, height * scale.y);
				cornerQuad.addQuad(_corner, _matrix, colorTransform);

				// bottom-left
				_matrix.setTo(-_matrix.b, _matrix.a, -_matrix.d, _matrix.c, _matrix.tx, _matrix.ty);
				_matrix.translate(-(width * scale.x), 0.0);
				cornerQuad.addQuad(_corner, _matrix, colorTransform);
			}
		}
	}

	function set_cornerSize(value:Int):Int
	{
		this.cornerSize = value;
		updateCorners();
		return value;
	}
}
