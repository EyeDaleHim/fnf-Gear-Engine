#if !flash
import flixel.graphics.FlxGraphic;
#end

#if sys
import sys.FileSystem;
import sys.io.File;
#end

import haxe.Json;
import haxe.Serializer;
import haxe.Unserializer;
import haxe.io.Bytes;
