package states.menu;

import states.internal.Page;
import flixel.effects.FlxFlicker;

class MenuState extends Page
{
	public static final itemList:Array<String> = ["story", "freeplay", "options", "donate"];

	public var background:FlxSprite;
	public var flicker:FlxSprite;

	public var menuItems:FlxTypedGroup<FlxSprite>;

	public var index:Int = 0;
	public var selected:Bool = false;

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

		changeItem();
	}

	override public function update(elapsed:Float)
	{
		if (!selected)
		{
			if (FlxG.keys.justPressed.ENTER)
				selectItem();
			else
			{
				if (FlxG.keys.justPressed.UP)
					changeItem(-1);
				if (FlxG.keys.justPressed.DOWN)
					changeItem(1);
			}
		}

		camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, index * 100, FlxMath.bound(elapsed * 3.175, 0, 1));

		super.update(elapsed);
	}

	override public function kill()
	{
		super.kill();

		if (camera != null)
			camera.scroll.y = 0.0;
	}

	override public function revive()
	{
		super.revive();

		flicker.kill();
		selected = false;
	}

	public function selectItem()
	{
		flicker.revive();
		FlxFlicker.flicker(flicker, 1.0, 0.15);
		FlxFlicker.flicker(menuItems.members[index], 1.0, 0.06);

		FlxG.sound.play(Assets.sound("sfx/menu/confirmMenu"), 0.7);

		FlxTimer.wait(1.0, function()
		{
			switch (itemList[index])
			{
				case 'freeplay':
					switchPage('freeplay');
				default:
					{
						// do something...
						flicker.kill();
						menuItems.forEach(function(spr:FlxSprite)
						{
							if (spr.ID != index)
								spr.alpha = 1.0;
						});

						selected = false;
					}
			}
		});

		selected = true;
	}

	public function changeItem(change:Int = 0)
	{
		if (selected)
			return;

		index = FlxMath.wrap(index + change, 0, itemList.length - 1);

		if (change != 0)
			FlxG.sound.play(Assets.sound("sfx/menu/scrollMenu"), 0.5);

		menuItems.forEach(function(spr:FlxSprite)
		{
			if (spr.ID == index)
				spr.animation.play("selected");
			else
				spr.animation.play("idle");

			spr.updateHitbox();
			spr.screenCenter(X);
		});
	}
}
