package objects.notes;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

import objects.notes.StrumNote;

// change to account for custom skins
class Strumline extends FlxTypedSpriteGroup<StrumNote>
{
    public function new(notes:Int = 4, index:Int = 0, gap:Float = 0.0, y:Float = 0.0)
    {
        super();

        ID = index;

        x = 75 + gap + (index == 0 ? 25 : 0);
        this.y = y;

        for (i in 0...notes)
        {
            var strum:StrumNote = new StrumNote(i);
            strum.x = (Note.noteWidth * i);
            add(strum);
        }
    }

    public function fadeIn():Void
    {

    }
}