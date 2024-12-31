package utils;

import flixel.FlxObject;
import flixel.math.FlxRect;
import flixel.util.FlxAxes;

class SpriteUtils
{
    public static function centerOverlay(object:FlxObject, ?base:FlxObject, axes:FlxAxes = XY):FlxObject
    {
        if (object == null || base == null)
            return object;

        if (axes.x)
            object.x = base.x + (base.width / 2) - (object.width / 2);

        if (axes.y)
            object.y = base.y + (base.height / 2) - (object.height / 2);

        return object;
    }
}