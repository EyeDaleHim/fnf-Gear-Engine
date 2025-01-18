package states.play;

import assets.formats.ChartFormat;
import assets.formats.SongFormat;
import assets.formats.StageFormat;
import objects.notes.Note;
import objects.notes.NoteObject;
import objects.play.PlayField;
import objects.play.Stage;
import lime.app.Future;

typedef Level =
{
	var ?chart:ChartFormat;
	var ?song:SongFormat;
};

class PlayState extends MainState
{
	public static var instance:PlayState;

	public static function loadGame(playlist:Array<Level>, story:Bool, finishCallback:PlayState->Void, ?errorCallback:Void->Void):Void
	{
		var wasError:Bool = false;
		var future:Future<PlayState> = new Future<PlayState>(() ->
		{
			try
			{
				var newState:PlayState = new PlayState(playlist, story);
				instance = newState;

				return instance;
			}
			catch (e)
			{
				instance = null;
				wasError = true;

				trace(e.stack);
				trace(e.message);

				if (errorCallback != null)
					errorCallback();

				return null;
			}

			return null;
		}, true);

		future.onComplete((_) ->
		{
			if (!wasError && finishCallback != null)
				finishCallback(instance);
		});
	}

	public var tweenManager:FlxTweenManager;
	public var timerManager:TimerManager;

	public var songStarted:Bool = false;
	public var songEnded:Bool = false;

	public var pauseMenu:PauseSubstate;

	public var gameCamera:FlxCamera;
	public var hudCamera:FlxCamera;
	public var pauseCamera:FlxCamera;

	public var stage:Stage;
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

		playlist ??= [];

		gameCamera = new FlxCamera();

		hudCamera = new FlxCamera();
		hudCamera.bgColor.alpha = 0;

		tweenManager = new FlxTweenManager();
		timerManager = new TimerManager();

		add(tweenManager);
		add(timerManager);

		var stageData:StageFormat = null;

		try
		{
			stageData = Json.parse(Assets.contents('assets/stages/${chart?.stage}.json'));
		}
		catch (e)
		{
			FlxG.log.error('Could not find stage ${chart?.stage}');
		}

		stage = new Stage(chart?.stage, stageData);
		stage.camera = gameCamera;
		add(stage);

		playfield = new PlayField(tweenManager, timerManager, 2);
		playfield.level = playlist[0];
		playfield.camera = hudCamera;
		add(playfield);

		storyMode = story;
		this.playlist = playlist;

		var trackList:Array<FlxSound> = [];
		var trackSource:Array<String> = [];

		trackSource = chart?.tracks ?? song?.tracks ?? [];

		var longest:FlxSound = null;

		var missing:Array<String> = [];

		for (i in 0...trackSource.length)
		{
			var newTrack:FlxSound;
			newTrack = FlxG.sound.load(Assets.levelSongTrack(song.name, trackSource[i], true));
			if (newTrack != null)
			{
				newTrack.looped = false;
				newTrack.persist = true;
				if (longest == null || longest.length < newTrack.length)
					longest = newTrack;

				trackList[i] = newTrack;
			}
			else
				missing.push(trackSource[i]);
		}

		if (longest != null)
		{
			longest.onComplete = endSong;
			playfield.songLength = longest.length;
		}

		_trackList = trackList;

		loadSong();
	}

	override public function create()
	{
		// TODO: find a way to do this officially!
		@:privateAccess
		{
			_constructor = function():FlxState
			{
				return new PlayState(playlist, storyMode);
			}
		}

		conductor.clear();
		conductor.channels = _trackList;

		FlxG.cameras.reset(gameCamera);
		FlxG.cameras.add(stage.freeflyCamera, false);
		FlxG.cameras.add(hudCamera, false);

		stage.initStageCameras(gameCamera, hudCamera);

		FlxG.camera.follow(stage.camFollow, 1.0);

		startCountdown();

		conductor.onBeat.add(playfield.beatHit);

		super.create();
	}

	public function startCountdown():Void
	{
		var tmr = FlxTimer.wait(0.5, () ->
		{
			playfield.start(conductor.crochet / 1000, startSong);
			for (strumline in playfield.strumlines)
			{
				strumline.fadeIn(tweenManager, timerManager);
			}
		});
		tmr.manager = timerManager;

		conductor.position = -5000;
		conductor.bpm = chart?.bpm ?? song?.bpm ?? 100;
	}

	public function startSong():Void
	{
		songStarted = true;

		conductor.play();
	}

	public function loadSong():Void
	{
		var noteList:Array<Note> = [];

		if (chart != null)
		{
			for (i in 0...chart.notes?.length)
			{
				var note:Note = chart.notes[i];
				var copiedNote:Note = [];

				for (j in 0...note.length)
				{
					copiedNote[j] = note[j];
				}
				if (copiedNote != null)
					noteList.push(copiedNote);
			}
		}

		playfield.pendingNotes = noteList;

		playfield.speed = chart?.speed ?? 1.0;
		playfield.ratingsData = chart?.ratingFormat ?? song.ratingFormat ?? playfield.ratingsData;
	}

	override public function update(elapsed:Float)
	{
		if (playfield.positionControlled)
			playfield.position = conductor.position;

		if (MainState.debugMode)
		{
			if (FlxG.keys.justPressed.F1 && FlxG.keys.pressed.SHIFT)
				stage.toggleFreeflyCamera();

		}

		super.update(elapsed);
	}

	public function restartSong(time:Float = 0.5):Void
	{
		songEnded = false;
		songStarted = false;

		conductor.pause();

		playfield.notes.forEachAlive((note) ->
		{
			tweenManager.tween(note, {alpha: 0.0}, time);
		});

		timerManager.start(time, () ->
		{
			loadSong();
			playfield.position = -5000;

			startCountdown();
		});
	}

	public function endSong():Void
	{
		songEnded = true;

		trace(playlist);
		playlist.shift();
		trace(playlist);

		if (playlist.length > 0)
		{
			restartSong(1.0);
			tweenManager.tween(playfield, {health: playfield.maxHealth / 2.0}, 0.5, {ease: FlxEase.expoOut});
			playfield.reset();
		}
		else
		{
			FlxG.switchState(() -> new PageState('freeplay'));
		}
	}

	override function startOutro(onOutroComplete:Void->Void)
	{
		playfield.removeInputListeners();

		conductor.onBeat.removeAll();
		conductor.onStep.removeAll();
		conductor.onMeasure.removeAll();

		super.startOutro(onOutroComplete);
	}

	override function destroy()
	{
		instance = null;
		super.destroy();
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
