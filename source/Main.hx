package;

import flixel.FlxGame;
import openfl.display.Sprite;
import objects.engine.DebugInfo;

class Main extends Sprite
{
	public static var game:FlxGame;
	public static var debugInfo:DebugInfo;

	public function new()
	{
		super();

		FlxGraphic.defaultPersist = true;

		PageState.pageInstances.set('menu', new MenuState());

		addChild(game);
		addChild(debugInfo);

		FlxTween.num(0.0, 1.0, (v) ->
		{
			debugInfo.alpha = v;
		});
	}
}
