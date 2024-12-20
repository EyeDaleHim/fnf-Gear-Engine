package states.internal;

class PageState extends MainState
{
	public static var pageInstances:Map<String, Page> = [];
	public static var instance:PageState;

	private var _pageHelper:String;

	public var currentPage:Page;

	public var music:FlxSound;

	public static function addPage(name:String, page:Page):Void
	{
		pageInstances.set(name, page);
		page.kill();

		if (instance != null)
			instance.add(page);
	}

	public function new(page:String)
	{
		super();
		instance = this;

		for (page in pageInstances.iterator())
			add(page);

		_pageHelper = page;
	}

	override function create()
	{
		super.create();

		Transition.instance.skipTransition();
		switchPage(_pageHelper);
	}

	public function switchPage(page:String):Void
	{
		if (currentPage != null)
			currentPage.active = false;

		if (pageInstances.exists(page))
		{
			Transition.instance.transitionIn(() ->
			{
				killMembers();

				currentPage = pageInstances.get(page);
				
				currentPage.revive();
				currentPage.active = true;

				Transition.instance.transitionOut();
			});
		}
		else
		{
			if (currentPage != null)
				currentPage.active = true;

			FlxG.log.error('Page $page was not found.');
		}
	}

	override function destroy()
	{
		clear();

		super.destroy();
	}
}
