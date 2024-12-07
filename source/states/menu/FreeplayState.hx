package states.menu;

import lime.app.Future;
import states.internal.Page;

class FreeplayState extends Page
{
	public var index:Int = 0;
	public var diffIndex:Int = 0;

	public var background:FlxSprite;
	public var songItems:AtlasTextGroup;

	public var playMusicTimer:FlxTimer;

	public var music:FlxSound;

	private var musicFuture:Future<Void>;
	private var playedSongIndex:Int = -1;

	public function new()
	{
		super();

		music = new FlxSound();
		FlxG.sound.list.add(music);

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

		changeItem();
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ESCAPE)
			switchPage('menu');
		if (Control.UI_UP.justPressed)
			changeItem(-1);
		if (Control.UI_DOWN.justPressed)
			changeItem(1);

		super.update(elapsed);
	}

	override public function kill()
	{
		super.kill();

		if (music.playing)
		{
			music.fadeOut((_) ->
			{
				if (FlxG.sound.music != null)
				{
					FlxG.sound.music.resume();
					FlxG.sound.music.fadeIn();
				}
			});
		}
	}

	override public function revive()
	{
		super.revive();

		musicFuture = new Future<Void>(loadSelectedSong, true);
	}

	public function changeItem(change:Int = 0):Void
	{
		index = FlxMath.wrap(index + change, 0, songItems.length - 1);

		if (change != 0)
			FlxG.sound.play(Assets.sound("sfx/menu/scrollMenu"), 0.5);

		songItems.selectedText.alpha = 0.6;
		songItems.selected = index;
		songItems.selectedText.alpha = 1.0;

		playMusicTimer.cancel();
		playMusicTimer.start(1.0, (tmr:FlxTimer) ->
		{
			if (playedSongIndex != index)
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
		var item = SongList.list[playedSongIndex];

		if (music.playing)
		{
			music.fadeOut((_) ->
			{
				music.stop();
				music.loadEmbedded(Assets.levelSongTrack(item.name, item.track, true), true);

				FlxTimer.wait(0.2, () ->
				{
					music.play();
				});
			});
		}
		else if (FlxG.sound.music != null)
		{
			music.loadEmbedded(Assets.levelSongTrack(item.name, item.track, true), true);

			FlxG.sound.music.fadeOut((_) ->
			{
				FlxTimer.wait(0.2, () ->
				{
					music.play();
				});
			});
		}
		else
		{
			music.loadEmbedded(Assets.levelSongTrack(item.name, item.track, true), true);
			FlxTimer.wait(0.2, () ->
			{
				music.play();
			});
		}
	}
}
