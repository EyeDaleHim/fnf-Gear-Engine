package objects.notes;

import flixel.animation.FlxAnimation;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawQuadsItem;

class SustainTrail extends FlxSprite
{
	public var parent:NoteObject;

	public var bodyAnimation:FlxAnimation;
	public var endAnimation:FlxAnimation;

	public var sustainRect:FlxRect = FlxRect.get(0, 0, 1, 1);

	override public function new(parent:NoteObject, ?preallocatedFrames:FlxFramesCollection)
	{
		super();

		this.parent = parent;

		frames = preallocatedFrames ?? Assets.frames("ui/game/notes/NOTE_assets");

		animation.addByPrefix("sustainLEFT", "purple hold piece", 24);
		animation.addByPrefix("sustainDOWN", "blue hold piece", 24);
		animation.addByPrefix("sustainUP", "green hold piece", 24);
		animation.addByPrefix("sustainRIGHT", "red hold piece", 24);

		animation.addByPrefix("sustainLEFTend", "pruple end hold", 24);
		animation.addByPrefix("sustainDOWNend", "blue hold end", 24);
		animation.addByPrefix("sustainUPend", "green hold end", 24);
		animation.addByPrefix("sustainRIGHTend", "red hold end", 24);

		scale.x = 0.7;
		alpha = 0.6;
	}

	override public function update(elapsed:Float)
	{
		if (bodyAnimation != null)
		{
			bodyAnimation.play();
			bodyAnimation.update(elapsed);
		}
		if (endAnimation != null)
		{
			endAnimation.play();
			endAnimation.update(elapsed);
		}

		var bodyFrame:FlxFrame = frames.getByIndex(bodyAnimation.curIndex);

		x = parent.x + ((parent.width / 2) - ((bodyFrame.sourceSize.x / scale.x) / 2));
		y = parent.y;

		super.update(elapsed);
	}

	public function updateSustainClip(?clipPart:Float = 0.0):Void
	{
		sustainRect.y = clipPart;
		sustainRect.width = width;
		sustainRect.height = height;
	}

	public inline function sustainHeight():Float
	{
		return (parent.data?.sustain ?? 0.0) * NoteObject.pixelsPerMS * parent.scrollSpeed;
	}

	override public function draw()
	{
		var bodyFrame:FlxFrame = frames.getByIndex(bodyAnimation.curIndex);
		var endFrame:FlxFrame = frames.getByIndex(endAnimation.curIndex);

		var center:Float = parent.height / 2;

		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists /*|| !isOnScreen(camera)*/)
				continue;

			var totalSustainHeight:Float = sustainHeight() - center;
			var sustainY:Float = center;

			var isColored = (colorTransform != null && colorTransform.hasRGBAMultipliers());
			var hasColorOffsets:Bool = (colorTransform != null && colorTransform.hasRGBAOffsets());

			var drawItem:FlxDrawQuadsItem = camera.startQuadBatch(graphic, isColored, hasColorOffsets, blend, antialiasing, shader);

			while (totalSustainHeight > endFrame.sourceSize.y)
			{
				bodyFrame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());

				_matrix.translate(-origin.x, -origin.y);
				_matrix.scale(scale.x, 1.0);

				if (bakedRotationAngle <= 0)
				{
					updateTrig();

					if (angle != 0)
						_matrix.rotateWithTrig(_cosAngle, _sinAngle);
				}

				getScreenPosition(_point, camera).subtractPoint(offset);
				_point.add(0, sustainY);
				_point.add(origin.x, origin.y);
				_matrix.translate(_point.x, _point.y);

				if (isPixelPerfectRender(camera))
				{
					_matrix.tx = Math.floor(_matrix.tx);
					_matrix.ty = Math.floor(_matrix.ty);
				}

				// TODO: add clipping later
				if ((checkFlipY() && _matrix.ty < sustainRect.bottom) || (!checkFlipY() && _matrix.ty > sustainRect.y))
				{
					// if (!checkFlipY())
						
					drawItem.addQuad(bodyFrame, _matrix, colorTransform);
				}

				sustainY += bodyFrame.sourceSize.y;
				totalSustainHeight -= bodyFrame.sourceSize.y;
			}

			bodyFrame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());

			_matrix.translate(-origin.x, -origin.y);
			_matrix.scale(scale.x, 1.0);

			if (bakedRotationAngle <= 0)
			{
				updateTrig();

				if (angle != 0)
					_matrix.rotateWithTrig(_cosAngle, _sinAngle);
			}

			getScreenPosition(_point, camera).subtractPoint(offset);
			_point.add(0, sustainY);
			_point.add(origin.x, origin.y);
			_matrix.translate(_point.x, _point.y);

			if (isPixelPerfectRender(camera))
			{
				_matrix.tx = Math.floor(_matrix.tx);
				_matrix.ty = Math.floor(_matrix.ty);
			}

			if ((checkFlipY() && _matrix.ty < sustainRect.bottom) || (!checkFlipY() && _matrix.ty > sustainRect.y))
				drawItem.addQuad(endFrame, _matrix, colorTransform);
		}

		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
			drawDebug();
		#end
	}

	override function get_width():Float
	{
		var bodyFrame:FlxFrame = frames.getByIndex(bodyAnimation.curIndex);
		var endFrame:FlxFrame = frames.getByIndex(endAnimation.curIndex);

		return Math.max(bodyFrame.sourceSize.x, endFrame.sourceSize.x);
	}

	override function get_height():Float
	{
		return sustainHeight();
	}
}
