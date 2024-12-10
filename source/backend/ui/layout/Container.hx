package backend.ui.layout;

import backend.ui.internal.IContainer;
import flixel.graphics.frames.FlxFrame;

// most basic element for all ui to extend from
class Container extends FlxSprite implements IContainer
{
	public var parent:Container;

	public var borderPadding:FlxRect = FlxRect.get();
    public var anchor:Anchor = TOP_LEFT;

	public function new(?x:Float = 0.0, ?y:Float = 0.0, ?width:Int = 24, ?height:Int = 24)
	{
		super(x, y);
		setSize(width, height);

		initialize();
	}

	public function initialize():Void
	{
        moves = false;

		makeGraphic(width.floor(), height.floor(), 0xFFFFFFFF);
	}

	private function getTruePosition(?result:FlxPoint, ?camera:FlxCamera):FlxPoint
	{
		if (result == null)
			result = FlxPoint.get();

		if (camera == null)
			camera = FlxG.camera;

		result.set();

		if (parent != null)
		{
			result.addPoint(parent.getScreenPosition()).addPoint(getPosition());
            result.add(parent.borderPadding.x, parent.borderPadding.y);
		}
		else
		{
			getScreenPosition(result, camera);
		}

		return result.subtractPoint(offset);
	}

	override public function draw()
	{
		checkEmptyFrame();

		if (alpha == 0)
			return;

		if (dirty) // rarely
			calcFrame(useFramePixels);

		for (camera in getCamerasLegacy())
		{
			if (!camera.visible || !camera.exists || !isOnScreen(camera))
				continue;

			if (isSimpleRender(camera))
				drawSimple(camera);
			else
				drawComplex(camera);

			#if FLX_DEBUG
			FlxBasic.visibleCount++;
			#end
		}

		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
			drawDebug();
		#end
	}

	override function drawSimple(camera:FlxCamera)
	{
		if (parent == null)
		{
			super.drawSimple(camera);
		}
		else
		{
			getTruePosition(_point, camera);
			if (isPixelPerfectRender(camera))
				_point.floor();

			_point.copyToFlash(_flashPoint);
			camera.copyPixels(_frame, framePixels, _flashRect, _flashPoint, colorTransform, blend, antialiasing);
		}
	}

	override function drawComplex(camera:FlxCamera)
	{
		if (parent == null)
		{
			super.drawComplex(camera);
		}
		else
		{
			_frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
			_matrix.translate(-origin.x, -origin.y);
			_matrix.scale(scale.x, scale.y);

			if (bakedRotationAngle <= 0)
			{
				updateTrig();

				if (angle != 0)
					_matrix.rotateWithTrig(_cosAngle, _sinAngle);
			}

			getTruePosition(_point, camera);
			_point.add(origin.x, origin.y);
			_matrix.translate(_point.x, _point.y);

			if (isPixelPerfectRender(camera))
			{
				_matrix.tx = Math.floor(_matrix.tx);
				_matrix.ty = Math.floor(_matrix.ty);
			}

			camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
		}
	}

	@:access(flixel.FlxCamera)
	override function getBoundingBox(camera:FlxCamera):FlxRect
	{
		getTruePosition(_point, camera);

		_rect.set(_point.x, _point.y, width, height);
		_rect = camera.transformRect(_rect);

		if (isPixelPerfectRender(camera))
		{
			_rect.floor();
		}

		return _rect;
	}

	override public function isOnScreen(?camera:FlxCamera):Bool
	{
		if (camera == null)
			camera = FlxG.camera;

		getTruePosition(_point, camera);
		return camera.containsPoint(_point, width, height);
	}

	// mouse overlaps
	public function mouseOverlaps(?camera:FlxCamera):Bool
	{
		if (camera == null)
			camera = this.camera;

		getTruePosition(_point, camera);

		var rect:FlxRect = FlxRect.get(_point.x, _point.y, width, height);
		var result:Bool = rect.containsPoint(FlxG.mouse.getWorldPosition(camera));
		rect.put();
		return result;
	}
}

enum Anchor
{
    TOP_LEFT;
    TOP_MIDDLE;
    TOP_RIGHT;

    LEFT;
    CENTER;
    RIGHT;

    BOTTOM_LEFT;
    BOTTOM_MIDDLE;
    BOTTOM_RIGHT;
}