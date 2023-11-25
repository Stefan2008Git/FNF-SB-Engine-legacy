package openfl.display;

import haxe.Timer;
import openfl.events.Event;
import states.MainMenuState;

#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
#if flash
import openfl.Lib;
#end
#if openfl
import openfl.system.System;
#end

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
enum GLInfo {
	RENDERER;
	SHADING_LANGUAGE_VERSION;
}

class FPS extends TextField {
	public var currentlyFPS(default, null):Int;
	public var totalFPS(default, null):Int;

	public var color:Int = 0xFF000000;
	public var currentlyMemory:Float;
	public var maximumMemory:Float;
	public var realAlpha:Float = 1;
	public var redText:Bool = false;

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;

	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10) {
		super();

		this.x = x;
		this.y = y;

		currentlyFPS = 0;
		totalFPS = 0;
		selectable = false;
		mouseEnabled = false;
		#if android
		defaultTextFormat = new TextFormat(null, 14, color);
		#else
		defaultTextFormat = new TextFormat(null, 12, color);
		#end
		autoSize = LEFT;
		multiline = true;
		text = LanguageHandler.fpsCounterTxt;

		cacheCount = 0;
		currentTime = 0;
		times = [];

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e) {
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end
	}

	var array:Array<FlxColor> = [
		FlxColor.fromRGB(148, 0, 211),
		FlxColor.fromRGB(75, 0, 130),
		FlxColor.fromRGB(0, 0, 255),
		FlxColor.fromRGB(0, 255, 0),
		FlxColor.fromRGB(255, 255, 0),
		FlxColor.fromRGB(255, 127, 0),
		FlxColor.fromRGB(255, 0, 0)
	];

	var skippedFrames = 0;

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void {
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000) {
			times.shift();
		}

		var minAlpha:Float = 0.5;
		var aggressor:Float = 1;

		if (ClientPrefs.rainbowFPS) {
			if (textColor >= array.length)
				textColor = 0;
			textColor = Math.round(FlxMath.lerp(0, array.length, skippedFrames / (ClientPrefs.framerate / 3)));
			(cast(Lib.current.getChildAt(0), Main)).changeFPSColor(array[textColor]);
			textColor++;
			skippedFrames++;
			if (skippedFrames > (ClientPrefs.framerate / 3))
				skippedFrames = 0;
		}

		if (!redText)
			realAlpha = CoolUtil.boundTo(realAlpha - (deltaTime / 1000) * aggressor, minAlpha, 1);
		else
			realAlpha = CoolUtil.boundTo(realAlpha + (deltaTime / 1000), 0.3, 1);

		var currentCount = times.length;
		currentlyFPS = Math.round((currentCount + cacheCount) / 2);
		totalFPS = Math.round(currentlyFPS + currentCount / 8);
		if (currentlyFPS > ClientPrefs.framerate)
			currentlyFPS = ClientPrefs.framerate;
		if (totalFPS < 10)
			totalFPS = 0;

		if (currentCount != cacheCount) {
			text = LanguageHandler.fpsCounterTxt + currentlyFPS;

			currentlyMemory = obtainMemory();
			if (currentlyMemory >= maximumMemory)
				maximumMemory = currentlyMemory;

			if (ClientPrefs.totalFPS) {
				text += LanguageHandler.totalFpsCounterTxt + totalFPS;
			}

			if (ClientPrefs.memory) {
				text += LanguageHandler.memoryCounterTxt + CoolUtil.formatMemory(Std.int(currentlyMemory));
			}

			if (ClientPrefs.totalMemory) {
				text += LanguageHandler.totalMemoryCounterTxt + CoolUtil.formatMemory(Std.int(maximumMemory));
			}

			if (ClientPrefs.engineVersion) {
				text += LanguageHandler.sbEngineVersionCounterTxt + MainMenuState.sbEngineVersion + " (" + LanguageHandler.psychEngineVersionCounterTxt + MainMenuState.psychEngineVersion + ") ";
			}

			if (ClientPrefs.debugInfo) {
				text += LanguageHandler.stateClassNameCounterTxt + '${Type.getClassName(Type.getClass(FlxG.state))}' + '.hx';
				if (FlxG.state.subState != null)
					text += LanguageHandler.substateClassNameCounterTxt + '${Type.getClassName(Type.getClass(FlxG.state.subState))}' + '.hx';
				text += LanguageHandler.operatingSystemCounterTxt + '${lime.system.System.platformLabel} ${lime.system.System.platformVersion}';
				text += LanguageHandler.glRenderCounterTxt + '${getGLInfo(RENDERER)}';
				text += LanguageHandler.glShadingVersionCounterTxt + '${getGLInfo(SHADING_LANGUAGE_VERSION)})';
			}

			switch (ClientPrefs.gameStyle) {
				case 'Psych Engine':
					#if android
					Main.fpsVar.defaultTextFormat = new TextFormat('_sans', 14, color);
					#else
					Main.fpsVar.defaultTextFormat = new TextFormat('_sans', 12, color);
					#end
				
				default:
					#if android
					Main.fpsVar.defaultTextFormat = new TextFormat('Bahnschrift', 14, color);
					#else
					Main.fpsVar.defaultTextFormat = new TextFormat('Bahnschrift', 12, color);
					#end
			}

			textColor = FlxColor.fromRGBFloat(255, 255, 255, realAlpha);
			if (currentlyFPS <= ClientPrefs.framerate / 2) {
				textColor = FlxColor.fromRGBFloat(255, 0, 0, realAlpha);
				redText = true;
			}

			#if (gl_stats && !disable_cffi && (!html5 || !canvas))
			text += "\ntotalDC: " + Context3DStats.totalDrawCalls();
			text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
			text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
			#end

			text += "\n";
		}

		cacheCount = currentCount;
	}

	function obtainMemory():Dynamic {
		return System.totalMemory;
	}

	private function getGLInfo(info:GLInfo):String {
		@:privateAccess
		var gl:Dynamic = Lib.current.stage.context3D.gl;

		switch (info) {
			case RENDERER:
				return Std.string(gl.getParameter(gl.RENDERER));
			case SHADING_LANGUAGE_VERSION:
				return Std.string(gl.getParameter(gl.SHADING_LANGUAGE_VERSION));
		}
		return '';
	}
}
