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

		addChild(game);
		addChild(debugInfo);

		Transition.instance.color = 0xFFFFFFFF;
	}
}
