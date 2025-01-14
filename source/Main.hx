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

		#if TRACY_ENABLED
		openfl.Lib.current.stage.addEventListener(openfl.events.Event.EXIT_FRAME, (e:openfl.events.Event) ->
		{
			cpp.vm.tracy.TracyProfiler.frameMark();
		});
		#end

		backend.engine.external.DPIAwareness.registerAsDPICompatible();

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

		#if SLOW_ASS_PC
		FlxG.stage.window.onDropFile.add((path) ->
		{
			if (FileSystem.isDirectory(path))
			{
				for (file in FileSystem.readDirectory(path))
				{
					try
					{
						var fullPath:String = Path.join([path, file]);

						var data:String = File.getContent(fullPath);

						var newChart = assets.parsers.converters.PsychLatestConverter.fromChart(Json.parse(data));

						FileSystem.createDirectory("temp");
						FileSystem.createDirectory('temp/${Path.withoutDirectory(path)}');
						File.saveContent('temp/${Path.withoutDirectory(path)}/${new Path(fullPath).file}.json', Json.stringify(newChart, "\t"));
					}
					catch (e)
					{
						trace(e.message);
					}
				}
			}
			else
			{
				try
				{
					var data:String = File.getContent(path);

					var newChart = assets.parsers.converters.PsychLatestConverter.fromChart(Json.parse(data));

					FileSystem.createDirectory("temp");
					File.saveContent('temp/${new Path(path).file}.json', Json.stringify(newChart, "\t"));
				}
				catch (e)
				{
					trace(e.message);
				}
			}
		});
		#else
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, (e) ->
		{
			if (e.keyCode == FlxKey.F2 && FlxG.keys.checkStatus(e.keyCode, JUST_PRESSED))
			{
				converter.browse();
			}
		});
		#end
	}
}
