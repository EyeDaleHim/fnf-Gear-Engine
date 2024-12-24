#if !macro
#if !flash
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.FlxSubState;
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

import flixel.text.FlxText;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween.FlxTweenManager;

import flixel.input.keyboard.FlxKey;

import flixel.sound.FlxSound;

import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.util.FlxTimer.FlxTimerManager;
import flixel.util.FlxSignal;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxSpriteUtil;

import assets.Assets;

import backend.engine.SongList;
import backend.engine.WeekList;

import backend.engine.input.Control;
import backend.engine.input.Controls;

import objects.engine.Conductor;
import objects.engine.Transition;

import backend.ui.input.Button;
import backend.ui.layout.Box;
import backend.ui.layout.Text;

import objects.AtlasText;
import objects.AtlasTextGroup;

import states.internal.MainState;
import states.internal.MainSubstate;
import states.internal.PageState;

import states.menu.MenuState;
import states.menu.FreeplayState;

import states.play.PlayState;

import substates.PauseSubstate;

using flixel.util.FlxColorTransformUtil;
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
import haxe.io.Path;

using StringTools;
using Math;
using utils.MathUtils;