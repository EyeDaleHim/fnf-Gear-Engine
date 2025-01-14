package backend.macros;

import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;

class AssetsMacro
{
	private static var cwd:String = Sys.getCwd();

	public static macro function build()
	{
		#if !display
		var config = haxe.macro.Compiler.getConfiguration();

		var target:String = Std.string(config.platform);

		if (target == 'cpp')
		{
			#if windows
			target = 'windows';
			#elseif mac
			target = "mac";
			#elseif linux
			target = "linux";
			#end
		}

		var exportLocation:String = Path.join(['export', haxe.macro.Context.getDefines()['BUILD_DIR'], target, 'bin']);

		function recursiveLoop(directory:String)
		{
			for (file in sys.FileSystem.readDirectory(directory))
			{
				var path = haxe.io.Path.join([directory, file]);

				if (!sys.FileSystem.isDirectory(path))
				{
					var exportPath:String = Path.join([exportLocation, path]);
					File.copy(path, exportPath);
				}
				else
				{
					if (!FileSystem.exists(Path.join([cwd, exportLocation, path])))
						FileSystem.createDirectory(Path.join([cwd, exportLocation, path]));

					var directory = haxe.io.Path.addTrailingSlash(path);
					recursiveLoop(directory);
				}
			}
		}

		recursiveLoop("assets/");
		#end

		return macro {};
	}
}
