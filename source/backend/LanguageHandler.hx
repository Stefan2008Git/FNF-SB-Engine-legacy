package backend;

import flixel.util.FlxSort;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import haxe.Json;
import haxe.format.JsonParser;

typedef LanguageFile =
{
	// Language
	var language:String;

	// FPS counter
	var fpsCounterTxt:String;
	var totalFpsCounterTxt:String;
	var memoryCounterTxt:String;
	var totalMemoryCounterTxt:String;
	var sbEngineVersionCounterTxt:String;
	var psychEngineVersionCounterTxt:String;
	var stateClassNameCounterTxt:String;
	var substateClassNameCounterTxt:String;
	var operatingSystemCounterTxt:String;
	var glRenderCounterTxt:String;
	var glShadingVersionCounterTxt:String;

	// Main menu
	var galleryTextAndroid:String;
	var secretTextAndroid:String;
	var galleryText:String;
	var secretText:String;
	var sbEngineVersionTxt:String;
	var modifiedPsychEngineVersionTxt:String;
	var psychEngineVersionTxt:String;
	var fnfEngineVersionTxt:String;

	// Story mode
	var weekScoreTxt:String;

	// Freeplay menu
	var personalBestTxt:String;
	var freeplayInfo1Android:String;
	var freeplayInfo2Android:String;
	var freeplayInfo3Android:String;
	var freeplayInfo1:String;
	var freeplayInfo2:String;
	var freeplayInfo3:String;
	var loadingSongText:String;

	// Mods menu
	var noModsInstalledTxt:String;
	var onTxt:String;
	var offTxt:String;
	var topTxt:String;
	var disableAllModsTxt:String;
	var enableAllModsTxt:String;
	var restartModDescriptionTxt:String;
	var modDescriptionTxt:String;

	// Credits menu
	var sbEngineTeamTxt:String;
	var stefan2008Description:String;
	var nuryDescription:String;
	var hutarozDescription:String;
	var maysLastPlayDescription:String;
	var fearester2008Description:String;
	var sunBurntTailsDescription:String;
	var aliAlafandyDescription:String;
	var luizFelipePlayDescription:String;
	var specialCreditsTxt:String;
	var stefanRo123Description:String;
	var elgatosinnobreDescription:String;
	var sussySamDescription:String;
	var lizzyStrawberyDescription:String;
	var joalor64Description:String;
	var justXaleDescription:String;
	var squidBowlDescription:String;
	var jordanSantiagoDescription:String;
	var coreDevDescription:String;
	var tomyGamyDescription:String;
	var marioMasterDescription:String;
	var nfBeihuDescription:String;
	var maJigsaw77Description:String;
	var goldieDescription:String;
	var psychEngineTeamTxt:String;
	var shadowMarioDescription:String;
	var riverOakenDescription:String;
	var formerEngineMemberTxt:String;
	var bbpanzuDescription:String;
	var engineContributorsTxt:String;
	var iflickyDescription:String;
	var sqirraRngDescription:String;
	var eliteMasterEricDescription:String;
	var polybiusProxyDescription:String;
	var kadeDevDescription:String;
	var keoikiDescription:String;
	var nebulaTheZoruaDescription:String;
	var smokeyDescription:String;
	var funkinCrewTxt:String;
	var ninjaMuffin99Description:String;
	var phantomAcradeDescription:String;
	var evilsk8rDescription:String;
	var kawaiSpriteDescription:String;

	// Options menu
	var delayCombo:String;
	var controls:String;
	var gameplay:String;
	var graphics:String;
	var languages:String;
	var noteColor:String;
	var visualsUI:String;
	var androidControlsSettings:String;
	var customizableAndroidControls:String;
	var delayComboTip:String;
	var controlsTip:String;
	var gameplayTip:String;
	var graphicsTip:String;
	var languagesTip:String;
	var noteColorTip:String;
	var visualsUITip:String;

	// Delay combo option menu
	var beatHitTxt:String;
	var ratingOffsetTxt:String;
	var numberOffsetTxt:String;
	var currentOffsetTxt:String;
	var acceptComboOffsetTxt:String;
	var noteBeatDelayTxt:String;

	// Controls sub option
	var notesTxt:String;
	var leftNoteTxt:String;
	var downNoteTxt:String;
	var upNoteTxt:String;
	var rightNoteTxt:String;
	var uiTxt:String;
	var leftKeyTxt:String;
	var downKeyTxt:String;
	var upKeyTxt:String;
	var rightKeyTxt:String;
	var resetKeyTxt:String;
	var acceptKeyTxt:String;
	var backKeyTxt:String;
	var pauseKeyTxt:String;
	var volumeTxt:String;
	var volumeMuteKeyTxt:String;
	var volumeUpKeyTxt:String;
	var volumeDownKeyTxt:String;
	var debugTxt:String;
	var debugKeyOneTxt:String;
	var debugKeyTwoTxt:String;
	var defaultKeyTxt:String;

	// Gameplay sub option
	var controllerMode:String;
	var controllerModeDescription:String;
	var noteSplashes:String;
	var noteSplashesDescription:String;
	var opponentArrowGlow:String;
	var opponentArrowGlowDescription:String;
	var hideHud:String;
	var hideHudDescription:String;
	var watermark:String;
	var watermarkDescription:String;
	var judgement:String;
	var judgementDescription:String;
	var downScroll:String;
	var downScrollDescription:String;
	var middleScroll:String;
	var middleScrollDescription:String;
	var ghostTapping:String;
	var ghostTappingDescription:String;
	var disableReset:String;
	var disableResetDescription:String;
	var cameraZoom:String;
	var cameraZoomDescription:String;
	var cameraMovement:String;
	var cameraMovementDescription:String;
	var scoreZoomText:String;
	var scoreZoomTextDescription:String;
	var judgementZoomText:String;
	var judgementZoomTextDescription:String;
	var showKeybinds:String;
	var showKeybindsDescription:String;
	var iconBounce:String;
	var iconBounceDescription:String;
	var healthTween:String;
	var healthTweenDescription:String;
	var ratingImages:String;
	var ratingImagesDescription:String;
	var resultsScreen:String;
	var resultsScreenDescription:String;
	var comboStacking:String;
	var comboStackingDescription:String;
	var playbackSpeedDecimal:String;
	var playbackSpeedDecimalDescription:String;
	var timePercent:String;
	var timePercentDescription:String;
	var songIntroCard:String;
	var songIntroCardDescription:String;
	var missSound:String;
	var missSoundDescription:String;
	var averageMillisecond:String;
	var averageMillisecondDescription:String;
	var underlay:String;
	var underlayDescription:String;
	var randomEngineNames:String;
	var randomEngineNamesDescription:String;
	var lessCpuController:String;
	var lessCpuControllerDescription:String;
	var botplayTxtOnTimeBar:String;
	var botplayTxtOnTimeBarDescription:String;
	var vibration:String;
	var vibrationDescription:String;
	var timeBarStyle:String;
	var timeBarStyleDescription:String;
	var watermarkStyle:String;
	var watermarkStyleDescription:String;
	var judgementStyle:String;
	var judgementStyleDescription:String;
	var healthAlpha:String;
	var healthAlphaDescription:String;
	var underlayAlpha:String;
	var underlayAlphaDescription:String;
	var hitSound:String;
	var hitSoundDescription:String;
	var rating:String;
	var ratingDescription:String;
	var impressive:String;
	var impressiveDescription:String;
	var sick:String;
	var sickDescription:String;
	var good:String;
	var goodDescription:String;
	var bad:String;
	var badDescription:String;
	var safeFrames:String;
	var safeFramesDescription:String;
	var timeDecimals:String;
	var timeDecimalsDescription:String;

	// Graphic sub option
	var lowQuality:String;
	var lowQualityDescription:String;
	var globalAntialiasing:String;
	var globalAntialiasingDescription:String;
	var shaders:String;
	var shadersDescription:String;
	var caching:String;
	var cachingDescription:String;
	var framerate:String;
	var framerateDescription:String;

	// Note color sub option
	var resetNoteColorTxtAndroid:String;
	var resetNoteColorTxt:String;
	var hsbTxt:String;

	// VisualsUI sub option
	var flashingLigths:String;
	var flashingLightsDescription:String;
	var showFps:String;
	var showFpsDescription:String;
	var showTotalFps:String;
	var showTotslFpsDescription:String;
	var showMemory:String;
	var showMemoryDescription:String;
	var showMemoryPeak:String;
	var showMemoryPeakDescription:String;
	var showEngineVersion:String;
	var shoeEngineVersionDescription:String;
	var toastCore:String;
	var toastCoreDescription:String;
	var toastCoreTxt:String;
	var enabled:String;
	var disabled:String;
	var velocityBackground:String;
	var velocityBackgroundDescription:String;
	var objects:String;
	var objectsDescription:String;
	var pauseMusic:String;
	var pauseMusicDescription:String;
	var freakyMenu:String;
	var freakyMenuDescription:String;
	var gameStyle:String;
	var gameStyleDescription:String;
	var mainMenuStyle:String;
	var mainMenuStyleDescription:String;
	var colorblind:String;
	var colorblindDescription:String;
	var themes:String;
	var themesDescription:String;

	// Secret debug menu option
	var debugMenu:String;
	var enteredTo:String;
	var thatOption:String;

	// Secret debug sub menu option
	var enableDebugInfo:String;
	var enableDebugInfoDescription:String;
	var enableRainbowFps:String;
	var enableRainbowFpsDescription:String;
	var skipTransition:String;
	var skipTransitionDescription:String;
	var autoPause:String;
	var autoPauseDescription:String;
	var discordRpc:String;
	var discordRpcDescription:String;

	// Android controls style
	var androidTitle:String;
	var hitboxStyle:String;
	var hitboxStyleDescription:String;
	var hitboxAlpha:String;
	var hitboxAlphaDescription:String;
	var virtualPadAlpha:String;
	var virtualPadAlphaDescription:String;
	var space:String;
	var spaceDescription:String;
	var spaceLocation:String;
	var spaceLocationDescription:String;
	var dynamicColor:String;
	var dynamicColorDescription:String;

	// Android control settings
	var padRight:String;
	var padLeft:String;
	var padCustom:String;
	var padDuo:String;
	var keyboard:String;
	var hitbox:String;
	var resetAndroidControlsTxt:String;
	var onlyKeyboardTxt:String;
	var tipTxt:String;
	var upPositionTxt:String;
	var downPositionTxt:String;
	var leftPositionTxt:String;
	var rightPositionTxt:String;

	// PlayState (aka. In-game text)
	var youSuckSbRatingNameTxt:String;
	var freakSbRatingNameTxt:String;
	var reallyBadSbRatingNameTxt:String;
	var badSbRatingNameTxt:String;
	var niceSbRatingNameTxt:String;
	var epicSbRatingNameTxt:String;
	var goodSbRatingNameTxt:String;
	var veryGoodSbRatingNameTxt:String;
	var sickSbRatingNameTxt:String;
	var perfectSbRatingNameTxt:String; // SB Engine
	var youSuckDefaultRatingNameTxt:String;
	var freakDefaultRatingNameTxt:String;
	var reallyBadDefaultRatingNameTxt:String;
	var badDefaultRatingNameTxt:String;
	var niceDefaultRatingNameTxt:String;
	var epicDefaultRatingNameTxt:String;
	var goodDefaultRatingNameTxt:String;
	var veryGoodDefaultRatingNameTxt:String;
	var sickDefaultRatingNameTxt:String;
	var perfectDefaultRatingNameTxt:String; // Psych Engine
	/* var youSuckDeafultNullRatingNameTxt:String;
	var freakDefaultNullRatingNameTxt:String;
	var reallyBadDefaultNullRatingNameTxt:String;
	var badDefaultNullRatingNameTxt:String;
	var niceDefaultNullRatingNameTxt:String;
	var epicDefaultNullRatingNameTxt:String;
	var goodDefaultNullRatingNameTxt:String;
	var veryGoodDefaultNullRatingNameTxt:String;
	var sickDefaultNullRatingNameTxt:String;
	var perfectDefaultNullRatingNameTxt:String; // Null Engine */
	var botplayTxt:String;
	var autoplayTxt:String;
	var sbPracticeModeTxt:String;
	var defaultPracticeModeTxt:String;
	var botplayTimeTxt:String;
	var autoplayTimeTxt:String;
	var scoreTxt:String;
	var missesTxt:String;
	var ratingAndFCNameTxt:String;
	var notePerSecondTxt:String;
	var notePerSecondPracticeTxt:String;
	var comboBreaksTxt:String;
	var averageTxt:String;
	var healthTxt:String;
	var accruracyTxt:String;
	var impressiveTxt:String;
	var extraImpressiveTxt:String;
	var sickTxt:String;
	var goodTxt:String;
	var badTxt:String;
	var freakTxt:String;
	var shitTxt:String;
	var comboBreakTxt:String;
	var songMissesTxt:String;
	var totalNoteHitTxt:String;
	var comboTxt:String;
	var maxComboTxt:String;
	var npsJudgeTxt:String;
	var impressiveFCDefaultTxt:String;
	var sickFCDefaultTxt:String;
	var goodFCDefaultTxt:String;
	var badFCDefaultTxt:String;
	var missesFCDefaultTxt:String;
	var clearFCDefaultTxt:String;
	var impressiveFCSbTxt:String;
	var sickFCSbTxt:String;
	var goodFCSbTxt:String;
	var badFCSbTxt:String;
	var missesFCSbTxt:String;
	var clearFCSbTxt:String;

	// Pause menu stuff
	var resumeTxt:String;
	var restartSongTxt:String;
	var changeDifficultyTxt:String;
	var optionsMenuTxt:String;
	var chartEditorMenuTxt:String;
	var exitToMenuTxt:String;
	var leaveChartingModeTxt:String;
	var skipTimeTxt:String;
	var endSongTxt:String;
	var togglePracticeModeTxt:String;
	var toggleBotplayTxt:String;
	var backToPauseMenuTxt:String;
	var pauseSongNameText:String;
	var pauseDifficultyNameTxt:String;
	var pauseDeathCounterText:String;
	var pausePracticeModeText:String;
	var pauseChartingModeText:String;
}

class LanguageHandler
{
	// Language
	public static var language:String;
	// FPS counter
	public static var fpsCounterTxt:String;
	public static var totalFpsCounterTxt:String;
	public static var memoryCounterTxt:String;
	public static var totalMemoryCounterTxt:String;
	public static var sbEngineVersionCounterTxt:String;
	public static var psychEngineVersionCounterTxt:String;
	public static var stateClassNameCounterTxt:String;
	public static var substateClassNameCounterTxt:String;
	public static var operatingSystemCounterTxt:String;
	public static var glRenderCounterTxt:String;
	public static var glShadingVersionCounterTxt:String;

	// Main menu
	public static var galleryTextAndroid:String;
	public static var secretTextAndroid:String;
	public static var galleryText:String;
	public static var secretText:String;
	public static var sbEngineVersionTxt:String;
	public static var modifiedPsychEngineVersionTxt:String;
	public static var psychEngineVersionTxt:String;
	public static var fnfEngineVersionTxt:String;

	// Story mode
	public static var weekScoreTxt:String;

	// Freeplay menu
	public static var personalBestTxt:String;
	public static var freeplayInfo1Android:String;
	public static var freeplayInfo2Android:String;
	public static var freeplayInfo3Android:String;
	public static var freeplayInfo1:String;
	public static var freeplayInfo2:String;
	public static var freeplayInfo3:String;
	public static var loadingSongText:String;

	// Mods menu
	public static var noModsInstalledTxt:String;
	public static var onTxt:String;
	public static var offTxt:String;
	public static var topTxt:String;
	public static var disableAllModsTxt:String;
	public static var enableAllModsTxt:String;
	public static var restartModDescriptionTxt:String;
	public static var modDescriptionTxt:String;

	// Credits menu
	public static var sbEngineTeamTxt:String;
	public static var stefan2008Description:String;
	public static var nuryDescription:String;
	public static var hutarozDescription:String;
	public static var maysLastPlayDescription:String;
	public static var fearester2008Description:String;
	public static var sunBurntTailsDescription:String;
	public static var aliAlafandyDescription:String;
	public static var luizFelipePlayDescription:String;
	public static var specialCreditsTxt:String;
	public static var stefanRo123Description:String;
	public static var elgatosinnobreDescription:String;
	public static var sussySamDescription:String;
	public static var lizzyStrawberyDescription:String;
	public static var joalor64Description:String;
	public static var justXaleDescription:String;
	public static var squidBowlDescription:String;
	public static var jordanSantiagoDescription:String;
	public static var coreDevDescription:String;
	public static var tomyGamyDescription:String;
	public static var marioMasterDescription:String;
	public static var nfBeihuDescription:String;
	public static var maJigsaw77Description:String;
	public static var goldieDescription:String;
	public static var psychEngineTeamTxt:String;
	public static var shadowMarioDescription:String;
	public static var riverOakenDescription:String;
	public static var formerEngineMemberTxt:String;
	public static var bbpanzuDescription:String;
	public static var engineContributorsTxt:String;
	public static var iflickyDescription:String;
	public static var sqirraRngDescription:String;
	public static var eliteMasterEricDescription:String;
	public static var polybiusProxyDescription:String;
	public static var kadeDevDescription:String;
	public static var keoikiDescription:String;
	public static var nebulaTheZoruaDescription:String;
	public static var smokeyDescription:String;
	public static var funkinCrewTxt:String;
	public static var ninjaMuffin99Description:String;
	public static var phantomAcradeDescription:String;
	public static var evilsk8rDescription:String;
	public static var kawaiSpriteDescription:String;

	// Options menu
	public static var delayCombo:String;
	public static var controls:String;
	public static var gameplay:String;
	public static var graphics:String;
	public static var languages:String;
	public static var noteColor:String;
	public static var visualsUI:String;
	public static var androidControlsSettings:String;
	public static var customizableAndroidControls:String;
	public static var delayComboTip:String;
	public static var controlsTip:String;
	public static var gameplayTip:String;
	public static var graphicsTip:String;
	public static var languagesTip:String;
	public static var noteColorTip:String;
	public static var visualsUITip:String;

	// Delay combo option menu
	public static var beatHitTxt:String;
	public static var ratingOffsetTxt:String;
	public static var numberOffsetTxt:String;
	public static var currentOffsetTxt:String;
	public static var acceptComboOffsetTxt:String;
	public static var noteBeatDelayTxt:String;

	// Controls sub option
	public static var notesTxt:String;
	public static var leftNoteTxt:String;
	public static var downNoteTxt:String;
	public static var upNoteTxt:String;
	public static var rightNoteTxt:String;
	public static var uiTxt:String;
	public static var leftKeyTxt:String;
	public static var downKeyTxt:String;
	public static var upKeyTxt:String;
	public static var rightKeyTxt:String;
	public static var resetKeyTxt:String;
	public static var acceptKeyTxt:String;
	public static var backKeyTxt:String;
	public static var pauseKeyTxt:String;
	public static var volumeTxt:String;
	public static var volumeMuteKeyTxt:String;
	public static var volumeUpKeyTxt:String;
	public static var volumeDownKeyTxt:String;
	public static var debugTxt:String;
	public static var debugKeyOneTxt:String;
	public static var debugKeyTwoTxt:String;
	public static var defaultKeyTxt:String;

	// Gameplay sub option
	public static var controllerMode:String;
	public static var controllerModeDescription:String;
	public static var noteSplashes:String;
	public static var noteSplashesDescription:String;
	public static var opponentArrowGlow:String;
	public static var opponentArrowGlowDescription:String;
	public static var hideHud:String;
	public static var hideHudDescription:String;
	public static var watermark:String;
	public static var watermarkDescription:String;
	public static var judgement:String;
	public static var judgementDescription:String;
	public static var downScroll:String;
	public static var downScrollDescription:String;
	public static var middleScroll:String;
	public static var middleScrollDescription:String;
	public static var ghostTapping:String;
	public static var ghostTappingDescription:String;
	public static var disableReset:String;
	public static var disableResetDescription:String;
	public static var cameraZoom:String;
	public static var cameraZoomDescription:String;
	public static var cameraMovement:String;
	public static var cameraMovementDescription:String;
	public static var scoreZoomText:String;
	public static var scoreZoomTextDescription:String;
	public static var judgementZoomText:String;
	public static var judgementZoomTextDescription:String;
	public static var showKeybinds:String;
	public static var showKeybindsDescription:String;
	public static var iconBounce:String;
	public static var iconBounceDescription:String;
	public static var healthTween:String;
	public static var healthTweenDescription:String;
	public static var ratingImages:String;
	public static var ratingImagesDescription:String;
	public static var resultsScreen:String;
	public static var resultsScreenDescription:String;
	public static var comboStacking:String;
	public static var comboStackingDescription:String;
	public static var playbackSpeedDecimal:String;
	public static var playbackSpeedDecimalDescription:String;
	public static var timePercent:String;
	public static var timePercentDescription:String;
	public static var songIntroCard:String;
	public static var songIntroCardDescription:String;
	public static var missSound:String;
	public static var missSoundDescription:String;
	public static var averageMillisecond:String;
	public static var averageMillisecondDescription:String;
	public static var underlay:String;
	public static var underlayDescription:String;
	public static var randomEngineNames:String;
	public static var randomEngineNamesDescription:String;
	public static var lessCpuController:String;
	public static var lessCpuControllerDescription:String;
	public static var botplayTxtOnTimeBar:String;
	public static var botplayTxtOnTimeBarDescription:String;
	public static var vibration:String;
	public static var vibrationDescription:String;
	public static var timeBarStyle:String;
	public static var timeBarStyleDescription:String;
	public static var watermarkStyle:String;
	public static var watermarkStyleDescription:String;
	public static var judgementStyle:String;
	public static var judgementStyleDescription:String;
	public static var healthAlpha:String;
	public static var healthAlphaDescription:String;
	public static var underlayAlpha:String;
	public static var underlayAlphaDescription:String;
	public static var hitSound:String;
	public static var hitSoundDescription:String;
	public static var rating:String;
	public static var ratingDescription:String;
	public static var impressive:String;
	public static var impressiveDescription:String;
	public static var sick:String;
	public static var sickDescription:String;
	public static var good:String;
	public static var goodDescription:String;
	public static var bad:String;
	public static var badDescription:String;
	public static var safeFrames:String;
	public static var safeFramesDescription:String;
	public static var timeDecimals:String;
	public static var timeDecimalsDescription:String;

	// Graphic sub option
	public static var lowQuality:String;
	public static var lowQualityDescription:String;
	public static var globalAntialiasing:String;
	public static var globalAntialiasingDescription:String;
	public static var shaders:String;
	public static var shadersDescription:String;
	public static var caching:String;
	public static var cachingDescription:String;
	public static var framerate:String;
	public static var framerateDescription:String;

	// Note color sub option
	public static var resetNoteColorTxtAndroid:String;
	public static var resetNoteColorTxt:String;
	public static var hsbTxt:String;

	// VisualsUI sub option
	public static var flashingLigths:String;
	public static var flashingLightsDescription:String;
	public static var showFps:String;
	public static var showFpsDescription:String;
	public static var showTotalFps:String;
	public static var showTotslFpsDescription:String;
	public static var showMemory:String;
	public static var showMemoryDescription:String;
	public static var showMemoryPeak:String;
	public static var showMemoryPeakDescription:String;
	public static var showEngineVersion:String;
	public static var shoeEngineVersionDescription:String;
	public static var toastCore:String;
	public static var toastCoreDescription:String;
	public static var toastCoreTxt:String;
	public static var enabled:String;
	public static var disabled:String;
	public static var velocityBackground:String;
	public static var velocityBackgroundDescription:String;
	public static var objects:String;
	public static var objectsDescription:String;
	public static var pauseMusic:String;
	public static var pauseMusicDescription:String;
	public static var freakyMenu:String;
	public static var freakyMenuDescription:String;
	public static var gameStyle:String;
	public static var gameStyleDescription:String;
	public static var mainMenuStyle:String;
	public static var mainMenuStyleDescription:String;
	public static var colorblind:String;
	public static var colorblindDescription:String;
	public static var themes:String;
	public static var themesDescription:String;

	// Secret debug menu option
	public static var debugMenu:String;
	public static var enteredTo:String;
	public static var thatOption:String;

	// Secret debug sub menu option
	public static var enableDebugInfo:String;
	public static var enableDebugInfoDescription:String;
	public static var enableRainbowFps:String;
	public static var enableRainbowFpsDescription:String;
	public static var skipTransition:String;
	public static var skipTransitionDescription:String;
	public static var autoPause:String;
	public static var autoPauseDescription:String;
	public static var discordRpc:String;
	public static var discordRpcDescription:String;

	// Android controls style
	public static var androidTitle:String;
	public static var hitboxStyle:String;
	public static var hitboxStyleDescription:String;
	public static var hitboxAlpha:String;
	public static var hitboxAlphaDescription:String;
	public static var virtualPadAlpha:String;
	public static var virtualPadAlphaDescription:String;
	public static var space:String;
	public static var spaceDescription:String;
	public static var spaceLocation:String;
	public static var spaceLocationDescription:String;
	public static var dynamicColor:String;
	public static var dynamicColorDescription:String;

	// Android control settings
	public static var padRight:String;
	public static var padLeft:String;
	public static var padCustom:String;
	public static var padDuo:String;
	public static var keyboard:String;
	public static var hitbox:String;
	public static var resetAndroidControlsTxt:String;
	public static var onlyKeyboardTxt:String;
	public static var tipTxt:String;
	public static var upPositionTxt:String;
	public static var downPositionTxt:String;
	public static var leftPositionTxt:String;
	public static var rightPositionTxt:String;

	// PlayState (aka. In-game text)
	public static var youSuckSbRatingNameTxt:String;
	public static var freakSbRatingNameTxt:String;
	public static var reallyBadSbRatingNameTxt:String;
	public static var badSbRatingNameTxt:String;
	public static var niceSbRatingNameTxt:String;
	public static var epicSbRatingNameTxt:String;
	public static var goodSbRatingNameTxt:String;
	public static var veryGoodSbRatingNameTxt:String;
	public static var sickSbRatingNameTxt:String;
	public static var perfectSbRatingNameTxt:String; // SB Engine
	public static var youSuckDefaultRatingNameTxt:String;
	public static var freakDefaultRatingNameTxt:String;
	public static var reallyBadDefaultRatingNameTxt:String;
	public static var badDefaultRatingNameTxt:String;
	public static var niceDefaultRatingNameTxt:String;
	public static var epicDefaultRatingNameTxt:String;
	public static var goodDefaultRatingNameTxt:String;
	public static var veryGoodDefaultRatingNameTxt:String;
	public static var sickDefaultRatingNameTxt:String;
	public static var perfectDefaultRatingNameTxt:String; // Psych Engine
	/* public static var youSuckDeafultNullRatingNameTxt:String;
	public static var freakDefaultNullRatingNameTxt:String;
	public static var reallyBadDefaultNullRatingNameTxt:String;
	public static var badDefaultNullRatingNameTxt:String;
	public static var niceDefaultNullRatingNameTxt:String;
	public static var epicDefaultNullRatingNameTxt:String;
	public static var goodDefaultNullRatingNameTxt:String;
	public static var veryGoodDefaultNullRatingNameTxt:String;
	public static var sickDefaultNullRatingNameTxt:String;
	public static var perfectDefaultNullRatingNameTxt:String; // Null Engine */
	public static var botplayTxt:String;
	public static var autoplayTxt:String;
	public static var sbPracticeModeTxt:String;
	public static var defaultPracticeModeTxt:String;
	public static var botplayTimeTxt:String;
	public static var autoplayTimeTxt:String;
	public static var scoreTxt:String;
	public static var missesTxt:String;
	public static var ratingAndFCNameTxt:String;
	public static var notePerSecondTxt:String;
	public static var notePerSecondPracticeTxt:String;
	public static var comboBreaksTxt:String;
	public static var averageTxt:String;
	public static var healthTxt:String;
	public static var accruracyTxt:String;
	public static var impressiveTxt:String;
	public static var extraImpressiveTxt:String;
	public static var sickTxt:String;
	public static var goodTxt:String;
	public static var badTxt:String;
	public static var freakTxt:String;
	public static var shitTxt:String;
	public static var comboBreakTxt:String;
	public static var songMissesTxt:String;
	public static var totalNoteHitTxt:String;
	public static var comboTxt:String;
	public static var maxComboTxt:String;
	public static var npsJudgeTxt:String;
	public static var impressiveFCDefaultTxt:String;
	public static var sickFCDefaultTxt:String;
	public static var goodFCDefaultTxt:String;
	public static var badFCDefaultTxt:String;
	public static var missesFCDefaultTxt:String;
	public static var clearFCDefaultTxt:String;
	public static var impressiveFCSbTxt:String;
	public static var sickFCSbTxt:String;
	public static var goodFCSbTxt:String;
	public static var badFCSbTxt:String;
	public static var missesFCSbTxt:String;
	public static var clearFCSbTxt:String;

	// Pause menu stuff
	public static var resumeTxt:String;
	public static var restartSongTxt:String;
	public static var changeDifficultyTxt:String;
	public static var optionsMenuTxt:String;
	public static var chartEditorMenuTxt:String;
	public static var exitToMenuTxt:String;
	public static var leaveChartingModeTxt:String;
	public static var skipTimeTxt:String;
	public static var endSongTxt:String;
	public static var togglePracticeModeTxt:String;
	public static var toggleBotplayTxt:String;
	public static var backToPauseMenuTxt:String;
	public static var pauseSongNameText:String;
	public static var pauseDifficultyNameTxt:String;
	public static var pauseDeathCounterText:String;
	public static var pausePracticeModeText:String;
	public static var pauseChartingModeText:String;

	public static var languagePath:String;

	public static function regenerateLang(lang:String)
	{

	    #if MODS_ALLOWED
	    var directories:Array<String> = [SUtil.getPath() + Paths.getPreloadPath('languages/' + ClientPrefs.language + '.json'), Paths.mods('languages/')];

	    for (mod in Paths.getGlobalMods())
		directories.push(Paths.mods(mod + '/languages/'));
	    #end

	    if (!Paths.fileExists('languages/' + lang + '.json', TEXT))
	    {
		ClientPrefs.language = 'english';
		ClientPrefs.saveSettings();
		lang = 'english';
		FlxG.log.advanced("Loading Default Language");
	    } else {
		FlxG.log.advanced("Loading " + lang + " language");
		trace("Loading " + lang + " language");
	     }

	    var languageJson:LanguageFile;
	    languagePath = Paths.getTextFromFile('languages/' + lang + '.json');
	    languageJson = cast Json.parse(languagePath);
	
	// Language
	language = languageJson.language;

	// FPS counter
	fpsCounterTxt = languageJson.fpsCounterTxt;
	totalFpsCounterTxt = languageJson.totalFpsCounterTxt;
	memoryCounterTxt = languageJson.memoryCounterTxt;
	totalMemoryCounterTxt = languageJson.totalMemoryCounterTxt;
	sbEngineVersionCounterTxt = languageJson.sbEngineVersionCounterTxt;
	psychEngineVersionCounterTxt = languageJson.psychEngineVersionCounterTxt;
	stateClassNameCounterTxt = languageJson.stateClassNameCounterTxt;
	substateClassNameCounterTxt = languageJson.substateClassNameCounterTxt;
	operatingSystemCounterTxt = languageJson.operatingSystemCounterTxt;
	glRenderCounterTxt = languageJson.glRenderCounterTxt;
	glShadingVersionCounterTxt = languageJson.glShadingVersionCounterTxt;

	// Main menu
	galleryTextAndroid = languageJson.galleryTextAndroid;
	secretTextAndroid = languageJson.secretTextAndroid;
	galleryText = languageJson.galleryText;
	secretText = languageJson.secretText;
	sbEngineVersionTxt = languageJson.sbEngineVersionTxt;
	modifiedPsychEngineVersionTxt = languageJson.modifiedPsychEngineVersionTxt;
	psychEngineVersionTxt = languageJson.psychEngineVersionTxt;
	fnfEngineVersionTxt = languageJson.fnfEngineVersionTxt;

	// Story mode
	weekScoreTxt = languageJson.weekScoreTxt;

	// Freeplay menu
	personalBestTxt = languageJson.personalBestTxt;
	freeplayInfo1Android = languageJson.freeplayInfo1Android;
	freeplayInfo2Android = languageJson.freeplayInfo2Android;
	freeplayInfo3Android = languageJson.freeplayInfo3Android;
	freeplayInfo1 = languageJson.freeplayInfo1;
	freeplayInfo2 = languageJson.freeplayInfo2;
	freeplayInfo3 = languageJson.freeplayInfo3;
	loadingSongText = languageJson.loadingSongText;

	// Mods menu
	noModsInstalledTxt = languageJson.noModsInstalledTxt;
	onTxt = languageJson.onTxt;
	offTxt = languageJson.offTxt;
	topTxt = languageJson.topTxt;
	disableAllModsTxt = languageJson.disableAllModsTxt;
	enableAllModsTxt = languageJson.enableAllModsTxt;
	restartModDescriptionTxt = languageJson.restartModDescriptionTxt;
	modDescriptionTxt = languageJson.modDescriptionTxt;

	// Credits menu
	sbEngineTeamTxt = languageJson.sbEngineTeamTxt;
	stefan2008Description = languageJson.stefan2008Description;
	nuryDescription = languageJson.nuryDescription;
	hutarozDescription = languageJson.hutarozDescription;
	maysLastPlayDescription = languageJson.maysLastPlayDescription;
	fearester2008Description = languageJson.fearester2008Description;
	sunBurntTailsDescription = languageJson.sunBurntTailsDescription;
	aliAlafandyDescription = languageJson.aliAlafandyDescription;
	luizFelipePlayDescription = languageJson.luizFelipePlayDescription;
	specialCreditsTxt = languageJson.specialCreditsTxt;
	stefanRo123Description = languageJson.stefanRo123Description;
	elgatosinnobreDescription = languageJson.elgatosinnobreDescription;
	sussySamDescription = languageJson.sussySamDescription;
	lizzyStrawberyDescription = languageJson.lizzyStrawberyDescription;
	joalor64Description = languageJson.joalor64Description;
	justXaleDescription = languageJson.justXaleDescription;
	squidBowlDescription = languageJson.squidBowlDescription;
	jordanSantiagoDescription = languageJson.jordanSantiagoDescription;
	coreDevDescription = languageJson.coreDevDescription;
	tomyGamyDescription = languageJson.tomyGamyDescription;
	marioMasterDescription = languageJson.marioMasterDescription;
	nfBeihuDescription = languageJson.nfBeihuDescription;
	maJigsaw77Description = languageJson.maJigsaw77Description;
	goldieDescription = languageJson.goldieDescription;
	psychEngineTeamTxt = languageJson.psychEngineTeamTxt;
	shadowMarioDescription = languageJson.shadowMarioDescription;
	var riverOakenDescription:String;
	var formerEngineMemberTxt:String;
	var bbpanzuDescription:String;
	var engineContributorsTxt:String;
	var iflickyDescription:String;
	var sqirraRngDescription:String;
	var eliteMasterEricDescription:String;
	var polybiusProxyDescription:String;
	var kadeDevDescription:String;
	var keoikiDescription:String;
	var nebulaTheZoruaDescription:String;
	var smokeyDescription:String;
	var funkinCrewTxt:String;
	var ninjaMuffin99Description:String;
	var phantomAcradeDescription:String;
	var evilsk8rDescription:String;
	var kawaiSpriteDescription:String;

	// Options menu
	delayCombo = languageJson.delayCombo;
	controls = languageJson.controls;
	gameplay = languageJson.gameplay;
	graphics = languageJson.graphics;
	languages = languageJson.languages;
	if (languages != 'Languages') languages += ' - Languages';
	noteColor = languageJson.noteColor;
	visualsUI = languageJson.visualsUI;
	androidControlsSettings = languageJson.androidControlsSettings;
	customizableAndroidControls = languageJson.customizableAndroidControls;
	delayComboTip = languageJson.delayComboTip;
	controlsTip = languageJson.controlsTip;
	gameplayTip = languageJson.gameplayTip;
	graphicsTip = languageJson.graphicsTip;
	languagesTip = languageJson.languagesTip;
	noteColorTip = languageJson.noteColorTip;
	visualsUITip = languageJson.visualsUITip;

	// Delay combo option menu
	beatHitTxt = languageJson.beatHitTxt;
	ratingOffsetTxt = languageJson.ratingOffsetTxt;
	numberOffsetTxt = languageJson.numberOffsetTxt;
	currentOffsetTxt = languageJson.currentOffsetTxt;
	acceptComboOffsetTxt = languageJson.acceptComboOffsetTxt;
	noteBeatDelayTxt = languageJson.noteBeatDelayTxt;

	// Controls sub option
	notesTxt = languageJson.notesTxt;
	leftNoteTxt = languageJson.leftNoteTxt;
	downNoteTxt = languageJson.downNoteTxt;
	upNoteTxt = languageJson.upNoteTxt;
	rightNoteTxt = languageJson.rightNoteTxt;
	uiTxt = languageJson.uiTxt;
	leftKeyTxt = languageJson.leftKeyTxt;
	downKeyTxt = languageJson.downKeyTxt;
	upKeyTxt = languageJson.upKeyTxt;
	rightKeyTxt = languageJson.rightKeyTxt;
	resetKeyTxt = languageJson.resetKeyTxt;
	acceptKeyTxt = languageJson.acceptKeyTxt;
	backKeyTxt = languageJson.backKeyTxt;
	pauseKeyTxt = languageJson.pauseKeyTxt;
	volumeTxt = languageJson.volumeTxt;
	volumeMuteKeyTxt = languageJson.volumeMuteKeyTxt;
	volumeUpKeyTxt = languageJson.volumeUpKeyTxt;
	volumeDownKeyTxt = languageJson.volumeDownKeyTxt;
	debugTxt = languageJson.debugTxt;
	debugKeyOneTxt = languageJson.debugKeyOneTxt;
	debugKeyTwoTxt = languageJson.debugKeyTwoTxt;
	defaultKeyTxt = languageJson.defaultKeyTxt;

	// Gameplay sub option
	var controllerMode:String;
	var controllerModeDescription:String;
	var noteSplashes:String;
	var noteSplashesDescription:String;
	var opponentArrowGlow:String;
	var opponentArrowGlowDescription:String;
	var hideHud:String;
	var hideHudDescription:String;
	var watermark:String;
	var watermarkDescription:String;
	var judgement:String;
	var judgementDescription:String;
	var downScroll:String;
	var downScrollDescription:String;
	var middleScroll:String;
	var middleScrollDescription:String;
	var ghostTapping:String;
	var ghostTappingDescription:String;
	var disableReset:String;
	var disableResetDescription:String;
	var cameraZoom:String;
	var cameraZoomDescription:String;
	var cameraMovement:String;
	var cameraMovementDescription:String;
	var scoreZoomText:String;
	var scoreZoomTextDescription:String;
	var judgementZoomText:String;
	var judgementZoomTextDescription:String;
	var showKeybinds:String;
	var showKeybindsDescription:String;
	var iconBounce:String;
	var iconBounceDescription:String;
	var healthTween:String;
	var healthTweenDescription:String;
	var ratingImages:String;
	var ratingImagesDescription:String;
	var resultsScreen:String;
	var resultsScreenDescription:String;
	var comboStacking:String;
	var comboStackingDescription:String;
	var playbackSpeedDecimal:String;
	var playbackSpeedDecimalDescription:String;
	var timePercent:String;
	var timePercentDescription:String;
	var songIntroCard:String;
	var songIntroCardDescription:String;
	var missSound:String;
	var missSoundDescription:String;
	var averageMillisecond:String;
	var averageMillisecondDescription:String;
	var underlay:String;
	var underlayDescription:String;
	var randomEngineNames:String;
	var randomEngineNamesDescription:String;
	var lessCpuController:String;
	var lessCpuControllerDescription:String;
	var botplayTxtOnTimeBar:String;
	var botplayTxtOnTimeBarDescription:String;
	var vibration:String;
	var vibrationDescription:String;
	var timeBarStyle:String;
	var timeBarStyleDescription:String;
	var watermarkStyle:String;
	var watermarkStyleDescription:String;
	var judgementStyle:String;
	var judgementStyleDescription:String;
	var healthAlpha:String;
	var healthAlphaDescription:String;
	var underlayAlpha:String;
	var underlayAlphaDescription:String;
	var hitSound:String;
	var hitSoundDescription:String;
	var rating:String;
	var ratingDescription:String;
	var impressive:String;
	var impressiveDescription:String;
	var sick:String;
	var sickDescription:String;
	var good:String;
	var goodDescription:String;
	var bad:String;
	var badDescription:String;
	var safeFrames:String;
	var safeFramesDescription:String;
	var timeDecimals:String;
	var timeDecimalsDescription:String;

	// Graphic sub option
	var lowQuality:String;
	var lowQualityDescription:String;
	var globalAntialiasing:String;
	var globalAntialiasingDescription:String;
	var shaders:String;
	var shadersDescription:String;
	var caching:String;
	var cachingDescription:String;
	var framerate:String;
	var framerateDescription:String;

	// Note color sub option
	resetNoteColorTxt = languageJson.resetNoteColorTxt;
	resetNoteColorTxtAndroid = languageJson.resetNoteColorTxtAndroid;
	hsbTxt = languageJson.hsbTxt;

	// VisualsUI sub option
	var flashingLigths:String;
	var flashingLightsDescription:String;
	var showFps:String;
	var showFpsDescription:String;
	var showTotalFps:String;
	var showTotslFpsDescription:String;
	var showMemory:String;
	var showMemoryDescription:String;
	var showMemoryPeak:String;
	var showMemoryPeakDescription:String;
	var showEngineVersion:String;
	var shoeEngineVersionDescription:String;
	var toastCore:String;
	var toastCoreDescription:String;
	var toastCoreTxt:String;
	var enabled:String;
	var disabled:String;
	var velocityBackground:String;
	var velocityBackgroundDescription:String;
	var objects:String;
	var objectsDescription:String;
	var pauseMusic:String;
	var pauseMusicDescription:String;
	var freakyMenu:String;
	var freakyMenuDescription:String;
	var gameStyle:String;
	var gameStyleDescription:String;
	var mainMenuStyle:String;
	var mainMenuStyleDescription:String;
	var colorblind:String;
	var colorblindDescription:String;
	var themes:String;
	var themesDescription:String;

	// Secret debug menu option
	var debugMenu:String;
	var enteredTo:String;
	var thatOption:String;

	// Secret debug sub menu option
	var enableDebugInfo:String;
	var enableDebugInfoDescription:String;
	var enableRainbowFps:String;
	var enableRainbowFpsDescription:String;
	var skipTransition:String;
	var skipTransitionDescription:String;
	var autoPause:String;
	var autoPauseDescription:String;
	var discordRpc:String;
	var discordRpcDescription:String;

	// Android controls style
	var androidTitle:String;
	var hitboxStyle:String;
	var hitboxStyleDescription:String;
	var hitboxAlpha:String;
	var hitboxAlphaDescription:String;
	var virtualPadAlpha:String;
	var virtualPadAlphaDescription:String;
	var space:String;
	var spaceDescription:String;
	var spaceLocation:String;
	var spaceLocationDescription:String;
	var dynamicColor:String;
	var dynamicColorDescription:String;

	// Android control settings
	padRight = languageJson.padRight;
	padLeft = languageJson.padLeft;
	padCustom = languageJson.padCustom;
	padDuo = languageJson.padDuo;
	keyboard = languageJson.keyboard;
	hitbox = languageJson.hitbox;
	resetAndroidControlsTxt = languageJson.resetAndroidControlsTxt;
	onlyKeyboardTxt = languageJson.onlyKeyboardTxt;
	tipTxt = languageJson.tipTxt;
	upPositionTxt = languageJson.upPositionTxt;
	downPositionTxt = languageJson.downPositionTxt;
	leftPositionTxt = languageJson.leftPositionTxt;
	rightPositionTxt = languageJson.rightPositionTxt;

	// PlayState (aka. In-game text)
	youSuckSbRatingNameTxt = languageJson.youSuckSbRatingNameTxt;
	freakSbRatingNameTxt = languageJson.freakSbRatingNameTxt;
	reallyBadSbRatingNameTxt = languageJson.reallyBadSbRatingNameTxt;
	badSbRatingNameTxt = languageJson.badSbRatingNameTxt;
	niceSbRatingNameTxt = languageJson.niceSbRatingNameTxt;
	epicSbRatingNameTxt = languageJson.epicSbRatingNameTxt;
	goodSbRatingNameTxt = languageJson.goodSbRatingNameTxt;
	veryGoodSbRatingNameTxt = languageJson.veryGoodSbRatingNameTxt;
	sickSbRatingNameTxt = languageJson.sickSbRatingNameTxt;
	perfectSbRatingNameTxt = languageJson.perfectSbRatingNameTxt; // SB Engine
	youSuckDefaultRatingNameTxt = languageJson.youSuckDefaultRatingNameTxt;
	freakDefaultRatingNameTxt = languageJson.freakDefaultRatingNameTxt;
	reallyBadDefaultRatingNameTxt = languageJson.reallyBadDefaultRatingNameTxt;
	badDefaultRatingNameTxt = languageJson.badDefaultRatingNameTxt;
	niceDefaultRatingNameTxt = languageJson.niceDefaultRatingNameTxt;
	epicDefaultRatingNameTxt = languageJson.epicDefaultRatingNameTxt;
	goodDefaultRatingNameTxt = languageJson.goodDefaultRatingNameTxt;
	veryGoodDefaultRatingNameTxt = languageJson.veryGoodDefaultRatingNameTxt;
	sickDefaultRatingNameTxt = languageJson.sickDefaultRatingNameTxt;
	perfectDefaultRatingNameTxt = languageJson.perfectDefaultRatingNameTxt; // Psych Engine
	/*youSuckDeafultNullRatingNameTxt:String;
	freakDefaultNullRatingNameTxt:String;
	reallyBadDefaultNullRatingNameTxt:String;
	badDefaultNullRatingNameTxt:String;
	niceDefaultNullRatingNameTxt:String;
	epicDefaultNullRatingNameTxt:String;
	goodDefaultNullRatingNameTxt:String;
	veryGoodDefaultNullRatingNameTxt:String;
	sickDefaultNullRatingNameTxt:String;
	perfectDefaultNullRatingNameTxt:String; // Null Engine */
	botplayTxt = languageJson.botplayTxt;
	autoplayTxt = languageJson.autoplayTxt;
	sbPracticeModeTxt = languageJson.sbPracticeModeTxt;
	defaultPracticeModeTxt = languageJson.defaultPracticeModeTxt;
	botplayTimeTxt = languageJson.botplayTimeTxt;
	autoplayTimeTxt = languageJson.autoplayTimeTxt;
	scoreTxt = languageJson.scoreTxt;
	missesTxt = languageJson.missesTxt;
	ratingAndFCNameTxt = languageJson.ratingAndFCNameTxt;
	notePerSecondTxt = languageJson.notePerSecondTxt;
	notePerSecondPracticeTxt = languageJson.notePerSecondPracticeTxt;
	comboBreaksTxt = languageJson.comboBreaksTxt;
	averageTxt = languageJson.averageTxt;
	healthTxt = languageJson.healthTxt;
	accruracyTxt = languageJson.accruracyTxt;
	impressiveTxt = languageJson.impressiveTxt;
	extraImpressiveTxt = languageJson.extraImpressiveTxt;
	sickTxt = languageJson.sickTxt;
	goodTxt = languageJson.goodTxt;
	badTxt = languageJson.badTxt;
	freakTxt = languageJson.freakTxt;
	shitTxt = languageJson.shitTxt;
	comboBreakTxt = languageJson.comboBreakTxt;
	songMissesTxt = languageJson.songMissesTxt;
	totalNoteHitTxt = languageJson.totalNoteHitTxt;
	comboTxt = languageJson.comboTxt;
	maxComboTxt = languageJson.maxComboTxt;
	npsJudgeTxt = languageJson.npsJudgeTxt;
	impressiveFCDefaultTxt = languageJson.impressiveFCDefaultTxt;
	sickFCDefaultTxt = languageJson.sickFCDefaultTxt;
	goodFCDefaultTxt = languageJson.goodFCDefaultTxt;
	badFCDefaultTxt = languageJson.badFCDefaultTxt;
	missesFCDefaultTxt = languageJson.missesFCDefaultTxt;
	clearFCDefaultTxt = languageJson.clearFCDefaultTxt;
	impressiveFCSbTxt = languageJson.impressiveFCSbTxt;
	sickFCSbTxt = languageJson.sickFCSbTxt;
	goodFCSbTxt = languageJson.goodFCSbTxt;
	badFCSbTxt = languageJson.badFCSbTxt;
	missesFCSbTxt = languageJson.missesFCSbTxt;
	clearFCSbTxt = languageJson.clearFCSbTxt;

	// Pause menu stuff
	resumeTxt = languageJson.resumeTxt;
	restartSongTxt = languageJson.restartSongTxt;
	changeDifficultyTxt = languageJson.changeDifficultyTxt;
	optionsMenuTxt = languageJson.optionsMenuTxt;
	chartEditorMenuTxt = languageJson.chartEditorMenuTxt;
	exitToMenuTxt = languageJson.exitToMenuTxt;
	leaveChartingModeTxt = languageJson.leaveChartingModeTxt;
	skipTimeTxt = languageJson.skipTimeTxt;
	endSongTxt = languageJson.endSongTxt;
	togglePracticeModeTxt = languageJson.togglePracticeModeTxt;
	toggleBotplayTxt = languageJson.toggleBotplayTxt;
	backToPauseMenuTxt = languageJson.backToPauseMenuTxt;
	pauseSongNameText = languageJson.pauseSongNameText;
	pauseDifficultyNameTxt = languageJson.pauseDifficultyNameTxt;
	pauseDeathCounterText = languageJson.pauseDeathCounterText;
	pausePracticeModeText = languageJson.pausePracticeModeText;
	pauseChartingModeText = languageJson.pauseChartingModeText;
	}
}
