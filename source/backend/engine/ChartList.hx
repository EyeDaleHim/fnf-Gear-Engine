package backend.engine;

import assets.formats.ChartFormat;
import assets.formats.SongFormat;
import backend.engine.SongList;

class ChartList
{
	public static final songFolder:String = "assets/levels/songs";
	public static final chartDefinition:String = "chart";

	public static var list(default, null):Array<ChartFormat> = [];

	public static function prefetch():Void
	{
		for (folder in Assets.directory(songFolder))
		{
			var path = Path.join([songFolder, folder]);
			if (!FileSystem.isDirectory(path))
				continue;

			var songName = folder;
			for (chartFolder in Assets.directory(path))
			{
				if (chartFolder != chartDefinition)
					continue;

				var chartPath = Path.join([path, chartFolder]);
				if (!FileSystem.isDirectory(chartPath))
					continue;

				var song = SongList.listByName.get(songName);
				if (song == null)
					continue;

				var difficultyList = song.difficulties ?? SongList.defaultDifficulties;
				for (chart in Assets.directory(chartPath))
				{
					var chartData:ChartFormat = cast Json.parse(Assets.contents(Path.join([chartPath, chart])));
					if (difficultyList.contains(Path.withoutExtension(chart)))
					{
					    SongList.chartsByName.get(songName).set(Path.withoutExtension(chart), chartData);
                    }
					list.push(chartData);
				}
			}
		}
	}

    public static function getChart(song:String, diff:Int = 1):ChartFormat
    {
        if (SongList.chartsByName.exists(song))
        {
            var songData:SongFormat = SongList.listByName.get(song);

            var diffList:Array<String> = songData.difficulties ?? SongList.defaultDifficulties;
            diff = FlxMath.bound(diff, 0, diffList.length).floor();

            if (SongList.chartsByName.get(song).exists(diffList[diff]))
                return SongList.chartsByName.get(song).get(diffList[diff]);
        }

        return null;
    }

	public static function refresh():Void
	{
		list.resize(0);

		for (songs in SongList.chartsByName.iterator())
			songs.clear();

		prefetch();
	}
}
