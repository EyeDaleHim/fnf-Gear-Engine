package utils;

class MathUtils
{
	/**
	 * Euler's constant.
	 */
	public static var E(default, null):Float = 2.718281828459045;

	/**
	 * Tau, equivalent to `2 * PI`.
	 */
	public static var TAU(default, null):Float = 6.283185307179586;

	/**
	 * The natural log of 10.
	 */
	public static var LN10(default, null):Float = 2.302585092994046;

	/**
	 * The natural log of 2.
	 */
	public static var LN2(default, null):Float = 0.6931471805599453;

	/**
	 * The logarithm base 10 of Euler's constant.
	 */
	public static var LOG10E(default, null):Float = 0.4342944819032518;

	/**
	 * The logarithm base 2 of Euler's constant.
	 */
	public static var LOG2E(default, null):Float = 1.4426950408889634;

	/**
	 * The square root of 1/2.
	 */
	public static var SQRT1_2(default, null):Float = 0.7071067811865476;

	/**
	 * The square root of 2.
	 */
	public static var SQRT2(default, null):Float = 1.4142135623730951;

	public static function min(...numbers:Float):Float
	{
		var output:Float = numbers[0];
		for (i in 0...numbers.length)
		{
			output = Math.min(output, numbers[i]);
		}

		return output;
	}

	public static function max(...numbers:Float):Float
	{
		var output:Float = numbers[0];
		for (i in 0...numbers.length)
		{
			output = Math.max(output, numbers[i]);
		}

		return output;
	}

	public static function mini(...numbers:Float):Int
	{
		var output:Float = numbers[0];
		for (i in 0...numbers.length)
		{
			output = Math.min(output, numbers[i]).round();
		}

		return output.round();
	}

	public static function maxi(...numbers:Float):Int
	{
		var output:Float = numbers[0];
		for (i in 0...numbers.length)
		{
			output = Math.max(output, numbers[i]).round();
		}

		return output.round();
	}
}
