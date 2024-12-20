package assets.formats;

import assets.helpers.PointData;

typedef Animation = {
    var ?name:String;
	var ?prefix:String;
	var ?indices:Array<Int>;
	var ?fps:Float;
	var ?looped:Bool;
	var ?offset:IntPointData;
};

typedef AnimationFormat = Array<Animation>;
