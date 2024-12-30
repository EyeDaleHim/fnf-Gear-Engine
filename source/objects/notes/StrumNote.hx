package objects.notes;

class StrumNote extends FlxSprite
{
	public var animationLength:Float = 0.0;
	public var decrementLength:Bool = true;

	public var direction:Int = 0;
	public var confirmAnim:String = 'confirm';
	public var pressAnim:String = 'press';
	public var staticAnim:String = 'static';

	public var strumAngle:Float = 0.0;

	private var animOffsets:Map<String, FlxPoint> = [];

	public function new(direction:Int = 0, angle:Float = 0.0)
	{
		super();

		this.direction = direction;
		this.strumAngle = angle;

		frames = Assets.frames('ui/game/notes/NOTE_assets');

		// temp stand-ins, implementt skins later
		animation.addByPrefix(staticAnim,
			if (direction == 0) "arrowLEFT" else if (direction == 1) "arrowDOWN" else if (direction == 2) "arrowUP" else "arrowRIGHT");
		animation.addByPrefix(pressAnim,
			if (direction == 0) "left press" else if (direction == 1) "down press" else if (direction == 2) "up press" else "right press", 24, false);
		animation.addByPrefix(confirmAnim,
			if (direction == 0) "left confirm" else if (direction == 1) "down confirm" else if (direction == 2) "up confirm" else "right confirm", 24, false);

		animation.play(staticAnim);

		scale.set(0.7, 0.7);
		updateHitbox();

		antialiasing = true;
	}

	override public function update(elapsed:Float)
	{
		if (animationLength > 0.0)
		{
			if (decrementLength)
				animationLength -= elapsed;
		}
        else if (animation.curAnim?.name != staticAnim)
            playAnimation(staticAnim);

		super.update(elapsed);
	}

	public function playAnimation(name:String, force:Bool = false, frame:Int = 0, ?animationLength:Float = 0.0):Void
	{
		animation.play(name, force);

		centerOffsets();
		centerOrigin();

		if (animOffsets.exists(name))
			offset += animOffsets.get(name);

		animationLength = Math.max(animationLength, 0);
		if (animationLength == 0 && animation.curAnim != null)
		{
			// TODO: i hear some frames have their own duration? look into that further
			this.animationLength = (animation.curAnim.numFrames - frame) / animation.curAnim.frameRate;
		}
	}
}
