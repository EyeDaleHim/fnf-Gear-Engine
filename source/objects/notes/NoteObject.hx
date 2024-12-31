package objects.notes;

import objects.notes.Note;

// TODO: add some sort of skin file impl, this is only temporary
class NoteObject extends FlxSprite
{
    public var data:Note;

    override public function new()
    {
        super();

        frames = Assets.frames("ui/game/notes/NOTE_assets");

		animation.addByPrefix("noteLEFT", "purple0", 24);
		animation.addByPrefix("noteDOWN", "blue0", 24);
		animation.addByPrefix("noteUP", "green0", 24);
		animation.addByPrefix("noteRIGHT", "red0", 24);

        scale.set(0.7, 0.7);
		updateHitbox();

        kill();
    }

    public function setData(newData:Note)
    {
        data = newData;
        animation.play(switch (data.lane)
        {
            case 0:
                "noteLEFT";
            case 1:
                "noteDOWN";
            case 2:
                "noteUP";
            case 3:
                "noteRIGHT";
            default:
                "noteLEFT";
        });
    }
}