package;

import openfl.Lib;
import flixel.FlxGame;
import flixel.input.keyboard.FlxKey;
import openfl.display.DisplayObjectContainer;
import openfl.events.KeyboardEvent;
import objects.engine.DebugInfo;

class Main extends DisplayObjectContainer
{
	public static var game:FlxGame;
	public static var debugInfo:DebugInfo;

	var converter:TempPsychConverter;

	public function new()
	{
		super();

		converter = new TempPsychConverter();

		FlxGraphic.defaultPersist = true;

		Lib.current.addChild(game);
		Lib.current.addChild(debugInfo);

		FlxG.console.registerClass(Assets);
		FlxG.console.registerClass(SongList);

		FlxTween.num(0.0, 1.0, (v) ->
		{
			debugInfo.alpha = v;
		});

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, (e) ->
		{
			if (e.keyCode == FlxKey.F2 && FlxG.keys.checkStatus(e.keyCode, JUST_PRESSED)) 
			{
				converter.browse();
			}
		});
	}
}
