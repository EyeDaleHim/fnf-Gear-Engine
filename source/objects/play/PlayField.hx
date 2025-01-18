package objects.play;

import assets.formats.GameplayRatingFormat;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import objects.notes.Strumline;
import objects.notes.StrumNote;
import objects.notes.NoteObject;
import objects.notes.Note;
import objects.play.Healthbar;
import states.play.PlayState.Level;
import openfl.events.KeyboardEvent;

class PlayField extends FlxGroup
{
	public static var defaultRatingsData:GameplayRatingFormat = {
		maxTiming: 166.66,
		list: [
			{
				name: 'sick',
				timing: 45.0,
				score: 500,
				accuracyFactor: 1.0,
				showRating: true,
				showCombo: true
			},
			{
				name: 'good',
				timing: 90.0,
				score: 350,
				accuracyFactor: 0.75,
				showRating: true,
				showCombo: true
			},
			{
				name: 'bad',
				timing: 135.0,
				score: 150,
				accuracyFactor: 0.50,
				showRating: true,
				showCombo: true
			},
			{
				name: 'shit',
				timing: 150.0,
				score: 25,
				accuracyFactor: 0.25,
				showRating: true,
				showCombo: false
			},
			{
				name: 'miss',
				score: -100,
				accuracyFactor: 0.0,
				showRating: false,
				showCombo: true
			}
		]
	};

	public static var noteRecycleAmount:Int = 32;

	public var botplay:Bool = true;

	public var safeInputFrames:Float = 10.0;
	public var level:Level;

	public var ratingsData:GameplayRatingFormat;

	private var noteHitCount:Float = 0;
	private var noteAccuracyCount:Float = 0.0;

	public var score:Int = 0;
	public var misses:Int = 0;
	public var accuracy:Float = 0.0;

	public var combo:Int = 0;

	public var health(get, set):Float;
	public var maxHealth(get, set):Float;

	public var positionControlled(default, null):Bool = false;

	public var tweenManager:FlxTweenManager;
	public var timerManager:TimerManager;

	public var position:Float = -5000;
	public var speed:Float = 1.0;

	public var songLength:Float = 0.0;

	public var pendingNotes:Array<Note> = [];
	public var notes:FlxTypedGroup<NoteObject>;

	public var countdown:Countdown;
	public var strumlines:Array<Strumline> = [];
	public var comboGroup:Combo;

	public var healthbar:Healthbar;
	public var scoreText:FlxText;

	public var controls:Array<Control> = [Control.NOTE_LEFT, Control.NOTE_DOWN, Control.NOTE_UP, Control.NOTE_RIGHT];

	private var _defaultPlayables:Array<Bool> = [false, true];
	private var _removeNotes:Array<Note> = [];

	private var _firstRatingSize:FlxPoint = FlxPoint.get();
	private var _highestAccuracyFactor:Float = 1.0;

	public function new(?tweenManager:FlxTweenManager, ?timerManager:TimerManager, strums:Int = 2)
	{
		super();

		this.tweenManager = tweenManager ?? FlxTween.globalManager;
		this.timerManager = timerManager ?? FlxTimer.globalManager;

		notes = new FlxTypedGroup<NoteObject>();
		var preallocatedFrames = Assets.frames("ui/game/notes/NOTE_assets");
		for (i in 0...noteRecycleAmount)
		{
			notes.add(new NoteObject(preallocatedFrames));
		}

		countdown = new Countdown(tweenManager, timerManager);
		add(countdown);

		healthbar = new Healthbar();
		add(healthbar);

		scoreText = new FlxText(0, 0, (FlxG.width * 0.85) * 2, "Score: 0 // Misses: 0 // Accuracy: 0.00%");
		scoreText.setFormat(Assets.fontByName('vcr'), 18 * 2, FlxColor.WHITE, CENTER);
		scoreText.scale.set(0.5, 0.5);
		scoreText.updateHitbox();
		scoreText.screenCenter();
		scoreText.y = FlxG.height * 0.95;
		add(scoreText);

		for (i in 0...strums)
		{
			createStrum(4, i, (FlxG.width / 2) * i, 50.0);
		}
		add(notes);

		comboGroup = new Combo();
		add(comboGroup);

		ratingsData = defaultRatingsData;
		if (ratingsData.list[0] != null)
		{
			_highestAccuracyFactor = ratingsData.list[0].accuracyFactor;

			var graphic = Assets.image('${Combo.comboPath}/${ratingsData.list[0].name}');
			if (graphic != null)
				_firstRatingSize.set(graphic.width, graphic.height);
		}

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, keyRelease);
	}

	public function changeScoreText():Void
	{
		accuracy = (noteAccuracyCount / noteHitCount) * 100;
		if (Math.isNaN(accuracy))
			accuracy = 0.0;
		scoreText.text = 'Score: ${FlxStringUtil.formatMoney(score, false)} // Misses: ${FlxStringUtil.formatMoney(misses, false)} // Accuracy: ${formatAccuracy(accuracy)}%';
	}

	public function beatHit(beat:Int)
	{
		healthbar.beatHit(beat);
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
					noteObject.alpha = 1.0;

					_removeNotes.push(note);
				}
				else
					break;
			}

			if (_removeNotes.length > 0)
			{
				for (note in _removeNotes.splice(0, _removeNotes.length))
				{
					pendingNotes.remove(note);
				}
			}

			pendingNotes.sort(sortNotes);
		}

		notes.forEachAlive(updateNotes);

		super.update(elapsed);
	}

	public function keyPress(event:KeyboardEvent)
	{
		var dir:Int = checkKeyCode(event.keyCode);

		if (!botplay && dir != -1 && FlxG.keys.checkStatus(event.keyCode, JUST_PRESSED))
		{
			final sortedNotes:Array<NoteObject> = notes.members.filter((noteObject:NoteObject) ->
			{
				var note = noteObject.data;
				if (note == null)
					return false;

				return (note.canBeHit(position, ratingsData.maxTiming) && note.lane == dir && level?.chart?.playables[note.strumIndex]);
			});

			sortedNotes.sort((a, b) -> Std.int(a.data?.time - b.data?.time));

			var confirm:Bool = sortedNotes.length > 0;

			forEachStrumPlayable((strum) ->
			{
				if (!confirm)
				{
					strum.members[dir].playAnimation(strum.members[dir].pressAnim, true);
					strum.members[dir].decrementLength = false;
				}
				else
				{
					strum.members[dir].playAnimation(strum.members[dir].confirmAnim, true);
					strum.members[dir].decrementLength = false;
				}
			}, level?.chart?.playables);

			if (!confirm)
				return;

			var firstNote:NoteObject = sortedNotes[0];
			hitNote(firstNote, true);
		}
	}

	public function keyRelease(event:KeyboardEvent)
	{
		var dir:Int = checkKeyCode(event.keyCode);

		if (!botplay && dir != -1 && FlxG.keys.checkStatus(event.keyCode, JUST_RELEASED))
		{
			final sortedNotes:Array<NoteObject> = notes.members.filter((noteObject:NoteObject) ->
			{
				var note = noteObject.data;
				if (note == null)
					return false;

				return (note.sustain > 0 && note.wasHit && note.lane == dir && level?.chart?.playables[note.strumIndex]);
			});

			sortedNotes.sort((a, b) -> Std.int(a.data?.time - b.data?.time));

			forEachStrumPlayable((strum) ->
			{
				strum.members[dir].playAnimation(strum.members[dir].staticAnim, true);
				strum.members[dir].decrementLength = true;
			}, level?.chart?.playables);

			for (note in sortedNotes)
			{
				if (note.data.sustainCanRelease(position, ratingsData.maxTiming, 0.5, 1.5))
					hitNote(note, true, 0);
				else
					missNote(note);
				note.killNote();
			}
		}
	}

	public function checkKeyCode(keyCode:Int = -1)
	{
		if (keyCode != -1)
		{
			for (control in controls)
			{
				for (key in control.keys)
				{
					if (key == keyCode)
						return controls.indexOf(control);
				}
			}
		}
		return -1;
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

	private function updateNotes(note:NoteObject):Void
	{
		var distance:Float = (NoteObject.pixelsPerMS * (position - note.data.time) * speed);

		if (strumlines[note.data.strumIndex] == null)
		{
			note.killNote();
			return;
		}

		var strumline:Strumline = strumlines[note.data.strumIndex];
		var strumNote:StrumNote = strumline.members[note.data.lane % strumline.length];

		note.scrollSpeed = speed;
		note.centerOverlay(strumNote, X);
		note.y = strumNote.y - distance;

		if (!note.data.missed && level?.chart != null)
		{
			var playable:Null<Bool> = level.chart.playables[note.data.strumIndex];
			if (botplay && playable)
			{
				if (note.data.time - position < 0)
				{
					if (note.data.wasHit && (note.data.time + note.data.sustain) - position < 0)
					{
						hitNote(note, level.chart.playables[note.data.strumIndex], 0.0);
						note.killNote();
					}
					else if (note.data.wasHit)
						hitSustain(note);
					else if (!note.data.wasHit)
						hitNote(note, level.chart.playables[note.data.strumIndex], 0.0);
				}
			}
			else
			{
				if (playable)
				{
					if (((note.data.wasHit && position > note.data.time + note.data.sustain + (ratingsData.maxTiming * 1.5))
						|| (!note.data.wasHit
							&& !note.data.canBeHit(position, ratingsData.maxTiming)
							&& note.data.time - position < ratingsData.maxTiming)))
						missNote(note);
				}
				else if (playable != null && !playable && note.data.time - position < 0)
				{
					if (note.data.wasHit && (note.data.time + note.data.sustain) - position < 0)
						note.killNote();
					else if (note.data.wasHit)
						hitSustain(note);
					else if (!note.data.wasHit)
						hitNote(note);
				}
			}
		}

		if (note.exists && note.data.missed && note.y < -((note.height / 2) + note.sustain.sustainHeight()))
			note.killNote();
	}

	public function hitNote(noteObject:NoteObject, playable:Bool = false, ?overrideDiff:Float):Void
	{
		var diff:Float = overrideDiff ?? noteObject.data.time - position;

		if (!playable)
		{
			var strumline:Strumline = strumlines[noteObject.data.strumIndex];
			var strumNote:StrumNote = strumline.members[noteObject.data.lane % strumline.length];

			strumNote.playAnimation(strumNote.confirmAnim, true);
		}
		else
		{
			if (botplay)
			{
				var strumline:Strumline = strumlines[noteObject.data.strumIndex];
				var strumNote:StrumNote = strumline.members[noteObject.data.lane % strumline.length];

				strumNote.playAnimation(strumNote.confirmAnim, true);
			}

			var rating:Rating = null;

			for (ratingData in ratingsData.list)
			{
				var earlyTiming:Null<Float> = ratingData.earlyTiming ?? ratingData.timing ?? Math.NaN;
				if (earlyTiming > 0)
					earlyTiming = -earlyTiming;
				var lateTiming:Null<Float> = ratingData.lateTiming ?? ratingData.timing ?? Math.NaN;

				if ((earlyTiming == null && lateTiming == null) || (diff > earlyTiming && diff < lateTiming))
				{
					rating = ratingData;
					break;
				}
			}

			// TODO: the way score is calculated here could be handled with better logic
			if (rating != null)
			{
				var addScore:Int = rating.score;

				// score calc here
				var absDiff:Float = Math.abs(diff);
				var nextRating = ratingsData.list[ratingsData.list.indexOf(rating) + 1];

				if (absDiff > 5.0 && nextRating != null)
				{
					if (diff < 0)
					{
						addScore = FlxMath.remapToRange(absDiff, Math.abs(rating.earlyTiming) ?? rating.timing ?? 0.0,
							Math.abs(nextRating.earlyTiming ?? nextRating.timing ?? ratingsData.maxTiming), rating.score, nextRating?.score ?? 0.0)
							.floor();
					}
					else
					{
						addScore = FlxMath.remapToRange(absDiff, Math.abs(rating.lateTiming ?? rating.timing ?? 0.0),
							Math.abs(nextRating.lateTiming ?? nextRating.timing ?? ratingsData.maxTiming), rating.score, nextRating?.score ?? 0.0)
							.floor();
					}
				}

				noteAccuracyCount += rating.accuracyFactor;
				noteHitCount += _highestAccuracyFactor;

				health += noteObject.data.health * rating.accuracyFactor;

				score += addScore;
				showCombo(rating);
			}
			else
				health += noteObject.data.health;

			combo++;

			changeScoreText();
		}

		noteObject.data.wasHit = true;

		if (noteObject.data.sustain <= 0)
			noteObject.killNote();
		else
			noteObject.parentVisible = false;
	}

	public function missNote(noteObject:NoteObject):Void
	{
		for (ratingData in ratingsData.list)
		{
			if (ratingData != null)
			{
				if (ratingData.timing == null && ratingData.earlyTiming == null && ratingData.lateTiming == null)
				{
					misses++;
					score -= Math.abs(ratingData.score).floor();
					showCombo(ratingData, true);
					break;
				}
			}
		}

		health -= noteObject.data.missHealth;

		noteHitCount += _highestAccuracyFactor;
		combo = 0;

		noteObject.data.missed = true;
		noteObject.alpha = noteObject.alpha * 0.5;

		changeScoreText();
	}

	public function hitSustain(noteObject:NoteObject)
	{
		var strumline:Strumline = strumlines[noteObject.data.strumIndex];
		var strumNote:StrumNote = strumline.members[noteObject.data.lane % strumline.length];

		noteObject.sustain.updateSustainClip(strumNote.height / 2);

		if (strumNote.animation.curAnim?.curFrame > 2)
			strumNote.playAnimation(strumNote.confirmAnim, true);
	}

	public function showCombo(rating:Rating, ?missed:Bool = false):Void
	{
		if (rating == null)
			return;

		var position:FlxPoint = FlxPoint.get(camera.width / 2, camera.height / 2);
		position.x -= 50.0;
		position.y -= 50.0;

		if (rating.showRating)
		{
			var ratingSpr = comboGroup.spawnObject(comboGroup.ratingList, Assets.image('${Combo.comboPath}/${rating.name}'), position.x, position.y, 0.5);
			ratingSpr.x -= _firstRatingSize.x / 2;
			ratingSpr.y -= _firstRatingSize.y / 2;
			ratingSpr.acceleration.y = 550;
			ratingSpr.velocity.y = -FlxG.random.int(140, 175);
			ratingSpr.velocity.x = -FlxG.random.int(0, 10);

			position.set(ratingSpr.x, ratingSpr.y);
			if (rating.showCombo)
				position.y += _firstRatingSize.y;
		}

		// TODO: remove hardcoding here
		if (rating.showCombo && (!missed || (missed && combo >= 10)))
		{
			if (!rating.showRating)
			{
				position.x -= _firstRatingSize.x / 2;
				position.y -= _firstRatingSize.y / 2;
				position.y += _firstRatingSize.y;
			}

			var stringified:String = missed ? '000' : '$combo'.lpad('0', 3);
			for (i in 0...stringified.length)
			{
				var str:String = stringified.charAt(i);

				var comboNum = comboGroup.spawnObject(comboGroup.comboList, Assets.image('${Combo.comboPath}/num$str'), position.x, position.y, 0.35);
				comboNum.acceleration.y = FlxG.random.int(200, 300);
				comboNum.velocity.y -= FlxG.random.int(140, 160);
				comboNum.velocity.x = FlxG.random.float(-5, 5);
				comboNum.scale.set(0.5, 0.5);
				comboNum.updateHitbox();
				comboNum.setPosition(position.x, position.y);
				position.x += comboNum.width;
			}
		}
	}

	public function removeInputListeners():Void
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, keyRelease);
	}

	public function reset()
	{
		maxHealth = 100.0;
		health = 50.0;

		combo = 0;

		score = 0;
		misses = 0;
	}

	private function noteFactory(note:Note):NoteObject
	{
		var obj:NoteObject = new NoteObject();
		obj.setData(note);
		obj.revive();

		return obj;
	}

	private function sortNotes(note1:Note, note2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, note1.time, note2.time);
	}

	private function formatAccuracy(value:Float)
	{
		var str = Std.string(value);
		var parts = str.split(".");

		if (parts.length == 1)
		{
			return str + ".00";
		}
		if (parts[1].length > 2)
			parts[1] = parts[1].substring(0, 2);

		return parts[0] + "." + parts[1].rpad("0", 2);
	}

	function get_health():Float
	{
		return healthbar.value ?? Math.NaN;
	}

	function set_health(value:Float):Float
	{
		if (healthbar?.bar != null)
			return healthbar.value = value;
		return Math.NaN;
	}

	function get_maxHealth():Float
	{
		return healthbar.bar.max ?? Math.NaN;
	}

	function set_maxHealth(value:Float):Float
	{
		if (healthbar.bar != null)
		{
			healthbar.bar.setRange(0, value);
			return healthbar.bar.max;
		}
		return Math.NaN;
	}
}
