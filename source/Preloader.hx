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
			Assets.font(font);
		}

		Main.game = new FlxGame(0, 0, () -> new states.play.PlayState());
		Main.debugInfo = new DebugInfo(4, 4);

		FlxG.plugins.addIfUniqueType(Transition.instance = new Transition());
	}
}
