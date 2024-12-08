package assets.platform;

import flixel.system.FlxAssets;
import lime.media.AudioBuffer;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.text.Font;
import haxe.io.Path;

class SystemAssets
{
	private static var contentsCache:Map<String, String> = [];
	private static var objectsCache:Map<String, Dynamic> = [];
	private static var soundCache:Map<String, Sound> = [];
	private static var fontCache:Map<String, Font> = [];

	private static var dummySound:Sound = new Sound();

	public static function purePath(path:String, ?prefix:String->String):String
	{
		if (prefix != null)
			return prefix(path);
		return path;
	}

	public inline static function imagePath(path:String):String
		return 'assets/images/$path.png';

	public inline static function soundPath(path:String):String
		return 'assets/sounds/$path.${FlxAssets.defaultSoundExtension}';

	public inline static function levelSongTrackPath(song:String, track:String):String
		return 'assets/levels/songs/$song/music/$track.${FlxAssets.defaultSoundExtension}';

	public inline static function fontPath(path:String):String
	{
		return (new Path(path).ext != null ? 'assets/fonts/$path' : 'assets/fonts/$path.ttf');
	}

	public static function exists(path:String, ?prefix:String->String):Bool
	{
		if (prefix != null)
			return FileSystem.exists(prefix(path));
		return FileSystem.exists(path);
	}

	public static function directory(path:String):Array<String>
	{
		if (!exists(path) || !FileSystem.isDirectory(path))
			return [];

		return FileSystem.readDirectory(path);
	}

	public static function contents(path:String, ?prefix:String->String, ?cache:Bool = false):String
	{
		var formattedPath:String = prefix == null ? path : prefix(path);

		if (contentsCache.exists(formattedPath))
			return contentsCache.get(formattedPath);

		if (exists(formattedPath))
		{
			var content:String = File.getContent(formattedPath);
			if (cache)
				contentsCache.set(formattedPath, content);
			return content;
		}

		return "";
	}

	public static function object(path:String, type:DataType, ?prefix:String->String, ?cache:Bool = false, ?refresh:Bool = false):Dynamic
	{
		var formattedPath:String = prefix == null ? path : prefix(path);

		if (!refresh && objectsCache.exists(formattedPath))
			return objectsCache.get(formattedPath);

		if (exists(formattedPath))
		{
			var data:Dynamic = switch (type)
			{
				case JSON:
					Json.parse(contents(formattedPath, false));
				case SERIALIZED:
					Unserializer.run(contents(formattedPath, false));
			}

			if (cache)
				objectsCache.set(formattedPath, data);
			return data;
		}

		return null;
	}

	public static function bytes(path:String, ?prefix:String->String):Bytes
	{
		var formattedPath:String = prefix == null ? path : prefix(path);

		if (exists(formattedPath))
			return File.getBytes(formattedPath);
		return null;
	}

	public static function image(path:String, ?cache:Bool = true):FlxGraphic
	{
		var formattedPath:String = imagePath(path);

		var bitmap:BitmapData = null;
		var graphic:FlxGraphic = null;

		if (FlxG.bitmap.checkCache(formattedPath))
			graphic = FlxG.bitmap.get(formattedPath);
		else if (exists(formattedPath))
		{
			bitmap = BitmapData.fromBytes(bytes(formattedPath));
			graphic = FlxGraphic.fromBitmapData(bitmap, formattedPath, false);
			graphic.destroyOnNoUse = false;

			if (cache)
				FlxG.bitmap.add(graphic, formattedPath);
		}

		return graphic;
	}

	public static function frames(path:String):FlxAtlasFrames
	{
		var xmlPath:String = imagePath(path).replace('.png', '.xml');

		if (exists(path, imagePath) && exists(xmlPath))
			return FlxAtlasFrames.fromSparrow(image(path), contents(xmlPath));

		return null;
	}

	public static function sound(path:String, ?cache:Bool = false):Sound
	{
		var formattedPath:String = soundPath(path);
		return internalSound(formattedPath, cache);
	}

	public static function levelSongTrack(song:String, track:String, ?cache:Bool = false):Sound
	{
		var formattedPath:String = levelSongTrackPath(song, track);
		return internalSound(formattedPath, cache);
	}

	public static function font(path:String):Font
	{
		var font:Font = null;
		var formattedPath:String = fontPath(path);

		if (fontCache.exists(path))
			font = fontCache.get(path);
		else
		{
			fontCache.set(path, Font.fromBytes(Assets.bytes(formattedPath)));
			font = Assets.font(path);

			Font.registerFont(font);
		}

		return font;
	}

	public static function fontByName(path:String):String
	{
		var font:Font = font(path);
		return (font == null ? "" : font.fontName);
	}

	private static function internalSound(finalPath:String, ?cache:Bool = false):Sound
	{
		var sound:Sound = null;

		if (soundCache.exists(finalPath))
			sound = soundCache.get(finalPath);
		else if (exists(finalPath))
		{
			sound = Sound.fromAudioBuffer(AudioBuffer.fromBytes(bytes(finalPath)));
			if (cache)
				soundCache.set(finalPath, sound);
		}

		return (sound == null ? null : sound);
	}
}

enum DataType
{
	JSON;
	SERIALIZED;
}
