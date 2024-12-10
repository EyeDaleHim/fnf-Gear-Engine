package backend.ui.layout;

import backend.ui.layout.Container;
import backend.ui.internal.IContainer;

class Text extends FlxText implements IContainer
{
	public var parent:Container;

	public var borderPadding:FlxRect = FlxRect.get();
    public var anchor:Anchor = TOP_LEFT;
}