package objects.notes;

abstract Note(Array<Dynamic>) from Array<Dynamic> to Array<Dynamic>
{
    public static var noteWidth:Float = 160 * 0.7;

    public var time(get, set):Float;
    public var strumIndex(get, never):Int;
    public var lane(get, set):Int;
    public var sustain(get, set):Float;
    public var characterTarget(get, set):String;
    public var singAnimation(get, set):String;
    public var missed(get, set):Bool;
    public var health(get, set):Float;
    public var missHealth(get, set):Float;
    public var wasHit(get, set):Bool;

    function get_time()
        return this[0] ?? 0.0;

    function set_time(value:Float = 0.0)
        return this[0] = value;

    function get_strumIndex():Int
        return this[1];

    function get_lane():Int
        return this[2] ?? -1;

    function set_lane(value:Int):Int
        return this[2] = value ?? -1;

    function get_sustain():Float
        return this[3] ?? 0.0;

    function set_sustain(value:Float):Float
        return this[3] = value;

    function get_characterTarget():String
        return this[4] ?? "";

    function set_characterTarget(value:String):String
        return this[4] = value;

    function get_noteType():Int
        return this[5] ?? -1;

    function set_noteType(value:Int):Int
        return this[5] = value;

    function get_singAnimation():String
        return this[6] ?? "";

    function set_singAnimation(value:String):String
        return this[6] = value;

    function get_missed():Bool
        return this[7] ?? false;

    function set_missed(value:Bool):Bool
        return this[7] = value;

    function get_health():Float
        return this[8] ?? 0.5;

    function set_health(value:Float):Float
        return this[8] = value;

    function get_missHealth():Float
        return this[9] ?? 3.0;

    function set_missHealth(value:Float):Float
        return this[9] = value;

    function get_wasHit():Bool
        return this[10] ?? false;

    function set_wasHit(value:Bool):Bool
        return this[10] = value;

    inline public function canBeHit(position:Float, safeZone:Float, ?earlyMult:Float = 1.0, ?lateMult:Float = 1.0):Bool
    {
        return (time > position - (safeZone * earlyMult) && time < (position + safeZone * lateMult));
    }

    inline public function sustainCanRelease(position:Float, safeZone:Float, ?earlyMult:Float = 1.0, ?lateMult:Float = 1.0):Bool
        {
            return (time + sustain > position - (safeZone * earlyMult) && time + sustain < (position + safeZone * lateMult));
        }

    // for backwards compat
    public var length(get, never):Int;

    function get_length():Int
        return this.length;
}