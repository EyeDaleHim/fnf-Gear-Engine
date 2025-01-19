package objects.play;

import assets.formats.StageFormat;
import assets.formats.StageFormat.CameraPoint;

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
			},
			{
				name: 'no_stage_detected',
				graphic: 'no_stage_detected',
				type: STATICSPRITE,
				x: 0.0,
				y: 0.0
			}
		]
	};

	public var name:String;
	public var data:StageFormat;

	public var freeflyCamera:FlxCamera;
	public var freeflyFollow:FlxObject;
	public var freeflyPosition:FlxPoint;
	public var freeflyZoom:Float = 1.0;

	public var camFollow:FlxObject;

	public var camFocus:String = "";

	public var cameraPoints:Map<String, CameraPoint> = [];
	public var actualCameraPositionSprite:FlxSprite;

	public var objectList:Array<FlxBasic> = [];

	public var freefly:Bool = false;

	public function new(?name:String, ?format:StageFormat)
	{
		super();

		freeflyCamera = new FlxCamera();
		freeflyCamera.visible = false;

		this.name = name;

		data = format ?? fallbackStage;

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.screenCenter();
		add(camFollow);

		freeflyFollow = new FlxObject(0, 0, 1, 1);
		freeflyFollow.screenCenter();
		add(freeflyFollow);

		freeflyCamera.follow(freeflyFollow, null, 1.0);

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
							flxObject.cameras = [camera, freeflyCamera];
							add(flxObject);
						}
					case ANIMATEDSPRITE:
						{}
					case STATICSPRITE:
						{
							add(createStaticSprite(object));
						}
				}
			}
		}

		if (data.cameraPoints == null || data.cameraPoints.length == 0)
		{
			cameraPoints = [
				"default" => {
					x: FlxG.width / 2,
					y: FlxG.height / 2,
					type: BASIC,
					name: "default",
					zoom: 1.1
				}
			];
			camFocus = "default";
		}
		else
		{
			for (point in data.cameraPoints)
			{
				cameraPoints.set(point.name, point);
			}
		}

		actualCameraPositionSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.RED);
		actualCameraPositionSprite.alpha = 0.0;
		actualCameraPositionSprite.camera = freeflyCamera;
		add(actualCameraPositionSprite);
	}

	override public function update(elapsed:Float)
	{
		if (freeflyCamera.visible)
		{
			actualCameraPositionSprite.x = camera.viewX;
			actualCameraPositionSprite.y = camera.viewY;
			actualCameraPositionSprite.setGraphicSize(camera.viewWidth, camera.viewHeight);
			actualCameraPositionSprite.updateHitbox();

			actualCameraPositionSprite.alpha = FlxMath.lerp(actualCameraPositionSprite.alpha, freeflyCamera.visible ? 0.5 : 0,
				FlxMath.bound(elapsed * 3.0, 0, 1));

			if (FlxG.keys.pressed.A)
				freeflyPosition.x -= elapsed * 250.0;
			if (FlxG.keys.pressed.D)
				freeflyPosition.x += elapsed * 250.0;
			if (FlxG.keys.pressed.W)
				freeflyPosition.y -= elapsed * 250.0;
			if (FlxG.keys.pressed.S)
				freeflyPosition.y += elapsed * 250.0;
			if (FlxG.keys.pressed.Q)
				freeflyZoom -= elapsed;
			if (FlxG.keys.pressed.E)
				freeflyZoom += elapsed;

			freeflyFollow.setPosition(FlxMath.lerp(freeflyFollow.x, freeflyPosition.x, FlxMath.bound(elapsed * 4.5, 0, 1)),
				FlxMath.lerp(freeflyFollow.y, freeflyPosition.y, FlxMath.bound(elapsed * 4.5, 0, 1)));
			freeflyCamera.zoom = FlxMath.lerp(freeflyCamera.zoom, freeflyZoom, FlxMath.bound(elapsed * 1.5, 0, 1));
		}

		if (cameraPoints.exists(camFocus))
		{
			camera.zoom = FlxMath.lerp(camera.zoom, cameraPoints.get(camFocus).zoom, FlxMath.bound(elapsed * 9.0, 0, 1));
			camFollow.setPosition(FlxMath.lerp(camFollow.x, cameraPoints.get(camFocus).x, FlxMath.bound(elapsed * 15.0, 0, 1)),
				FlxMath.lerp(camFollow.y, cameraPoints.get(camFocus).y, FlxMath.bound(elapsed * 15.0, 0, 1)));
		}

		super.update(elapsed);
	}

	public function toggleFreeflyCamera():Void
	{
		if (!freeflyCamera.visible)
		{
			if (freeflyPosition == null)
			{
				freeflyPosition = FlxPoint.get(camFollow.x, camFollow.y);
				freeflyFollow.setPosition(freeflyPosition.x, freeflyPosition.y);
			}

			freeflyFollow.setPosition(camFollow.x, camFollow.y);
			freeflyCamera.zoom = camera.zoom;
		}
		else
		{
			camFollow.setPosition(freeflyFollow.x, freeflyFollow.y);
			camera.zoom = freeflyCamera.zoom;
		}

		freeflyCamera.visible = !freeflyCamera.visible;
		camera.visible = !freeflyCamera.visible;
	}

	public function initStageCameras(?gameCamera:FlxCamera, ?hudCamera:FlxCamera):Void
	{
		if (data.objects != null)
		{
			for (obj in data.objects)
			{
				var object:Dynamic = cast obj;
				var correspondingObject = objectList[data.objects.indexOf(obj)];
				switch (object.camera)
				{
					case "hud":
						correspondingObject.camera = hudCamera;
					default:
						correspondingObject.cameras = [gameCamera, freeflyCamera];
				}
			}
		}
	}

	private function createStaticSprite(obj:Dynamic):FlxSprite
	{
		var sprite:FlxSprite = new FlxSprite(obj.x, obj.y);
		sprite.cameras = [camera, freeflyCamera];
		sprite.loadGraphic(Assets.image(Path.join(['stages', obj.graphic])));
		if (obj.scroll != null)
			sprite.scrollFactor.set(obj.scroll.x ?? 1.0, obj.scroll.y ?? 1.0);
		if (obj.scale != null)
			sprite.scale.set(obj.scale.x ?? 1.0, obj.scale.y ?? 1.0);
		sprite.active = false;

		objectList.push(sprite);

		return sprite;
	}
}
