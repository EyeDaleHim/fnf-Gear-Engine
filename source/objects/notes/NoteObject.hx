package objects.notes;

import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawQuadsItem;
import objects.notes.Note;

// TODO: add some sort of skin file impl, this is only temporary
class NoteObject extends FlxSprite
{
	public static final pixelsPerMS:Float = 0.45;

	public var data:Note;

	public var parentVisible:Bool = false;
	public var sustainVisible:Bool = false;
	public var scrollSpeed:Float = 1.0;

	var _animTimer:Float = 0.0;
	var _sustainAnims:Array<String> = [];

	override public function new(?preallocatedFrames:FlxFramesCollection)
	{
		super();

		frames = preallocatedFrames ?? Assets.frames("ui/game/notes/NOTE_assets");

		animation.addByPrefix("noteLEFT", "purple0", 24);
		animation.addByPrefix("noteDOWN", "blue0", 24);
		animation.addByPrefix("noteUP", "green0", 24);
		animation.addByPrefix("noteRIGHT", "red0", 24);

		animation.addByPrefix("sustainLEFT", "purple hold piece", 24);
		animation.addByPrefix("sustainDOWN", "blue hold piece", 24);
		animation.addByPrefix("sustainUP", "green hold piece", 24);
		animation.addByPrefix("sustainRIGHT", "red hold piece", 24);

		animation.addByPrefix("sustainLEFTend", "pruple end hold", 24);
		animation.addByPrefix("sustainDOWNend", "blue hold end", 24);
		animation.addByPrefix("sustainUPend", "green hold end", 24);
		animation.addByPrefix("sustainRIGHTend", "red hold end", 24);

		scale.set(0.7, 0.7);
		updateHitbox();

		kill();
	}

	public inline function sustainHeight():Float
	{
		return (data?.sustain ?? 0.0) * pixelsPerMS * scrollSpeed;
	}

	override public function update(elapsed:Float)
	{
		if (sustainVisible)
		{
			for (anims in _sustainAnims)
			{
                var animByName = animation.getByName(anims);
				var fps:Float = animByName.frameRate;

				_animTimer += elapsed * FlxG.animationTimeScale;
				var advance = Math.floor(_animTimer * fps);
				_animTimer -= advance / fps;

				if (advance != 0) 
                    animByName.curFrame = FlxMath.wrap(animByName.curFrame + advance, 0, animByName.frames.length);
			}
		}

		super.update(elapsed);
	}

	override public function draw()
	{
		if (sustainVisible)
		{
			var center:Float = height / 2;

			/*for (camera in cameras)
			{
				if (!camera.visible || !camera.exists || !isOnScreen(camera))
					continue;

				var sustainFrame = frames.getByName(animation.getByName(_sustainAnims[0]).parent.);
				var sustainFrameEnd = frames.getByIndex(animation.getByName(_sustainAnims[1]).frames[animation.getByName(_sustainAnims[1]).curFrame]);

				var totalSustainHeight:Float = sustainHeight();
				var sustainY:Float = center;

				var isColored = (colorTransform != null && colorTransform.hasRGBAMultipliers());
				var hasColorOffsets:Bool = (colorTransform != null && colorTransform.hasRGBAOffsets());

				var drawItem:FlxDrawQuadsItem = camera.startQuadBatch(graphic, isColored, hasColorOffsets, blend, antialiasing, shader);

				while (totalSustainHeight > sustainFrameEnd.sourceSize.y)
				{
					sustainFrame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());

					_matrix.translate(-origin.x, -origin.y);
					_matrix.scale(scale.x, 1.0);
			
					if (bakedRotationAngle <= 0)
					{
						updateTrig();
			
						if (angle != 0)
							_matrix.rotateWithTrig(_cosAngle, _sinAngle);
					}

					getScreenPosition(_point, camera).subtractPoint(offset);
					_point.add(sustainY);
					_point.add(origin.x, origin.y);
					_matrix.translate(_point.x, _point.y);

					if (isPixelPerfectRender(camera))
					{
						_matrix.tx = Math.floor(_matrix.tx);
						_matrix.ty = Math.floor(_matrix.ty);
					}

					drawItem.addQuad(sustainFrame, _matrix, colorTransform);

					sustainY += sustainFrame.sourceSize.y;
					totalSustainHeight -= sustainFrame.sourceSize.y;
				}
			}*/
		}

		if (parentVisible)
			super.draw();
	}

	public function setData(newData:Note)
	{
		data = newData;
		sustainVisible = newData.sustain > 0;
		parentVisible = true;

		var noteName:String = switch (data.lane)
		{
			case 0:
				"noteLEFT";
			case 1:
				"noteDOWN";
			case 2:
				"noteUP";
			case 3:
				"noteRIGHT";
			default:
				"noteLEFT";
		};

		_sustainAnims.splice(0, _sustainAnims.length);

		_sustainAnims.push(switch (data.lane)
		{
			case 0:
				"sustainLEFT";
			case 1:
				"sustainDOWN";
			case 2:
				"sustainUP";
			case 3:
				"sustainRIGHT";
			default:
				"sustainLEFT";
		});

		_sustainAnims.push(switch (data.lane)
		{
			case 0:
				"sustainLEFTend";
			case 1:
				"sustainDOWNend";
			case 2:
				"sustainUPend";
			case 3:
				"sustainRIGHTend";
			default:
				"sustainLEFTend";
		});

		animation.play(noteName);
	}

	public function killNote():Void
	{
		kill();
		sustainVisible = false;
		data = null;
	}
}
