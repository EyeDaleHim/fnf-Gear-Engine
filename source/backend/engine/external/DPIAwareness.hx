package backend.engine.external;

#if (windows && cpp)
@:headerInclude("windows.h")
@:headerInclude("winuser.h")
#end
class DPIAwareness
{
    #if (windows && cpp)
	@:functionCode('
    SetProcessDPIAware();
    ')
    #end
	public static function registerAsDPICompatible() {}
}
