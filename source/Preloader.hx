package;

import objects.engine.DebugInfo;
import flixel.system.FlxBasePreloader;

class Preloader extends FlxBasePreloader
{
	public function new()
	{
		super();

		for (font in Assets.directory('assets/fonts/'))
		{
			if (!FileSystem.isDirectory(Path.join(['assets/fonts', font])))
				Assets.font(font);
		}

		preloadSongs();

		Controls.initialize();

		Main.game = new FlxGame(0, 0, () -> new InitState()); // if confused, use InitState
		Main.debugInfo = new DebugInfo(4, 4);

		FlxG.plugins.addIfUniqueType(Transition.instance = new Transition());
	}

	public function preloadSongs():Void
	{
		WeekList.prefetch();
		SongList.prefetch();
	}
}
