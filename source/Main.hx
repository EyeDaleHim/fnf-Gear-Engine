package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		FlxGraphic.defaultPersist = true;
		addChild(new FlxGame(0, 0, states.play.PlayState));
	}
}
