package objects.play;

import objects.notes.Strumline;
import objects.notes.StrumNote;
import objects.notes.NoteObject;
import objects.notes.Note;

class PlayField extends FlxGroup
{
	public static var noteRecycleAmount:Int = 32;

	public var positionControlled(default, null):Bool = false;

	public var tweenManager:FlxTweenManager;
	public var timerManager:FlxTimerManager;

	public var position:Float = 0;
	public var speed:Float = 1.0;

	public var pendingNotes:Array<Note> = [];
	public var notes:FlxTypedGroup<NoteObject>;

	public var countdown:Countdown;
	public var strumlines:Array<Strumline> = [];

	private var _defaultPlayables:Array<Bool> = [false, true];
	private var _removeNotes:Array<Note> = [];

	public function new(?tweenManager:FlxTweenManager, ?timerManager:FlxTimerManager, strums:Int = 2)
	{
		super();

		this.tweenManager = tweenManager;
		this.timerManager = timerManager;

		notes = new FlxTypedGroup<NoteObject>();
		for (i in 0...noteRecycleAmount)
		{
			notes.add(new NoteObject());
		}

		countdown = new Countdown(tweenManager, timerManager);
		add(countdown);

		for (i in 0...strums)
		{
			createStrum(4, i, (FlxG.width / 2) * i, 50.0);
		}
		add(notes);
	}

	override public function update(elapsed:Float)
	{
		if (pendingNotes.length > 0)
		{
			var spawnTime:Float = 3000 / speed;

			for (i in 0...pendingNotes.length)
			{
				var note:Note = pendingNotes[i];
				if (note == null)
					continue;

				if (note.time - position <= spawnTime)
				{
					var noteObject:NoteObject = notes.recycle(NoteObject, noteFactory.bind(note));
					if (noteObject.data == null)
						noteObject.setData(note);

					_removeNotes.push(note);				
				}
				else
					break;
			}

			for (note in _removeNotes.splice(0, _removeNotes.length))
				pendingNotes.remove(note);
		}

		notes.forEachAlive(forEachNote);

		super.update(elapsed);
	}

	public function start(interval:Float = 0.5, ?finishCallback:Void->Void):Void
	{
		var countdownFactor:Float = countdown.start(interval, () ->
		{
			positionControlled = true;
			finishCallback();
		});

		tweenManager.num(-countdownFactor * 1000, 0.0, countdownFactor, (num:Float) ->
		{
			position = num;
		});
	}

	public function createStrum(notes:Int = 4, index:Int, gap:Float, y:Float = 0.0):Void
	{
		var strumline:Strumline = new Strumline(notes, index, gap, y);
		add(strumline);
		strumlines.push(strumline);
	}

	public function forEachStrum(func:(Strumline) -> Void):Void
	{
		for (strumline in strumlines)
		{
			func(strumline);
		}
	}

	public function forEachStrumPlayable(func:(Strumline) -> Void, playables:Array<Bool>):Void
	{
		for (strumline in strumlines)
		{
			if ((playables ?? _defaultPlayables)[strumline.ID])
				func(strumline);
		}
	}

	private function forEachNote(note:NoteObject):Void
	{
		// stupid fucking magic number
		var distance:Float = (0.45 * (position - note.data.time) * speed);

		if (strumlines[note.data.strumIndex] == null)
		{
			note.kill();
			return;
		}

		var strumline:Strumline = strumlines[note.data.strumIndex];
		var strumNote:StrumNote = strumline.members[note.data.lane % strumline.length];

		note.centerOverlay(strumNote, X);
		note.y = strumNote.y - distance;
	}

	private function noteFactory(note:Note):NoteObject
	{
		var obj:NoteObject = new NoteObject();
		obj.setData(note);

		return obj;
	}
}
