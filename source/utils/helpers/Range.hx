package utils.helpers;

class Range
{
	public var min:Float;
	public var max:Float;
	public var length(get, never):Float;

	public function new(min:Float, max:Float)
	{
		if (min > max)
		{
			var temp:Float = min;
			min = max;
			max = temp;
		}

		this.min = min;
		this.max = max;
	}

	public function set(min:Float, max:Float):Range
	{
		this.min = min;
		this.max = max == null ? min : max;

		return this;
	}

	public function contains(value:Float):Bool
	{
		return value >= min && value <= max;
	}

	public function isContainedBy(other:Range):Bool
	{
		return min >= other.min && max <= other.max;
	}

	public function overlaps(other:Range):Bool
	{
		return min <= other.max && max >= other.min;
	}

	public function intersection(other:Range):Range
	{
		var newMin:Float = Math.max(min, other.min);
		var newMax:Float = Math.min(max, other.max);

		if (newMin <= newMax)
			return new Range(newMin, newMax);
		else
			return null; // No intersection
	}

    public function union(other:Range):Range
    {
        var newMin:Float = Math.min(min, other.min);
        var newMax:Float = Math.max(max, other.max);
        return new Range(newMin, newMax);
    }

    public function extend(amount:Float):Range
    {
        return new Range(min - amount, max + amount);
    }

    public inline function getMidpoint():Float
    {
        return (min + max) / 2;
    }

	private function get_length():Float
	{
		return max - min;
	}
}
