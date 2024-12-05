package;

import openfl.Lib;
import flixel.FlxGame;
import openfl.display.DisplayObjectContainer;
import objects.engine.DebugInfo;

class Main extends DisplayObjectContainer
{
	public static var game:FlxGame;
	public static var debugInfo:DebugInfo;

	public function new()
	{
		super();

		FlxGraphic.defaultPersist = true;

		PageState.pageInstances.set('menu', new MenuState());

		Lib.current.addChild(game);
		Lib.current.addChild(debugInfo);

		FlxTween.num(0.0, 1.0, (v) ->
		{
			debugInfo.alpha = v;
		});
	}
}
