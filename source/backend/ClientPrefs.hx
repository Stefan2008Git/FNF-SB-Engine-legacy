package backend;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import backend.Controls;
import states.TitleScreenState;

class ClientPrefs {
	public static var downScroll:Bool = false;
	public static var middleScroll:Bool = false;
	public static var opponentStrums:Bool = true;
	public static var showFPS:Bool = true;
	public static var rainbowFPS:Bool = false;
	public static var memory:Bool = false;
	public static var totalMemory:Bool = false;
	public static var engineVersion:Bool = false;
	public static var debugInfo:Bool = false;
	public static var flashing:Bool = true;
	public static var resultsScreen:Bool = false;
	public static var globalAntialiasing:Bool = true;
	public static var noteSplashes:Bool = true;
	public static var opponentArrowGlow:Bool = true;
	public static var lowQuality:Bool = false;
	public static var shaders:Bool = true;
	public static var velocityBackground:Bool = true;
	public static var framerate:Int = 60;
	public static var cursing:Bool = true;
	public static var violence:Bool = true;
	public static var camZooms:Bool = true;
	public static var hideHud:Bool = false;
	public static var hideWatermark:Bool = false;
	public static var hideJudgementCounter:Bool = false;
	public static var noteOffset:Int = 0;
	public static var arrowHSV:Array<Array<Int>> = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]];
	public static var vibration:Bool = false;
	public static var ghostTapping:Bool = true;
	public static var timeBarType:String = 'Time Left';
	public static var showTimeBar:Bool = true;
	// public static var cpuController:Bool = true;
	public static var colorblindMode:String = 'None';
	public static var scoreZoom:Bool = true;
	public static var noReset:Bool = false;
	public static var healthBarAlpha:Float = 1;
	public static var controllerMode:Bool = #if android true #else false #end;
	public static var hitsoundVolume:Float = 0;
	public static var pauseMusic:String = 'Tea Time';
	public static var comboStacking = true;
	public static var hitboxSelection:String = 'Original';
	public static var hitboxAlpha:Float = 0.2;
	public static var virtualPadAlpha:Float = 0.5;
	public static var hitboxSpace:Bool = true;
	public static var hitboxSpaceLocation:String = 'Bottom';
	public static var mainMenuStyle:String = 'Original';
	public static var gameStyle:String = 'SB Engine';
	public static var watermarkStyle:String = 'SB Engine';
	public static var objectEffects:Bool = true;
	public static var themes:String = 'SB Engine';
	public static var gameplaySettings:Map<String, Dynamic> = [
		'scrollspeed' => 1.0,
		'scrolltype' => 'multiplicative',
		'songspeed' => 1.0,
		'healthgain' => 1.0,
		'healthloss' => 1.0,
		'instakill' => false,
		'practice' => false,
		'botplay' => false,
		'opponentplay' => false
	];

	public static var comboOffset:Array<Int> = [0, 0, 0, 0];
	public static var ratingOffset:Int = 0;
	public static var sickWindow:Int = 45;
	public static var goodWindow:Int = 90;
	public static var badWindow:Int = 135;
	public static var safeFrames:Float = 10;

	// Every key has two binds, add your key bind down here and then add your control on options/ControlsSubState.hx and Controls.hx
	public static var keyBinds:Map<String, Array<FlxKey>> = [
		// Key Bind, Name for ControlsSubState
		'note_left' => [A, LEFT],
		'note_down' => [S, DOWN],
		'note_up' => [W, UP],
		'note_right' => [D, RIGHT],
		'ui_left' => [A, LEFT],
		'ui_down' => [S, DOWN],
		'ui_up' => [W, UP],
		'ui_right' => [D, RIGHT],
		'accept' => [SPACE, ENTER],
		'back' => [BACKSPACE, ESCAPE],
		'pause' => [ENTER, ESCAPE],
		'reset' => [R, NONE],
		'volume_mute' => [ZERO, NONE],
		'volume_up' => [NUMPADPLUS, PLUS],
		'volume_down' => [NUMPADMINUS, MINUS],
		'debug_1' => [SEVEN, NONE],
		'debug_2' => [EIGHT, NONE]
	];
	public static var defaultKeys:Map<String, Array<FlxKey>> = null;

	public static function loadDefaultKeys() {
		defaultKeys = keyBinds.copy();
		// trace(defaultKeys);
	}

	public static function saveSettings() {
		FlxG.save.data.downScroll = downScroll;
		FlxG.save.data.middleScroll = middleScroll;
		FlxG.save.data.opponentStrums = opponentStrums;
		FlxG.save.data.showFPS = showFPS;
		FlxG.save.data.rainbowFPS = rainbowFPS;
		FlxG.save.data.memory = memory;
		FlxG.save.data.totalMemory = totalMemory;
		FlxG.save.data.engineVersion = engineVersion;
		FlxG.save.data.debugInfo = debugInfo;
		FlxG.save.data.flashing = flashing;
		FlxG.save.data.resultsScreen = resultsScreen;
		FlxG.save.data.globalAntialiasing = globalAntialiasing;
		FlxG.save.data.noteSplashes = noteSplashes;
		FlxG.save.data.opponentArrowGlow = opponentArrowGlow;
		FlxG.save.data.lowQuality = lowQuality;
		FlxG.save.data.shaders = shaders;
		FlxG.save.data.velocityBackground = velocityBackground;
		FlxG.save.data.framerate = framerate;
		FlxG.save.data.camZooms = camZooms;
		FlxG.save.data.colorblindMode = colorblindMode;
		FlxG.save.data.noteOffset = noteOffset;
		FlxG.save.data.hideHud = hideHud;
		FlxG.save.data.hideWatermark = hideWatermark;
		FlxG.save.data.hideJudgementCounter = hideJudgementCounter;
		FlxG.save.data.arrowHSV = arrowHSV;
		FlxG.save.data.vibration = vibration;
		FlxG.save.data.ghostTapping = ghostTapping;
		FlxG.save.data.timeBarType = timeBarType;
		FlxG.save.data.showTimeBar = showTimeBar;
		// FlxG.save.data.cpuController = cpuController;
		FlxG.save.data.scoreZoom = scoreZoom;
		FlxG.save.data.noReset = noReset;
		FlxG.save.data.healthBarAlpha = healthBarAlpha;
		FlxG.save.data.comboOffset = comboOffset;
		FlxG.save.data.ratingOffset = ratingOffset;
		FlxG.save.data.sickWindow = sickWindow;
		FlxG.save.data.goodWindow = goodWindow;
		FlxG.save.data.badWindow = badWindow;
		FlxG.save.data.safeFrames = safeFrames;
		FlxG.save.data.gameplaySettings = gameplaySettings;
		FlxG.save.data.controllerMode = controllerMode;
		FlxG.save.data.hitsoundVolume = hitsoundVolume;
		FlxG.save.data.pauseMusic = pauseMusic;
		FlxG.save.data.hitboxSelection = hitboxSelection;
		FlxG.save.data.hitboxAlpha = hitboxAlpha;
		FlxG.save.data.virtualPadAlpha = virtualPadAlpha;
		FlxG.save.data.hitboxSpace = hitboxSpace;
		FlxG.save.data.hitboxSpaceLocation = hitboxSpaceLocation;
		FlxG.save.data.mainMenuStyle = mainMenuStyle;
		FlxG.save.data.gameStyle = gameStyle;
		FlxG.save.data.watermarkStyle = watermarkStyle;
		FlxG.save.data.objectEffects = objectEffects;
		FlxG.save.data.themes = themes;
		FlxG.save.data.comboStacking = comboStacking;

		FlxG.save.flush();

		var save:FlxSave = new FlxSave();
		save.bind('controls_v2', 'ninjamuffin99'); // Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		save.data.customControls = keyBinds;
		save.flush();
		FlxG.log.add("Settings saved!");
	}

	public static function loadPrefs() {
		if (FlxG.save.data.downScroll != null) {
			downScroll = FlxG.save.data.downScroll;
		}
		if (FlxG.save.data.middleScroll != null) {
			middleScroll = FlxG.save.data.middleScroll;
		}
		if (FlxG.save.data.opponentStrums != null) {
			opponentStrums = FlxG.save.data.opponentStrums;
		}
		if (FlxG.save.data.showFPS != null) {
			showFPS = FlxG.save.data.showFPS;
			if (Main.fpsVar != null) {
				Main.fpsVar.visible = showFPS;
			}
		}
		if (FlxG.save.data.rainbowFPS != null) {
			rainbowFPS = FlxG.save.data.rainbowFPS;
		}
		if (FlxG.save.data.memory != null) {
			memory = FlxG.save.data.memory;
		}
		if (FlxG.save.data.totalMemory != null) {
			totalMemory = FlxG.save.data.totalMemory;
		}
		if (FlxG.save.data.engineVersion != null) {
			engineVersion = FlxG.save.data.engineVersion;
		}
		if (FlxG.save.data.debugInfo != null) {
			debugInfo = FlxG.save.data.debugInfo;
		}
		if (FlxG.save.data.flashing != null) {
			flashing = FlxG.save.data.flashing;
		}
		if (FlxG.save.data.resultsScreen != null) {
			resultsScreen = FlxG.save.data.resultsScreen;
		}
		if (FlxG.save.data.globalAntialiasing != null) {
			globalAntialiasing = FlxG.save.data.globalAntialiasing;
		}
		if (FlxG.save.data.colorblindMode != null) {
			colorblindMode = FlxG.save.data.colorblindMode;
		}
		if (FlxG.save.data.noteSplashes != null) {
			noteSplashes = FlxG.save.data.noteSplashes;
		}
		if (FlxG.save.data.opponentArrowGlow != null) {
			opponentArrowGlow = FlxG.save.data.opponentArrowGlow;
		}
		if (FlxG.save.data.lowQuality != null) {
			lowQuality = FlxG.save.data.lowQuality;
		}
		if (FlxG.save.data.shaders != null) {
			shaders = FlxG.save.data.shaders;
		}
		if (FlxG.save.data.velocityBackground != null) {
			velocityBackground = FlxG.save.data.velocityBackground;
		}
		if (FlxG.save.data.framerate != null) {
			framerate = FlxG.save.data.framerate;
			if (framerate > FlxG.drawFramerate) {
				FlxG.updateFramerate = framerate;
				FlxG.drawFramerate = framerate;
			} else {
				FlxG.drawFramerate = framerate;
				FlxG.updateFramerate = framerate;
			}
		}
		if (FlxG.save.data.camZooms != null) {
			camZooms = FlxG.save.data.camZooms;
		}
		if (FlxG.save.data.hideHud != null) {
			hideHud = FlxG.save.data.hideHud;
		}
		if (FlxG.save.data.hideWatermark != null) {
			hideWatermark = FlxG.save.data.hideWatermark;
		}
		if (FlxG.save.data.hideJudgementCounter != null) {
			hideJudgementCounter = FlxG.save.data.hideJudgementCounter;
		}
		if (FlxG.save.data.noteOffset != null) {
			noteOffset = FlxG.save.data.noteOffset;
		}
		if (FlxG.save.data.arrowHSV != null) {
			arrowHSV = FlxG.save.data.arrowHSV;
		}
		if (FlxG.save.data.vibration != null) {
			vibration = FlxG.save.data.vibration;
		}
		if (FlxG.save.data.ghostTapping != null) {
			ghostTapping = FlxG.save.data.ghostTapping;
		}
		if (FlxG.save.data.timeBarType != null) {
			timeBarType = FlxG.save.data.timeBarType;
		}
		if (FlxG.save.data.showTimeBar != null) {
			showTimeBar = FlxG.save.data.showTimeBar;
		}
		/* if (FlxG.save.data.cpuController != null) {
			cpuController = FlxG.save.data.cpuController;
		} */
		if (FlxG.save.data.scoreZoom != null) {
			scoreZoom = FlxG.save.data.scoreZoom;
		}
		if (FlxG.save.data.noReset != null) {
			noReset = FlxG.save.data.noReset;
		}
		if (FlxG.save.data.healthBarAlpha != null) {
			healthBarAlpha = FlxG.save.data.healthBarAlpha;
		}
		if (FlxG.save.data.comboOffset != null) {
			comboOffset = FlxG.save.data.comboOffset;
		}

		if (FlxG.save.data.ratingOffset != null) {
			ratingOffset = FlxG.save.data.ratingOffset;
		}
		if (FlxG.save.data.sickWindow != null) {
			sickWindow = FlxG.save.data.sickWindow;
		}
		if (FlxG.save.data.goodWindow != null) {
			goodWindow = FlxG.save.data.goodWindow;
		}
		if (FlxG.save.data.badWindow != null) {
			badWindow = FlxG.save.data.badWindow;
		}
		if (FlxG.save.data.safeFrames != null) {
			safeFrames = FlxG.save.data.safeFrames;
		}
		if (FlxG.save.data.controllerMode != null) {
			controllerMode = FlxG.save.data.controllerMode;
		}
		if (FlxG.save.data.hitsoundVolume != null) {
			hitsoundVolume = FlxG.save.data.hitsoundVolume;
		}
		if (FlxG.save.data.pauseMusic != null) {
			pauseMusic = FlxG.save.data.pauseMusic;
		}
		if (FlxG.save.data.hitboxSelection != null) {
			hitboxSelection = FlxG.save.data.hitboxSelection;
		}
		if (FlxG.save.data.hitboxAlpha != null) {
			hitboxAlpha = FlxG.save.data.hitboxAlpha;
		}
		if (FlxG.save.data.virtualPadAlpha != null) {
			virtualPadAlpha = FlxG.save.data.virtualPadAlpha;
		}
		if (FlxG.save.data.mainMenuStyle != null) {
			mainMenuStyle = FlxG.save.data.mainMenuStyle;
		}
		if (FlxG.save.data.gameStyle != null) {
			gameStyle = FlxG.save.data.gameStyle;
		}
		if (FlxG.save.data.watermarkStyle != null) {
			watermarkStyle = FlxG.save.data.watermarkStyle;
		}
		if (FlxG.save.data.objectEffects != null) {
			objectEffects = FlxG.save.data.objectEffects;
		}
		if (FlxG.save.data.themes != null) {
			themes = FlxG.save.data.themes;
		}
		if (FlxG.save.data.gameplaySettings != null) {
			var savedMap:Map<String, Dynamic> = FlxG.save.data.gameplaySettings;
			for (name => value in savedMap) {
				gameplaySettings.set(name, value);
			}
		}

		// flixel automatically saves your volume!
		if (FlxG.save.data.volume != null) {
			FlxG.sound.volume = FlxG.save.data.volume;
		}
		if (FlxG.save.data.mute != null) {
			FlxG.sound.muted = FlxG.save.data.mute;
		}
		if (FlxG.save.data.comboStacking != null)
			comboStacking = FlxG.save.data.comboStacking;

		var save:FlxSave = new FlxSave();
		save.bind('controls_v2', 'ninjamuffin99');
		if (save != null && save.data.customControls != null) {
			var loadedControls:Map<String, Array<FlxKey>> = save.data.customControls;
			for (control => keys in loadedControls) {
				keyBinds.set(control, keys);
			}
			reloadControls();
		}
	}

	inline public static function getGameplaySetting(name:String, defaultValue:Dynamic):Dynamic {
		return /*PlayState.isStoryMode ? defaultValue : */ (gameplaySettings.exists(name) ? gameplaySettings.get(name) : defaultValue);
	}

	public static function reloadControls() {
		PlayerSettings.player1.controls.setKeyboardScheme(KeyboardScheme.Solo);

		TitleScreenState.muteKeys = copyKey(keyBinds.get('volume_mute'));
		TitleScreenState.volumeDownKeys = copyKey(keyBinds.get('volume_down'));
		TitleScreenState.volumeUpKeys = copyKey(keyBinds.get('volume_up'));
		FlxG.sound.muteKeys = TitleScreenState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleScreenState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleScreenState.volumeUpKeys;
	}

	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey> {
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;

		while (i < len) {
			if (copiedArray[i] == NONE) {
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}
		return copiedArray;
	}
}
