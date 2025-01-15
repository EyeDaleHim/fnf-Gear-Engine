package states.menu;

import assets.formats.SongFormat;
import assets.formats.ChartFormat;
import objects.Icon;
import lime.app.Future;
import states.internal.Page;

class FreeplayState extends Page
{
	public var index:Int = 0;
	public var diffIndex:Int = 1;

	public var background:FlxSprite;
	public var songItems:AtlasTextGroup;
	public var iconGroup:FlxTypedGroup<Icon>;

	public var scoreBox:Box;
	public var scoreText:Text;
	public var difficultyText:Text;

	public var musics:Array<FlxSound> = [];

	private var musicFuture:Future<Void>;
	private var playedSongIndex:Int = -1;
	private var playedDiffIndex:Int = -1;
	private var playedTracks:Array<String> = [];

	private var waitPreviewTimer:FlxTimer;
	private var previewTimer:FlxTimer;

	public function new()
	{
		super();

		waitPreviewTimer = new FlxTimer();

		background = new FlxSprite(Assets.image('menus/backgrounds/freeplayBG'));
		background.active = false;
		add(background);

		var songPlaylist:Array<String> = [for (song in SongList.list) song.display ?? song.name];
		var iconDisplays:Array<String> = [for (song in SongList.list) song.freeplayDisplay ?? ""];

		songItems = new AtlasTextGroup(songPlaylist, (text) ->
		{
			text.bold = true;
			text.alpha = 0.6;
		});
		add(songItems);

		iconGroup = new FlxTypedGroup<Icon>();

		var i:Int = 0;
		for (iconName in iconDisplays)
		{
			var icon:Icon = new Icon(Icon.freeplayPath, iconName ?? "bf");
			icon.ID = i;

			if (iconName.length == 0)
				icon.color = 0xFF767676;

			if (icon.frames != null)
			{
				icon.animation.addByPrefix('idle', 'idle', 10, true);
				icon.animation.addByPrefix('confirm', 'confirm0', 10, false);
				icon.animation.addByPrefix('confirm-hold', 'confirm-hold', 10, false);

				icon.setGraphicSize(150);
				icon.updateHitbox();
			}
			else
			{
				icon.animation.add('idle', [0]);
			}

			icon.animation.onFinish.add((name:String) ->
			{
				if (name == "confirm")
					icon.animation.play('confirm-hold');
			});

			icon.animation.play('idle');

			iconGroup.add(icon);

			i++;
		}

		add(iconGroup);

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
			interruptSongPreview();

			if (musics.length > 0 && musics[0].playing)
			{
				FlxTween.num(1.0, 0.0, 0.5, {
					onComplete: (_) ->
					{
						parent.conductor.clearChannels();

						if (parent.music != null)
						{
							parent.conductor.mainChannel = parent.music;
							parent.conductor.resume();
							parent.music.fadeIn();
						}
					}
				}, (v) ->
					{
						for (music in musics)
						{
							music.volume = v;
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

		iconGroup.forEach((icon:Icon) ->
		{
			icon.x = songItems.members[icon.ID].x + songItems.members[icon.ID].width + 10;
			icon.centerOverlay(songItems.members[icon.ID], Y);
		});
	}

	override public function revive()
	{
		super.revive();

		checkMenuSong();
		startPreviewTimer(true);
	}

	public function selectItem():Void
	{
		interruptSongPreview();

		if (parent.music.playing)
		{
			parent.music.fadeOut((_) ->
			{
				parent.music.pause();
			});
		}

		for (music in musics)
		{
			if (music.playing)
			{
				music.fadeOut(0.5, (_) ->
				{
					music.stop();
				});
			}
		}

		if (iconGroup.members[index].animation.exists('confirm'))
			iconGroup.members[index].animation.play('confirm');

		PlayState.loadGame([
			{song: SongList.list[index], chart: ChartList.getChart(SongList.list[index].name, diffIndex)}
		], false, (newState) ->
			{
				parent.conductor.clear();

				FlxG.switchState(() -> newState);
			});
	}

	public function changeItem(change:Int = 0):Void
	{
		index = FlxMath.wrap(index + change, 0, songItems.length - 1);

		if (change != 0)
			FlxG.sound.play(Assets.sound("sfx/menu/scrollMenu"), 0.5);

		iconGroup.members[songItems.selected].alpha = songItems.selectedText.alpha = 0.6;
		songItems.selected = index;
		iconGroup.members[songItems.selected].alpha = songItems.selectedText.alpha = 1.0;

		changeDifficulty();
	}

	public function changeDifficulty(change:Int = 0)
	{
		var selectedSong = SongList.list[index];
		diffIndex = FlxMath.bound(diffIndex + change, 0, selectedSong.difficulties.length - 1).floor();

		if (change != 0)
			FlxG.sound.play(Assets.sound("sfx/menu/scrollMenu"), 0.1);

		difficultyText.text = '< ${selectedSong.difficulties[diffIndex].toUpperCase()} >';

		randomScore();

		startPreviewTimer();
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

	private function startPreviewTimer(?force:Bool = false):Void
	{
		waitPreviewTimer.cancel();
		waitPreviewTimer.start(1.0, (tmr:FlxTimer) ->
		{
			if (force || (playedSongIndex != index || playedDiffIndex != diffIndex))
			{
				playedDiffIndex = diffIndex;
				playedSongIndex = index;
				musicFuture = new Future<Void>(loadSelectedSong, true);
			}
		});
	}

	private function loadSelectedSong():Void
	{
		// NOTE: I think I need to improve how the chart is grabbed here
		var songItem:SongFormat = SongList.list[playedSongIndex];
		var chartItem:ChartFormat = SongList.chartsByName.get(songItem.name).get(songItem.difficulties[diffIndex]);

		var item:Dynamic = null;
		var tracks:Array<String> = [];

		if (chartItem?.tracks?.length > 0)
		{
			tracks = chartItem.tracks;
			item = chartItem;

			trace('got $tracks from chart');
		}
		else if (songItem?.tracks?.length > 0)
		{
			tracks = songItem.tracks;
			item = songItem;

			trace('got $tracks from song');
		}

		for (track in tracks)
		{
			Assets.levelSongTrack(songItem.name, track, true);
		}

		songLoadComplete(songItem.name, tracks);
	}

	private function songLoadComplete(name:String, tracks:Array<String>):Void
	{
		if (!exists || tracks?.length == 0)
			return;

		if (parent.music.playing)
		{
			parent.music.fadeOut((_) ->
			{
				parent.music.pause();
			});
		}

		for (music in musics)
		{
			if (music.playing)
			{
				music.fadeOut((_) ->
				{
					music.stop();
				});
			}
		}

		previewTimer = FlxTimer.wait(1.2, () ->
		{
			for (i in 0...tracks.length)
			{
				if (musics[i] == null)
					musics[i] = new FlxSound();

				musics[i].loadEmbedded(Assets.levelSongTrack(name, tracks[i], true));
				musics[i].looped = true;
				musics[i].persist = true;
			}

			parent.conductor.clearChannels();
			for (i in 0...musics.length)
			{
				parent.conductor.channels[i] = musics[i];
				FlxG.sound.list.add(musics[i]);
			}

			parent.conductor.play();
		});
	}

	private function interruptSongPreview():Void
	{
		if (waitPreviewTimer != null)
			waitPreviewTimer.cancel();
		if (previewTimer != null)
			previewTimer.cancel();
		musicFuture = null;
	}
}
