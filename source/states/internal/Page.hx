package states.internal;

class Page extends FlxContainer
{
	public function switchPage(page:String)
	{
		cast(container, PageState).switchPage(page);
	}
}
