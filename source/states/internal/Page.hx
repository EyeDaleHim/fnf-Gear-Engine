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

	public function playMenuSong(?bpm:Float = 102):Void
	{
		parent.conductor.clearChannels();
		parent.conductor.mainChannel = parent.music;
		parent.conductor.bpm = bpm;
		@:privateAccess
		if (parent.music._paused)
			parent.conductor.resume();
		else
			parent.conductor.play();
	}

	public function createMenuSong(?song:String = "freakyMenu"):Void
	{
		parent.music = new FlxSound();
		parent.music.loadEmbedded(Assets.sound('music/$song', true));
		parent.music.persist = true;

		FlxG.sound.list.add(parent.music);
	}

	public inline function checkMenuSong(?song:String = "freakyMenu", ?bpm:Float = 102):Void
	{
		if (parent.music == null)
			createMenuSong(song);
		playMenuSong(bpm);
	}
}
