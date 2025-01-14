package assets.parsers.converters;

import assets.formats.ChartFormat;

typedef PsychSong =
{
	var song:String;
	var notes:Array<PsychSection>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var stage:String;

	var ?gameOverChar:String;
	var ?gameOverSound:String;
	var ?gameOverLoop:String;
	var ?gameOverEnd:String;

	var ?disableNoteRGB:Bool;

	var ?arrowSkin:String;
	var ?splashSkin:String;
}

typedef PsychSection =
{
	var sectionNotes:Array<Dynamic>;
	var sectionBeats:Float;
	var mustHitSection:Bool;
	var gfSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
}

class PsychLatestConverter
{
	public static var noteTypeList:Array<String> = ['', 'Alt Animation', 'Hey!', 'Hurt Note', 'GF Sing', 'No Animation'];

	public static function fromChart(file:Dynamic):Dynamic // psych -> gear
	{
		var chart:ChartFormat = {version: "0"};

		if (file != null)
		{
			// meta, from the chart
			chart.characters = [
				file.player1 ?? "bf",
				file.player2 ?? "dad",
				file.gfVersion ?? file.player3 ?? "gf"
			];

			chart.strums = [
				{character: chart.characters[0], attachedTrack: 'Voices', lanes: 4},
				{character: chart.characters[1], attachedTrack: 'Voices', lanes: 4}
			];

			chart.playables = [false, true];

			chart.bpm = file.bpm ?? 100.0;
			chart.speed = file.speed ?? 1.0;

			chart.stage = file.stage ?? "stage";

			chart.tracks = ['Inst', 'Voices'];

			if (file.notes != null)
			{
				var usesNoteTypes:Bool = false;

				chart.notes = [];
				chart.noteTypes = noteTypeList;
				var sections:Array<Dynamic> = file.notes;
				for (section in sections)
				{
					var notes:Array<Dynamic> = section.sectionNotes ?? section.notes;
					for (note in notes)
					{
						var daStrumTime:Float = note[0];
						var daNoteData:Int = Std.int(note[1] % 4);
						var gottaHitNote:Bool = note[1] < 4;

						var gearNote:Array<Dynamic> = [
							daStrumTime,
							gottaHitNote,
							daNoteData,
							note[2],
							(section.gfSection ? chart.characters[2] : (gottaHitNote ? chart.characters[0] : chart.characters[1]))
						];

						if (note[3] != null)
						{
							usesNoteTypes = true;

							if (Std.isOfType(note[3], String))
							{
								var index = chart.noteTypes.indexOf(note[3]);

								if (index == -1)
								{
									chart.noteTypes.push(note[3]);
									index = chart.noteTypes.indexOf(note[3]);
								}
								note.push(index);
							}
							else
							{
								note.push(note[3]);
							}
						}

						chart.notes.push(gearNote);
					}
				}

				if (!usesNoteTypes)
					Reflect.deleteField(chart, "noteTypes");
			}

			trace(chart);

			return chart;
		}

		return null;
	}

	public static function toChart(file:Dynamic):Dynamic // gear -> psych
	{
		return null;
	}

	public static function fromMeta(file:Dynamic):Dynamic // psych -> gear
	{
		return null;
	}

	public static function toMeta(file:Dynamic):Dynamic // gear -> psych
	{
		return null;
	}
}
