package states.menu;

import states.internal.Page;

class FreeplayState extends Page
{
	public var index:Int = 0;
	public var diffIndex:Int = 0;

	public var background:FlxSprite;
	public var songItems:AtlasTextGroup;

	public function new()
	{
		super();

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
		if (FlxG.keys.justPressed.UP)
			changeItem(-1);
		if (FlxG.keys.justPressed.DOWN)
			changeItem(1);

		super.update(elapsed);
	}

	public function changeItem(change:Int = 0):Void
	{
		index = FlxMath.wrap(index + change, 0, songItems.length - 1);

		if (change != 0)
			FlxG.sound.play(Assets.sound("sfx/menu/scrollMenu"), 0.5);

		songItems.selectedText.alpha = 0.6;
		songItems.selected = index;
		songItems.selectedText.alpha = 1.0;
	}
}
