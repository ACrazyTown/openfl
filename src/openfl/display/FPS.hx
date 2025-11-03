package openfl.display;

import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
#if flash
import openfl.Lib;
#end

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class FPS extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	/**
		The current frame time, in miliseconds.
	**/
	public var currentFrameTime(default, null):Float;

	@:noCompletion private var updateTimer:Float = 0;
	@:noCompletion private var pollRate:Float = 100;
	@:noCompletion private var lastText:String = null;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 12, color);
		text = "FPS: ";
		width = 200;

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end
	}

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		updateTimer += deltaTime;

		if (updateTimer > pollRate)
		{
			updateTimer -= pollRate;
			currentFrameTime = deltaTime;
			currentFPS = Math.round(1000 / deltaTime);

			var newText = "FPS: " + currentFPS;
			newText += " (" + roundDecimal(deltaTime, 2) + "ms)";

			#if (gl_stats && !disable_cffi && (!html5 || !canvas))
			newText += "\ntotalDC: " + Context3DStats.totalDrawCalls();
			newText += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
			newText += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
			#end

			if (newText != lastText) {
				text = newText;
				lastText = newText;
			}
		}
	}

	// https://github.com/HaxeFlixel/flixel/blob/master/flixel/math/FlxMath.hx
	@:noCompletion
	private function roundDecimal(n:Float, p:Int):Float
	{
		var mult:Float = 1;
		for (i in 0...p)
		{
			mult *= 10;
		}
		return Math.fround(n * mult) / mult;
	}
}
