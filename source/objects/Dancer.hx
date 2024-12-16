package objects;

class Dancer extends FlxSprite
{
	public var animationLength:Float = 0.0;

	public var bopList:Array<String> = [];
	public var bopIndex:Int = 0;
	public var bopActive:Bool = true;

	public var animOffsets:Map<String, FlxPoint> = [];
	public var globalOffset:FlxPoint = FlxPoint.get();

	public function new(?x:Float = 0.0, ?y:Float = 0.0, imagePath:String, ?xmlPath:String)
	{
		super(x, y);

		frames = Assets.frames(imagePath, xmlPath);
	}

	override public function update(elapsed:Float)
	{
		if (bopActive && bopList.length > 0)
		{
			animationLength -= elapsed;

			if (animationLength < 0.0)
			{
				playBop(bopIndex);
				bopIndex = FlxMath.wrap(bopIndex + 1, 0, bopList.length - 1);
			}
		}

		super.update(elapsed);
	}

	public function playBop(?forceBop:Int = -1):Void
	{
		if (forceBop != -1)
			bopIndex = forceBop;

		if (animation.exists(bopList[bopIndex]))
			playAnimation(bopList[bopIndex], true);
	}

	public function pushAnimationToBopList(name:String)
	{
		if (animation.exists(name))
			bopList.push(name);
	}

	public function unshiftAnimationToBopList(name:String)
	{
		if (animation.exists(name))
			bopList.unshift(name);
	}

	public function playAnimation(name:String, force:Bool = false, frame:Int = 0, ?animationLength:Float = 0.0):Void
	{
		animation.play(name, force);

		offset.copyFrom(globalOffset);

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
