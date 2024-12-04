package objects.engine;

import flixel.util.FlxStringUtil;
import openfl.events.Event;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.system.System;

class DebugInfo extends TextField
{
	static final updateTimer:Int = 200;

	public var curFPS:Int = 0;

	private var _lastTime:Float = 0;
	private var _frameCount:Int = 0;

	override public function new(?x:Float = 0.0, ?y:Float = 0.0)
	{
		super();

		this.x = x;
		this.y = y;

		defaultTextFormat = new TextFormat(Assets.fontByName('vcr'), 12, 0xFFFFFF);
	
		autoSize = LEFT;

		addEventListener(Event.ENTER_FRAME, enterFrame);
	}

	function enterFrame(e:Event)
	{
        _frameCount++;
        var currentTime = openfl.Lib.getTimer();
        var elapsed = currentTime - _lastTime;

        if (elapsed >= 1000) {
			var buf:StringBuf = new StringBuf();
            var fps:Float = (_frameCount / elapsed) * 1000;
			buf.add('FPS: ${Std.int(fps)}');
			buf.add('\n');
            buf.add('MEM: ${FlxStringUtil.formatBytes(System.totalMemory)}');
			text = buf.toString();
			buf = null;
            _frameCount = 0;
            _lastTime = currentTime;
        }
	}
}
