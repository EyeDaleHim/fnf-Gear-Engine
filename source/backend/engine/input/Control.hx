package backend.engine.input;

import flixel.input.FlxInput.FlxInputState;

class Control
{
	@:allow(backend.engine.input.Controls)
	private static final list:Array<Control> = [];

	public static final UI_LEFT:Control = new Control([A, LEFT]);
	public static final UI_DOWN:Control = new Control([S, DOWN]);
	public static final UI_UP:Control = new Control([W, UP]);
	public static final UI_RIGHT:Control = new Control([D, RIGHT]);

	public var name:String = "";

	public var keys:Array<FlxKey> = [];
	public var defaultKeys:Array<FlxKey> = [];

	public var justPressed(get, never):Bool;
	public var pressed(get, never):Bool;

	public var justReleased(get, never):Bool;
	public var released(get, never):Bool;

	public var callbacks:FlxTypedSignal<FlxInputState->Void> = new FlxTypedSignal(); // wiped after every state switch or page switch
    public var persistentCallbacks:FlxTypedSignal<FlxInputState->Void> = new FlxTypedSignal();

	public function new(keys:Array<FlxKey>)
	{
    	this.keys = keys;
		defaultKeys = keys.copy();

        list.push(this);
	}

	function get_justPressed():Bool
		return FlxG.keys.anyJustPressed(keys);

	function get_pressed():Bool
		return FlxG.keys.anyPressed(keys);

	function get_justReleased():Bool
		return FlxG.keys.anyJustReleased(keys);

	function get_released():Bool
		return !FlxG.keys.anyPressed(keys);
}
