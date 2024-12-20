package states.internal;

class Page extends FlxContainer
{
	public var parent(get, never):PageState;

	function get_parent():PageState
	{
		return cast(container, PageState);
	}

	public function switchPage(page:String):Void
	{
		parent.switchPage(page);
	}

	public function playMenuSong(?song:String = "freakyMenu", ?bpm:Float = 102):Void
	{
		parent.conductor.clear();

		if (parent.music == null)
			parent.music = new FlxSound();
		parent.music.loadEmbedded(Assets.sound('music/$song', true));
		parent.music.persist = true;
		parent.conductor.startSong(parent.music, bpm);
		FlxG.sound.list.add(parent.music);
	}
}
