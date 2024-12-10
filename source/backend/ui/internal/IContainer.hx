package backend.ui.internal;

import backend.ui.layout.Container;

interface IContainer
{
    var parent:Container;
    var borderPadding:FlxRect;
    var anchor:Anchor;
}