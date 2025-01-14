package objects.play;

import objects.Icon;

import flixel.ui.FlxBar;
import flixel.group.FlxContainer;

class Healthbar extends FlxContainer
{
    public var bar:FlxBar;

    public var leftIcon:Icon;
    public var rightIcon:Icon;

    private var _barValue:Float = 0.0;

    public function new(width:Int = 600, height:Int = 20)
    {
        super();

        bar = new FlxBar(0, 0, RIGHT_TO_LEFT, width, height, null, "", 0, 100, true);
        bar.createFilledBar(FlxColor.RED, FlxColor.LIME, true, FlxColor.WHITE, 4);
        bar.screenCenter();
        bar.y = FlxG.height * 0.9;
        bar.numDivisions = width;
        bar.value = 50.0;
        add(bar);

        leftIcon = new Icon(Icon.gameplayPath, "dad");
        leftIcon.changeScale = true;
        add(leftIcon);

        rightIcon = new Icon(Icon.gameplayPath, "bf");
        rightIcon.changeScale = true;
        add(rightIcon);

        _barValue = bar.value;
    }
}