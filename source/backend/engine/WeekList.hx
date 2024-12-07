package backend.engine;

import assets.formats.WeekFormat;

class WeekList
{
    public static final weekFolder:String = 'assets/levels/weeks';

	public static var list(default, null):Array<WeekFormat> = [];

    // order of the weeks is alphabetical order
	public static function prefetch():Void 
    {
        for (week in Assets.directory(weekFolder))
        {
            var path:String = Path.join([weekFolder, week]);

            if (!FileSystem.isDirectory(path) && Path.extension(path) == "json")
                list.push(cast Json.parse(Assets.contents(path)));
        }
    }

	public static function refresh():Void
	{
		list.resize(0);
		prefetch();
	}
}
