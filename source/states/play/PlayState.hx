package states.play;

import assets.formats.ChartFormat;
import assets.formats.SongFormat;

import objects.play.Countdown;
import objects.play.PlayField;

import lime.app.Future;

typedef Level =
{
	var ?chart:ChartFormat;
	var ?song:SongFormat;
};

class PlayState extends MainState
{
	public static function loadGame(playlist:Array<Level>, story:Bool, finishCallback:PlayState->Void):Void
	{
		var future:Future<Void> = new Future<Void>(() ->
		{
			try
			{
				var newState:PlayState = new PlayState(playlist, story);

				if (finishCallback != null)
					finishCallback(newState);
			}
			catch (e)
			{
				trace(e.stack);
				trace(e.message);
			}
		}, true);
	}

	public var tweenManager:FlxTweenManager;
	public var timerManager:FlxTimerManager;

	public var songStarted:Bool = false;

	public var pauseMenu:PauseSubstate;

	public var hudCamera:FlxCamera;
	public var pauseCamera:FlxCamera;

	public var playfield:PlayField;

	public var storyMode:Bool = false;
	public var playlist:Array<Level> = [];

	public var chart(get, set):ChartFormat;
	public var song(get, set):SongFormat;

	// internal variables to use upon create()
	var _trackList:Array<FlxSound> = [];

	public function new(playlist:Array<Level>, story:Bool = false)
	{
		super();

		FlxG.fixedTimestep = false;

		playlist ??= [];

		hudCamera = new FlxCamera();
		hudCamera.bgColor.alpha = 0;

		tweenManager = new FlxTweenManager();
		timerManager = new FlxTimerManager();

		playfield = new PlayField(tweenManager, timerManager, 2);
		playfield.camera = hudCamera;
		add(playfield);

		storyMode = story;
		this.playlist = playlist;

		var trackList:Array<FlxSound> = [];
		var trackSource:Array<String> = [];

		trackSource = chart?.tracks ?? song?.tracks ?? [];

		for (i in 0...trackSource.length)
		{
			trackList[i] = FlxG.sound.load(Assets.levelSongTrack(song.name, trackSource[i], true));
			trackList[i].looped = true;
			trackList[i].persist = true;
		}
		_trackList = trackList;
	}

	override public function create()
	{
		@:privateAccess
		{
			_constructor = function():FlxState
			{
				return new PlayState(playlist, storyMode);
			}
		}

		conductor.clear();
		conductor.channels = _trackList;

		FlxG.cameras.add(hudCamera);

		FlxTimer.wait(0.5, () ->
		{
			playfield.countdown.start(conductor.crochet / 1000, startSong);
		});

		conductor.position = 0;
		conductor.bpm = chart?.bpm ?? song?.bpm ?? 100;

		super.create();
	}

	public function startSong():Void
	{
		songStarted = true;
		conductor.play();
	}

	public function loadSong():Void {}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function get_chart():ChartFormat
	{
		if (playlist[0] == null)
			return null;

		return playlist[0].chart;
	}

	function set_chart(chart:ChartFormat):ChartFormat
	{
		if (playlist[0] == null)
			playlist[0] = {};

		return playlist[0].chart = chart;
	}

	function get_song():SongFormat
	{
		if (playlist[0] == null)
			return null;

		return playlist[0].song;
	}

	function set_song(song:SongFormat):SongFormat
	{
		if (playlist[0] == null)
			playlist[0] = {};

		return playlist[0].song = song;
	}
}
