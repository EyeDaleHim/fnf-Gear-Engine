package objects.play;

import assets.formats.ChartFormat;
import assets.formats.ChartFormat.IconNames;

import objects.Icon;

import flixel.ui.FlxBar;
import flixel.group.FlxContainer;

class Healthbar extends FlxContainer
{
    public var value(get, set):Float;

    public var bar:FlxBar;

    public var leftIcon:Icon;
    public var rightIcon:Icon;

    public var iconBarSpeed:Float = 2.5;

    private var _barValue:Float = 0.0;

    public function new(?chart:ChartFormat, width:Int = 600, height:Int = 20)
    {
        super();

        bar = new FlxBar(0, 0, RIGHT_TO_LEFT, width, height, null, "", 0, 100, true);
        bar.createFilledBar(FlxColor.RED, FlxColor.LIME, true, FlxColor.BLACK, 4);
        bar.screenCenter();
        bar.y = FlxG.height * 0.9;
        bar.numDivisions = width;
        bar.value = 50.0;
        add(bar);

        leftIcon = new Icon(Icon.gameplayPath, "dad");
        leftIcon.changeScale = true;

        leftIcon.animation.add('normal', [0], 1.0);
        leftIcon.animation.add('losing', [1], 1.0);

        add(leftIcon);

        rightIcon = new Icon(Icon.gameplayPath, "bf");
        rightIcon.changeScale = true;
        rightIcon.flipX = true;
        add(rightIcon);

        rightIcon.animation.add('normal', [0], 1.0);
        rightIcon.animation.add('losing', [1], 1.0);

        leftIcon.animation.play('normal');
        rightIcon.animation.play('normal');

        _barValue = value;
        set_value(value);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        _barValue = FlxMath.lerp(_barValue, value, FlxMath.bound(elapsed * 4.0 * iconBarSpeed, 0, 1));

        var range:Float = bar.max - bar.min;
        var percent:Float = ((_barValue - bar.min) / range) * 100.0;

        leftIcon.x = FlxMath.remapToRange(percent, bar.min, bar.max, bar.x + bar.width, bar.x);
        leftIcon.x -= leftIcon.width - 10.0;

        rightIcon.x = FlxMath.remapToRange(percent, bar.min, bar.max, bar.x + bar.width, bar.x);
        rightIcon.x -= 10.0;

        leftIcon.y = bar.y + bar.height - (leftIcon.height / 1.6);
        rightIcon.y = bar.y + bar.height - (rightIcon.height / 1.6);
    }

    public function changeIcons(newIcons:IconNames)
    {
        if (newIcons != null)
        {
            
        }
    }

    public function beatHit(beat:Int)
    {
        if (beat >= 0)
        {
            leftIcon.scale.set(1.2, 1.2);
            rightIcon.scale.set(1.2, 1.2);

            leftIcon.updateHitbox();
            rightIcon.updateHitbox();
        }
    }

    function get_value():Float
    {
        return bar.value;
    }

    function set_value(value:Float):Float
    {
        bar.value = value;

        if (bar.percent > 80)
            leftIcon.animation.play('losing');
        else
            leftIcon.animation.play('normal');

        if (bar.percent < 20)
            rightIcon.animation.play('losing');
        else
            rightIcon.animation.play('normal');

        return value;
    }
}