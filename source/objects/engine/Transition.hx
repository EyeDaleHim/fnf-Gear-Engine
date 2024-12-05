package objects.engine;

import flixel.util.FlxGradient;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxMatrix;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawBaseItem;
import flixel.graphics.tile.FlxDrawQuadsItem;
import openfl.display.BitmapData;
import openfl.geom.ColorTransform;

class Transition extends FlxBasic
{
	public static var instance:Transition;

	public var color(default, set):FlxColor = 0xFF000000;

	private var _x:Float = 0.0;
	private var _y:Float = 0.0;

	private var _transitionType:Bool = false;

	private var _gradient:FlxGraphic;
	private var _pixel:FlxGraphic;
	private var _frame:FlxFrame;
	private var _matrix:FlxMatrix;

	private var _tween:FlxTween;

	private var _colorTransform:ColorTransform;

	public function new()
	{
		super();

		var bmp:BitmapData = FlxGradient.createGradientBitmapData(1280, 72, [0xFFFFFFFF, 0x00000000], 1, 90);
		_gradient = FlxGraphic.fromBitmapData(bmp, true, false);
		_pixel = FlxGraphic.fromBitmapData(new BitmapData(1, 1, false), true, false);

		_matrix = new FlxMatrix();
		_colorTransform = new ColorTransform();

        color = 0xFF000000;
	}

	public function transitionIn(duration:Float = 0.5, ?finishCallback:Void->Void):Void
	{
		var cam:FlxCamera = startCamera();

		if (duration <= 0.0 && finishCallback != null)
		{
			finishCallback();
			return;
		}

		_y = -FlxG.height - (FlxG.height * 0.1);
		_tween = FlxTween.tween(this, {_y: 0.0}, duration, {
			onComplete: (_) ->
			{
				if (finishCallback != null)
					finishCallback();
			}
		});

		_transitionType = true;
	}

	public function transitionOut(duration:Float = 0.5, ?finishCallback:Void->Void):Void
	{
		var cam:FlxCamera = startCamera();

		if (duration <= 0.0 && finishCallback != null)
		{
			finishCallback();
			return;
		}

		_y = 0.0;
		_tween = FlxTween.tween(this, {_y: FlxG.height + (FlxG.height * 0.1)}, duration, {
			onComplete: (_) ->
			{
				if (finishCallback != null)
					finishCallback();
			}
		});

		_transitionType = false;
	}

	public function skipTransition():Void
	{
		if (_tween != null)
		{
			@:privateAccess
			_tween.update(FlxMath.MAX_VALUE_FLOAT);
		}
	}

	private function startCamera():FlxCamera
	{
		var cam:FlxCamera = new FlxCamera();
		cam.bgColor.alpha = 0;
		camera = cam;
		return FlxG.cameras.add(cam, false);
	}

	override function draw()
	{
		_frame = _pixel.imageFrame.frame.copyTo();

		_matrix.identity();

		_frame.prepareMatrix(_matrix);
		_matrix.scale(FlxG.width, FlxG.height);
		_matrix.translate(_x, _y);

		camera.drawPixels(_frame, _frame.parent.bitmap, _matrix, _colorTransform, null, true, null);

		_frame = _gradient.imageFrame.frame.copyTo();
		if (_transitionType)
		{
			_frame.prepareMatrix(_matrix);
			_matrix.translate(_x, _y + FlxG.height);
		}
		else
		{
			_frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, false, true);
			_matrix.translate(_x, _y - _frame.sourceSize.y);
		}

		camera.drawPixels(_frame, _frame.parent.bitmap, _matrix, _colorTransform, null, true, null);

		super.draw();
	}

	private function set_color(newColor:FlxColor):FlxColor
	{
		color = newColor;

		_colorTransform.redMultiplier = color.redFloat;
        _colorTransform.greenMultiplier = color.greenFloat;
        _colorTransform.blueMultiplier = color.blueFloat;

		return newColor;
	}
}
