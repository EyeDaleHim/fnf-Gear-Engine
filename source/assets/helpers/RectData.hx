package assets.helpers;

typedef RectData<T> =
{
	var x:T;
	var y:T;
	var width:T;
	var height:T;
}

typedef IntRectData = RectData<Int>;
typedef FloatRectData = RectData<Float>;