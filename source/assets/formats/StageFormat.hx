package assets.formats;

import assets.formats.AnimationFormat;

typedef StageFormat =
{
	var ?objects:Array<ObjectData<StaticSprite, AnimatedSprite>>;
	var ?character:Array<Character>;

	var ?cameraPoints:Array<CameraPoint>;

	var ?startingCamera:String; // default camera point is at 1280/2, 720/2
};

typedef Object =
{
	var name:String;
	var x:Float;
	var y:Float;
}

typedef Sprite = 
{
	var ?scale:{x:Float, y:Float};
	var ?scrollFactor:{x:Float, y:Float};
};

typedef StaticSprite =
{
	> Object,
	> Sprite,
	var graphic:String;
};

typedef AnimatedSprite =
{
	> Object,
	> Sprite,
	var frames:String;
	var animation:AnimationFormat;

	var ?currentAnimation:String;
	var ?animationOrder:Array<String>;
};

typedef Character = {
	var characterReference:String;
	var object:String; // reference in "objects"
}

typedef CameraPoint =
{
	> Object,
	var zoom:Float;
};

abstract ObjectData<T1, T2>(Object) from T1 from T2 to T1 to T2 {}