package states.internal;

class PageState extends MainState
{
	public static var pageInstances:Map<String, FlxContainer> = [];

	public var currentPage:FlxContainer;

	private var _pageHelper:String;

	public function new(page:String)
	{
		super();

		_pageHelper = page;
	}

	override function create()
	{
		super.create();

		Transition.instance.skipTransition();
		switchPage(_pageHelper);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (currentPage?.exists && currentPage.active)
			currentPage.update(elapsed);
	}

	override public function draw()
	{
		super.draw();

		if (currentPage?.exists && currentPage.visible)
			currentPage.draw();
	}

	public function switchPage(page:String):Void
	{
		if (pageInstances.exists(page))
		{
			Transition.instance.transitionOut(() ->
			{
				currentPage = pageInstances.get(page);
				Transition.instance.transitionOut();
			});
		}
		else
		{
			FlxG.log.error('Page $page was not found.');
		}
	}
}
