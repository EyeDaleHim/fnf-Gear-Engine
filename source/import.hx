#if !macro
#if !flash
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.FlxSprite;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;

import flixel.group.FlxContainer;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;

import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import flixel.input.keyboard.FlxKey;

import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.util.FlxSignal.FlxTypedSignal;

import assets.Assets;

import objects.engine.Transition;

import states.internal.MainState;
import states.internal.PageState;

import states.menu.MenuState;
#end

#if sys
import sys.FileSystem;
import sys.io.File;
#end
#end

import haxe.Json;
import haxe.Serializer;
import haxe.Unserializer;
import haxe.io.Bytes;

using StringTools;