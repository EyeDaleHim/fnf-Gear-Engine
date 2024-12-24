package backend.engine;

import assets.formats.SongFormat;

class SongList
{
	public static final songFolder:String = "assets/levels/songs";
	public static final metaDefinition:String = "meta.json";

	public static final defaultDifficulties:Array<String> = ['easy', 'normal', 'hard'];

	public static var list(default, null):Array<SongFormat> = [];
	public static var listByName(default, null):Map<String, SongFormat> = [];

	public static function prefetch():Void
	{
		var unsorted:Array<SongFormat> = [];

		for (folder in Assets.directory(songFolder))
		{
			var path:String = Path.join([songFolder, folder]);

			if (FileSystem.isDirectory(path))
			{
				for (file in Assets.directory(path))
				{
					var filePath:String = Path.join([path, file]);

					if (!FileSystem.isDirectory(filePath) && file.toLowerCase() == metaDefinition)
					{
						unsorted.push(cast Json.parse(Assets.contents(filePath)));
					}
				}
			}
		}

		for (week in WeekList.list)
		{
			if (week.order != null)
			{
				for (song in week.order)
				{
					for (unsortedSong in unsorted)
					{
						if (song == unsortedSong.name)
						{
							list.push(unsortedSong);
							listByName.set(song, unsortedSong);
							unsorted.splice(unsorted.indexOf(unsortedSong), 1);
							continue;
						}
					}
				}
			}
		}

		while (unsorted.length > 0)
		{
			var song = unsorted.shift();
			list.push(song);
			listByName.set(song.name, song);
		}
	}

	public static function refresh():Void
	{
		list.resize(0);
		prefetch();
	}
}
