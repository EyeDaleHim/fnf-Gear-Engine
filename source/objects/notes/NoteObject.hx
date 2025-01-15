package objects.notes;

import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawQuadsItem;
import objects.notes.Note;
import objects.notes.SustainTrail;

// TODO: add some sort of skin file impl, this is only temporary
class NoteObject extends FlxSprite
{
	public static final pixelsPerMS:Float = 0.45;

	public var data:Note;
	public var sustain:SustainTrail;

	public var parentVisible:Bool = false;
	public var sustainVisible:Bool = false;
	public var scrollSpeed:Float = 1.0;

	var _animTimer:Float = 0.0;
	var _sustainAnims:Array<String> = [];

	override public function new(?preallocatedFrames:FlxFramesCollection)
	{
		super();

		frames = preallocatedFrames ?? Assets.frames("ui/game/notes/NOTE_assets");
		sustain = new SustainTrail(this, frames);

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

	override public function update(elapsed:Float)
	{
		if (sustainVisible)
			sustain.update(elapsed);
		super.update(elapsed);
	}

	override public function draw()
	{
		if (sustainVisible)
			sustain.draw();

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

		sustain.bodyAnimation = animation.getByName(switch (data.lane)
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

		sustain.endAnimation = animation.getByName(switch (data.lane)
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
