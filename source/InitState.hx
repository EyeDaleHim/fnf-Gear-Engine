package;

class InitState extends FlxState
{
	override function create()
	{
		PageState.addPage('menu', new MenuState());
		PageState.addPage('freeplay', new FreeplayState());

		#if MENU
		#else
		FlxG.switchState(() -> new PageState('menu'));
		#end
	}
}
