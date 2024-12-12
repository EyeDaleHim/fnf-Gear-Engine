package backend.ui.layout;

import openfl.display.Graphics;
import flixel.graphics.frames.FlxFrame;
import flixel.util.FlxDirectionFlags;

// most basic element for all ui to extend from
class Container extends FlxSprite
{
	public var parent(default, set):Container;

	public var acceptsChildren:Bool = true;

	public var borderPadding:FlxRect = FlxRect.get();
	public var anchor:Anchor = TOP_LEFT;

	public var paddingDebugColor:FlxColor = FlxColor.ORANGE;

	public function new(?x:Float = 0.0, ?y:Float = 0.0, ?width:Int = 24, ?height:Int = 24)
	{
		super(x, y);
		setSize(width, height);

		initialize();
	}

	private function initialize():Void
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
			switch (anchor)
			{
				case TOP_MIDDLE:
					{
						result.addPoint(parent.getScreenPosition()).addPoint(getPosition());

						var outputRect:FlxRect = getHitbox();
						outputRect.setPosition(parent.borderPadding.x, parent.borderPadding.y);
						outputRect.setSize(parent.width - parent.borderPadding.width, parent.height - parent.borderPadding.height);

						result.add(outputRect.x, outputRect.y);
						result.add((outputRect.width / 2) - (width / 2), 0);
					}
				case TOP_RIGHT:
					{
						result.addPoint(parent.getScreenPosition()).addPoint(getPosition());

						var outputRect:FlxRect = getHitbox();
						outputRect.setPosition(parent.borderPadding.x, parent.borderPadding.y);
						outputRect.setSize(parent.width - parent.borderPadding.width, parent.height - parent.borderPadding.height);

						result.add(outputRect.x, outputRect.y);
						result.add(outputRect.width - width, 0);
					}
				case LEFT:
					{
						result.addPoint(parent.getScreenPosition()).addPoint(getPosition());

						var outputRect:FlxRect = getHitbox();
						outputRect.setPosition(parent.borderPadding.x, parent.borderPadding.y);
						outputRect.setSize(parent.width - parent.borderPadding.width, parent.height - parent.borderPadding.height);

						result.add(outputRect.x, outputRect.y);
						result.add(0, (outputRect.height / 2) - (height / 2));
					}
				case CENTER:
					{
						result.addPoint(parent.getScreenPosition()).addPoint(getPosition());

						var outputRect:FlxRect = getHitbox();
						outputRect.setPosition(parent.borderPadding.x, parent.borderPadding.y);
						outputRect.setSize(parent.width - parent.borderPadding.width, parent.height - parent.borderPadding.height);

						result.add(outputRect.x, outputRect.y);
						result.add((outputRect.width / 2) - (width / 2), (outputRect.height / 2) - (height / 2));
					}
				case RIGHT:
					{
						result.addPoint(parent.getScreenPosition()).addPoint(getPosition());

						var outputRect:FlxRect = getHitbox();
						outputRect.setPosition(parent.borderPadding.x, parent.borderPadding.y);
						outputRect.setSize(parent.width - parent.borderPadding.width, parent.height - parent.borderPadding.height);

						result.add(outputRect.x, outputRect.y);
						result.add(outputRect.width - width, (outputRect.height / 2) - (height / 2));
					}
				case BOTTOM_LEFT:
					{
						result.addPoint(parent.getScreenPosition()).addPoint(getPosition());

						var outputRect:FlxRect = getHitbox();
						outputRect.setPosition(parent.borderPadding.x, parent.borderPadding.y);
						outputRect.setSize(parent.width - parent.borderPadding.width, parent.height - parent.borderPadding.height);

						result.add(outputRect.x, outputRect.y);
						result.add(0, outputRect.height - height);
					}
				case BOTTOM_MIDDLE:
					{
						result.addPoint(parent.getScreenPosition()).addPoint(getPosition());

						var outputRect:FlxRect = getHitbox();
						outputRect.setPosition(parent.borderPadding.x, parent.borderPadding.y);
						outputRect.setSize(parent.width - parent.borderPadding.width, parent.height - parent.borderPadding.height);

						result.add(outputRect.x, outputRect.y);
						result.add((outputRect.width / 2) - (width / 2), outputRect.height - height);
					}
				case BOTTOM_RIGHT:
					{
						result.addPoint(parent.getScreenPosition()).addPoint(getPosition());

						var outputRect:FlxRect = getHitbox();
						outputRect.setPosition(parent.borderPadding.x, parent.borderPadding.y);
						outputRect.setSize(parent.width - parent.borderPadding.width, parent.height - parent.borderPadding.height);

						result.add(outputRect.x, outputRect.y);
						result.add(outputRect.width - width, outputRect.height - height);
					}
				default: // TOP LEFT
					result.addPoint(parent.getScreenPosition()).addPoint(getPosition());
					result.add(parent.borderPadding.x, parent.borderPadding.y);
			}
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

	#if FLX_DEBUG
	var _drawWithPadding:Bool = false;

	override function drawDebugBoundingBox(gfx:Graphics, rect:FlxRect, allowCollisions:Int, partial:Bool)
	{
		// Find the color to use
		var color:Null<Int> = debugBoundingBoxColor;
		if (_drawWithPadding)
			color = paddingDebugColor;

		if (color == null)
		{
			if (allowCollisions != FlxDirectionFlags.NONE)
			{
				color = partial ? debugBoundingBoxColorPartial : debugBoundingBoxColorSolid;
			}
			else
			{
				color = debugBoundingBoxColorNotSolid;
			}
		}

		// fill static graphics object with square shape
		gfx.lineStyle(1, color, 0.75);
		gfx.drawRect(rect.x + 0.5, rect.y + 0.5, rect.width - 1.0, rect.height - 1.0);
	}

	override public function drawDebugOnCamera(camera:FlxCamera):Void
	{
		if (!camera.visible || !camera.exists || !isOnScreen(camera))
			return;

		var rect = getBoundingBox(camera);
		var gfx:Graphics = beginDrawDebug(camera);
		drawDebugBoundingBox(gfx, rect, allowCollisions, immovable);

		_drawWithPadding = true;
		rect.set(rect.x + borderPadding.x, rect.y + borderPadding.y, rect.width - borderPadding.width, rect.height - borderPadding.height);
		drawDebugBoundingBox(gfx, rect, allowCollisions, immovable);

		endDrawDebug(camera);

		_drawWithPadding = false;
	}
	#end

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

		return getBoundingBox(camera).containsPoint(FlxG.mouse.getPositionInCameraView(camera));
	}

	function set_parent(newParent:Container):Container
	{
		if (newParent == this)
		{
			FlxG.log.error('This container cannot be a child of itself.');
			return this;
		}

		if (!newParent?.acceptsChildren)
		{
			FlxG.log.error('This container does not accept children.');
			return parent;
		}

		parent = newParent;

		return newParent;
	}
}

enum abstract Anchor(Int)
{
	var TOP_LEFT = 1;
	var TOP_MIDDLE = 2;
	var TOP_RIGHT = 3;

	var LEFT = 4;
	var CENTER = 5;
	var RIGHT = 6;

	var BOTTOM_LEFT = 7;
	var BOTTOM_MIDDLE = 8;
	var BOTTOM_RIGHT = 9;

	var NONE = 0;
}
