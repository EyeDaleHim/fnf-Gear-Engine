package assets.formats;

import flixel.util.typeLimit.OneOfThree;
import assets.formats.AnimationFormat;
import assets.helpers.PointData;

typedef StageFormat =
{
	var ?objects:Array<ObjectData>;
	var ?character:Array<Character>;

	var ?cameraPoints:Array<CameraPoint>;

	var ?startingCamera:String; // default camera point is at 1280/2, 720/2
};

typedef Object =
{
	var name:String;
	var type:ObjectType;
	var x:Float;
	var y:Float;
	var ?camera:String;
}

typedef Sprite = 
{
	var ?scale:FloatPointData;
	var ?graphicSize:FloatPointData; // if you need to resize by specific width and height, this is the way to do it
	var ?scrollFactor:FloatPointData;
	var ?flip:BoolPointData;
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

typedef ObjectData = OneOfThree<Object, StaticSprite, AnimatedSprite>;

enum abstract ObjectType(String)
{
	var BASIC;
	var STATICSPRITE;
	var ANIMATEDSPRITE;
}