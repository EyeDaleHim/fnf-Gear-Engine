package backend.engine.input;

class Control {
    public static final UI_LEFT:Control = new Control([A, LEFT]);
    public static final UI_DOWN:Control = new Control([S, DOWN]);
    public static final UI_UP:Control = new Control([W, UP]);
    public static final UI_RIGHT:Control = new Control([D, RIGHT]);

    public var name:String = "";
    public var keys:Array<FlxKey> = [];

    // public var 

    public function new(keys:Array<FlxKey>)
    {
        this.keys = keys;
    }
}