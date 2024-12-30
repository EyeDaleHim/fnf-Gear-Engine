package;

import openfl.filesystem.File as OpenFlFile;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.FileListEvent;
import openfl.net.FileFilter;

class TempPsychConverter
{
	public var fileIO:OpenFlFile;
    public var saveIO:OpenFlFile;

	public function new()
	{
		fileIO = new OpenFlFile();
        fileIO.addEventListener(FileListEvent.SELECT_MULTIPLE, open);

        saveIO = new OpenFlFile();
	}

	public function browse():Void 
    {
		fileIO.browseForOpenMultiple("Chart");
    }

	public function open(event:FileListEvent)
	{
		try
		{
            var list:Array<Dynamic> = [];

			for (file in event.files)
			{
				file.load();

                var utf:String = file.data.readUTFBytes(file.data.length);
                
                var newChart = assets.parsers.converters.PsychConverter.fromChart(Json.parse(utf));
                list.push({chart: Json.stringify(newChart), name: file.name});
			}

            for (item in list)
            {
                saveIO = new OpenFlFile();
                saveIO.save(item.chart, item.name);
            }
		}
        catch (e)
        {
            trace(e.stack);
            trace(e.message);
        }
	}
}
