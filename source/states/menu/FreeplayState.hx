package states.menu;

import lime.app.Future;
import states.internal.Page;

class FreeplayState extends Page
{
	public var index:Int = 0;
	public var diffIndex:Int = 1;

	public var background:FlxSprite;
	public var songItems:AtlasTextGroup;

	public var scoreBox:Box;
	public var scoreText:Text;
	public var difficultyText:Text;

	public var playMusicTimer:FlxTimer;

	public var music:FlxSound;

	private var musicFuture:Future<Void>;
	private var playedSongIndex:Int = -1;

	public function new()
	{
		super();

		music = new FlxSound();

		playMusicTimer = new FlxTimer();

		background = new FlxSprite(Assets.image('menus/backgrounds/freeplayBG'));
		background.active = false;
		add(background);

		var songPlaylist:Array<String> = [for (song in SongList.list) song.display ?? song.name];

		songItems = new AtlasTextGroup(songPlaylist, (text) ->
		{
			text.bold = true;
			text.alpha = 0.6;
		});
		add(songItems);

		scoreBox = new Box(FlxG.width * 0.6, 0, FlxG.width * 0.4, 66, 16, 2);
		scoreBox.color = 0xFF000000;
		scoreBox.alpha = 0.6;
		scoreBox.x -= 4.0;
		scoreBox.y += 4.0;
		add(scoreBox);

		scoreText = new Text("PERSONAL BEST: 0");
		scoreText.setFormat(Assets.fontByName('vcr'), 32, FlxColor.WHITE);
		scoreText.anchor = TOP_MIDDLE;
		scoreText.parent = scoreBox;
		add(scoreText);

		difficultyText = new Text("< NORMAL >");
		difficultyText.setFormat(Assets.fontByName('vcr'), 24, FlxColor.WHITE);
		difficultyText.anchor = BOTTOM_MIDDLE;
		difficultyText.parent = scoreBox;
		difficultyText.y -= 4.0;
		add(difficultyText);

		changeItem();
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ESCAPE)
		{
			if (music.playing)
			{
				music.fadeOut(0.5, (_) ->
				{
					parent.conductor.clearChannels();
	
					if (parent.music != null)
					{
						parent.conductor.mainChannel = parent.music;
						parent.conductor.resume();
						parent.music.fadeIn();
					}
				});
			}

			switchPage('menu');
		}
		if (FlxG.keys.justPressed.ENTER)
			selectItem();
		if (Control.UI_UP.justPressed)
			changeItem(-1);
		if (Control.UI_DOWN.justPressed)
			changeItem(1);
		if (Control.UI_LEFT.justPressed)
			changeDifficulty(-1);
		if (Control.UI_RIGHT.justPressed)
			changeDifficulty(1);

		scoreBox.setSize(scoreText.width + 32, scoreBox.height);
		scoreBox.x = FlxG.width - scoreBox.width - 4.0;

		super.update(elapsed);
	}

	override public function revive()
	{
		super.revive();

		checkMenuSong();
		startSongTimer(true);
	}

	public function selectItem():Void
	{
		FlxG.switchState(() -> new states.play.PlayState());
	}

	public function changeItem(change:Int = 0):Void
	{
		index = FlxMath.wrap(index + change, 0, songItems.length - 1);

		if (change != 0)
			FlxG.sound.play(Assets.sound("sfx/menu/scrollMenu"), 0.5);

		songItems.selectedText.alpha = 0.6;
		songItems.selected = index;
		songItems.selectedText.alpha = 1.0;

		changeDifficulty();

		startSongTimer();
	}

	public function changeDifficulty(change:Int = 0)
	{
		var selectedSong = SongList.list[index];
		diffIndex = FlxMath.bound(diffIndex + change, 0, selectedSong.difficulties.length - 1).floor();

		if (change != 0)
			FlxG.sound.play(Assets.sound("sfx/menu/scrollMenu"), 0.1);

		difficultyText.text = '< ${selectedSong.difficulties[diffIndex].toUpperCase()} >';

		randomScore();
	}

	private var twn:FlxTween;
	private var score:Int = 0;

	private function randomScore():Void
	{
		twn = FlxTween.num(score, FlxG.random.int(1, 2500) * 350, 0.1, (v) ->
		{
			score = v.floor();
			scoreText.text = 'PERSONAL BEST: ${score}';
		});
	}

	private function startSongTimer(?force:Bool = false):Void
	{
		playMusicTimer.cancel();
		playMusicTimer.start(1.0, (tmr:FlxTimer) ->
		{
			if (force || playedSongIndex != index)
			{
				playedSongIndex = index;
				musicFuture = new Future<Void>(loadSelectedSong, true);
			}
		});
	}

	private function loadSelectedSong():Void
	{
		var item = SongList.list[playedSongIndex];
		if (item.track == null)
			return;

		Assets.levelSongTrack(item.name, item.track, true);
		songLoadComplete();
	}

	private function songLoadComplete():Void
	{
		if (!exists)
			return;

		var item = SongList.list[playedSongIndex];

		if (parent.music.playing)
		{
			parent.music.fadeOut((_) ->
			{
				parent.music.pause();
			});
		}

		if (music.playing)
		{
			music.fadeOut((_) ->
			{
				music.stop();
			});
		}

		FlxTimer.wait(1.2, () ->
		{
			music.loadEmbedded(Assets.levelSongTrack(item.name, item.track, true), true);

			parent.conductor.clearChannels();
			parent.conductor.mainChannel = music;
			parent.conductor.play();
		});
	}
}
