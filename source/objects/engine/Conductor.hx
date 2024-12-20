package objects.engine;

class Conductor extends FlxBasic
{
	public static var instance:Conductor;

	public var mainChannel(get, set):FlxSound;
	public var channels:Array<FlxSound> = [];

	public var onStep:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public var onBeat:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public var onMeasure:FlxTypedSignal<Int->Void> = new FlxTypedSignal();

	public var beat(null, default):Float = 0.0;
	public var step(null, default):Float = 0.0;
	public var measure(null, default):Float = 0.0;

	public var position:Float = 0.0;
	public var offset:Float = 0.0;

	public var bpm:Float = 100.0;
	public var crochet(get, never):Float;
	public var stepCrochet(get, never):Float;

	public var bounds:Float = 20.0;

	public var callMissingCallbacks:Bool = true;

	private var lastBeat(null, default):Int = -1;
	private var lastStep(null, default):Int = -1;
	private var lastMeasure(null, default):Int = -1;

	private var lastTime:Float = 0.0;
	private var resyncTimer:Float = 0.0;

	public function new()
	{
		super();

		active = false;
	}

	override public function update(elapsed:Float)
	{
		updatePosition(elapsed);
		syncChannels();

		super.update(elapsed);
	}

	// courtesy of Rudyrue & StepMania, ty!
	public function updatePosition(delta:Float):Void
	{
		final addition:Float = (delta * 1000);

		if (mainChannel == null || !mainChannel.playing)
		{
			position += addition;
			return;
		}

		if (mainChannel.time == lastTime)
			resyncTimer += addition;
		else
			resyncTimer = 0.0;

		position = (mainChannel.time + resyncTimer) + offset;
		lastTime = mainChannel.time;

		step = position / stepCrochet;
		beat = step / 4;
		measure = beat / 4;

		if (lastBeat != getBeat())
		{
			if (callMissingCallbacks)
			{
				var missing:Int = getBeat().floor() - lastBeat;

				for (i in 0...missing)
				{
					onBeat.dispatch(lastBeat + i);
				}
			}
			else
			{
				onBeat.dispatch(getBeat().floor());
			}

			lastBeat = getBeat().floor();
		}

		if (lastStep != getStep())
		{
			if (callMissingCallbacks)
			{
				var missing:Int = getStep().floor() - lastStep;

				for (i in 0...missing)
				{
					onStep.dispatch(lastStep + i);
				}
			}
			else
			{
				onStep.dispatch(getStep().floor());
			}

			lastStep = getStep().floor();
		}

		if (lastMeasure != getMeasure())
		{
			if (callMissingCallbacks)
			{
				var missing:Int = getMeasure().floor() - lastMeasure;

				for (i in 0...missing)
				{
					onMeasure.dispatch(lastMeasure + i);
				}
			}
			else
			{
				onMeasure.dispatch(getMeasure().floor());
			}

			lastMeasure = getMeasure().floor();
		}
	}

	public function syncChannels(?force:Bool = false):Void
	{
		if (mainChannel == null || !mainChannel.playing)
			return;

		final mainPosition:Float = mainChannel.time;

		for (i in 1...channels.length)
		{
			var channel = channels[i];

			if (channel == null || !channel.playing || channel.length < mainPosition)
				continue;

			final deltaTime:Float = Math.abs(channel.time - mainPosition);

			if (force)
				channel.time = mainPosition;
			else
				channel.time = deltaTime >= bounds ? mainPosition : channel.time;
		}
	}

	public function getBeat(floor:Bool = true):Float
	{
		if (floor)
			return beat.floor();
		return beat;
	}

	public function getStep(floor:Bool = true):Float
	{
		if (floor)
			return step.floor();
		return step;
	}

	public function getMeasure(floor:Bool = true):Float
	{
		if (floor)
			return measure.floor();
		return measure;
	}

	public function clearCallbacks():Void
	{
		onStep.removeAll();
		onBeat.removeAll();
		onMeasure.removeAll();
	}

	public function clearChannels(?destroyChannels:Bool = false):Void
	{
		pause();
		for (channel in channels)
		{
			if (destroyChannels)
				channel.destroy();
			FlxG.sound.list.remove(channel);
		}

		channels.resize(0);

		position = 0.0;
		offset = 0.0;

		lastTime = 0.0;
		resyncTimer = 0.0;
	}

	public function clear():Void
	{
		clearChannels();
		clearCallbacks();
	}

	public function pause():Void
	{
		for (channel in channels)
		{
			if (channel?.playing)
				channel.pause();
		}

		active = false;
	}

	public function play():Void
	{
		for (channel in channels)
		{
			if (!channel?.playing)
				channel.stop();
			channel.play();
		}

		position = 0.0;
		active = true;
	}

	public function resume():Void
	{
		for (channel in channels)
		{
			if (!channel?.playing)
				channel.resume();
		}

		active = true;
	}

	function get_mainChannel():FlxSound
	{
		return channels[0];
	}

	function set_mainChannel(newSound:FlxSound):FlxSound
	{
		if (newSound != null)
			FlxG.sound.list.add(newSound);

		return channels[0] = newSound;
	}

	function get_crochet():Float
	{
		return ((60 / bpm) * 1000);
	}

	function get_stepCrochet():Float
	{
		return crochet / 4;
	}
}
