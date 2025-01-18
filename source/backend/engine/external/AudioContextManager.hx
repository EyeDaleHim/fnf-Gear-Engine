package backend.engine.external;

import lime.system.CFFIPointer;
import lime.media.openal.AL;
import lime.media.openal.ALC;
import lime.media.openal.ALDevice;

// TODO: i think fixing the audio device change is possible without native code!
@:allow(Main)
class AudioContextManager
{
	public static function init():Void
	{
		//        currentDevice = ALC.getString(null, ALC.DEFAULT_DEVICE_SPECIFIER);
	}

	private static var currentDevice:Null<String> = null;

	private static function checkDeviceChange():Bool
	{
		/*var newDevice:Null<String> = ALC.getString(null, ALC.DEFAULT_DEVICE_SPECIFIER);

		if (currentDevice != newDevice)
		{
			trace(currentDevice);
			trace(newDevice);
			currentDevice = newDevice;
			return true;
		}*/

		return false;
	}
}
