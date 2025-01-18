package objects.play;

import assets.formats.StageFormat;

class Stage extends FlxGroup
{
	public static final fallbackStage:StageFormat = {
		objects: [
			{
                name: 'back',
				graphic: 'stage/stageBack',
                type: STATICSPRITE,
				x: -600.0,
				y: -200.0,
				scroll: {x: 0.90, y: 0.90}
			},
            {
                name: 'front',
				graphic: 'stage/stageFront',
                type: STATICSPRITE,
				x: -650.0,
				y: 600.0,
				scroll: {x: 0.90, y: 0.90},
                scale: {x: 1.1, y: 1.1}
			},
			{
                name: 'curtains',
                graphic: 'stage/stageCurtains',
                type: STATICSPRITE,
                x: -500.0,
                y: -300.0,
                scroll: {x: 1.30, y: 1.30},
                scale: {x: 0.90, y: 0.90}
            }
		]
	};

    public var name:String;
	public var data:StageFormat;

	public function new(?name:String, ?format:StageFormat)
	{
		super();

        this.name = name;

		data = format ?? fallbackStage;

        // I don't think I cooked... system is good, but redo the code at some point
		if (data.objects != null)
		{
			for (obj in data.objects) 
            {
                var object:Dynamic = cast obj;
                switch (object.type)
                {
                    case BASIC:
                    {
                        var flxObject:FlxObject = new FlxObject(object.x, object.y);
                        flxObject.active = false;
                        add(flxObject);
                    }
                    case ANIMATEDSPRITE:
                    {

                    }
                    case STATICSPRITE:
                    {
                        var sprite:FlxSprite = new FlxSprite(object.x, object.y);
                        sprite.loadGraphic(Assets.image(Path.join(['stages', object.graphic])));
                        if (object.scroll != null)
                            sprite.scrollFactor.set(object.scroll.x ?? 1.0, object.scroll.y ?? 1.0);
                        if (object.scale != null)
                            sprite.scale.set(object.scale.x ?? 1.0, object.scale.y ?? 1.0);
                        sprite.active = false;
                        add(sprite);
                    }
                }
            }
		}
	}
}
