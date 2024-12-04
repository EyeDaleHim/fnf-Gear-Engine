package states.menu;

class MenuState extends FlxContainer
{
	public static final itemList:Array<String> = ["story", "freeplay", "options", "donate"];

    public var background:FlxSprite;
	public var flicker:FlxSprite;

	public var menuItems:FlxTypedGroup<FlxSprite>;

	public var index:Int = 0;
	public var selected:Bool = false;

	public var followLerp:FlxPoint = FlxPoint.get();

	public function new()
	{
		super();

        background = new FlxSprite(Assets.image('menus/backgrounds/mainBG'));
		background.scrollFactor.y = 0.20;
		background.active = false;
		background.scale.set(1.175, 1.175);
		background.updateHitbox();
		background.screenCenter();
		add(background);

        flicker = new FlxSprite(Assets.image('menus/backgrounds/flickerBG'));
		flicker.scrollFactor.y = 0.20;
		flicker.active = false;
		flicker.scale.set(1.175, 1.175);
		flicker.updateHitbox();
		flicker.screenCenter();
		flicker.kill();
		add(flicker);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (item in itemList)
		{
			var i:Int = itemList.indexOf(item);

			var sprItem:FlxSprite = new FlxSprite(0, 50 + (i * 170));
			sprItem.frames = Assets.frames('menus/mainmenu/menu_${itemList[i]}');
			sprItem.animation.addByPrefix('idle', itemList[i] + " basic", 24);
			sprItem.animation.addByPrefix('selected', itemList[i] + " white", 24);
			sprItem.animation.play('idle');
			sprItem.ID = i;
			sprItem.scrollFactor.set();
			sprItem.screenCenter(X);
			sprItem.updateHitbox();
			menuItems.add(sprItem);
		}
	}
}
