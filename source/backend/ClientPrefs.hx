package backend;

import flixel.util.FlxSave;
import states.TitleState;

class ClientPrefs {
	public static var language:String = null;
	public static var discordRPC:Bool = true;
	public static var autoPause:Bool = true;
	public static var downScroll:Bool = false;
	public static var middleScroll:Bool = false;
	public static var opponentStrums:Bool = true;
	public static var showFPS:Bool = true;
	public static var totalFPS:Bool = false;
	public static var rainbowFPS:Bool = false;
	public static var memory:Bool = false;
	public static var totalMemory:Bool = false;
	public static var engineVersion:Bool = false;
	public static var debugInfo:Bool = false;
	public static var toastCore:Bool = true;
	public static var flashing:Bool = true;
	public static var skipFadeTransition:Bool = false;
	public static var resultsScreen:Bool = false;
	public static var mainMenuMusic:String = 'FNF';
	public static var showKeybindsOnStart:Bool = true;
	public static var iconBounce:Bool = true;
	public static var lessCpuController:Bool = false;
	public static var healthTween:Bool = true;
	public static var ratingImages:Bool = true;
	public static var globalAntialiasing:Bool = true;
	public static var noteSplashes:Bool = true;
	public static var opponentArrowGlow:Bool = true;
	public static var lowQuality:Bool = false;
	public static var shaders:Bool = true;
	public static var velocityBackground:Bool = true;
	public static var framerate:Int = 60;
	public static var gpuCaching:Bool = false;
	public static var cursing:Bool = true;
	public static var violence:Bool = true;
	public static var camZooms:Bool = true;
	public static var cameraMovement:Bool = false;
	public static var noteAngleSpin:Bool = true;
	public static var hideHud:Bool = false;
	public static var watermark:Bool = true;
	public static var judgementCounter:Bool = true;
	public static var judgementCounterStyle:String = 'Original';
	public static var songIntro:Bool = true;
	public static var noteOffset:Int = 0;
	public static var arrowHSV:Array<Array<Int>> = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]];
	public static var ghostTapping:Bool = true;
	public static var timeBarType:String = 'Time Elapsed';
	public static var showTimeBar:Bool = true;
	public static var colorBars:Bool = false;
	public static var botplayOnTimebar:Bool = true;
	public static var laneunderlayAlpha:Float = 0.1;
	public static var laneunderlay:Bool = false;
	public static var randomEngineNames:Bool = false;
	public static var colorblindMode:String = 'None';
	public static var scoreZoom:Bool = true;
	public static var judgementZoom:Bool = true;
	public static var noReset:Bool = false;
	public static var healthBarAlpha:Float = 1;
	public static var controllerMode:Bool = #if android true #else false #end;
	public static var hitsoundVolume:Float = 0;
	public static var pauseMusic:String = 'Tea Time';
	public static var comboStacking = true;
	public static var missedComboStacking:Bool = true;
	public static var objectTxtSine:Bool = true;
	public static var vibration:Bool = true;
	public static var dynamicColours:Bool = true;
	public static var hitboxSelection:String = 'Original';
	public static var hitboxAlpha:Float = 0.5;
	public static var virtualPadAlpha:Float = 0.5;
	public static var hitboxSpace:Bool = false;
	public static var hitboxSpaceLocation:String = 'Bottom';
	public static var mainMenuStyle:String = 'Original';
	public static var gameStyle:String = 'SB Engine';
	public static var watermarkStyle:String = 'SB Engine';
	public static var playbackRateDecimal:Bool = false;
	public static var timePercent:Bool = false;
	public static var timePercentValue:Int = 2;
	public static var objects:Bool = true;
	public static var missSound:Bool = true;
	public static var averageMiliseconds:Bool = true;
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
		'loop' => false
	];

	public static var comboOffset:Array<Int> = [0, 0, 0, 0];
	public static var ratingOffset:Int = 0;
	public static var impressiveWindow:Int = 25;
	public static var sickWindow:Int = 45;
	public static var goodWindow:Int = 90;
	public static var badWindow:Int = 135;
	public static var safeFrames:Float = 10;

	// Every key has two binds, add your key bind down here and then add your control on options/ControlsSubState.hx and backend/Controls.hx
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
		FlxG.save.data.language = language;
		FlxG.save.data.discordRPC = discordRPC;
		FlxG.save.data.autoPause = autoPause;
		FlxG.save.data.downScroll = downScroll;
		FlxG.save.data.middleScroll = middleScroll;
		FlxG.save.data.opponentStrums = opponentStrums;
		FlxG.save.data.showFPS = showFPS;
		FlxG.save.data.totalFPS = totalFPS;
		FlxG.save.data.rainbowFPS = rainbowFPS;
		FlxG.save.data.memory = memory;
		FlxG.save.data.totalMemory = totalMemory;
		FlxG.save.data.engineVersion = engineVersion;
		FlxG.save.data.debugInfo = debugInfo;
		FlxG.save.data.toastCore = toastCore;
		FlxG.save.data.flashing = flashing;
		FlxG.save.data.skipFadeTransition = skipFadeTransition;
		FlxG.save.data.resultsScreen = resultsScreen;
		FlxG.save.data.mainMenuMusic = mainMenuMusic;
		FlxG.save.data.showKeybindsOnStart = showKeybindsOnStart;
		FlxG.save.data.iconBounce = iconBounce;
		FlxG.save.data.lessCpuController = lessCpuController;
		FlxG.save.data.healthTween = healthTween;
		FlxG.save.data.ratingImages = ratingImages;
		FlxG.save.data.globalAntialiasing = globalAntialiasing;
		FlxG.save.data.noteSplashes = noteSplashes;
		FlxG.save.data.opponentArrowGlow = opponentArrowGlow;
		FlxG.save.data.lowQuality = lowQuality;
		FlxG.save.data.shaders = shaders;
		FlxG.save.data.velocityBackground = velocityBackground;
		FlxG.save.data.framerate = framerate;
		FlxG.save.data.gpuCaching = gpuCaching;
		FlxG.save.data.camZooms = camZooms;
		FlxG.save.data.cameraMovement = cameraMovement;
		FlxG.save.data.noteAngleSpin = noteAngleSpin;
		FlxG.save.data.colorblindMode = colorblindMode;
		FlxG.save.data.noteOffset = noteOffset;
		FlxG.save.data.hideHud = hideHud;
		FlxG.save.data.watermark = watermark;
		FlxG.save.data.judgementCounter = judgementCounter;
		FlxG.save.data.judgementCounterStyle = judgementCounterStyle;
		FlxG.save.data.songIntro = songIntro;
		FlxG.save.data.arrowHSV = arrowHSV;
		FlxG.save.data.vibration = vibration;
		FlxG.save.data.ghostTapping = ghostTapping;
		FlxG.save.data.timeBarType = timeBarType;
		FlxG.save.data.showTimeBar = showTimeBar;
		FlxG.save.data.colorBars = colorBars;
		FlxG.save.data.botplayOnTimebar = botplayOnTimebar;
		FlxG.save.data.laneunderlayAlpha = laneunderlayAlpha;
		FlxG.save.data.laneunderlay = laneunderlay;
		FlxG.save.data.randomEngineNames = randomEngineNames;
		FlxG.save.data.scoreZoom = scoreZoom;
		FlxG.save.data.judgementZoom = judgementZoom;
		FlxG.save.data.noReset = noReset;
		FlxG.save.data.healthBarAlpha = healthBarAlpha;
		FlxG.save.data.comboOffset = comboOffset;
		FlxG.save.data.ratingOffset = ratingOffset;
		FlxG.save.data.impressiveWindow = impressiveWindow;
		FlxG.save.data.sickWindow = sickWindow;
		FlxG.save.data.goodWindow = goodWindow;
		FlxG.save.data.badWindow = badWindow;
		FlxG.save.data.safeFrames = safeFrames;
		FlxG.save.data.gameplaySettings = gameplaySettings;
		FlxG.save.data.controllerMode = controllerMode;
		FlxG.save.data.hitsoundVolume = hitsoundVolume;
		FlxG.save.data.pauseMusic = pauseMusic;
		FlxG.save.data.dynamicColours = dynamicColours;
		FlxG.save.data.hitboxSelection = hitboxSelection;
		FlxG.save.data.hitboxAlpha = hitboxAlpha;
		FlxG.save.data.virtualPadAlpha = virtualPadAlpha;
		FlxG.save.data.hitboxSpace = hitboxSpace;
		FlxG.save.data.hitboxSpaceLocation = hitboxSpaceLocation;
		FlxG.save.data.mainMenuStyle = mainMenuStyle;
		FlxG.save.data.gameStyle = gameStyle;
		FlxG.save.data.watermarkStyle = watermarkStyle;
		FlxG.save.data.playbackRateDecimal = playbackRateDecimal;
		FlxG.save.data.timePercent = timePercent;
		FlxG.save.data.timePercentValue = timePercentValue;
		FlxG.save.data.objects = objects;
		FlxG.save.data.missSound = missSound;
		FlxG.save.data.averageMiliseconds = averageMiliseconds;
		FlxG.save.data.themes = themes;
		FlxG.save.data.comboStacking = comboStacking;
		FlxG.save.data.missedComboStacking = missedComboStacking;
		FlxG.save.data.objectTxtSine = objectTxtSine;

		FlxG.save.flush();

		var save:FlxSave = new FlxSave();
		save.bind('controls_v2', 'Stefan2008'); // Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		save.data.customControls = keyBinds;
		save.flush();
		FlxG.log.add("Settings saved!");
	}

	public static function loadPrefs() {
		FlxG.save.data.language != null ? language = FlxG.save.data.language : language = null;
		FlxG.save.data.discordRPC != null ? discordRPC = FlxG.save.data.discordRPC : discordRPC = true;
		FlxG.save.data.autoPause != null ? autoPause = FlxG.save.data.autoPause : autoPause = true;
		FlxG.save.data.downScroll != null ? downScroll = FlxG.save.data.downScroll : downScroll = false;
		FlxG.save.data.middleScroll != null ? middleScroll = FlxG.save.data.middleScroll : middleScroll = false;
		FlxG.save.data.opponentStrums != null ? opponentStrums = FlxG.save.data.opponentStrums : opponentStrums = true;
		if (FlxG.save.data.showFPS != null) {
			showFPS = FlxG.save.data.showFPS;
			if (Main.fpsVar != null) {
				Main.fpsVar.visible = showFPS;
			}
		}
		FlxG.save.data.totalFPS != null ? totalFPS = FlxG.save.data.totalFPS : totalFPS = false;
		FlxG.save.data.rainbowFPS != null ? rainbowFPS = FlxG.save.data.rainbowFPS : rainbowFPS = false;
		FlxG.save.data.memory != null ? memory = FlxG.save.data.memory : memory = false;
		FlxG.save.data.totalMemory != null ? totalMemory = FlxG.save.data.totalMemory : totalMemory = false;
		FlxG.save.data.engineVersion != null ? engineVersion = FlxG.save.data.engineVersion : engineVersion = false;
		FlxG.save.data.debugInfo != null ? debugInfo = FlxG.save.data.debugInfo : debugInfo = false;
		FlxG.save.data.toastCore != null ? toastCore = FlxG.save.data.toastCore : toastCore = true;
		FlxG.save.data.flashing != null ? flashing = FlxG.save.data.flashing : flashing = true;
		FlxG.save.data.skipFadeTransition != null ? skipFadeTransition = FlxG.save.data.skipFadeTransition : skipFadeTransition = false;
		FlxG.save.data.resultsScreen != null ? resultsScreen = FlxG.save.data.resultsScreen : resultsScreen = false;
		FlxG.save.data.mainMenuMusic != null ? mainMenuMusic = FlxG.save.data.mainMenuMusic : mainMenuMusic = 'FNF';
		FlxG.save.data.showKeybindsOnStart != null ? showKeybindsOnStart = FlxG.save.data.showKeybindsOnStart : showKeybindsOnStart = true;
		FlxG.save.data.iconBounce != null ? iconBounce = FlxG.save.data.iconBounce : iconBounce = true;
		FlxG.save.data.lessCpuController != null ? lessCpuController = FlxG.save.data.lessCpuController : lessCpuController = false;
		FlxG.save.data.healthTween != null ? healthTween = FlxG.save.data.healthTween : healthTween = true;
		FlxG.save.data.ratingImages != null ? ratingImages = FlxG.save.data.ratingImages : ratingImages = true;
		FlxG.save.data.globalAntialiasing != null ? globalAntialiasing = FlxG.save.data.globalAntialiasing : globalAntialiasing = true;
		FlxG.save.data.colorblindMode != null ? colorblindMode = FlxG.save.data.colorblindMode : colorblindMode = 'None';
		FlxG.save.data.noteSplashes != null ? noteSplashes = FlxG.save.data.noteSplashes : noteSplashes = true;
		FlxG.save.data.opponentArrowGlow != null ? opponentArrowGlow = FlxG.save.data.opponentArrowGlow : opponentArrowGlow= true;
		FlxG.save.data.lowQuality != null ? lowQuality = FlxG.save.data.lowQuality : lowQuality = false;
		FlxG.save.data.shaders != null ? shaders = FlxG.save.data.shaders : shaders = true;
		FlxG.save.data.velocityBackground != null ? velocityBackground = FlxG.save.data.velocityBackground : velocityBackground = true;
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
		FlxG.save.data.gpuCaching != null ? gpuCaching = FlxG.save.data.gpuCaching : gpuCaching = false;
		FlxG.save.data.camZooms != null ? camZooms = FlxG.save.data.camZooms : camZooms = true;
		FlxG.save.data.cameraMovement != null ? cameraMovement = FlxG.save.data.cameraMovement : cameraMovement = false;
		FlxG.save.data.noteAngleSpin != null ? noteAngleSpin = FlxG.save.data.noteAngleSpin : noteAngleSpin = true;
		FlxG.save.data.hideHud != null ? hideHud = FlxG.save.data.hideHud : hideHud = false;
		FlxG.save.data.watermark != null ? watermark = FlxG.save.data.watermark : watermark = true;
		FlxG.save.data.judgementCounter != null ? judgementCounter = FlxG.save.data.judgementCounter : judgementCounter = true;
		FlxG.save.data.judgementCounterStyle != null ? judgementCounterStyle = FlxG.save.data.judgementCounterStyle : judgementCounterStyle = 'Original';
		FlxG.save.data.songIntro != null ? songIntro = FlxG.save.data.songIntro : songIntro = true;
		FlxG.save.data.noteOffset != null ? noteOffset = FlxG.save.data.noteOffset : noteOffset = 0;
		FlxG.save.data.arrowHSV != null ? arrowHSV = FlxG.save.data.arrowHSV : arrowHSV = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]];
		FlxG.save.data.vibration != null ? vibration = FlxG.save.data.vibration : vibration = true;
		FlxG.save.data.ghostTapping != null ? ghostTapping = FlxG.save.data.ghostTapping : ghostTapping = true;
		FlxG.save.data.timeBarType != null ? timeBarType = FlxG.save.data.timeBarType : timeBarType = 'Time Elapsed';
		FlxG.save.data.showTimeBar != null ? showTimeBar = FlxG.save.data.showTimeBar : showTimeBar = true;
		FlxG.save.data.colorBars != null ? colorBars = FlxG.save.data.colorBars : colorBars = false;
		FlxG.save.data.botplayOnTimebar != null ? botplayOnTimebar = FlxG.save.data.botplayOnTimebar : botplayOnTimebar = true;
		FlxG.save.data.laneunderlayAlpha != null ? laneunderlayAlpha = FlxG.save.data.laneunderlayAlpha : laneunderlayAlpha = 0;
		FlxG.save.data.laneunderlay != null ? laneunderlay = FlxG.save.data.laneunderlay : laneunderlay = false;
		FlxG.save.data.randomEngineNames != null ? randomEngineNames = FlxG.save.data.randomEngineNames : randomEngineNames = false;
		FlxG.save.data.scoreZoom != null ? scoreZoom = FlxG.save.data.scoreZoom : scoreZoom = true;
		FlxG.save.data.judgementZoom != null ? scoreZoom = FlxG.save.data.judgementZoom : judgementZoom = true;
		FlxG.save.data.noReset != null ? noReset = FlxG.save.data.noReset : noReset = false;
		FlxG.save.data.healthBarAlpha != null ? healthBarAlpha = FlxG.save.data.healthBarAlpha : healthBarAlpha = 1;
		FlxG.save.data.comboOffset != null ? comboOffset = FlxG.save.data.comboOffset : comboOffset = [0, 0, 0, 0];
		FlxG.save.data.ratingOffset != null ? ratingOffset = FlxG.save.data.ratingOffset : ratingOffset = 0;
		FlxG.save.data.impressiveWindow != null ? impressiveWindow = FlxG.save.data.impressiveWindow : impressiveWindow = 25;
		FlxG.save.data.sickWindow != null ? sickWindow = FlxG.save.data.sickWindow : sickWindow = 45;
		FlxG.save.data.goodWindow != null ? goodWindow = FlxG.save.data.goodWindow : goodWindow = 90;
		FlxG.save.data.badWindow != null ? badWindow = FlxG.save.data.badWindow : badWindow = 135;
		FlxG.save.data.safeFrames != null ? safeFrames = FlxG.save.data.safeFrames : safeFrames = 10;
		FlxG.save.data.controllerMode != null ? controllerMode = FlxG.save.data.controllerMode : controllerMode = #if android true #else false #end;
		FlxG.save.data.hitsoundVolume != null ? hitsoundVolume = FlxG.save.data.hitsoundVolume : hitsoundVolume = 0;
		FlxG.save.data.pauseMusic != null ? pauseMusic = FlxG.save.data.pauseMusic : pauseMusic = 'Tea Time';
		FlxG.save.data.dynamicColours != null ? dynamicColours = FlxG.save.data.dynamicColours : dynamicColours = true;
		FlxG.save.data.hitboxSelection != null ? hitboxSelection = FlxG.save.data.hitboxSelection : hitboxSelection = 'Original';
		FlxG.save.data.hitboxAlpha != null ? hitboxAlpha = FlxG.save.data.hitboxAlpha : hitboxAlpha = 0.5;
		FlxG.save.data.virtualPadAlpha != null ? virtualPadAlpha = FlxG.save.data.virtualPadAlpha : virtualPadAlpha = 0.5;
		FlxG.save.data.mainMenuStyle != null ? mainMenuStyle = FlxG.save.data.mainMenuStyle : mainMenuStyle = 'Original';
		FlxG.save.data.gameStyle != null ? gameStyle = FlxG.save.data.gameStyle : gameStyle = 'SB Engine';
		FlxG.save.data.watermarkStyle != null ? watermarkStyle = FlxG.save.data.watermarkStyle : watermarkStyle = 'SB Engine';
		FlxG.save.data.playbackRateDecimal != null ? playbackRateDecimal = FlxG.save.data.playbackRateDecimal : playbackRateDecimal = false;
		FlxG.save.data.timePercent != null ? timePercent = FlxG.save.data.timePercent : timePercent = false;
		FlxG.save.data.timePercentValue != null ? timePercentValue = FlxG.save.data.timePercentValue : timePercentValue = 1;
		FlxG.save.data.objects != null ? objects = FlxG.save.data.objects : objects = true;
		FlxG.save.data.missSound != null ? missSound = FlxG.save.data.missSound : missSound = true;
		FlxG.save.data.averageMiliseconds != null ? averageMiliseconds = FlxG.save.data.averageMiliseconds : averageMiliseconds = true;
		FlxG.save.data.themes != null ? themes = FlxG.save.data.themes : themes = 'SB Engine';
		FlxG.save.data.objectTxtSine != null ? objectTxtSine = FlxG.save.data.objectTxtSine : objectTxtSine = true;
		if (FlxG.save.data.gameplaySettings != null) {
			var savedMap:Map<String, Dynamic> = FlxG.save.data.gameplaySettings;
			for (name => value in savedMap) {
				gameplaySettings.set(name, value);
			}
		}

		// flixel automatically saves your volume!
		FlxG.save.data.volume != null ? FlxG.sound.volume = FlxG.save.data.volume : FlxG.sound.volume = 1;
		FlxG.save.data.mute != null ? FlxG.sound.muted = FlxG.save.data.mute : FlxG.sound.muted = false;
		FlxG.save.data.comboStacking != null ? comboStacking = FlxG.save.data.comboStacking : comboStacking = true;
		FlxG.save.data.missedComboStacking != null ? missedComboStacking = FlxG.save.data.missedComboStacking : missedComboStacking = true;

		var save:FlxSave = new FlxSave();
		save.bind('controls_v2', 'Stefan2008');
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

		TitleState.muteKeys = copyKey(keyBinds.get('volume_mute'));
		TitleState.volumeDownKeys = copyKey(keyBinds.get('volume_down'));
		TitleState.volumeUpKeys = copyKey(keyBinds.get('volume_up'));
		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
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
