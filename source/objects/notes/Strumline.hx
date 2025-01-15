package objects.notes;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

import objects.notes.StrumNote;

// change to account for custom skins
class Strumline extends FlxTypedSpriteGroup<StrumNote>
{
    public var tweenManager:FlxTweenManager;
	public var timerManager:TimerManager;

    public function new(notes:Int = 4, index:Int = 0, gap:Float = 0.0, y:Float = 0.0)
    {
        super();

        ID = index;

        x = 75 + gap + (index == 0 ? 25 : 0);
        this.y = y;

        for (i in 0...notes)
        {
            var strum:StrumNote = new StrumNote(i);
            strum.ID = i;
            strum.x = (Note.noteWidth * i);
            add(strum);
        }
    }

    public function fadeIn(?tweenManager:FlxTweenManager, ?timerManager:TimerManager):Void
    {
        this.timerManager = timerManager ?? FlxTimer.globalManager;
		this.tweenManager = tweenManager ?? FlxTween.globalManager;

        for (strum in members)
        {
            var formerOffsetY:Float = strum.offset.y;

            strum.alpha = 0.0;
            strum.offset.y += 10.0;
            tweenManager.tween(strum, {"offset.y": formerOffsetY, alpha: 1.0}, 0.5, {ease: FlxEase.circOut, startDelay: 0.25 + (0.1 * strum.ID)});
        }
    }
}