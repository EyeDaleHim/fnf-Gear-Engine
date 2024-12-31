package states.play;

import assets.formats.ChartFormat;
import assets.formats.SongFormat;
import objects.notes.Note;
import objects.play.Countdown;
import objects.play.PlayField;
import openfl.events.KeyboardEvent;
import lime.app.Future;

typedef Level =
{
	var ?chart:ChartFormat;
	var ?song:SongFormat;
};

class PlayState extends MainState
{
	public static var instance:PlayState;
	public static function loadGame(playlist:Array<Level>, story:Bool, finishCallback:PlayState->Void):Void
	{
		var future:Future<Void> = new Future<Void>(() ->
		{
			try
			{
				var newState:PlayState = new PlayState(playlist, story);
				instance = newState;

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

	public var controls:Array<Control> = [Control.NOTE_LEFT, Control.NOTE_DOWN, Control.NOTE_UP, Control.NOTE_RIGHT];

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

		add(tweenManager);
		add(timerManager);

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

		loadSong();
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

		var tmr = FlxTimer.wait(0.5, () ->
		{
			playfield.start(conductor.crochet / 1000, startSong);
			for (strumline in playfield.strumlines)
			{
				strumline.fadeIn(tweenManager, timerManager);
			}
		});
		tmr.manager = timerManager;

		conductor.position = 0;
		conductor.bpm = chart?.bpm ?? song?.bpm ?? 100;

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, keyRelease);

		super.create();
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
	}

	override public function update(elapsed:Float)
	{
		if (playfield.positionControlled)
			playfield.position = conductor.position;

		super.update(elapsed);
	}

	public function keyPress(event:KeyboardEvent)
	{
		var dir:Int = checkKeyCode(event.keyCode);

		if (dir != -1 && FlxG.keys.checkStatus(event.keyCode, JUST_PRESSED))
		{
			var confirm:Bool = false;

			playfield.forEachStrumPlayable((strum) ->
			{
				if (!confirm)
				{
					strum.members[dir].playAnimation(strum.members[dir].pressAnim, true);
					strum.members[dir].decrementLength = false;
				}
				else
				{
					strum.members[dir].playAnimation(strum.members[dir].confirmAnim, true);
					strum.members[dir].decrementLength = false;
				}
			}, chart?.playables);
		}
	}

	public function keyRelease(event:KeyboardEvent)
	{
		var dir:Int = checkKeyCode(event.keyCode);

		if (dir != -1 && FlxG.keys.checkStatus(event.keyCode, JUST_RELEASED))
		{
			for (strum in playfield.strumlines)
			{
				strum.members[dir].playAnimation(strum.members[dir].staticAnim, true);
				strum.members[dir].decrementLength = true;
			}
		}
	}

	public function checkKeyCode(keyCode:Int = -1)
	{
		if (keyCode != -1)
		{
			for (control in controls)
			{
				for (key in control.keys)
				{
					if (key == keyCode)
						return controls.indexOf(control);
				}
			}
		}
		return -1;
	}

	override function startOutro(onOutroComplete:Void->Void)
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, keyRelease);

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
