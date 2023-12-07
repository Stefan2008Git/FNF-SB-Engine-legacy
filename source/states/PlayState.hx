package states;

import stages.tank.TankmenBG;
import stages.pico.PhillyGlowGradient;
import stages.pico.PhillyGlowParticle;
import states.StoryModeState;
import states.FreeplayState;
import states.editors.ChartingState;
import states.editors.CharacterEditorState;
import substates.PauseSubState;
import substates.GameOverSubstate;
import substates.ResultsScreenSubState;
import openfl.display.Shader;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.util.FlxCollision;
import flixel.util.FlxSort;
import haxe.Json;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets as OpenFlAssets;
import states.editors.ChartingState;
import states.editors.CharacterEditorState;
import openfl.events.KeyboardEvent;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxSave;
import flixel.animation.FlxAnimationController;
import animateatlas.AtlasFrameMaker;
import flixel.system.FlxAssets.FlxShader;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

#if VIDEOS_ALLOWED
#if (hxCodec >= "3.0.0")
import hxcodec.flixel.FlxVideo as MP4Handler;
#elseif (hxCodec == "2.6.1")
import hxcodec.VideoHandler as MP4Handler;
#elseif (hxCodec == "2.6.0")
import VideoHandler as MP4Handler;
#else
import vlc.MP4Handler;
#end
#end

#if !flash 
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

import enginelua.HScript;


class PlayState extends MusicBeatState {
	public static var STRUM_X = 48.5;
	public static var STRUM_X_MIDDLESCROLL = -278;
	public static var cameraMovemtableOffset = 20;
	public static var cameraMovemtableOffsetBoyfriend = 20; 

	public static var ratingStuff:Array<Dynamic> = [];

	// event variables
	public var isCameraOnForcedPosition:Bool = false;

	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	public var variables:Map<String, Dynamic> = new Map();

	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();

	#if HSCRIPT_ALLOWED
	public var hscriptArray:Array<HScript> = [];
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var playbackRate(default, set):Float = 1;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;

	public static var currentlyStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var notesCanMoveCamera:Bool = true;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyModeDifficulty:Int = 1;

	public var spawnTime:Float = 2000;

	public var vocals:FlxSound;

	var vocalsFinished:Bool = false;

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;

	public var laneunderlay:FlxSprite;
    public var laneunderlayOpponent:FlxSprite;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	private var strumLine:FlxSprite;

	// Handles the new epic mega camera code that i've done
	public var cameraFollow:FlxPoint;
	public var cameraFollowPosition:FlxObject;

	private static var prevcameraFollow:FlxPoint;
	private static var prevcameraFollowPosition:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;

	private var currentlySong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;
	public var maxCombo:Int = 0;
	public var missCombo:Int = 0;

	private var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;
	var healthTweenFunction:FlxTween;

	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;

	public var ratingsData:Array<Rating> = [];
	public var impressives:Int = 0;
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var freaks:Int = 0;
	public var nps:Int = 0;

	public var isNormalStart:Bool = true;

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;

	private var updateTime:Bool = true;
	private var updatePercent:Bool = true;
	var songPercentValue:Float = 0;

	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	public var shaderUpdates:Array<Float->Void> = [];
	public var camGameShaders:Array<ShaderEffect> = [];
	public var camHUDShaders:Array<ShaderEffect> = [];
	public var camOtherShaders:Array<ShaderEffect> = [];

	// Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;
	public var loopMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;
	public var cameraMoveOffset:Float = 0;
	public var characterToFollow:String = 'bf';

	var notesHitArray:Array<Date> = [];

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;

	var dadbattleBlack:BGSprite;
	var dadbattleLight:BGSprite;
	var dadbattleSmokes:FlxSpriteGroup;

	var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;

	var phillyLightsColors:Array<FlxColor>;
	var phillyWindow:BGSprite;
	var phillyStreet:BGSprite;
	var phillyTrain:BGSprite;
	var blammedLightsBlack:FlxSprite;
	var phillyWindowEvent:BGSprite;
	var trainSound:FlxSound;

	var phillyGlowGradient:PhillyGlowGradient;
	var phillyGlowParticles:FlxTypedGroup<PhillyGlowParticle>;

	var limoKillingState:Int = 0;
	var limo:BGSprite;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;

	var opponentFlxTrail:FlxTrail;
	var boyfriendFlxTrail:FlxTrail;

	var upperBoppers:BGSprite;
	var bottomBoppers:BGSprite;
	var santa:BGSprite;
	var heyTimer:Float;

	var sbEngineIconBounce:Bool = false;

	var bgGirls:BackgroundGirls;
	var bgGhouls:BGSprite;

	var tankWatchtower:BGSprite;
	var tankGround:BGSprite;
	var tankmanRun:FlxTypedGroup<TankmenBG>;
	var foregroundSprites:FlxTypedGroup<BGSprite>;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	public var scoreTxtSine:Float = 0;
	public var nowPlayingTxt:FlxText;
	public var songNameTxt:FlxText;
	public var songNameBackground:FlxSprite;
	public var judgementCounterTxt:FlxText;
	public var engineVersionTxt:FlxText;
	public var songAndDifficultyNameTxt:FlxText;
	public var playbackRateDecimalTxt:FlxText;
	public var timePercentTxt:FlxText;

	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;
	var judgementCounterTxtTween:FlxTween;

	var allNotesMs:Float = 0;
	var averageMs:Float = 0;

	public var msScoreLabel:FlxText;
	public var msScoreLabelTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;

	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if desktop
	// Discord RPC variables
	var storyModeDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	// Achievement freak
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua freak
	public static var instance:PlayState;

	public var luaArray:Array<FunkinLua> = [];

	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;

	public var introSoundsSuffix:String = '';

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;

	// Less laggy controls
	private var keysArray:Array<Dynamic>;
	private var controlArray:Array<String>;

	var precacheList:Map<String, String> = new Map<String, String>();

	// stores the last judgement object
	public static var lastRating:FlxSprite;
	// stores the last combo sprite object
	public static var lastCombo:FlxSprite;
	// stores the last missed combo sprite object
	public static var lastMissedCombo:FlxSprite;
	// stores the last combo score objects in an array
	public static var lastScore:Array<FlxSprite> = [];

	var healthCounter:Float;

	override public function create() {
		Paths.clearStoredMemory();

		callOnLuas('onCreate', []);
		callOnHScript('create', []);

		// for lua
		instance = this;

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));
		PauseSubState.songName = null; // Reset to default
		playbackRate = ClientPrefs.getGameplaySetting('songspeed', 1);

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		controlArray = ['NOTE_LEFT', 'NOTE_DOWN', 'NOTE_UP', 'NOTE_RIGHT'];

		// Ratings
		ratingsData.push(new Rating('impressive')); // default rating

		var rating:Rating = new Rating('sick');
		rating.ratingMod = 1;
		rating.score = 350;
		rating.noteSplash = true;
		ratingsData.push(rating);

		var rating:Rating = new Rating('good');
		rating.ratingMod = 0.7;
		rating.score = 200;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('bad');
		rating.ratingMod = 0.4;
		rating.score = 100;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('freak');
		rating.ratingMod = 0;
		rating.score = 50;
		rating.noteSplash = false;
		ratingsData.push(rating);

		ratingStuff = switch (ClientPrefs.gameStyle) {
		    case 'SB Engine':
			    [
				    [LanguageHandler.youSuckSbRatingNameTxt, 0.2], // From 0% to 19%
                    [LanguageHandler.freakSbRatingNameTxt, 0.4], // From 20% to 39%
                    [LanguageHandler.reallyBadSbRatingNameTxt, 0.5], // From 40% to 49%
                    [LanguageHandler.badSbRatingNameTxt, 0.6], // From 50% to 59%
                    [LanguageHandler.niceSbRatingNameTxt, 0.69], // From 60% to 68%
                    [LanguageHandler.epicSbRatingNameTxt, 0.7], // 69%
                    [LanguageHandler.goodSbRatingNameTxt, 0.8], // From 70% to 79%
                    [LanguageHandler.veryGoodSbRatingNameTxt, 0.9], // From 80% to 89%
                    [LanguageHandler.sickSbRatingNameTxt, 1], // From 90% to 99%
                    [LanguageHandler.perfectSbRatingNameTxt, 1] // The value on this one isn't used actually, since Perfect is always "1"
		        ];

			case 'Psych Engine':
			    [
				    [LanguageHandler.youSuckDefaultRatingNameTxt, 0.2], // From 0% to 19%
                    [LanguageHandler.freakDefaultRatingNameTxt, 0.4], // From 20% to 39%
                    [LanguageHandler.reallyBadDefaultRatingNameTxt, 0.5], // From 40% to 49%
                    [LanguageHandler.badDefaultRatingNameTxt, 0.6], // From 50% to 59%
                    [LanguageHandler.niceDefaultRatingNameTxt, 0.69], // From 60% to 68%
                    [LanguageHandler.epicDefaultRatingNameTxt, 0.7], // 69%
                    [LanguageHandler.goodDefaultRatingNameTxt, 0.8], // From 70% to 79%
                    [LanguageHandler.veryGoodDefaultRatingNameTxt, 0.9], // From 80% to 89%
                    [LanguageHandler.sickDefaultRatingNameTxt, 1], // From 90% to 99%
                    [LanguageHandler.perfectDefaultRatingNameTxt, 1] // The value on this one isn't used actually, since Perfect is always "1"
		        ];

			// in-case none of the above apply (NEEDED)
			default:
				[
					['You Suck!', 0.2], //From 0% to 19%
					['Shit', 0.4], //From 20% to 39%
					['Bad', 0.5], //From 40% to 49%
					['Bruh', 0.6], //From 50% to 59%
					['Meh', 0.69], //From 60% to 68%
					['Nice', 0.7], //69%
					['Good', 0.8], //From 70% to 79%
					['Great', 0.9], //From 80% to 89%
					['Sick!', 1], //From 90% to 99%
					['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
		        ];
		}

		sbEngineIconBounce = (ClientPrefs.iconBounce && ClientPrefs.gameStyle == 'SB Engine');
		notesCanMoveCamera = (ClientPrefs.cameraMovement);

		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray.length) {
			keysPressed.push(false);
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);
		loopMode = ClientPrefs.getGameplaySetting('loop', false);

		healthTweenFunction = FlxTween.tween(this, {}, 0);

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		CustomFadeTransition.nextCamera = camOther;

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		storyModeDifficultyText = CoolUtil.difficulties[storyModeDifficulty];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode) {
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		} else {
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);

		currentlyStage = SONG.stage;
		// trace('stage is: ' + currentlyStage);
		if (SONG.stage == null || SONG.stage.length < 1) {
			switch (songName) {
				case 'spookeez' | 'south' | 'monster':
					currentlyStage = 'spooky';
				case 'pico' | 'blammed' | 'philly' | 'philly-nice':
					currentlyStage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
					currentlyStage = 'limo';
				case 'cocoa' | 'eggnog':
					currentlyStage = 'mall';
				case 'winter-horrorland':
					currentlyStage = 'mallEvil';
				case 'senpai' | 'roses':
					currentlyStage = 'school';
				case 'thorns':
					currentlyStage = 'schoolEvil';
				case 'ugh' | 'guns' | 'stress':
					currentlyStage = 'tank';
				default:
					currentlyStage = 'stage';
			}
		}
		SONG.stage = currentlyStage;

		var stageData:StageFile = StageData.getStageFile(currentlyStage);
		if (stageData == null) { // Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,

				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1,
				camera_move_offset: 0
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];
		
		if (stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if (boyfriendCameraOffset == null)
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if (opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if (girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		if (stageData.camera_move_offset != null)
			cameraMoveOffset = stageData.camera_move_offset;

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		switch (currentlyStage) {
			case 'stage': // Week 1
				var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);
				if (!ClientPrefs.lowQuality) {
					var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);
					var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}
				dadbattleSmokes = new FlxSpriteGroup(); // troll'd

			case 'spooky': // Week 2
				if (!ClientPrefs.lowQuality) {
					halloweenBG = new BGSprite('halloween_bg', -200, -100, ['halloweem bg0', 'halloweem bg lightning strike']);
				} else {
					halloweenBG = new BGSprite('halloween_bg_low', -200, -100);
				}
				add(halloweenBG);

				halloweenWhite = new BGSprite(null, -800, -400, 0, 0);
				halloweenWhite.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
				halloweenWhite.alpha = 0;
				halloweenWhite.blend = ADD;

				// PRECACHE SOUNDS
				precacheList.set('thunder_1', 'sound');
				precacheList.set('thunder_2', 'sound');

			case 'philly': // Week 3
				if (!ClientPrefs.lowQuality) {
					var bg:BGSprite = new BGSprite('philly/sky', -100, 0, 0.1, 0.1);
					add(bg);
				}

				var city:BGSprite = new BGSprite('philly/city', -10, 0, 0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);

				phillyLightsColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
				phillyWindow = new BGSprite('philly/window', city.x, city.y, 0.3, 0.3);
				phillyWindow.setGraphicSize(Std.int(phillyWindow.width * 0.85));
				phillyWindow.updateHitbox();
				add(phillyWindow);
				phillyWindow.alpha = 0;

				if (!ClientPrefs.lowQuality) {
					var streetBehind:BGSprite = new BGSprite('philly/behindTrain', -40, 50);
					add(streetBehind);
				}

				phillyTrain = new BGSprite('philly/train', 2000, 360);
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
				FlxG.sound.list.add(trainSound);

				phillyStreet = new BGSprite('philly/street', -40, 50);
				add(phillyStreet);

			case 'limo': // Week 4
				var skyBG:BGSprite = new BGSprite('limo/limoSunset', -120, -50, 0.1, 0.1);
				add(skyBG);

				if (!ClientPrefs.lowQuality) {
					limoMetalPole = new BGSprite('gore/metalPole', -500, 220, 0.4, 0.4);
					add(limoMetalPole);

					bgLimo = new BGSprite('limo/bgLimo', -150, 480, 0.4, 0.4, ['background limo pink'], true);
					add(bgLimo);

					limoCorpse = new BGSprite('gore/noooooo', -500, limoMetalPole.y - 130, 0.4, 0.4, ['Henchmen on rail'], true);
					add(limoCorpse);

					limoCorpseTwo = new BGSprite('gore/noooooo', -500, limoMetalPole.y, 0.4, 0.4, ['henchmen death'], true);
					add(limoCorpseTwo);

					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5) {
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 170, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
					}

					limoLight = new BGSprite('gore/coldHeartKiller', limoMetalPole.x - 180, limoMetalPole.y - 80, 0.4, 0.4);
					add(limoLight);

					grpLimoParticles = new FlxTypedGroup<BGSprite>();
					add(grpLimoParticles);

					// PRECACHE BLOOD
					var particle:BGSprite = new BGSprite('gore/stupidBlood', -400, -400, 0.4, 0.4, ['blood'], false);
					particle.alpha = 0.01;
					grpLimoParticles.add(particle);
					resetLimoKill();

					// PRECACHE SOUND
					precacheList.set('dancerdeath', 'sound');
				}

				limo = new BGSprite('limo/limoDrive', -120, 550, 1, 1, ['Limo stage'], true);

				fastCar = new BGSprite('limo/fastCarLol', -300, 160);
				fastCar.active = true;
				limoKillingState = 0;

			case 'mall': // Week 5 - Cocoa, Eggnog
				var bg:BGSprite = new BGSprite('christmas/bgWalls', -1000, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				if (!ClientPrefs.lowQuality) {
					upperBoppers = new BGSprite('christmas/upperBop', -240, -90, 0.33, 0.33, ['Upper Crowd Bob']);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					add(upperBoppers);

					var bgEscalator:BGSprite = new BGSprite('christmas/bgEscalator', -1100, -600, 0.3, 0.3);
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);
				}

				var tree:BGSprite = new BGSprite('christmas/christmasTree', 370, -250, 0.40, 0.40);
				add(tree);

				bottomBoppers = new BGSprite('christmas/bottomBop', -300, 140, 0.9, 0.9, ['Bottom Level Boppers Idle']);
				bottomBoppers.animation.addByPrefix('hey', 'Bottom Level Boppers HEY', 24, false);
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				add(bottomBoppers);

				var fgSnow:BGSprite = new BGSprite('christmas/fgSnow', -600, 700);
				add(fgSnow);

				santa = new BGSprite('christmas/santa', -840, 150, 1, 1, ['santa idle in fear']);
				add(santa);
				precacheList.set('Lights_Shut_off', 'sound');

			case 'mallEvil': // Week 5 - Winter Horrorland
				var bg:BGSprite = new BGSprite('christmas/evilBG', -400, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				var evilTree:BGSprite = new BGSprite('christmas/evilTree', 300, -300, 0.2, 0.2);
				add(evilTree);

				var evilSnow:BGSprite = new BGSprite('christmas/evilSnow', -200, 700);
				add(evilSnow);

			case 'school': // Week 6 - Senpai, Roses
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				var bgSky:BGSprite = new BGSprite('weeb/weebSky', 0, 0, 0.1, 0.1);
				add(bgSky);
				bgSky.antialiasing = false;

				var repositionfreak = -200;

				var bgSchool:BGSprite = new BGSprite('weeb/weebSchool', repositionfreak, 0, 0.6, 0.90);
				add(bgSchool);
				bgSchool.antialiasing = false;

				var bgStreet:BGSprite = new BGSprite('weeb/weebStreet', repositionfreak, 0, 0.95, 0.95);
				add(bgStreet);
				bgStreet.antialiasing = false;

				var widfreak = Std.int(bgSky.width * 6);
				if (!ClientPrefs.lowQuality) {
					var fgTrees:BGSprite = new BGSprite('weeb/weebTreesBack', repositionfreak + 170, 130, 0.9, 0.9);
					fgTrees.setGraphicSize(Std.int(widfreak * 0.8));
					fgTrees.updateHitbox();
					add(fgTrees);
					fgTrees.antialiasing = false;
				}

				var bgTrees:FlxSprite = new FlxSprite(repositionfreak - 380, -800);
				bgTrees.frames = Paths.getPackerAtlas('weeb/weebTrees');
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);
				bgTrees.antialiasing = false;

				if (!ClientPrefs.lowQuality) {
					var treeLeaves:BGSprite = new BGSprite('weeb/petals', repositionfreak, -40, 0.85, 0.85, ['PETALS ALL'], true);
					treeLeaves.setGraphicSize(widfreak);
					treeLeaves.updateHitbox();
					add(treeLeaves);
					treeLeaves.antialiasing = false;
				}

				bgSky.setGraphicSize(widfreak);
				bgSchool.setGraphicSize(widfreak);
				bgStreet.setGraphicSize(widfreak);
				bgTrees.setGraphicSize(Std.int(widfreak * 1.4));

				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();

				if (!ClientPrefs.lowQuality) {
					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					add(bgGirls);
				}

			case 'schoolEvil': // Week 6 - Thorns
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				/*if(!ClientPrefs.lowQuality) { //Does this even do something?
					var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
					var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
				}*/
				var positionX = 400;
				var posY = 200;
				if (!ClientPrefs.lowQuality) {
					var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool', positionX, posY, 0.8, 0.9, ['background 2'], true);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);

					bgGhouls = new BGSprite('weeb/bgGhouls', -100, 190, 0.9, 0.9, ['BG freaks glitch instance'], false);
					bgGhouls.setGraphicSize(Std.int(bgGhouls.width * daPixelZoom));
					bgGhouls.updateHitbox();
					bgGhouls.visible = false;
					bgGhouls.antialiasing = false;
					add(bgGhouls);
				} else {
					var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool_low', positionX, posY, 0.8, 0.9);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);
				}

			case 'tank': // Week 7 - Ugh, Guns, Stress
				var sky:BGSprite = new BGSprite('tankSky', -400, -400, 0, 0);
				add(sky);

				if (!ClientPrefs.lowQuality) {
					var clouds:BGSprite = new BGSprite('tankClouds', FlxG.random.int(-700, -100), FlxG.random.int(-20, 20), 0.1, 0.1);
					clouds.active = true;
					clouds.velocity.x = FlxG.random.float(5, 15);
					add(clouds);

					var mountains:BGSprite = new BGSprite('tankMountains', -300, -20, 0.2, 0.2);
					mountains.setGraphicSize(Std.int(1.2 * mountains.width));
					mountains.updateHitbox();
					add(mountains);

					var buildings:BGSprite = new BGSprite('tankBuildings', -200, 0, 0.3, 0.3);
					buildings.setGraphicSize(Std.int(1.1 * buildings.width));
					buildings.updateHitbox();
					add(buildings);
				}

				var ruins:BGSprite = new BGSprite('tankRuins', -200, 0, .35, .35);
				ruins.setGraphicSize(Std.int(1.1 * ruins.width));
				ruins.updateHitbox();
				add(ruins);

				if (!ClientPrefs.lowQuality) {
					var smokeLeft:BGSprite = new BGSprite('smokeLeft', -200, -100, 0.4, 0.4, ['SmokeBlurLeft'], true);
					add(smokeLeft);
					var smokeRight:BGSprite = new BGSprite('smokeRight', 1100, -100, 0.4, 0.4, ['SmokeRight'], true);
					add(smokeRight);

					tankWatchtower = new BGSprite('tankWatchtower', 100, 50, 0.5, 0.5, ['watchtower gradient color']);
					add(tankWatchtower);
				}

				tankGround = new BGSprite('tankRolling', 300, 300, 0.5, 0.5, ['BG tank w lighting'], true);
				add(tankGround);

				tankmanRun = new FlxTypedGroup<TankmenBG>();
				add(tankmanRun);

				var ground:BGSprite = new BGSprite('tankGround', -420, -150);
				ground.setGraphicSize(Std.int(1.15 * ground.width));
				ground.updateHitbox();
				add(ground);
				moveTank();

				foregroundSprites = new FlxTypedGroup<BGSprite>();
				foregroundSprites.add(new BGSprite('tank0', -500, 650, 1.7, 1.5, ['fg']));
				if (!ClientPrefs.lowQuality)
					foregroundSprites.add(new BGSprite('tank1', -300, 750, 2, 0.2, ['fg']));
				foregroundSprites.add(new BGSprite('tank2', 450, 940, 1.5, 1.5, ['foreground']));
				if (!ClientPrefs.lowQuality)
					foregroundSprites.add(new BGSprite('tank4', 1300, 900, 1.5, 1.5, ['fg']));
				foregroundSprites.add(new BGSprite('tank5', 1620, 700, 1.5, 1.5, ['fg']));
				if (!ClientPrefs.lowQuality)
					foregroundSprites.add(new BGSprite('tank3', 1300, 1200, 3.5, 2.5, ['fg']));
		}

		switch (Paths.formatToSongPath(SONG.song)) {
			case 'stress':
				GameOverSubstate.characterName = 'bf-holding-gf-dead';
		}

		if (isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		add(gfGroup); // Needed for blammed lights

		// freakty layering but whatev it works LOL
		if (currentlyStage == 'limo')
			add(limo);

		add(dadGroup);
		add(boyfriendGroup);

		switch (currentlyStage) {
			case 'spooky':
				add(halloweenWhite);
			case 'tank':
				add(foregroundSprites);
		}

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		// "GLOBAL" HSCRIPTS
		#if LUA_ALLOWED
		var foldersToCheck:Array<String> = Mods.directoriesWithFile(SUtil.getPath() + Paths.getPreloadPath(), 'scripts/');
		for (folder in foldersToCheck)
			for (file in FileSystem.readDirectory(folder))
			{
				if(file.toLowerCase().endsWith('.hx'))
					initHScript(folder + file);
			}
		#end

		// "GLOBAL" LUA SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [SUtil.getPath() + Paths.getPreloadPath('scripts/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('scripts/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/scripts/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end

		// STAGE SCRIPTS
		#if LUA_ALLOWED
		startLuasOnFolder('stages/' + currentlyStage + '.lua');
		#end

		// STAGE HSCRIPTS
		#if HSCRIPT_ALLOWED
		startHScriptsNamed('stages/' + currentlyStage + '.hx');
		#end

		var gfVersion:String = SONG.gfVersion;
		if (gfVersion == null || gfVersion.length < 1) {
			switch (currentlyStage) {
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				case 'tank':
					gfVersion = 'gf-tankmen';
				default:
					gfVersion = 'gf';
			}

			switch (Paths.formatToSongPath(SONG.song)) {
				case 'stress':
					gfVersion = 'pico-speaker';
			}
			SONG.gfVersion = gfVersion; // Fix for the Chart Editor
		}

		if (!stageData.hide_girlfriend) {
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			startCharacterLua(gf.curCharacter);

			if (gfVersion == 'pico-speaker') {
				if (!ClientPrefs.lowQuality) {
					var firstTank:TankmenBG = new TankmenBG(20, 500, true);
					firstTank.resetfreak(20, 600, true);
					firstTank.strumTime = 10;
					tankmanRun.add(firstTank);

					for (i in 0...TankmenBG.animationNotes.length) {
						if (FlxG.random.bool(16)) {
							var tankBih = tankmanRun.recycle(TankmenBG);
							tankBih.strumTime = TankmenBG.animationNotes[i][0];
							tankBih.resetfreak(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
							tankmanRun.add(tankBih);
						}
					}
				}
			}
		}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterLua(dad.curCharacter);

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterLua(boyfriend.curCharacter);

		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if (gf != null) {
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if (dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if (gf != null)
				gf.visible = false;
		}

		if (SONG.opponentTrail) {
			opponentFlxTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069); // Credits: (Grafex Engine team)
			insert(members.indexOf(dadGroup) - 1, opponentFlxTrail);
			addBehindDad(opponentFlxTrail);
		}

		if (SONG.boyfriendTrail) {
			boyfriendFlxTrail = new FlxTrail(boyfriend, null, 4, 24, 0.3, 0.069); // Creedits: (Grafex Engine team)
			insert(members.indexOf(boyfriendGroup) - 1, boyfriendFlxTrail);
			addBehindBF(boyfriendFlxTrail);
		}

		switch (currentlyStage) {
			case 'limo':
				resetFastCar();
				addBehindGF(fastCar);

			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069); // nice
				addBehindDad(evilTrail);
		}

		var file:String = Paths.json(songName + '/dialogue'); // Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			dialogueJson = DialogueBoxPsych.parseDialogue(SUtil.getPath() + file);
		}

		var file:String = Paths.txt(songName + '/' + songName + 'Dialogue'); // Checks for vanilla/Senpai dialogue
		if (OpenFlAssets.exists(file)) {
			dialogue = CoolUtil.coolTextFile(SUtil.getPath() + file);
		}
		var doof:DialogueBox = new DialogueBox(false, dialogue);
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;
		doof.skipDialogueThing = skipDialogue;

		Conductor.songPosition = -5000 / Conductor.songPosition;

		laneunderlayOpponent = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlayOpponent.color = FlxColor.BLACK;
		laneunderlayOpponent.scrollFactor.set();
        laneunderlayOpponent.alpha = ClientPrefs.laneunderlayAlpha - 1;
        laneunderlayOpponent.visible = ClientPrefs.laneunderlay;
		laneunderlayOpponent.cameras = [camHUD];

		laneunderlay = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlay.color = FlxColor.BLACK;
		laneunderlay.scrollFactor.set();
        laneunderlay.alpha = ClientPrefs.laneunderlayAlpha - 1;
        laneunderlay.visible = ClientPrefs.laneunderlay;
		laneunderlay.cameras = [camHUD];
        if(!ClientPrefs.middleScroll) 
        {
        	add(laneunderlayOpponent);
        }
		add(laneunderlay);

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if (ClientPrefs.downScroll)
			strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		generateSong();

		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys()) {
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if (FileSystem.exists(luaToLoad)) {
				luaArray.push(new FunkinLua(luaToLoad));
			} else {
				luaToLoad = SUtil.getPath() + Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
				if (FileSystem.exists(luaToLoad)) {
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
		}
		for (event in eventPushedMap.keys()) {
			var luaToLoad:String = Paths.modFolders('custom_events/' + event + '.lua');
			if (FileSystem.exists(luaToLoad)) {
				luaArray.push(new FunkinLua(luaToLoad));
			} else {
				luaToLoad = SUtil.getPath() + Paths.getPreloadPath('custom_events/' + event + '.lua');
				if (FileSystem.exists(luaToLoad)) {
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
		}
		#end

		cameraFollow = new FlxPoint();
		cameraFollowPosition = new FlxObject(0, 0, 1, 1);

		snapcameraFollowToPos(camPos.x, camPos.y);
		if (prevcameraFollow != null) {
			cameraFollow = prevcameraFollow;
			prevcameraFollow = null;
		}
		if (prevcameraFollowPosition != null) {
			cameraFollowPosition = prevcameraFollowPosition;
			prevcameraFollowPosition = null;
		}
		add(cameraFollowPosition);

		FlxG.camera.follow(cameraFollowPosition, LOCKON, 1);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(cameraFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection();

		var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		if (ClientPrefs.gameStyle == 'SB Engine') {
			timeTxt.setFormat(Paths.font("bahnschrift.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}

		if (ClientPrefs.gameStyle == 'Psych Engine') {
			timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}

		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if (ClientPrefs.downScroll)
			timeTxt.y = FlxG.height - 44;

		if (ClientPrefs.timeBarType == 'Song Name') {
			timeTxt.text = SONG.song;
		}
		updateTime = showTime;

		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine':
			    timeBarBG = new AttachedSprite('timeBar');
			    timeBarBG.x = timeTxt.x;
			    timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
			    timeBarBG.scrollFactor.set();
			
			default:
			    timeBarBG = new AttachedSprite('sbEngineBar');
			    timeBarBG.x = timeTxt.x;
			    timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
			    timeBarBG.scrollFactor.set();
			    timeBarBG.screenCenter(X);
				timeBarBG.sprTracker = timeBar;
		}

		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime && ClientPrefs.showTimeBar;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();

		switch (ClientPrefs.gameStyle) {
			case 'SB Engine':
				reloadTimeBarColors();
				insert(members.indexOf(timeBarBG), timeBar);
			
			case 'Psych Engine':
				timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		}

		timeBar.numDivisions = 800;
		timeBar.alpha = 0;
		timeBar.visible = showTime && ClientPrefs.showTimeBar;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;

		if (ClientPrefs.timeBarType == 'Song Name') {
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		final m = (ClientPrefs.gameStyle == 'Psych Engine'); 
		final antiRedundancy:String = m ? 'healthBar' : (ClientPrefs.gameStyle == 'SB Engine') ? 'sbEngineBar' : 'healthBar';
		healthBarBG = new AttachedSprite(antiRedundancy);
		if (ClientPrefs.watermarkStyle == 'SB Engine') {
			healthBarBG.y = FlxG.height * 0.84;
		} else {
			healthBarBG.y = FlxG.height * 0.85;
		}
		
		healthBarBG.screenCenter(X);

		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		if (ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;
		healthBarBG.alpha = 0;
		healthBarBG.cameras = [camHUD];
		add(healthBarBG);

		if (ClientPrefs.gameStyle == 'SB Engine') {
			healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
				'health', 0, 2);
			insert(members.indexOf(healthBarBG), healthBar);
		}

		if (ClientPrefs.gameStyle == 'Psych Engine') {
			healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
				'health', 0, 2);
		}

		healthBar.scrollFactor.set();
		healthBar.visible = !ClientPrefs.hideHud;
		healthBarBG.sprTracker = healthBar;
		healthBarBG.alpha = 0;
		healthBar.cameras = [camHUD];
		add(healthBar);

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = 0;
		iconP1.cameras = [camHUD];
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = 0;
		iconP2.cameras = [camHUD];
		add(iconP2);
		reloadHealthBarColors();

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		switch (ClientPrefs.gameStyle) {
			
			case 'Psych Engine':
				scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			
			default:
			    scoreTxt.setFormat(Paths.font("bahnschrift.ttf"), 17, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}

		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		scoreTxt.scrollFactor.set();
		scoreTxt.alpha = 0;
		scoreTxt.cameras = [camHUD];
		add(scoreTxt);

		nowPlayingTxt = new FlxText(20, 15, 0, "", 32);
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine':
				nowPlayingTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			
			default:
				nowPlayingTxt.setFormat(Paths.font("bahnschrift.ttf"), 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		nowPlayingTxt.visible = !ClientPrefs.hideHud && ClientPrefs.songIntro;
		nowPlayingTxt.scrollFactor.set();
		nowPlayingTxt.updateHitbox();
		nowPlayingTxt.text = 'Now Playing: ';
		nowPlayingTxt.alpha = 0;
		nowPlayingTxt.cameras = [camHUD];
		add(nowPlayingTxt);

		songNameTxt = new FlxText(20, 50, 0, "", 20);
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine':
				songNameTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			
			default:
				songNameTxt.setFormat(Paths.font("bahnschrift.ttf"), 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		songNameTxt.visible = !ClientPrefs.hideHud && ClientPrefs.songIntro;
		songNameTxt.scrollFactor.set();
		songNameTxt.updateHitbox();
		songNameTxt.text = currentlySong;
		songNameTxt.alpha = 0;
		songNameTxt.cameras = [camHUD];
		add(songNameTxt);

		songNameBackground = new FlxSprite(songNameTxt.x, 20).makeGraphic((Std.int(songNameTxt.width + 100)), Std.int(songNameTxt.height + 40), FlxColor.BLACK);
		songNameBackground.visible = !ClientPrefs.hideHud && ClientPrefs.songIntro;
		songNameBackground.alpha = 0;
		songNameBackground.cameras = [camHUD];
		add(songNameBackground);

		judgementCounterTxt = new FlxText(25, 25, FlxG.width, "", 20);
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine':
				judgementCounterTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			
			default:
				judgementCounterTxt.setFormat(Paths.font("bahnschrift.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}

		if (ClientPrefs.judgementCounterStyle == 'Original' && ClientPrefs.gameStyle == 'SB Engine') {
			judgementCounterTxt.text = LanguageHandler.impressiveTxt + ${impressives} + LanguageHandler.sickTxt + ${sicks} + LanguageHandler.goodTxt + ${goods} + LanguageHandler.badTxt + ${bads} + LanguageHandler.freakTxt + ${freaks};
		} else if (ClientPrefs.judgementCounterStyle == 'Original' && ClientPrefs.gameStyle == 'Psych Engine') {
			judgementCounterTxt.text = LanguageHandler.impressiveTxt + ${impressives} + LanguageHandler.sickTxt + ${sicks} + LanguageHandler.goodTxt + ${goods} + LanguageHandler.badTxt + ${bads} + LanguageHandler.shitTxt + ${freaks};
		} else if (ClientPrefs.judgementCounterStyle == 'With Misses' && ClientPrefs.gameStyle == 'SB Engine') {
			judgementCounterTxt.text = LanguageHandler.impressiveTxt + ${impressives} + LanguageHandler.sickTxt + ${sicks} + LanguageHandler.goodTxt + ${goods} + LanguageHandler.badTxt + ${bads} + LanguageHandler.freakTxt + ${freaks} + LanguageHandler.comboBreakTxt + ${songMisses};
		} else if (ClientPrefs.judgementCounterStyle == 'With Misses' && ClientPrefs.gameStyle == 'Psych Engine') {
			judgementCounterTxt.text = LanguageHandler.impressiveTxt + ${impressives} + LanguageHandler.sickTxt + ${sicks} + LanguageHandler.goodTxt + ${goods} + LanguageHandler.badTxt + ${bads} + LanguageHandler.shitTxt + ${freaks} + LanguageHandler.songMissesTxt + ${songMisses};
		} else if (ClientPrefs.judgementCounterStyle == 'Better Judge' && ClientPrefs.gameStyle == 'SB Engine') {
			judgementCounterTxt.text = LanguageHandler.totalNoteHitTxt + ${totalNotes} + LanguageHandler.comboTxt + ${combo} + LanguageHandler.maxComboTxt + ${maxCombo} + LanguageHandler.npsJudgeTxt + ${nps} + LanguageHandler.extraImpressiveTxt + ${impressives} + LanguageHandler.sickTxt + ${sicks} + LanguageHandler.goodTxt + ${goods} + LanguageHandler.badTxt + ${bads} + LanguageHandler.freakTxt + ${freaks} + LanguageHandler.comboBreakTxt + ${songMisses};
		} else if (ClientPrefs.judgementCounterStyle == 'Better Judge' && ClientPrefs.gameStyle == 'Psych Engine') {
			judgementCounterTxt.text = LanguageHandler.totalNoteHitTxt + ${totalNotes} + LanguageHandler.comboTxt + ${combo} + LanguageHandler.maxComboTxt + ${maxCombo} +LanguageHandler.npsJudgeTxt + ${nps} + LanguageHandler.extraImpressiveTxt + ${impressives} + LanguageHandler.sickTxt + ${sicks} + LanguageHandler.goodTxt + ${goods} + LanguageHandler.badTxt + ${bads} + LanguageHandler.shitTxt + ${freaks} + LanguageHandler.songMissesTxt + ${songMisses};
		}
		judgementCounterTxt.borderSize = 2;
		judgementCounterTxt.borderQuality = 2;
		judgementCounterTxt.scrollFactor.set();
		judgementCounterTxt.size = 22;
		judgementCounterTxt.screenCenter(Y);
		judgementCounterTxt.visible = ClientPrefs.judgementCounter && !ClientPrefs.hideHud;
		judgementCounterTxt.alpha = 0;
		judgementCounterTxt.cameras = [camHUD];
		add(judgementCounterTxt);

		// Used from Bambi Purgatory repository :D (Please don't kill me WhatsDown :(. If you want me to remove the code, i will remove it and never use it)
		var randomName:Int = FlxG.random.int(0, 12);
		var engineName:String = 'Null ';
		switch (randomName)
	    {
			case 0:
				engineName = 'SB ';
			case 1:
				engineName = 'StefanBeta Engine ';
			case 2:
				engineName = 'Stefan2008 Engine ';
			case 3:
				engineName = 'Nury Engine ';
			case 4:
				engineName = 'MaysLastPlay Engine ';
			case 5:
				engineName = 'Fearester Engine ';
			case 6:
				engineName = 'Play Engine ';
			case 7:
				engineName = 'SunBurntTails Engine '; 
			case 8:
				engineName = 'Ali Alafandy Engine ';
			case 9:
				engineName = 'Luiz Engine ';
			case 10:
				engineName = 'MemeHoovy Engine '; // Added because he is helpful and best dude who want to help :)
			case 11:
				engineName = 'Boris2014 Engine '; // My little brother engine :).
		}
		if (ClientPrefs.watermarkStyle == 'SB Engine') {
		    engineVersionTxt = new FlxText(12, FlxG.height - 44, 0, "", 8);
			if (ClientPrefs.gameStyle == 'SB Engine') {
		        engineVersionTxt.setFormat(Paths.font("bahnschrift.ttf"), 15, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			}
			if (ClientPrefs.gameStyle == 'Psych Engine') {
		        engineVersionTxt.setFormat(Paths.font("vcr.ttf"), 15, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			}
		    engineVersionTxt.scrollFactor.set();
		    if (ClientPrefs.gameStyle == 'SB Engine' || ClientPrefs.gameStyle == 'Psych Engine') {
		        engineVersionTxt.borderSize = 1.25;
			}
		    engineVersionTxt.visible = ClientPrefs.watermark && !ClientPrefs.hideHud;
		    if (ClientPrefs.randomEngineNames) {
				engineVersionTxt.text = engineName + MainMenuState.sbEngineVersion + " (PE " + MainMenuState.psychEngineVersion + ")";
			} else {
				engineVersionTxt.text = "SB " + MainMenuState.sbEngineVersion + " (PE " + MainMenuState.psychEngineVersion + ")";
			}

		    songAndDifficultyNameTxt = new FlxText(12, FlxG.height - 24, 0, "", 8);
			if (ClientPrefs.gameStyle == 'SB Engine') {
		        songAndDifficultyNameTxt.setFormat(Paths.font("bahnschrift.ttf"), 15, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			}
			if (ClientPrefs.gameStyle == 'Psych Engine') {
		        songAndDifficultyNameTxt.setFormat(Paths.font("vcr.ttf"), 15, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			}
		    songAndDifficultyNameTxt.scrollFactor.set();
			if (ClientPrefs.gameStyle == 'SB Engine' || ClientPrefs.gameStyle == 'Psych Engine') {
		        songAndDifficultyNameTxt.borderSize = 1.25;
			}
		    songAndDifficultyNameTxt.visible = ClientPrefs.watermark && !ClientPrefs.hideHud;
			songAndDifficultyNameTxt.text =  currentlySong + " (" + CoolUtil.difficulties[storyModeDifficulty] + ") ";
		}

		if (ClientPrefs.watermarkStyle == 'Kade Engine') {
			engineVersionTxt = new FlxText(12, FlxG.height - 44, 0, "", 8);
			if (ClientPrefs.gameStyle == 'SB Engine') {
		        engineVersionTxt.setFormat(Paths.font("bahnschrift.ttf"), 15, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			}
			if (ClientPrefs.gameStyle == 'Psych Engine') {
		        engineVersionTxt.setFormat(Paths.font("vcr.ttf"), 15, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			}
		    engineVersionTxt.scrollFactor.set();
		    if (ClientPrefs.gameStyle == 'SB Engine' || ClientPrefs.gameStyle == 'Psych Engine') {
		        engineVersionTxt.borderSize = 1.25;
			}
		    engineVersionTxt.visible = false;
			if (ClientPrefs.randomEngineNames) {
				engineVersionTxt.text = engineName + MainMenuState.sbEngineVersion + " (PE " + MainMenuState.psychEngineVersion + ")";
			} else {
				engineVersionTxt.text = "SB " + MainMenuState.sbEngineVersion + " (PE " + MainMenuState.psychEngineVersion + ")";
			}
			
		    songAndDifficultyNameTxt = new FlxText(12, FlxG.height - 24, 0, "", 8);
		    if (ClientPrefs.gameStyle == 'SB Engine') {
		        songAndDifficultyNameTxt.setFormat(Paths.font("bahnschrift.ttf"), 15, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			} else {
		        songAndDifficultyNameTxt.setFormat(Paths.font("vcr.ttf"), 15, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			}
		    songAndDifficultyNameTxt.scrollFactor.set();
		    if (ClientPrefs.gameStyle == 'SB Engine' || ClientPrefs.gameStyle == 'Psych Engine') {
		        songAndDifficultyNameTxt.borderSize = 1.25;
			}

		    songAndDifficultyNameTxt.visible = ClientPrefs.watermark && !ClientPrefs.hideHud;
			if (ClientPrefs.randomEngineNames) {
				songAndDifficultyNameTxt.text =  currentlySong + " (" + CoolUtil.difficulties[storyModeDifficulty] + ") " + "| " + engineName + MainMenuState.sbEngineVersion + " (PE " + MainMenuState.psychEngineVersion + ") ";
			} else {
				songAndDifficultyNameTxt.text =  currentlySong + " (" + CoolUtil.difficulties[storyModeDifficulty] + ") " + "| SB " + MainMenuState.sbEngineVersion + " (PE " + MainMenuState.psychEngineVersion + ") ";
			}
		}

		if (ClientPrefs.downScroll && ClientPrefs.watermarkStyle == 'SB Engine') {
			engineVersionTxt.y = 140;
			songAndDifficultyNameTxt.y = 160;
		}

		if (ClientPrefs.downScroll && ClientPrefs.watermarkStyle == 'Kade Engine' || ClientPrefs.watermarkStyle == 'Dave and Bambi') {
			engineVersionTxt.y = 0;
			songAndDifficultyNameTxt.y = 140;
		}

		engineVersionTxt.alpha = 0;
		songAndDifficultyNameTxt.alpha = 0;
		engineVersionTxt.cameras = [camHUD];
		songAndDifficultyNameTxt.cameras = [camHUD];
		add(engineVersionTxt);
		add(songAndDifficultyNameTxt);

		if (ClientPrefs.gameStyle == 'SB Engine') {
			botplayTxt = new FlxText(400, timeBarBG.y + 500, FlxG.width - 800, LanguageHandler.autoplayTxt, 32);
			botplayTxt.setFormat(Paths.font("bahnschrift.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
	
		if (ClientPrefs.gameStyle == 'Psych Engine') {
			botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, LanguageHandler.botplayTxt, 32);
			botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}

		botplayTxt.scrollFactor.set();
		botplayTxt.visible = cpuControlled;

		if (ClientPrefs.downScroll && ClientPrefs.gameStyle == 'SB Engine') {
			botplayTxt.y = timeBarBG.y - 500;
		}

		if (ClientPrefs.downScroll && ClientPrefs.gameStyle == 'Psych Engine') {
			botplayTxt.y = timeBarBG.y - 78;
	    }

		botplayTxt.alpha = 0;
		botplayTxt.cameras = [camHUD];
	    add(botplayTxt);

		msScoreLabel = new FlxText(0, 0, 400, "", 32);
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine':
				msScoreLabel.setFormat(Paths.font('vcr.ttf'), 32, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			
			default:
				msScoreLabel.setFormat(Paths.font('bahnschrift.ttf'), 32, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		msScoreLabel.visible = !cpuControlled;
		msScoreLabel.alpha = 0;
		msScoreLabel.scrollFactor.set();
		msScoreLabel.borderSize = 2;
		msScoreLabel.cameras = [camHUD];
		add(msScoreLabel);

		playbackRateDecimalTxt = new FlxText(12, FlxG.height - 550, FlxG.width - 24, "", 12);
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine':
				playbackRateDecimalTxt.setFormat(Paths.font('vcr.ttf'), 20, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

			default:
				playbackRateDecimalTxt.setFormat(Paths.font('bahnschrift.ttf'), 20, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		playbackRateDecimalTxt.visible = ClientPrefs.playbackRateDecimal;
		playbackRateDecimalTxt.text = 'Playback: ' + Std.string(playbackRate) + 'x';
		playbackRateDecimalTxt.alpha = 0;
		playbackRateDecimalTxt.cameras = [camHUD];
		add(playbackRateDecimalTxt);

		timePercentTxt = new FlxText(12, FlxG.height - 30, FlxG.width - 24, "", 12);
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine':
				timePercentTxt.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			default:
				timePercentTxt.setFormat(Paths.font('bahnschrift.ttf'), 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		timePercentTxt.scrollFactor.set();
		timePercentTxt.alpha = 0;
		if (ClientPrefs.downScroll) {
			timePercentTxt.y = 140;
		}
		timePercentTxt.visible = ClientPrefs.timePercent;
		updatePercent = ClientPrefs.timePercent;
		timePercentTxt.screenCenter(X);
		timePercentTxt.cameras = [camHUD];
		add(timePercentTxt);

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		#if android
		addAndroidControls();
		androidControls.visible = false;
		#end

		startingSong = true;

		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			startLuasOnFolder('custom_notetypes/' + notetype + '.lua');
		}
		for (event in eventPushedMap.keys())
		{
			startLuasOnFolder('custom_events/' + event + '.lua');
		}
		#end

		#if HSCRIPT_ALLOWED
		for (notetype in noteTypeMap.keys())
			startHScriptsNamed('custom_notetypes/' + notetype + '.hx');

		for (event in eventPushedMap.keys())
			startHScriptsNamed('custom_events/' + event + '.hx');
		#end

		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		if (eventNotes.length > 1) {
			for (event in eventNotes)
				event.strumTime -= eventNoteEarlyTrigger(event);
			eventNotes.sort(sortByTime);
		}

		// SONG SPECIFIC HSCRIPTS
		#if LUA_ALLOWED
		var foldersToCheck:Array<String> = Mods.directoriesWithFile(SUtil.getPath() + Paths.getPreloadPath(), 'data/' + Paths.formatToSongPath(SONG.song) + '/');
		
		for (folder in foldersToCheck)
			for (file in FileSystem.readDirectory(folder))
			{
				if(file.toLowerCase().endsWith('.hx'))
					initHScript(folder + file);
			}
		#end

		// SONG SPECIFIC LUA SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [SUtil.getPath() + Paths.getPreloadPath('data/' + Paths.formatToSongPath(SONG.song) + '/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('data/' + Paths.formatToSongPath(SONG.song) + '/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(SONG.song) + '/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/data/' + Paths.formatToSongPath(SONG.song) + '/' ));// using push instead of insert because these should run after everything else
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end

		var daSong:String = Paths.formatToSongPath(currentlySong);
		if (isStoryMode && !seenCutscene) {
			switch (daSong) {
				case "monster":
					var whiteScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
					add(whiteScreen);
					whiteScreen.scrollFactor.set();
					whiteScreen.blend = ADD;
					camHUD.visible = false;
					snapcameraFollowToPos(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
					inCutscene = true;

					FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
						startDelay: 0.1,
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween) {
							camHUD.visible = true;
							remove(whiteScreen);
							startCountdown();
						}
					});
					FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
					if (gf != null)
						gf.playAnim('scared', true);
					boyfriend.playAnim('scared', true);

				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;
					inCutscene = true;

					FlxTween.tween(blackScreen, {alpha: 0}, 0.7, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween) {
							remove(blackScreen);
						}
					});
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					snapcameraFollowToPos(400, -2050);
					FlxG.camera.focusOn(cameraFollow);
					FlxG.camera.zoom = 1.5;

					new FlxTimer().start(0.8, function(tmr:FlxTimer) {
						camHUD.visible = true;
						remove(blackScreen);
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween) {
								startCountdown();
							}
						});
					});
				case 'senpai' | 'roses' | 'thorns':
					if (daSong == 'roses')
						FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);

				case 'ugh':
					startVideo('ughCutscene');
				case 'guns':
					startVideo('gunsCutscene');
				case 'stress':
					startVideo('stressCutscene');

				default:
					startCountdown();
			}
			seenCutscene = true;
		} else {
			startCountdown();
		}
		recalculateRating();

		if (ClientPrefs.hitsoundVolume > 0)
			precacheList.set('hitsound', 'sound');
		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');

		if (PauseSubState.songName != null) {
			precacheList.set(PauseSubState.songName, 'music');
		} else if (ClientPrefs.pauseMusic != 'None') {
			precacheList.set(Paths.formatToSongPath(ClientPrefs.pauseMusic), 'music');
		}

		precacheList.set('alphabet', 'image');

		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyModeDifficultyText + ")", iconP2.getCharacter());
		#end

		if (!ClientPrefs.controllerMode) {
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		callOnLuas('onCreatePost', []);
		callOnHScript('createPost', []);
		
		super.create();

		cacheCountdown();
		cachePopUpScore();
		for (key => type in precacheList) {
			// trace('Key $key is type $type');
			switch (type) {
				case 'image':
					Paths.image(key);
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
				case 'video':
					Paths.video(key);
			}
		}

		Paths.clearUnusedMemory();

		CustomFadeTransition.nextCamera = camOther;
		if (eventNotes.length < 1)
			checkEventNote();
	}

	static public function quickSpin(sprite)
	{
		FlxTween.angle(sprite, 0, 360, 0.5, { type: FlxTweenType.ONESHOT, ease: FlxEase.quadInOut, startDelay: 0, loopDelay: 0});
	}

	#if (!flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	public function createRuntimeShader(name:String):FlxRuntimeShader
	{
		if(!ClientPrefs.shaders) return new FlxRuntimeShader();

		#if (!flash && MODS_ALLOWED && sys)
		if(!runtimeShaders.exists(name) && !initLuaShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new FlxRuntimeShader();
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new FlxRuntimeShader(arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	#if !android
	public function initLuaShader(name:String, ?glslVersion:Int = 120)
	#else
	public function initLuaShader(name:String, ?glslVersion:Int = 100)
	#end
	{
		if(!ClientPrefs.shaders) return false;

		if(runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		var foldersToCheck:Array<String> = [SUtil.getPath() + Paths.getPreloadPath('shaders/')];

		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)

			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/shaders/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/shaders/'));
		
		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				var frag:String = folder + name + '.frag';
				var vert:String = folder + name + '.vert';
				var found:Bool = false;
				if(FileSystem.exists(frag))
				{
					frag = File.getContent(frag);
					found = true;
				}
				else frag = null;

				if (FileSystem.exists(vert))
				{
					vert = File.getContent(vert);
					found = true;
				}
				else vert = null;

				if(found)
				{
					runtimeShaders.set(name, [frag, vert]);
					//trace('Finally Found shader $name!');
					return true;
				}
			}
		}
		FlxG.log.warn('Missing shader $name .frag AND .vert files!');
		return false;
	}
	#end

	function set_songSpeed(value:Float):Float {
		if (generatedMusic) {
			var ratio:Float = value / songSpeed; // funny word huh
			for (note in notes)
				note.resizeByRatio(ratio);
			for (note in unspawnNotes)
				note.resizeByRatio(ratio);
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	inline function set_playbackRate(value:Float):Float {
		if (generatedMusic) {
			if (vocals != null)
				vocals.pitch = value;
			FlxG.sound.music.pitch = value;
		}
		playbackRate = value;
		FlxAnimationController.globalSpeed = value;
		trace('Anim speed: ' + FlxAnimationController.globalSpeed);
		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000 * value;
		setOnLuas('playbackRate', playbackRate);
		return value;
	}

	public function addTextToDebug(text:String, color:FlxColor) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});

		if (luaDebugGroup.members.length > 34) {
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}
		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup, color));
		#end
	}

	public function reloadHealthBarColors() {
		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));

		healthBar.updateBar();
	}

	public function reloadTimeBarColors() {
		if (ClientPrefs.colorBars) {
		    timeBar.createFilledBar(0xFF1A1A1A, FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]));
		} else {
			timeBar.createFilledBar(0xFF1A1A1A, 0xFF800080);
		}

		timeBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch (type) {
			case 0:
				if (!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if (!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if (gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
				}
		}
	}

	function startCharacterLua(name:String) {
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = SUtil.getPath() + Paths.getPreloadPath(luaFile);
			if (FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}
		#else
		luaFile = Paths.getPreloadPath(luaFile);
		if (Assets.exists(luaFile)) {
			doPush = true;
		}
		#end

		if (doPush) {
			for (script in luaArray) {
				if (script.scriptName == luaFile)
					return;
			}
			luaArray.push(new FunkinLua(luaFile));
		}
		#end
	}

	public function addLuaShaderToCamera(cam:String, effect:ShaderEffect) { // STOLE FROM ANDROMEDA

		switch (cam.toLowerCase()) {
			case 'camhud' | 'hud':
				camHUDShaders.push(effect);
				var newCamEffects:Array<BitmapFilter> = []; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
				for (i in camHUDShaders) {
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				camHUD.setFilters(newCamEffects);
			case 'camother' | 'other':
				camOtherShaders.push(effect);
				var newCamEffects:Array<BitmapFilter> = []; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
				for (i in camOtherShaders) {
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				camOther.setFilters(newCamEffects);
			case 'camgame' | 'game':
				camGameShaders.push(effect);
				var newCamEffects:Array<BitmapFilter> = []; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
				for (i in camGameShaders) {
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				camGame.setFilters(newCamEffects);
			default:
				if (modchartSprites.exists(cam)) {
					Reflect.setProperty(modchartSprites.get(cam), "shader", effect.shader);
				} else if (modchartTexts.exists(cam)) {
					Reflect.setProperty(modchartTexts.get(cam), "shader", effect.shader);
				} else {
					var OBJ = Reflect.getProperty(PlayState.instance, cam);
					Reflect.setProperty(OBJ, "shader", effect.shader);
				}
		}
	}

	public function removeShaderFromCamera(cam:String, effect:ShaderEffect) {
		switch (cam.toLowerCase()) {
			case 'camhud' | 'hud':
				camHUDShaders.remove(effect);
				var newCamEffects:Array<BitmapFilter> = [];
				for (i in camHUDShaders) {
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				camHUD.setFilters(newCamEffects);
			case 'camother' | 'other':
				camOtherShaders.remove(effect);
				var newCamEffects:Array<BitmapFilter> = [];
				for (i in camOtherShaders) {
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				camOther.setFilters(newCamEffects);
			default:
				camGameShaders.remove(effect);
				var newCamEffects:Array<BitmapFilter> = [];
				for (i in camGameShaders) {
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				camGame.setFilters(newCamEffects);
		}
	}

	public function clearShaderFromCamera(cam:String) {
		switch (cam.toLowerCase()) {
			case 'camhud' | 'hud':
				camHUDShaders = [];
				var newCamEffects:Array<BitmapFilter> = [];
				camHUD.setFilters(newCamEffects);
			case 'camother' | 'other':
				camOtherShaders = [];
				var newCamEffects:Array<BitmapFilter> = [];
				camOther.setFilters(newCamEffects);
			default:
				camGameShaders = [];
				var newCamEffects:Array<BitmapFilter> = [];
				camGame.setFilters(newCamEffects);
		}
	}

	public function getLuaObject(tag:String, text:Bool = true):FlxSprite {
		if (modchartSprites.exists(tag))
			return modchartSprites.get(tag);
		if (text && modchartTexts.exists(tag))
			return modchartTexts.get(tag);
		if (variables.exists(tag))
			return variables.get(tag);
		return null;
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if (gfCheck && char.curCharacter.startsWith('gf')) { // IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String) {
		#if VIDEOS_ALLOWED
		inCutscene = true;

		var filepath:String = Paths.video(name);
		#if sys
		if (!FileSystem.exists(filepath))
		#else
		if (!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			startAndEnd();
			return;
		}

		var video:MP4Handler = new MP4Handler();
		#if (hxCodec < "3.0.0")
		video.playVideo(filepath);
		video.finishCallback = function() {
			startAndEnd();
			return;
		}
		#else
		video.play(filepath);
		video.onEndReached.add(function(){
			video.dispose();
			startAndEnd();
			return;
		});
		#end
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		return;
		#end
	}

	function startAndEnd() {
		if (endingSong)
			endSong();
		else
			startCountdown();
	}

	var dialogueCount:Int = 0;

	public var psychDialogue:DialogueBoxPsych;

	// You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void {
		// TO DO: Make this more flexible, maybe?
		if (psychDialogue != null)
			return;

		if (dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			precacheList.set('dialogue', 'sound');
			precacheList.set('dialogueClose', 'sound');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if (endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if (endingSong) {
				endSong();
			} else {
				startCountdown();
			}
		}
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void {
		if (dialogueBox == null){
			startCountdown();
			return;
		} // don't load any of this, since there's not even any dialogue

		inCutscene = true;
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += 300;

		var songName:String = Paths.formatToSongPath(SONG.song);
		if (songName == 'roses' || songName == 'thorns') {
			remove(black);

			if (songName == 'thorns') {
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer) {
			black.alpha -= 0.15;

			if (black.alpha > 0) {
				tmr.reset(0.3);
			} else {
				if (Paths.formatToSongPath(SONG.song) == 'thorns') {
					add(senpaiEvil);
					senpaiEvil.alpha = 0;
					new FlxTimer().start(0.3, function(swagTimer:FlxTimer) {
						senpaiEvil.alpha += 0.15;
						if (senpaiEvil.alpha < 1) {
							swagTimer.reset();
						} else {
							senpaiEvil.animation.play('idle');
							FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function() {
								remove(senpaiEvil);
								remove(red);
								FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function() {
									add(dialogueBox);
									camHUD.visible = true;
								}, true);
							});
							new FlxTimer().start(3.2, function(deadTime:FlxTimer) {
								FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
							});
						}
					});
				} 
				else
					add(dialogueBox);

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;

	public static var startOnTime:Float = 0;

	function cacheCountdown() {
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		introAssets.set('default', ['ready', 'set', 'go']);
		introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

		var introAlts:Array<String> = introAssets.get('default');
		if (isPixelStage)
			introAlts = introAssets.get('pixel');

		for (asset in introAlts)
			Paths.image(asset);

		Paths.sound('intro3' + introSoundsSuffix);
		Paths.sound('intro2' + introSoundsSuffix);
		Paths.sound('intro1' + introSoundsSuffix);
		Paths.sound('introGo' + introSoundsSuffix);
	}

	public function startCountdown():Void {
		if (startedCountdown) {
			callOnLuas('onStartCountdown', []);
			callOnHScript('startCountdown', []);

			return;
		}

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', []);
		var retHX:Dynamic = callOnHScript('startCountdown', []);

		if (ret != FunkinLua.Function_Stop || retHX != FunkinLua.Function_Stop) {
			if (skipCountdown || startOnTime > 0)
				skipArrowStartTween = true;
			#if android
			androidControls.visible = !cpuControlled;
			#end
			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				// if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
			}

			laneunderlay.x = playerStrums.members[0].x - 25;
		    laneunderlayOpponent.x = opponentStrums.members[0].x - 25;

		    laneunderlay.screenCenter(Y);
		    laneunderlayOpponent.screenCenter(Y);

			startedCountdown = true;
			Conductor.songPosition = -Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);
			setOnHScript('startedCountdown', true);

			callOnLuas('onCountdownStarted', []);
			callOnHScript('countdownStarted', []);

			var swagCounter:Int = 0;

			if (ClientPrefs.averageMiliseconds) {
				if (ClientPrefs.downScroll) {
					msScoreLabel.x = playerStrums.members[1].x-100;
					msScoreLabel.y = playerStrums.members[1].y+100;
				} else {
					msScoreLabel.x = playerStrums.members[1].x-100;
					msScoreLabel.y = playerStrums.members[1].y-50;
				}

				if (ClientPrefs.middleScroll) {
					msScoreLabel.x = playerStrums.members[0].x-250;
					msScoreLabel.y = playerStrums.members[1].y+30;
				}
			}

			if (startOnTime < 0)
				startOnTime = 0;

			if (startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
				return;
			} else if (skipCountdown) {
				setSongTime(0);
				return;
			}

			startTimer = new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer) {
				if (gf != null
					&& tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0
					&& gf.animation.curAnim != null
					&& !gf.animation.curAnim.name.startsWith("sing")
					&& !gf.stunned) {
					gf.dance();
				}
				if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0
					&& boyfriend.animation.curAnim != null
					&& !boyfriend.animation.curAnim.name.startsWith('sing')
					&& !boyfriend.stunned) {
					boyfriend.dance();
				}
				if (tmr.loopsLeft % dad.danceEveryNumBeats == 0
					&& dad.animation.curAnim != null
					&& !dad.animation.curAnim.name.startsWith('sing')
					&& !dad.stunned) {
					dad.dance();
				}

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				if (isPixelStage) {
					introAlts = introAssets.get('pixel');
					antialias = false;
				}

				// head bopping for bg characters on Mall
				if (currentlyStage == 'mall') {
					if (!ClientPrefs.lowQuality)
						upperBoppers.dance(true);

					bottomBoppers.dance(true);
					santa.dance(true);
				}

				// putted it in coolutil for now
				var tick:Countdown = THREE;

				final sound = switch (swagCounter)
				{
					case 0: 'intro3' + FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
					case 1: 'intro2' + FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
					case 2: 'intro1' + FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
					case 3: 'introGo' + FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
					default: null;
				}
				if (sound != null)
				{
					final introSound = FlxG.sound.play(Paths.sound(sound), 0.6);
					introSound.endTime = introSound.length;
					introSound.onComplete = () -> { // modified to fix a bug
						if (swagCounter == 4)
							introSound.volume = 0;
						else if (swagCounter > 4)
							@:privateAccess introSound.cleanup(true, false);
					}
				}
				switch (swagCounter)
				{
					case 0:
						tick = THREE;
					case 1:
						countdownReady = createCountdownSprite(introAlts[0], antialias);
						tick = TWO;
					case 2:
						countdownSet = createCountdownSprite(introAlts[1], antialias);
						tick = ONE;
					case 3:
						countdownGo = createCountdownSprite(introAlts[2], antialias);
						tick = GO;
						strumLineNotes.forEach(function(note)
						{
							if (ClientPrefs.noteAngleSpin) {
								quickSpin(note);
							}
						});
						if (isNormalStart) {
							FlxTween.tween(healthBar, {alpha: ClientPrefs.healthBarAlpha}, 0.35);
							FlxTween.tween(healthBarBG, {alpha: ClientPrefs.healthBarAlpha}, 0.35);
							FlxTween.tween(iconP1, {alpha: ClientPrefs.healthBarAlpha}, 0.35);
							FlxTween.tween(iconP2, {alpha: ClientPrefs.healthBarAlpha}, 0.35);
							FlxTween.tween(scoreTxt, {alpha: 1}, 0.35);
							FlxTween.tween(botplayTxt, {alpha: 1}, 0.35);
							FlxTween.tween(judgementCounterTxt, {alpha: 1}, 0.35);
							FlxTween.tween(songNameTxt, {alpha: 1}, 0.35);
							FlxTween.tween(engineVersionTxt, {alpha: 1}, 0.35);
							FlxTween.tween(songAndDifficultyNameTxt, {alpha: 1}, 0.35);
							FlxTween.tween(playbackRateDecimalTxt, {alpha: 1}, 0.35);
						}
					case 4:
						tick = START;
				}

				notes.forEachAlive(function(note:Note) {
					if (ClientPrefs.opponentStrums || note.mustPress) {
						note.copyAlpha = false;
						note.alpha = note.multAlpha;
						if (ClientPrefs.middleScroll && !note.mustPress) {
							note.alpha *= 0.35;
						}
					}
				});
				callOnLuas('onCountdownTick', [swagCounter]);
				callOnHScript('countdownTick', [swagCounter]);
				swagCounter++;
			}, 4);
		}
		strumLineNotes.forEach(function(note)
		{
			if (ClientPrefs.noteAngleSpin) {
				quickSpin(note);
			}
		});
	}

	inline private function createCountdownSprite(image:String, antialias:Bool):FlxSprite
	{
		var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(image));
		spr.cameras = [camHUD];
		spr.scrollFactor.set();
		spr.updateHitbox();

		if (PlayState.isPixelStage) spr.setGraphicSize(Std.int(spr.width * daPixelZoom));

		spr.screenCenter();
		spr.antialiasing = antialias;
		insert(members.indexOf(notes), spr);
		FlxTween.tween(spr, {alpha: 0}, Conductor.crochet / 1000 / playbackRate, {
			ease: FlxEase.cubeInOut,
			onComplete: _ ->
			{
				remove(spr);
				spr.destroy();
			}
		});
		return spr;
	}

	public function addBehindGF(obj:FlxObject) {
		insert(members.indexOf(gfGroup), obj);
	}

	public function addBehindBF(obj:FlxObject) {
		insert(members.indexOf(boyfriendGroup), obj);
	}

	public function addBehindDad(obj:FlxObject) {
		insert(members.indexOf(dadGroup), obj);
	}

	public function clearNotesBefore(time:Float) {
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if (daNote.strumTime - 350 < time) {
				daNote.ignoreNote = true;

				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if (daNote.strumTime - 350 < time) {
				daNote.ignoreNote = true;

				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function updateScore(miss:Bool = false) {
		if (!cpuControlled && !practiceMode && ClientPrefs.gameStyle == 'SB Engine') {
			scoreTxt.text = LanguageHandler.scoreTxt + songScore + LanguageHandler.notePerSecondTxt + nps + LanguageHandler.averageTxt + Math.round(averageMs) + 'ms' + LanguageHandler.comboBreaksTxt + songMisses + LanguageHandler.healthTxt + ' ${Std.string(Math.floor(Std.parseFloat(Std.string((healthCounter) / 2))))} %' + LanguageHandler.accruracyTxt + Highscore.floorDecimal(ratingPercent * 100, 2) + '%' + ' // ' + ratingName + ' [' + ratingFC + ']';
		} else if (!cpuControlled && !practiceMode && ClientPrefs.gameStyle == 'Psych Engine') {
			scoreTxt.text = LanguageHandler.scoreTxt + songScore  + LanguageHandler.missesTxt + songMisses + LanguageHandler.ratingAndFCNameTxt + ratingName + (ratingName != '?' ? ' (${Highscore.floorDecimal(ratingPercent * 100, 2)}%) - $ratingFC' : '');
		} else if (!cpuControlled && practiceMode && ClientPrefs.gameStyle == 'SB Engine') {
			scoreTxt.text = LanguageHandler.notePerSecondPracticeTxt + nps + LanguageHandler.sbPracticeModeTxt + LanguageHandler.comboBreaksTxt + songMisses;
		} else if  (!cpuControlled && practiceMode && ClientPrefs.gameStyle == 'Psych Engine') {
			scoreTxt.text = LanguageHandler.defaultPracticeModeTxt + LanguageHandler.missesTxt + songMisses;
		} else if (cpuControlled && !practiceMode && ClientPrefs.gameStyle == 'SB Engine') {
			scoreTxt.text = LanguageHandler.autoplayTxt;
		} else if (cpuControlled && !practiceMode && ClientPrefs.gameStyle == 'Psych Engine') {
			scoreTxt.text = LanguageHandler.botplayTxt;
		}

		if (ClientPrefs.judgementCounterStyle == 'Original' && ClientPrefs.gameStyle == 'SB Engine') {
			judgementCounterTxt.text = LanguageHandler.impressiveTxt + ${impressives} + LanguageHandler.sickTxt + ${sicks} + LanguageHandler.goodTxt + ${goods} + LanguageHandler.badTxt + ${bads} + LanguageHandler.freakTxt + ${freaks};
		} else if (ClientPrefs.judgementCounterStyle == 'Original' && ClientPrefs.gameStyle == 'Psych Engine') {
			judgementCounterTxt.text = LanguageHandler.impressiveTxt + ${impressives} + LanguageHandler.sickTxt + ${sicks} + LanguageHandler.goodTxt + ${goods} + LanguageHandler.badTxt + ${bads} + LanguageHandler.shitTxt + ${freaks};
		} else if (ClientPrefs.judgementCounterStyle == 'With Misses' && ClientPrefs.gameStyle == 'SB Engine') {
			judgementCounterTxt.text = LanguageHandler.impressiveTxt + ${impressives} + LanguageHandler.sickTxt + ${sicks} + LanguageHandler.goodTxt + ${goods} + LanguageHandler.badTxt + ${bads} + LanguageHandler.freakTxt + ${freaks} + LanguageHandler.comboBreakTxt + ${songMisses};
		} else if (ClientPrefs.judgementCounterStyle == 'With Misses' && ClientPrefs.gameStyle == 'Psych Engine') {
			judgementCounterTxt.text = LanguageHandler.impressiveTxt + ${impressives} + LanguageHandler.sickTxt + ${sicks} + LanguageHandler.goodTxt + ${goods} + LanguageHandler.badTxt + ${bads} + LanguageHandler.shitTxt + ${freaks} + LanguageHandler.songMissesTxt + ${songMisses};
		} else if (ClientPrefs.judgementCounterStyle == 'Better Judge' && ClientPrefs.gameStyle == 'SB Engine') {
			judgementCounterTxt.text = LanguageHandler.totalNoteHitTxt + ${totalNotes} + LanguageHandler.comboTxt + ${combo} + LanguageHandler.maxComboTxt + ${maxCombo} + LanguageHandler.npsJudgeTxt + ${nps} + LanguageHandler.extraImpressiveTxt + ${impressives} + LanguageHandler.sickTxt + ${sicks} + LanguageHandler.goodTxt + ${goods} + LanguageHandler.badTxt + ${bads} + LanguageHandler.freakTxt + ${freaks} + LanguageHandler.comboBreakTxt + ${songMisses};
		} else if (ClientPrefs.judgementCounterStyle == 'Better Judge' && ClientPrefs.gameStyle == 'Psych Engine') {
			judgementCounterTxt.text = LanguageHandler.totalNoteHitTxt + ${totalNotes} + LanguageHandler.comboTxt + ${combo} + LanguageHandler.maxComboTxt + ${maxCombo} + LanguageHandler.npsJudgeTxt + ${nps} + LanguageHandler.extraImpressiveTxt + ${impressives} + LanguageHandler.sickTxt + ${sicks} + LanguageHandler.goodTxt + ${goods} + LanguageHandler.badTxt + ${bads} + LanguageHandler.shitTxt + ${freaks} + LanguageHandler.songMissesTxt + ${songMisses};
		}

		callOnLuas('onUpdateScore', [miss]);
		callOnHScript('updateScore', [miss]);
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;
	
		FlxG.sound.music.pause();
		vocals.pause();
	
		FlxG.sound.music.time = time;
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.play();
	
		if (!vocalsFinished) {
			if (Conductor.songPosition <= vocals.length)
			{
				vocals.time = time;
				vocals.pitch = playbackRate;
			}
			vocals.play();
		}
		else
			vocals.time = vocals.length;

		Conductor.songPosition = time;
	}

	function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
		callOnHScript('nextDialogue', [dialogueCount]);
	}

	function skipDialogue() {
		callOnLuas('onSkipDialogue', [dialogueCount]);
		callOnHScript('skipDialogue', [dialogueCount]);
		dialogueCount++;
	}

	function startSong():Void {
		startingSong = false;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.onComplete = finishSong.bind();
		vocals.play();
		vocals.onComplete = () -> vocalsFinished = true;

		if (startOnTime > 0) {
			setSongTime(startOnTime - 500);
		}
		startOnTime = 0;

		if (paused) {
			// trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine':
		        FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circInOut});
		        FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circInOut});
				FlxTween.tween(timePercentTxt, {alpha: 1}, 0.5, {ease: FlxEase.circInOut});
				FlxTween.tween(laneunderlayOpponent, {alpha: ClientPrefs.laneunderlayAlpha}, 0.5, {ease: FlxEase.circInOut});
				FlxTween.tween(laneunderlay, {alpha: ClientPrefs.laneunderlayAlpha}, 0.5, {ease: FlxEase.circInOut});
				new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					FlxTween.tween(nowPlayingTxt, {alpha: 0, y: -20}, 0.8, {ease: FlxEase.circInOut, startDelay: 0.3});
				});
		        FlxTween.tween(songNameTxt, {alpha: 1, y: 47}, 0.8, {ease: FlxEase.circInOut, startDelay: 0.3});
			    new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					FlxTween.tween(songNameTxt, {alpha: 0, y: -20}, 0.8, {ease: FlxEase.circInOut, startDelay: 0.3});
			    });
		        FlxTween.tween(songNameBackground, {alpha: 0.5}, 0.8, {ease: FlxEase.circInOut, startDelay: 0.3});
			    new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					FlxTween.tween(songNameBackground, {alpha: 0, y: -20}, 0.8, {ease: FlxEase.circInOut, startDelay: 0.3});
				});
			
			default:
		        FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.expoInOut});
		        FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.expoInOut});
				FlxTween.tween(timePercentTxt, {alpha: 1}, 0.5, {ease: FlxEase.expoInOut});
				FlxTween.tween(laneunderlayOpponent, {alpha: ClientPrefs.laneunderlayAlpha}, 0.5, {ease: FlxEase.expoInOut});
				FlxTween.tween(laneunderlay, {alpha: ClientPrefs.laneunderlayAlpha}, 0.5, {ease: FlxEase.expoInOut});
				FlxTween.tween(nowPlayingTxt, {alpha: 1, y: 20}, 0.8, {ease: FlxEase.expoInOut, startDelay: 0.3});
			    new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					FlxTween.tween(nowPlayingTxt, {alpha: 0, y: -20}, 0.8, {ease: FlxEase.expoInOut, startDelay: 0.3});
				});
		        FlxTween.tween(songNameTxt, {alpha: 1, y: 47}, 0.8, {ease: FlxEase.expoInOut, startDelay: 0.3});
			    new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					FlxTween.tween(songNameTxt, {alpha: 0, y: -20}, 0.8, {ease: FlxEase.expoInOut, startDelay: 0.3});
			    });
		        FlxTween.tween(songNameBackground, {alpha: 0.5}, 0.8, {ease: FlxEase.expoInOut, startDelay: 0.3});
			    new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					FlxTween.tween(songNameBackground, {alpha: 0, y: -20}, 0.8, {ease: FlxEase.expoInOut, startDelay: 0.3});
				});
		}

		switch (currentlyStage) {
			case 'tank':
				if (!ClientPrefs.lowQuality)
					tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BGSprite) {
					spr.dance();
				});
		}

		#if desktop
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyModeDifficultyText + ")", iconP2.getCharacter(), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		setOnHScript('songLength', songLength);

		callOnLuas('onSongStart', []);
		callOnHScript('startSong', []);

	}

	public function lerpSongSpeed(num:Float, time:Float):Void
	{
		FlxTween.num(playbackRate, num, time, {onUpdate: function(tween:FlxTween){
			var rateThing = FlxMath.lerp(playbackRate, num, tween.percent);
			if (rateThing != 0)
				playbackRate = rateThing;

		}});
	}

	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();

	private function generateSong():Void {
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype', 'multiplicative');

		switch (songSpeedType) {
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		currentlySong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		vocals.pitch = playbackRate;
		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW freak
		noteData = songData.notes;

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(SUtil.getPath() + file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) // Event Notes
			{
				for (i in 0...event[1].length) {
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData) {
			for (songNotes in section.sectionNotes) {
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3) {
					gottaHitNote = !section.mustHitSection;
				}
				var oldNote:Note;

				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;
				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);

				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1] < 4));
				swagNote.noteType = songNotes[3];
				if (!Std.isOfType(songNotes[3], String))
					swagNote.noteType = states.editors.ChartingState.noteTypeList[songNotes[3]]; // Backward compatibility + compatibility with Week 7 charts
				swagNote.scrollFactor.set();
				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);
				var floorSus:Int = Math.floor(susLength);

				if (floorSus > 0) {
					for (susNote in 0...floorSus + 1) {
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
						var sustainNote:Note = new Note(daStrumTime
							+ (Conductor.stepCrochet * susNote)
							+ (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote,
							true);

						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1] < 4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						swagNote.tail.push(sustainNote);
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);
						if (sustainNote.mustPress) {
							sustainNote.x += FlxG.width / 2; // general offset
						} else if (ClientPrefs.middleScroll) {
							sustainNote.x += 310;
							if (daNoteData > 1) // Up and Right
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}
				if (swagNote.mustPress) {
					swagNote.x += FlxG.width / 2; // general offset
				} else if (ClientPrefs.middleScroll) {
					swagNote.x += 310;
					if (daNoteData > 1) // Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}
				if (!noteTypeMap.exists(swagNote.noteType)) {
					noteTypeMap.set(swagNote.noteType, true);
				}
			}
		}
		for (event in songData.events) // Event Notes
		{
			for (i in 0...event[1].length) {
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}
		unspawnNotes.sort(sortByTime);
		generatedMusic = true;
		setOnLuas('song', SONG.song);
		setOnHScript('song', SONG.song);

		callOnLuas('onGenerateSong', []);
		callOnHScript('generateSong', []);
	}

	function eventPushed(event:EventNote) {
		switch (event.event) {
			case 'Change Character':
				var charType:Int = 0;
				switch (event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if (Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);

			case 'Dadbattle Spotlight':
				dadbattleBlack = new BGSprite(null, -800, -400, 0, 0);
				dadbattleBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				dadbattleBlack.alpha = 0.25;
				dadbattleBlack.visible = false;
				add(dadbattleBlack);

				dadbattleLight = new BGSprite('spotlight', 400, -400);
				dadbattleLight.alpha = 0.375;
				dadbattleLight.blend = ADD;
				dadbattleLight.visible = false;

				dadbattleSmokes.alpha = 0.7;
				dadbattleSmokes.blend = ADD;
				dadbattleSmokes.visible = false;
				add(dadbattleLight);
				add(dadbattleSmokes);

				var offsetX = 200;
				var smoke:BGSprite = new BGSprite('smoke', -1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(15, 22);
				smoke.active = true;
				dadbattleSmokes.add(smoke);
				var smoke:BGSprite = new BGSprite('smoke', 1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(-15, -22);
				smoke.active = true;
				smoke.flipX = true;
				dadbattleSmokes.add(smoke);

			case 'Philly Glow':
				blammedLightsBlack = new FlxSprite(FlxG.width * -0.5,
					FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				blammedLightsBlack.visible = false;
				insert(members.indexOf(phillyStreet), blammedLightsBlack);

				phillyWindowEvent = new BGSprite('philly/window', phillyWindow.x, phillyWindow.y, 0.3, 0.3);
				phillyWindowEvent.setGraphicSize(Std.int(phillyWindowEvent.width * 0.85));
				phillyWindowEvent.updateHitbox();
				phillyWindowEvent.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyWindowEvent);

				phillyGlowGradient = new PhillyGlowGradient(-400, 225); // This freak was refusing to properly load FlxGradient so freak it
				phillyGlowGradient.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyGlowGradient);
				if (!ClientPrefs.flashing)
					phillyGlowGradient.intendedAlpha = 0.7;

				precacheList.set('philly/particle', 'image'); // precache particle image
				phillyGlowParticles = new FlxTypedGroup<PhillyGlowParticle>();
				phillyGlowParticles.visible = false;
				insert(members.indexOf(phillyGlowGradient) + 1, phillyGlowParticles);
		}

		if (!eventPushedMap.exists(event.event)) {
			eventPushedMap.set(event.event, true);
		}
	}

	function eventNoteEarlyTrigger(event:EventNote):Float {
		var returnedValue:Null<Float> = callOnLuas('eventEarlyTrigger', [event.event, event.value1, event.value2, event.strumTime], [], [0]);
		var returnedHXValue:Null<Float> = callOnHScript('eventEarlyTrigger', [event.event, event.value1, event.value2, event.strumTime], [], [0]);

		if ((returnedValue != null && returnedValue != 0 && returnedValue != FunkinLua.Function_Continue) || (returnedHXValue != null && returnedHXValue != 0 && returnedHXValue != FunkinLua.Function_Continue)) {
			return #if LUA_ALLOWED returnedValue; #else returnedHXValue; #end
		}

		switch (event.event) {
			case 'Kill Henchmen': // Better timing so that the kill sound matches the beat intended
				return 280; // Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByTime(Obj1:Dynamic, Obj2:Dynamic):Int {
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false; // for lua

	private function generateStaticArrows(player:Int):Void {
		for (i in 0...4) {
			var tweenDuration:Float = 4;
			var tweenStart:Float = 0.5 + ((0.8) * i);
			var targetAlpha:Float = 1;
			if (player < 1) {
				if (!ClientPrefs.opponentStrums)
					targetAlpha = 0;
				else if (ClientPrefs.middleScroll)
					targetAlpha = 0.35;
			}

			var opponentArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			opponentArrow.downScroll = ClientPrefs.downScroll;
			if (!isStoryMode && !skipArrowStartTween) {
				opponentArrow.alpha = 0;
				FlxTween.tween(opponentArrow, {alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			} else {
				opponentArrow.alpha = targetAlpha;
			}

			if (player == 1) {
				playerStrums.add(opponentArrow);
			} else {
				if (ClientPrefs.middleScroll) {
					opponentArrow.x += 310;
					if (i > 1) { // Up and Right
						opponentArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(opponentArrow);
			}

			strumLineNotes.add(opponentArrow);
			opponentArrow.postAddedToGroup();

			#if desktop
			if (ClientPrefs.showKeybindsOnStart && player == 1) {
				for (j in 0...keysArray[i].length) {
					var daKeyTxt:FlxText = new FlxText(opponentArrow.x, opponentArrow.y - 10, 0, InputFormatter.getKeyName(keysArray[i][j]), 32);
					switch (ClientPrefs.gameStyle) {
						case 'Psych Engine':
							daKeyTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						
						default:
							daKeyTxt.setFormat(Paths.font("bahnschrift.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					}
					daKeyTxt.borderSize = 1.25;
					daKeyTxt.alpha = 0;
					daKeyTxt.size = 32;
					daKeyTxt.x = opponentArrow.x + (opponentArrow.width / 2);
					daKeyTxt.x -= daKeyTxt.width / 2;
					add(daKeyTxt);
					daKeyTxt.cameras = [camHUD];
					var textY:Float = (j == 0 ? opponentArrow.y - 32 : ((opponentArrow.y - 32) + opponentArrow.height) - daKeyTxt.height);
					daKeyTxt.y = textY;

					if (!skipArrowStartTween) {
						FlxTween.tween(daKeyTxt, {y: textY + 32, alpha: 1}, tweenDuration, {ease: FlxEase.circOut, startDelay: tweenStart});
					} else {
						daKeyTxt.y += 16;
						daKeyTxt.alpha = 1;
					}
					new FlxTimer().start(Conductor.crochet * 0.001 * 12, function(_) {
						FlxTween.tween(daKeyTxt, {y: daKeyTxt.y + 32, alpha: 0}, tweenDuration, {ease: FlxEase.circIn, startDelay: tweenStart, onComplete:
						function(t) {
							remove(daKeyTxt);
						}});
					});
				}
			}
			#end
		}
	}

	override function openSubState(SubState:FlxSubState) {
		if (paused) {
			if (FlxG.sound.music != null) {
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			if (carTimer != null)
				carTimer.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if (char != null && char.colorTween != null) {
					char.colorTween.active = false;
				}
			}

			for (tween in modchartTweens) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState() {
		if (paused) {
			if (FlxG.sound.music != null && !startingSong) {
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

			if (carTimer != null)
				carTimer.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if (char != null && char.colorTween != null) {
					char.colorTween.active = true;
				}
			}

			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;
			callOnLuas('onResume', []);
			callOnHScript('resume', []);

			#if desktop
			if (startTimer != null && startTimer.finished) {
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyModeDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			} else {
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyModeDifficultyText + ")", iconP2.getCharacter());
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void {
		#if desktop
		if (health > 0 && !paused) {
			if (Conductor.songPosition > 0.0) {
				DiscordClient.changePresence(detailsText, SONG.song
					+ " ("
					+ storyModeDifficultyText
					+ ")", iconP2.getCharacter(), true,
					songLength
					- Conductor.songPosition
					- ClientPrefs.noteOffset);
			} else {
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyModeDifficultyText + ")", iconP2.getCharacter());
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void {
		#if desktop
		if (health > 0 && !paused) {
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyModeDifficultyText + ")", iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null || vocalsFinished || isDead) return;
	
		vocals.pause();
	
		FlxG.sound.music.play();
		FlxG.sound.music.pitch = playbackRate;
		Conductor.songPosition = FlxG.sound.music.time;
	
		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = Conductor.songPosition;
			vocals.pitch = playbackRate;
		}
		vocals.play();
	}

	public var paused:Bool = false;
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;

	override public function update(elapsed:Float) {
		callOnLuas('onUpdate', [elapsed]);
		callOnHScript('update', [elapsed]);

		switch (currentlyStage) {
			case 'tank':
				moveTank(elapsed);
			case 'schoolEvil':
				if (!ClientPrefs.lowQuality && bgGhouls.animation.curAnim.finished) {
					bgGhouls.visible = false;
				}
			case 'philly':
				if (trainMoving) {
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24) {
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				phillyWindow.alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;

				if (phillyGlowParticles != null) {
					var i:Int = phillyGlowParticles.members.length - 1;
					while (i > 0) {
						var particle = phillyGlowParticles.members[i];
						if (particle.alpha < 0) {
							particle.kill();
							phillyGlowParticles.remove(particle, true);
							particle.destroy();
						}
						--i;
					}
				}
			case 'limo':
				if (!ClientPrefs.lowQuality) {
					grpLimoParticles.forEach(function(spr:BGSprite) {
						if (spr.animation.curAnim.finished) {
							spr.kill();
							grpLimoParticles.remove(spr, true);
							spr.destroy();
						}
					});

					switch (limoKillingState) {
						case 1:
							limoMetalPole.x += 5000 * elapsed;
							limoLight.x = limoMetalPole.x - 180;
							limoCorpse.x = limoLight.x - 50;
							limoCorpseTwo.x = limoLight.x + 35;

							var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
							for (i in 0...dancers.length) {
								if (dancers[i].x < FlxG.width * 1.5 && limoLight.x > (370 * i) + 170) {
									switch (i) {
										case 0 | 3:
											if (i == 0)
												FlxG.sound.play(Paths.sound('dancerdeath'), 0.5);

											var diffStr:String = i == 3 ? ' 2 ' : ' ';
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 200, dancers[i].y, 0.4, 0.4,
												['hench leg spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 160, dancers[i].y + 200, 0.4, 0.4,
												['hench arm spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x, dancers[i].y + 50, 0.4, 0.4,
												['hench head spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);

											var particle:BGSprite = new BGSprite('gore/stupidBlood', dancers[i].x - 110, dancers[i].y + 20, 0.4, 0.4, ['blood'],
												false);
											particle.flipX = true;
											particle.angle = -57.5;
											grpLimoParticles.add(particle);
										case 1:
											limoCorpse.visible = true;
										case 2:
											limoCorpseTwo.visible = true;
									} // Note: Nobody cares about the fifth dancer because he is mostly hidden offscreen :(
									dancers[i].x += FlxG.width * 2;
								}
							}

							if (limoMetalPole.x > FlxG.width * 2) {
								resetLimoKill();
								limoSpeed = 800;
								limoKillingState = 2;
							}

						case 2:
							limoSpeed -= 4000 * elapsed;
							bgLimo.x -= limoSpeed * elapsed;
							if (bgLimo.x > FlxG.width * 1.5) {
								limoSpeed = 3000;
								limoKillingState = 3;
							}

						case 3:
							limoSpeed -= 2000 * elapsed;
							if (limoSpeed < 1000)
								limoSpeed = 1000;

							bgLimo.x -= limoSpeed * elapsed;
							if (bgLimo.x < -275) {
								limoKillingState = 4;
								limoSpeed = 800;
							}

						case 4:
							bgLimo.x = FlxMath.lerp(bgLimo.x, -150, CoolUtil.boundTo(elapsed * 9, 0, 1));
							if (Math.round(bgLimo.x) == -150) {
								bgLimo.x = -150;
								limoKillingState = 0;
							}
					}

					if (limoKillingState > 2) {
						var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
						for (i in 0...dancers.length) {
							dancers[i].x = (370 * i) + bgLimo.x + 280;
						}
					}
				}
			case 'mall':
				if (heyTimer > 0) {
					heyTimer -= elapsed;
					if (heyTimer <= 0) {
						bottomBoppers.dance(true);
						heyTimer = 0;
					}
				}
		}

		if (!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed * playbackRate, 0, 1);
			cameraFollowPosition.setPosition(FlxMath.lerp(cameraFollowPosition.x, cameraFollow.x, lerpVal),
				FlxMath.lerp(cameraFollowPosition.y, cameraFollow.y, lerpVal));
			if (!startingSong
				&& !endingSong
				&& boyfriend.animation.curAnim != null
				&& boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if (boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}

		for(i in 0...notesHitArray.length)
		{
			var npsCounter:Date = notesHitArray[i];
			if (npsCounter != null)
				if (npsCounter.getTime() + 2000 < Date.now().getTime())
			notesHitArray.remove(npsCounter);
		}
		if (!cpuControlled) {
			nps = Math.floor(notesHitArray.length / 2);
		}

		healthCounter = health * 100;

		super.update(elapsed);
		updateScore();

		setOnLuas('curDecStep', curDecStep);
		setOnLuas('curDecBeat', curDecBeat);

		setOnHScript('curDecStep', curDecStep);
		setOnHScript('curDecBeat', curDecBeat);

		var speed:Float = 1;
		if (sbEngineIconBounce) {
			if (iconP1.angle >= 0) {
				speed *= playbackRate;
				if (iconP1.angle != 0) {
					iconP1.angle -= speed;
				}
			} else {
				if (iconP1.angle != 0) {
					iconP1.angle += speed;
				}
			}
			if (iconP2.angle >= 0) {
				if (iconP2.angle != 0) {
					iconP2.angle -= speed;
				}
			} else {
				if (iconP2.angle != 0) {
					iconP2.angle += speed;
				}
			}
		}
		
		if (ClientPrefs.objectTxtSine) {
			switch (ClientPrefs.gameStyle) {
				case 'Psych Engine':
			    	if (botplayTxt.visible) {
				 		botplaySine += 180 * elapsed;
				    	botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
						scoreTxtSine += 180 * elapsed;
				    	scoreTxt.alpha = 1 - Math.sin((Math.PI * scoreTxtSine) / 180);
			   	 	}
			
				default:
			    	if (botplayTxt.visible) {
				    	botplaySine += 50 * elapsed;
				    	botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 120);
						scoreTxtSine += 50 * elapsed;
				    	scoreTxt.alpha = 1 - Math.sin((Math.PI * scoreTxtSine) / 120);
			    }
			}
		}

		if (controls.PAUSE #if android || FlxG.android.justReleased.BACK #end && startedCountdown && canPause) {
			var ret:Dynamic = callOnLuas('onPause', []);
			var retHX:Dynamic = callOnHScript('pause', []);

			if (ret != FunkinLua.Function_Stop || retHX != FunkinLua.Function_Stop) {
				openPauseMenu();
			}
		}

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene) {
			openChartEditor();
		}

		
		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();
 
		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x
			+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
			+ (150 * iconP1.scale.x - 150) / 2
			- iconOffset;
		iconP2.x = healthBar.x
			+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
			- (150 * iconP2.scale.x) / 2
			- iconOffset * 2;

		if (health > 2)
			health = 2;

		switch (iconP1.animation.numFrames){
			case 3:
				if (healthBar.percent < 20)
					iconP1.animation.curAnim.curFrame = 1;
				else if (healthBar.percent >80)
					iconP1.animation.curAnim.curFrame = 2;
				else
					iconP1.animation.curAnim.curFrame = 0;
			case 2:
				if (healthBar.percent < 20)
					iconP1.animation.curAnim.curFrame = 1;
				else
					iconP1.animation.curAnim.curFrame = 0;
			case 1:
				iconP1.animation.curAnim.curFrame = 0;
		}

		switch(iconP2.animation.numFrames){
			case 3:
				if (healthBar.percent > 80)
					iconP2.animation.curAnim.curFrame = 1;
				else if (healthBar.percent < 20)
					iconP2.animation.curAnim.curFrame = 2;
				else 
					iconP2.animation.curAnim.curFrame = 0;
			case 2:
				if (healthBar.percent > 80)
					iconP2.animation.curAnim.curFrame = 1;
				else 
					iconP2.animation.curAnim.curFrame = 0;
			case 1:
				iconP2.animation.curAnim.curFrame = 0;
		}

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene) {
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
			Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Character Editor Menu";
		}

		if (startedCountdown) {
			Conductor.songPosition += FlxG.elapsed * 1000 * playbackRate;
		}

		if (startingSong) {
			if (startedCountdown && Conductor.songPosition >= 0)
				startSong();
			else if (!startedCountdown)
				Conductor.songPosition = -Conductor.crochet * 5;
		} else {
			if (!paused) {
				if (updateTime) {
					var currentlyTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if (currentlyTime < 0)
						currentlyTime = 0;
					songPercent = (currentlyTime / songLength);

					var songDurationSeconds:Float = FlxMath.roundDecimal(songLength / 1000, 0);
					songPercentValue = FlxMath.roundDecimal(currentlyTime / songLength * 100, ClientPrefs.timePercentValue);

					var songCalculating:Float = (songLength - currentlyTime);
					if (ClientPrefs.timeBarType == 'Time Elapsed' || ClientPrefs.timeBarType == 'Modern Time' || ClientPrefs.timeBarType == 'Song Name + Time') songCalculating = currentlyTime;

					var secondsTotal:Int = Math.floor((songCalculating / playbackRate) / 1000);
					if (secondsTotal < 0)
						secondsTotal = 0;

					var hoursRemaining:Int = Math.floor(secondsTotal / 3600);
					var minutesRemaining:Int = Math.floor(secondsTotal / 60) % 60;
					var minutesRemainingValue:String = '' + minutesRemaining;
					var secondsRemaining:String = '' + secondsTotal % 60;

					if(secondsRemaining.length < 2) secondsRemaining = '0' + secondsRemaining; //let's see if the old time format works actually
					//if (minutesRemaining == 60) minutesRemaining = 0; //reset the minutes to 0 every time it counts another hour
					if (minutesRemainingValue.length < 2) minutesRemainingValue = '0' + minutesRemaining; 
					//also, i wont add a day thing because there's no way someone can mod a song that's over 24 hours long into this engine

					var hoursShown:Int = Math.floor(songDurationSeconds / 3600);
					var minutesShown:Int = Math.floor(songDurationSeconds / 60) % 60;
					var minutesShownValue:String = '' + minutesShown;
					var secondsShown:String = '' + songDurationSeconds % 60;
					if(secondsShown.length < 2) secondsShown = '0' + secondsShown; //let's see if the old time format works actually
					if (minutesShownValue.length < 2) minutesShownValue = '0' + minutesShown;

					if(ClientPrefs.timeBarType != 'Song Name' && songLength <= 3600000)
						timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);

					if(ClientPrefs.timeBarType != 'Song Name' && songLength >= 3600000)
						timeTxt.text = hoursRemaining + ':' + minutesRemainingValue + ':' + secondsRemaining;

					if(ClientPrefs.timeBarType == 'Song Name + Time' && songLength <= 3600000)
						timeTxt.text = SONG.song + ' (' + FlxStringUtil.formatTime(secondsTotal, false) + ' / ' + FlxStringUtil.formatTime(songLength / 1000, false) + ')';

					if(ClientPrefs.timeBarType == 'Song Name + Time' && songLength >= 3600000)
						timeTxt.text = SONG.song + ' (' + hoursRemaining + ':' + minutesRemainingValue + ':' + secondsRemaining + ' / ' + hoursShown + ':' + minutesShownValue + ':' + secondsShown + ')';

					if(ClientPrefs.timeBarType == 'Modern Time' && songLength <= 3600000)
						timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false) + ' / ' + FlxStringUtil.formatTime(songLength / 1000, false);

					if(ClientPrefs.timeBarType == 'Modern Time' && songLength >= 3600000)
						timeTxt.text = hoursRemaining + ':' + minutesRemainingValue + ':' + secondsRemaining + ' / ' + hoursShown + ':' + minutesShownValue + ':' + secondsShown;

					if (ClientPrefs.botplayOnTimebar) {
		            	if (cpuControlled && ClientPrefs.timeBarType != 'Song Name' && ClientPrefs.gameStyle == 'SB Engine') timeTxt.text += LanguageHandler.autoplayTimeTxt;
						if (cpuControlled && ClientPrefs.timeBarType != 'Song Name' && ClientPrefs.gameStyle == 'Psych Engine') timeTxt.text += LanguageHandler.botplayTimeTxt;
					}
				}
			}

			     if(updatePercent) {
					var currentlyTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if(currentlyTime < 0) currentlyTime = 0;
					songPercent = (currentlyTime / songLength);
					songPercentValue = FlxMath.roundDecimal(currentlyTime / songLength * 100, ClientPrefs.timePercentValue);
					if (ClientPrefs.gameStyle != 'SB Engine' && ClientPrefs.gameStyle != 'Psych Engine')
					{
					timePercentTxt.text = songPercentValue  + '% Completed';
					}
					else
					{
					timePercentTxt.text = songPercentValue  + '%';
				}
			}
		}

		if (camZooming) {
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
		}

		FlxG.watch.addQuick("sectionValue", curSection);
		FlxG.watch.addQuick("beatValue", curBeat);
		FlxG.watch.addQuick("stepValue", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong) {
			doDeathCheck(true);
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null) {
			var time:Float = spawnTime;
			if (songSpeed < 1)
				time /= songSpeed;
			if (unspawnNotes[0].multSpeed < 1)
				time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time) {
				var dunceNote:Note = unspawnNotes.shift();
				notes.insert(0, dunceNote);
				dunceNote.spawned = true;
				callOnLuas('onSpawnNote', [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote]);
				callOnHScript('spawnNote', [dunceNote]);

			}
		}

		if (generatedMusic) {
			if (!inCutscene) {
				if (!cpuControlled) {
					keyfreak();
				} else if (boyfriend.animation.curAnim != null
					&& boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration
						&& boyfriend.animation.curAnim.name.startsWith('sing')
						&& !boyfriend.animation.curAnim.name.endsWith('miss')) {
					boyfriend.dance();
					// boyfriend.animation.curAnim.finish();
				}

				if (startedCountdown) {
					var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
					notes.forEachAlive(function(daNote:Note) {
						var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
						if (!daNote.mustPress)
							strumGroup = opponentStrums;

						var strumX:Float = strumGroup.members[daNote.noteData].x;
						var strumY:Float = strumGroup.members[daNote.noteData].y;
						var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
						var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
						var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
						var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;

						strumX += daNote.offsetX;
						strumY += daNote.offsetY;
						strumAngle += daNote.offsetAngle;
						strumAlpha *= daNote.multAlpha;

						if (strumScroll) // Downscroll
							daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
						else // Upscroll
							daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);

						var angleDir = strumDirection * Math.PI / 180;
						if (daNote.copyAngle)
							daNote.angle = strumDirection - 90 + strumAngle;

						if (daNote.copyAlpha)
							daNote.alpha = strumAlpha;

						if (daNote.copyX)
							daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

						if (daNote.copyY) {
							daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

							// Jesus freak this took me so much mother freaking time AAAAAAAAAA
							if (strumScroll && daNote.isSustainNote) {
								if (daNote.animation.curAnim.name.endsWith('end')) {
									daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
									daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
									if (PlayState.isPixelStage) {
										daNote.y += 8 + (6 - daNote.originalHeightForCalcs) * PlayState.daPixelZoom;
									} else {
										daNote.y -= 19;
									}
								}
								daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
								daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
							}
						}

						if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote) {
							opponentNoteHit(daNote);
						}

						if (!daNote.blockHit && daNote.mustPress && cpuControlled && daNote.canBeHit) {
							if (daNote.isSustainNote) {
								if (daNote.canBeHit) {
									goodNoteHit(daNote);
								}
							} else if (daNote.strumTime <= Conductor.songPosition || daNote.isSustainNote) {
								goodNoteHit(daNote);
							}
						}

						var center:Float = strumY + Note.swagWidth / 2;
						if (strumGroup.members[daNote.noteData].sustainReduce
							&& daNote.isSustainNote
							&& (daNote.mustPress || !daNote.ignoreNote)
							&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit)))) {
							if (strumScroll) {
								if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center) {
									var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
									swagRect.height = (center - daNote.y) / daNote.scale.y;
									swagRect.y = daNote.frameHeight - swagRect.height;

									daNote.clipRect = swagRect;
								}
							} else {
								if (daNote.y + daNote.offset.y * daNote.scale.y <= center) {
									var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
									swagRect.y = (center - daNote.y) / daNote.scale.y;
									swagRect.height -= swagRect.y;

									daNote.clipRect = swagRect;
								}
							}
						}

						// Kill extremely late notes and cause misses
						if (Conductor.songPosition > noteKillOffset + daNote.strumTime) {
							if (daNote.mustPress && !cpuControlled && !daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
								noteMiss(daNote);
							}
							notes.remove(daNote, true);
							daNote.destroy();
						}
					});
				} else {
					notes.forEachAlive(function(daNote:Note) {
						daNote.canBeHit = daNote.wasGoodHit = false;
					});
				}
			}
			checkEventNote();
		}

		#if debug
		if (!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if (FlxG.keys.justPressed.TWO) { // Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		#end

		for (i in shaderUpdates) {
			i(elapsed);
		}

		setOnLuas('cameraX', cameraFollowPosition.x);
		setOnLuas('cameraY', cameraFollowPosition.y);
		setOnLuas('botPlay', cpuControlled);

		setOnHScript('cameraX', cameraFollowPosition.x);
		setOnHScript('cameraY', cameraFollowPosition.y);
		setOnHScript('botPlay', cpuControlled);

		callOnLuas('onUpdatePost', [elapsed]);
		callOnHScript('updatePost', [elapsed]);

	}

	function openPauseMenu() {
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		if (FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
		}
		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Paused current song: " + SONG.song + " (" + CoolUtil.difficulties[storyModeDifficulty] + ") ";
		// }

		#if desktop
		DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyModeDifficultyText + ")", iconP2.getCharacter());
		#end
	}

	function openChartEditor() {
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		MusicBeatState.switchState(new ChartingState());
		Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Chart Editor Menu";
		chartingMode = true;

		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
	}

	public var isDead:Bool = false; // Don't mess with this on Lua!!!

	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead) {
			var ret:Dynamic = callOnLuas('onGameOver', [], false);
			var retHX:Dynamic = callOnHScript('gameOver', [], false);

			if (ret != FunkinLua.Function_Stop || retHX != FunkinLua.Function_Stop) {
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();
	
				persistentUpdate = false;
				persistentDraw = false;
				for (tween in modchartTweens) {
					tween.active = true;
				}
				for (timer in modchartTimers) {
					timer.active = true;
				}
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0],
					boyfriend.getScreenPosition().y - boyfriend.positionArray[1], cameraFollowPosition.x, cameraFollowPosition.y));
					Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Game Over: " + SONG.song + " (" + CoolUtil.difficulties[storyModeDifficulty] + ") ";

				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyModeDifficultyText + ")", iconP2.getCharacter());
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while (eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if (Conductor.songPosition < leStrumTime) {
				return;
			}

			var value1:String = '';
			if (eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if (eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		// trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch (eventName) {
			case 'Dadbattle Spotlight':
				if (currentlyStage != 'stage') return;
				var val:Null<Int> = Std.parseInt(value1);
				if (val == null)
					val = 0;

				switch (Std.parseInt(value1)) {
					case 1, 2, 3: // enable and target dad
						if (val == 1) // enable
						{
							dadbattleBlack.visible = true;
							dadbattleLight.visible = true;
							dadbattleSmokes.visible = true;
							defaultCamZoom += 0.12;
						}

						var who:Character = dad;
						if (val > 2)
							who = boyfriend;
						// 2 only targets dad
						dadbattleLight.alpha = 0;
						new FlxTimer().start(0.12, function(tmr:FlxTimer) {
							dadbattleLight.alpha = 0.375;
						});
						dadbattleLight.setPosition(who.getGraphicMidpoint().x - dadbattleLight.width / 2, who.y + who.height - dadbattleLight.height + 50);

					default:
						dadbattleBlack.visible = false;
						dadbattleLight.visible = false;
						defaultCamZoom -= 0.12;
						FlxTween.tween(dadbattleSmokes, {alpha: 0}, 1, {
							onComplete: function(twn:FlxTween) {
								dadbattleSmokes.visible = false;
							}
						});
				}

			case 'Hey!':
				var value:Int = 2;
				switch (value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if (Math.isNaN(time) || time <= 0)
					time = 0.6;

				if (value != 0) {
					if (dad.curCharacter.startsWith('gf')) { // Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}

					if (currentlyStage == 'mall') {
						bottomBoppers.animation.play('hey', true);
						heyTimer = time;
					}
				}
				if (value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if (Math.isNaN(value) || value < 1)
					value = 1;
				gfSpeed = value;

			case 'Philly Glow':
				if (currentlyStage != 'philly') return;
				var lightId:Int = Std.parseInt(value1);
				if (Math.isNaN(lightId))
					lightId = 0;

				var doFlash:Void->Void = function() {
					var color:FlxColor = FlxColor.WHITE;
					if (!ClientPrefs.flashing)
						color.alphaFloat = 0.5;

					FlxG.camera.flash(color, 0.15, null, true);
				};

				var chars:Array<Character> = [boyfriend, gf, dad];
				switch (lightId) {
					case 0:
						if (phillyGlowGradient.visible) {
							doFlash();
							if (ClientPrefs.camZooms) {
								FlxG.camera.zoom += 0.5;
								camHUD.zoom += 0.1;
							}

							blammedLightsBlack.visible = false;
							phillyWindowEvent.visible = false;
							phillyGlowGradient.visible = false;
							phillyGlowParticles.visible = false;
							curLightEvent = -1;

							for (who in chars) {
								who.color = FlxColor.WHITE;
							}
							phillyStreet.color = FlxColor.WHITE;
						}

					case 1: // turn on
						curLightEvent = FlxG.random.int(0, phillyLightsColors.length - 1, [curLightEvent]);
						var color:FlxColor = phillyLightsColors[curLightEvent];

						if (!phillyGlowGradient.visible) {
							doFlash();
							if (ClientPrefs.camZooms) {
								FlxG.camera.zoom += 0.5;
								camHUD.zoom += 0.1;
							}

							blammedLightsBlack.visible = true;
							blammedLightsBlack.alpha = 1;
							phillyWindowEvent.visible = true;
							phillyGlowGradient.visible = true;
							phillyGlowParticles.visible = true;
						} else if (ClientPrefs.flashing) {
							var colorButLower:FlxColor = color;
							colorButLower.alphaFloat = 0.25;
							FlxG.camera.flash(colorButLower, 0.5, null, true);
						}

						var charColor:FlxColor = color;
						if (!ClientPrefs.flashing)
							charColor.saturation *= 0.5;
						else
							charColor.saturation *= 0.75;

						for (who in chars) {
							who.color = charColor;
						}
						phillyGlowParticles.forEachAlive(function(particle:PhillyGlowParticle) {
							particle.color = color;
						});
						phillyGlowGradient.color = color;
						phillyWindowEvent.color = color;

						color.brightness *= 0.5;
						phillyStreet.color = color;

					case 2: // spawn particles
						if (!ClientPrefs.lowQuality) {
							var particlesNum:Int = FlxG.random.int(8, 12);
							var width:Float = (2000 / particlesNum);
							var color:FlxColor = phillyLightsColors[curLightEvent];
							for (j in 0...3) {
								for (i in 0...particlesNum) {
									var particle:PhillyGlowParticle = new PhillyGlowParticle(-400
										+ width * i
										+ FlxG.random.float(-width / 5, width / 5),
										phillyGlowGradient.originalY
										+ 200
										+ (FlxG.random.float(0, 125) + j * 40), color);
									phillyGlowParticles.add(particle);
								}
							}
						}
						phillyGlowGradient.bop();
				}

			case 'Kill Henchmen':
				killHenchmen();

			case 'Add Camera Zoom':
				if (ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if (Math.isNaN(camZoom))
						camZoom = 0.015;
					if (Math.isNaN(hudZoom))
						hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Trigger BG Ghouls':
				if (currentlyStage == 'schoolEvil' && !ClientPrefs.lowQuality) {
					bgGhouls.dance(true);
					bgGhouls.visible = true;
				}

			case 'Play Animation':
				// trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch (value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if (Math.isNaN(val2))
							val2 = 0;

						switch (val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null) {
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				if (cameraFollow != null) {
					var val1:Float = Std.parseFloat(value1);
					var val2:Float = Std.parseFloat(value2);
					if (Math.isNaN(val1))
						val1 = 0;
					if (Math.isNaN(val2))
						val2 = 0;

					isCameraOnForcedPosition = false;
					if (!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
						cameraFollow.x = val1;
						cameraFollow.y = val2;
						isCameraOnForcedPosition = true;
					}
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch (value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if (Math.isNaN(val))
							val = 0;

						switch (val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null) {
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if (split[0] != null)
						duration = Std.parseFloat(split[0].trim());
					if (split[1] != null)
						intensity = Std.parseFloat(split[1].trim());
					if (Math.isNaN(duration))
						duration = 0;
					if (Math.isNaN(intensity))
						intensity = 0;

					if (duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}

			case 'Change Character':
				var charType:Int = 0;
				switch (value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if (Math.isNaN(charType)) charType = 0;
				}

				switch (charType) {
					case 0:
						if (boyfriend.curCharacter != value2) {
							if (!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnLuas('boyfriendName', boyfriend.curCharacter);

					case 1:
						if (dad.curCharacter != value2) {
							if (!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if (!dad.curCharacter.startsWith('gf')) {
								if (wasGf && gf != null) {
									gf.visible = true;
								}
							} else if (gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnLuas('dadName', dad.curCharacter);

					case 2:
						if (gf != null) {
							if (gf.curCharacter != value2) {
								if (!gfMap.exists(value2)) {
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnLuas('gfName', gf.curCharacter);
						}
				}
				reloadHealthBarColors();
				reloadTimeBarColors();

			case 'BG Freaks Expression':
				if (bgGirls != null)
					bgGirls.swapDanceType();

			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if (Math.isNaN(val1))
					val1 = 1;
				if (Math.isNaN(val2))
					val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if (val2 <= 0) {
					songSpeed = newValue;
				} else {
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2 / playbackRate, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween) {
							songSpeedTween = null;
						}
					});
				}

			case 'Set Property':
				var killMe:Array<String> = value1.split('.');
				if (killMe.length > 1) {
					FunkinLua.setVarInArray(FunkinLua.getPropertyLoopThingWhatever(killMe, true, true), killMe[killMe.length - 1], value2);
				} else {
					FunkinLua.setVarInArray(this, value1, value2);
				}
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
		callOnHScript('onEvent', [eventName, value1, value2]);

	}

	function moveCameraSection():Void {
		if(SONG.notes[curSection] == null) return;

		if (gf != null && SONG.notes[curSection].gfSection) {
			cameraFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			cameraFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			cameraFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnLuas('onMoveCamera', ['gf']);
			callOnHScript('moveCamera', ['gf']);

			return;
		}
		if (!SONG.notes[curSection].mustHitSection) 
		{
			moveCamera(true);
		} else {
			moveCamera(false);
		}
	}

	var cameraTwn:FlxTween;

	public function moveCamera(isDad:Bool) {
		if (isDad) {
			cameraFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			cameraFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			cameraFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
			tweenCamIn();
		} else {
			cameraFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			cameraFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			cameraFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];

			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1) {
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {
					ease: FlxEase.elasticInOut,
					onComplete: function(twn:FlxTween) {
						cameraTwn = null;
					}
				});
			}
		}
	}

	function tweenCamIn() {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {
				ease: FlxEase.elasticInOut,
				onComplete: function(twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	function snapcameraFollowToPos(x:Float, y:Float) {
		cameraFollow.set(x, y);
		cameraFollowPosition.setPosition(x, y);
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void {
		var finishCallback:Void->Void = endSong; // In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if (ClientPrefs.noteOffset <= 0 || ignoreNoteOffset) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}

	public var transitioning = false;
	public function endSong():Void {
		// Should kill you if you tried to cheat
		if (!startingSong) {
			notes.forEach(function(daNote:Note) {
				if (daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if (daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			}

			if (doDeathCheck()) {
				return;
			}
		}

		    #if android
		    androidControls.visible = false;
		    #end
		    timeBar.visible = false;
		    timeBarBG.visible = false;
		    timeTxt.visible = false;
		    canPause = false;
		    endingSong = true;
		    camZooming = false;
		    inCutscene = false;
		    updateTime = false;

		    deathCounter = 0;
		    seenCutscene = false;

		var ret:Dynamic = callOnLuas('onEndSong', [], false);
		var retHX:Dynamic = callOnHScript('endSong', [], false);

		if ((ret != FunkinLua.Function_Stop || retHX != FunkinLua.Function_Stop) && !transitioning) {
			if (SONG.validScore) {
				#if !switch
				var percent:Float = ratingPercent;
				if (Math.isNaN(percent))
					percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyModeDifficulty, percent);
				Highscore.saveMiss(SONG.song, songMisses, storyModeDifficulty);
				#end
			}
			playbackRate = 1;

			if (chartingMode) {
				openChartEditor();
				return;
			}

			if (isStoryMode) {
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0) {
					WeekData.loadTheFirstEnabledMod();
					FlxG.sound.playMusic(Paths.music('freakyMenu-' + ClientPrefs.mainMenuMusic));

					cancelMusicFadeTween();
					if (FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
					if (ClientPrefs.resultsScreen)
						openSubState(new ResultsScreenSubState([sicks, goods, bads, freaks], campaignScore, songMisses,
							Highscore.floorDecimal(ratingPercent * 100, 2), ratingName + (' [' + ratingFC + '] ')));
					else
						MusicBeatState.switchState(new StoryModeState());
					    Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Story Mode";

					if (!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false)) {
						StoryModeState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore) {
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyModeDifficulty);
						}

						FlxG.save.data.weekCompleted = StoryModeState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				} else {
					var difficulty:String = CoolUtil.getDifficultyFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					var winterHorrorlandNext = (Paths.formatToSongPath(SONG.song) == "eggnog");
					if (winterHorrorlandNext) {
						var blackfreak:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackfreak.scrollFactor.set();
						add(blackfreak);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevcameraFollow = cameraFollow;
					prevcameraFollowPosition = cameraFollowPosition;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					if (winterHorrorlandNext) {
						new FlxTimer().start(1.5, function(tmr:FlxTimer) {
							cancelMusicFadeTween();
							LoadingState.loadAndSwitchState(new PlayState());
							Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Current song: " + PlayState.SONG.song + " (" + CoolUtil.difficulties[storyModeDifficulty] + ") ";
						});
					} else {
						cancelMusicFadeTween();
						LoadingState.loadAndSwitchState(new PlayState());
						Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Current song: " + PlayState.SONG.song + " (" + CoolUtil.difficulties[storyModeDifficulty] + ") ";
					}
				}
			} else {
				trace('WENT BACK TO FREEPLAY??');
				WeekData.loadTheFirstEnabledMod();
				cancelMusicFadeTween();
				if (FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}
				if (ClientPrefs.resultsScreen)
					openSubState(new ResultsScreenSubState([sicks, goods, bads, freaks], songScore, songMisses, Highscore.floorDecimal(ratingPercent * 100, 2),
						ratingName + (' [' + ratingFC + '] ')));
				else
				MusicBeatState.switchState(new FreeplayState());
				Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Freeplay Menu";
				FlxG.sound.playMusic(Paths.music('freakyMenu-' + ClientPrefs.mainMenuMusic));
				changedDifficulty = false;
			    }
			transitioning = true;
		}
	}

	public function KillNotes() {
		while (notes.length > 0) {
			var daNote:Note = notes.members[0];
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotes:Float = 0;
	public var showCombo:Bool = true;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;
	public var showMissedCombo:Bool = true;

	private function cachePopUpScore() {
		var pixelfreakPart1:String = '';
		var pixelfreakPart2:String = '';
		if (isPixelStage) {
			pixelfreakPart1 = 'pixelUI/';
			pixelfreakPart2 = '-pixel';
		}

		Paths.image(pixelfreakPart1 + "sick" + pixelfreakPart2);
		Paths.image(pixelfreakPart1 + "good" + pixelfreakPart2);
		Paths.image(pixelfreakPart1 + "bad" + pixelfreakPart2);
		Paths.image(pixelfreakPart1 + "freak" + pixelfreakPart2);
		Paths.image(pixelfreakPart1 + "combo" + pixelfreakPart2);

		for (i in 0...10) {
			Paths.image(pixelfreakPart1 + 'num' + i + pixelfreakPart2);
		}
	}

	private function popUpScore(note:Note = null):Void {
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
		vocals.volume = vocalsFinished ? 0 : 1;
		allNotesMs += noteDiff;
		averageMs = allNotesMs / songHits;
		if (ClientPrefs.averageMiliseconds) {
			msScoreLabel.alpha = 1;
		    msScoreLabel.text = Std.string(Math.round(noteDiff)) + "ms";
		    if (msScoreLabelTween != null) {
			    msScoreLabelTween.cancel(); msScoreLabelTween.destroy(); // top 10 awesome code
		    }
			    msScoreLabelTween = FlxTween.tween(msScoreLabel, {alpha: 0}, 0.25, {
			    onComplete: function(tw:FlxTween) {msScoreLabelTween = null;}, startDelay: 0.7
		    });
			if (noteDiff >= ClientPrefs.impressiveWindow) msScoreLabel.color = FlxColor.BLUE;
		    if (noteDiff >= ClientPrefs.sickWindow) msScoreLabel.color = FlxColor.LIME;
		    if (noteDiff >= ClientPrefs.goodWindow) msScoreLabel.color = FlxColor.ORANGE;
		    if (noteDiff >= ClientPrefs.badWindow) msScoreLabel.color = FlxColor.RED;
		}

		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;

		if (ClientPrefs.scoreZoom && !cpuControlled) {
			if (scoreTxtTween != null) {
				scoreTxtTween.cancel();
			}
			scoreTxt.scale.x = scoreTxt.scale.y = 1.075;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween) {
					scoreTxtTween = null;
				}
			});
		}

		if (ClientPrefs.judgementZoom && !cpuControlled) {
			if (judgementCounterTxtTween != null) {
				judgementCounterTxtTween.cancel();
			}
			judgementCounterTxt.scale.x = judgementCounterTxt.scale.y = 1.075;
			judgementCounterTxtTween = FlxTween.tween(judgementCounterTxt.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween) {
					judgementCounterTxtTween = null;
				}
			});
		}

		var rating:FlxSprite = new FlxSprite();
		var comboSpr:FlxSprite = new FlxSprite();
		var score:Int = 350;

		// tryna do MS based judgment due to popular demand
		var daRating:Rating = Conductor.judgeNote(ratingsData, noteDiff / playbackRate);

		totalNotes += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if (!note.ratingDisabled)
			daRating.increase();
		note.rating = daRating.name;
		score = daRating.score;

		if (daRating.noteSplash && !note.noteSplashDisabled) {
			spawnNoteSplashOnNote(note);
		}

		if (!practiceMode && !cpuControlled) {
			songScore += score;
			if (!note.ratingDisabled) {
				songHits++;
				totalPlayed++;
				recalculateRating(false);
			}
		}

		var pixelfreakPart1:String = "";
		var pixelfreakPart2:String = '';

		if (PlayState.isPixelStage) {
			pixelfreakPart1 = 'pixelUI/';
			pixelfreakPart2 = '-pixel';
		}

		if ((!ClientPrefs.ratingImages || ClientPrefs.comboStacking) && !cpuControlled) {
			rating.loadGraphic(Paths.image(pixelfreakPart1 + daRating.image + pixelfreakPart2));
		    rating.cameras = [camHUD];
		    rating.screenCenter();
		    rating.x = coolText.x - 40;
		    rating.y -= 60;
		    rating.acceleration.y = 550 * playbackRate * playbackRate;
		    rating.velocity.y -= FlxG.random.int(140, 175) * playbackRate;
		    rating.velocity.x -= FlxG.random.int(0, 10) * playbackRate;
		    rating.visible = (!ClientPrefs.hideHud && showRating);
		    rating.x += ClientPrefs.comboOffset[0];
		    rating.y -= ClientPrefs.comboOffset[1];

			comboSpr.loadGraphic(Paths.image(pixelfreakPart1 + 'combo' + pixelfreakPart2));
		    comboSpr.cameras = [camHUD];
		    comboSpr.screenCenter();
		    comboSpr.x = coolText.x;
		    comboSpr.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
		    comboSpr.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
		    comboSpr.visible = (!ClientPrefs.hideHud && showCombo);
		    comboSpr.x += ClientPrefs.comboOffset[0];
		    comboSpr.y -= ClientPrefs.comboOffset[1];
		    comboSpr.y += 60;
		    comboSpr.velocity.x += FlxG.random.int(1, 10) * playbackRate;
		}

		insert(members.indexOf(strumLineNotes), rating);

		if (!ClientPrefs.comboStacking) {
			if (lastRating != null)
				lastRating.kill();
			lastRating = rating;
		}

		if (!PlayState.isPixelStage) {
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		} else {
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		var daLoop:Int = 0;
		var xThing:Float = 0;
		if (showCombo) {
			insert(members.indexOf(strumLineNotes), comboSpr);
		}
		if (!ClientPrefs.comboStacking) {
			if (lastCombo != null)
				lastCombo.kill();
			lastCombo = comboSpr;
		}
		if (lastScore != null) {
			while (lastScore.length > 0) {
				lastScore[0].kill();
				lastScore.remove(lastScore[0]);
			}
		}

		for (i in seperatedScore) {
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelfreakPart1 + 'num' + Std.int(i) + pixelfreakPart2));
			numScore.cameras = [camHUD];
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			numScore.x += ClientPrefs.comboOffset[2];
			numScore.y -= ClientPrefs.comboOffset[3];

			if (!ClientPrefs.comboStacking)
				lastScore.push(numScore);

			if (!PlayState.isPixelStage) {
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			} else {
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
			numScore.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
			numScore.velocity.x = FlxG.random.float(-5, 5) * playbackRate;
			numScore.visible = !ClientPrefs.ratingImages || !ClientPrefs.hideHud;

			if (showComboNum)
				insert(members.indexOf(strumLineNotes), numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2 / playbackRate, {
				onComplete: function(tween:FlxTween) {
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002 / playbackRate
			});

			daLoop++;
			if (numScore.x > xThing)
				xThing = numScore.x;
		}

		/* var seperatedMissedScore:Array<Int> = [];
		if (missCombo >= 1000) {
			seperatedMissedScore.push(Math.floor(missCombo / 1000) % 10);
		}
		if (missCombo >= 10000) {
			seperatedMissedScore.push(Math.floor(missCombo / 10000) % 10);
		}
		if (missCombo >= 100000) {
			seperatedMissedScore.push(Math.floor(missCombo / 100000) % 10);
		}
		if (missCombo >= 1000000) {
			seperatedMissedScore.push(Math.floor(missCombo / 1000000) % 10);
		}
		seperatedMissedScore.push(Math.floor(missCombo / 100) % 10);
		seperatedMissedScore.push(Math.floor(missCombo / 10) % 10);
		seperatedMissedScore.push(missCombo % 10);

		for (i in seperatedMissedScore) {
			Paths.image(pixelfreakPart1 + "missedCombo" + pixelfreakPart2);
			var missedPlacement:String = Std.string(missCombo);
			var missedCoolText:FlxText = new FlxText(0, 0, 0, missedPlacement, 32);
			missedCoolText.screenCenter();
			missedCoolText.x = FlxG.width * 0.45;

			var missComboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelfreakPart1 + 'missedCombo' + pixelfreakPart2));
		    missComboSpr.cameras = [camHUD];
		    missComboSpr.screenCenter();
		    missComboSpr.x = coolText.x;

			if (!PlayState.isPixelStage) {
				missComboSpr.setGraphicSize(Std.int(missComboSpr.width * 0.7));
				missComboSpr.antialiasing = ClientPrefs.globalAntialiasing;
			} else {
				missComboSpr.setGraphicSize(Std.int(missComboSpr.width * daPixelZoom * 0.85));
			}
			missComboSpr.updateHitbox();

		    missComboSpr.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
		    missComboSpr.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
		    missComboSpr.visible = (!ClientPrefs.hideHud && showMissedCombo);

		    missComboSpr.x += ClientPrefs.comboOffset[0];
		    missComboSpr.y -= ClientPrefs.comboOffset[1];

			if (!ClientPrefs.missedComboStacking) {
				if (lastMissedCombo != null)
					lastMissedCombo.kill();
				lastMissedCombo = missComboSpr;
			}

		    missComboSpr.y += 60;
		    missComboSpr.velocity.x += FlxG.random.int(1, 10) * playbackRate;

			if (showMissedCombo) {
				insert(members.indexOf(strumLineNotes), missComboSpr);
			}

			FlxTween.tween(missComboSpr, {alpha: 0}, 0.3 / playbackRate, {
				onComplete: function(tween:FlxTween) {
					missedCoolText.destroy();
					missComboSpr.destroy();
	
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.003 / playbackRate
			});

			missComboSpr.x = xThing + 55;
			missedCoolText.text = Std.string(seperatedMissedScore);
		} */ // DIsabled and unfixable if i don't find the solution!

		comboSpr.x = xThing + 50;
		coolText.text = Std.string(seperatedScore);

		FlxTween.tween(rating, {alpha: 0}, 0.2 / playbackRate, {
			startDelay: Conductor.crochet * 0.001 / playbackRate
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2 / playbackRate, {
			onComplete: function(tween:FlxTween) {
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.002 / playbackRate
		});
	}

	public var strumsBlocked:Array<Bool> = [];

	private function onKeyPress(event:KeyboardEvent):Void {
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		// trace('Pressed: ' + eventKey);

		if (!cpuControlled && startedCountdown && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode)) {
			if (!boyfriend.stunned && generatedMusic && !endingSong) {
				// more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				// var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note) {
					if (strumsBlocked[daNote.noteData] != true
						&& daNote.canBeHit
						&& daNote.mustPress
						&& !daNote.tooLate
						&& !daNote.wasGoodHit
						&& !daNote.isSustainNote
						&& !daNote.blockHit) {
						if (daNote.noteData == key) {
							sortedNotesList.push(daNote);
							// notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort(sortHitNotes);

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList) {
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}

						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}
					}
				} else {
					callOnLuas('onGhostTap', [key]);
					callOnHScript('ghostTap', [key]);

					if (canMiss) {
						noteMissPress(key);
					}
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				// Shubs, this is for the "Just the Two of Us" achievement lol
				//									- Shadow Mario
				keysPressed[key] = true;

				// more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if (strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm') {
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyPress', [key]);
			callOnHScript('keyPress', [key]);

		}
		// trace('pressed: ' + controlArray);
	}

	function sortHitNotes(a:Note, b:Note):Int {
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void {
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if (!cpuControlled && startedCountdown && !paused && key > -1) {
			var spr:StrumNote = playerStrums.members[key];
			if (spr != null) {
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyRelease', [key]);
			callOnHScript('keyRelease', [key]);

		}
		// trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int {
		if (key != NONE) {
			for (i in 0...keysArray.length) {
				for (j in 0...keysArray[i].length) {
					if (key == keysArray[i][j]) {
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyfreak():Void {
		// HOLDING
		var parsedHoldArray:Array<Bool> = parseKeys();

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if (ClientPrefs.controllerMode) {
			var parsedArray:Array<Bool> = parseKeys('_P');
			if (parsedArray.contains(true)) {
				for (i in 0...parsedArray.length) {
					if (parsedArray[i] && strumsBlocked[i] != true)
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (startedCountdown && !boyfriend.stunned && generatedMusic) {
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note) {
				// hold note functions
				if (strumsBlocked[daNote.noteData] != true
					&& daNote.isSustainNote
					&& parsedHoldArray[daNote.noteData]
					&& daNote.canBeHit
					&& daNote.mustPress
					&& !daNote.tooLate
					&& !daNote.wasGoodHit
					&& !daNote.blockHit) {
					goodNoteHit(daNote);
				}
			});

			if (!parsedHoldArray.contains(true) || endingSong)
			{
				if (boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				{
					boyfriend.dance();
				}
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if (ClientPrefs.controllerMode || strumsBlocked.contains(true)) {
			var parsedArray:Array<Bool> = parseKeys('_R');
			if (parsedArray.contains(true)) {
				for (i in 0...parsedArray.length) {
					if (parsedArray[i] || strumsBlocked[i] == true)
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	private function parseKeys(?suffix:String = ''):Array<Bool> {
		var ret:Array<Bool> = [];
		for (i in 0...controlArray.length) {
			ret[i] = Reflect.getProperty(controls, controlArray[i] + suffix);
		}
		return ret;
	}

	function noteMiss(daNote:Note):Void { // You didn't hit the key and let it go offscreen, also used by Hurt Notes
		// Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note
				&& daNote.mustPress
				&& daNote.noteData == note.noteData
				&& daNote.isSustainNote == note.isSustainNote
				&& Math.abs(daNote.strumTime - note.strumTime) < 1) {
				notes.remove(note, true);
				note.destroy();
			}
		});
		combo = 0;
		missCombo = 1;
		if (ClientPrefs.healthTween) {
			healthTween(-daNote.missHealth * healthLoss * missCombo);
		} else {
			health -= daNote.missHealth * healthLoss * missCombo;
		}

		if (instakillOnMiss) {
			vocals.volume = 0;
			doDeathCheck(true);
		}

		// For testing purposes
		// trace(daNote.missHealth);
		songMisses++;
		if(ClientPrefs.missSound) {
        	FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), 0.07);
			vocals.volume = 0; 
		}
		if (!practiceMode)
			songScore -= 10;

		totalPlayed++;
		recalculateRating(true);

		var char:Character = boyfriend;
		if (daNote.gfNote) {
			char = gf;
		}

		if (char != null && !daNote.noMissAnimation && char.hasMissAnimations) {
			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daNote.animSuffix;
			char.playAnim(animToPlay, true);
		}

		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
		callOnHScript('noteMiss', [daNote]);

	}

	function noteMissPress(direction:Int = 1):Void // You pressed a key when there was no notes to press for this key
	{
		if (ClientPrefs.ghostTapping)
			return; // freak it

		if (!boyfriend.stunned) {
			if (ClientPrefs.healthTween) {
				healthTween(-0.05 * healthLoss);
			} else {
				health -= 0.05 * healthLoss;
			}
			if (instakillOnMiss) {
				vocals.volume = 0;
				doDeathCheck(true);
			}

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad')) {
				gf.playAnim('sad');
			}
			combo = 0;
			missCombo = 1;

			if (!practiceMode)
				songScore -= 10;
			if (!endingSong) {
				songMisses++;
			}
			totalPlayed++;
			recalculateRating(true);

			if (ClientPrefs.missSound)
				FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.3, 0.4));

			if (boyfriend.hasMissAnimations) {
				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			if (ClientPrefs.missSound)
				vocals.volume = 0;
		}
		callOnLuas('noteMissPress', [direction]);
		callOnHScript('noteMissPress', [direction]);

	}

	function opponentNoteHit(note:Note):Void {
		if (Paths.formatToSongPath(SONG.song) != 'tutorial')
			camZooming = true;

		if (note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if (!note.noAnimation) {
			var altAnim:String = note.animSuffix;

			if (SONG.notes[curSection] != null) {
				if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection) {
					altAnim = '-alt';
				}
			}

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
			if (note.gfNote) {
				char = gf;
			}
			if (notesCanMoveCamera) {
				if(SONG.notes[Math.floor(curStep / 16)].mustHitSection == false && !note.isSustainNote)
					{
						if (!dad.stunned)
							{
								switch(Std.int(Math.abs(note.noteData)))
								{
									case 0:
										cameraFollow.set(dad.getMidpoint().x + 170, dad.getMidpoint().y - 140);
										cameraFollow.x += dad.cameraPosition[0] - cameraMovemtableOffset; cameraFollow.y += dad.cameraPosition[1];
									case 1:
										cameraFollow.set(dad.getMidpoint().x + 170, dad.getMidpoint().y - 140);
										cameraFollow.x += dad.cameraPosition[0]; cameraFollow.y += dad.cameraPosition[1] + cameraMovemtableOffset;
									case 2:
										cameraFollow.set(dad.getMidpoint().x + 170, dad.getMidpoint().y - 140);
										cameraFollow.x += dad.cameraPosition[0]; cameraFollow.y += dad.cameraPosition[1] - cameraMovemtableOffset;
									case 3:							
										cameraFollow.set(dad.getMidpoint().x + 170, dad.getMidpoint().y - 140);
										cameraFollow.x += dad.cameraPosition[0] + cameraMovemtableOffset; cameraFollow.y += dad.cameraPosition[1];
								}                   
							}
					} 
			}

			if (char != null) {
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}
		}

		if (SONG.needsVoices)
			vocals.volume = vocalsFinished ? 0 : 1;

		var time:Float = 0.15;
		if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
			time += 0.15;
		}
		if (ClientPrefs.opponentArrowGlow) {
			StrumPlayAnim(true, Std.int(Math.abs(note.noteData)), time);
		}
		note.hitByOpponent = true;

		callOnHScript('opponentNoteHit', [note]);
		callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);

		if (!note.isSustainNote) {
			notes.remove(note, true);
			note.destroy();
		}
	}

	function goodNoteHit(note:Note):Void {
		if (!note.isSustainNote)
			notesHitArray.push(Date.now());

		if (!note.wasGoodHit) {
			if (cpuControlled && (note.ignoreNote || note.hitCausesMiss))
				return;

			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled) {
				FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
			}

			if (note.hitCausesMiss) {
				noteMiss(note);
				if (!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(note);
				}

				if (!note.noMissAnimation) {
					switch (note.noteType) {
						case 'Hurt Note': // Hurt note
							if (boyfriend.animation.getByName('hurt') != null) {
								boyfriend.playAnim('hurt', true);
								boyfriend.specialAnim = true;
							}
					}
				}

				note.wasGoodHit = true;
				if (!note.isSustainNote) {
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote && !cpuControlled)
			{
				combo += 1;
				missCombo = 0;
				notesHitArray.unshift(Date.now());
				popUpScore(note);
			}
			if (!note.isSustainNote && !cpuControlled && !ClientPrefs.lessCpuController)
			{
				songScore += 350;
				combo += 1;
				missCombo = 0;
				notesHitArray.unshift(Date.now());
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(note);
				}
			}
			if (!note.isSustainNote && !cpuControlled && ClientPrefs.lessCpuController) {
				if(combo >= maxCombo)
                	maxCombo += 1;
				combo += 1;
				missCombo = 0;
				popUpScore(note);

				if(combo > 9999)
					combo = 9999;
			}
			if (ClientPrefs.healthTween) {
				healthTween(note.hitHealth * healthGain);
			} else {
				health += note.hitHealth * healthGain;
			}

			if (!note.noAnimation) {
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];

				if (note.gfNote) {
					if (gf != null) {
						gf.playAnim(animToPlay + note.animSuffix, true);
						gf.holdTimer = 0;
					}
				} else {
					boyfriend.playAnim(animToPlay + note.animSuffix, true);
					boyfriend.holdTimer = 0;

					if (notesCanMoveCamera) {
						if(SONG.notes[Math.floor(curStep / 16)].mustHitSection == true && !note.isSustainNote){
							if (!boyfriend.stunned){
								switch(Std.int(Math.abs(note.noteData))){				 
									case 0:
										cameraFollow.set(boyfriend.getMidpoint().x - 170, boyfriend.getMidpoint().y - 140);
										cameraFollow.x += boyfriend.cameraPosition[0] - cameraMovemtableOffsetBoyfriend; cameraFollow.y += boyfriend.cameraPosition[1];	
									case 1:
										cameraFollow.set(boyfriend.getMidpoint().x - 170, boyfriend.getMidpoint().y - 140);
										cameraFollow.x += boyfriend.cameraPosition[0]; cameraFollow.y += boyfriend.cameraPosition[1] + cameraMovemtableOffsetBoyfriend;			
									case 2:
										cameraFollow.set(boyfriend.getMidpoint().x - 170, boyfriend.getMidpoint().y - 140);
										cameraFollow.x += boyfriend.cameraPosition[0]; cameraFollow.y += boyfriend.cameraPosition[1] - cameraMovemtableOffsetBoyfriend;
									case 3:							
										cameraFollow.set(boyfriend.getMidpoint().x - 170, boyfriend.getMidpoint().y - 140);
										cameraFollow.x += boyfriend.cameraPosition[0] + cameraMovemtableOffsetBoyfriend; cameraFollow.y += boyfriend.cameraPosition[1];			
								}                        
							}
						}
					}
				}

				if (note.noteType == 'Hey!') {
					if (boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}

					if (gf != null && gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if (cpuControlled) {
				var time:Float = 0.15;
				if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)), time);
			} else {
				var spr = playerStrums.members[note.noteData];
				if (spr != null) {
					spr.playAnim('confirm', true);
				}
			}
			note.wasGoodHit = true;
			vocals.volume = vocalsFinished ? 0 : 1;
	
			var isSus:Bool = note.isSustainNote; // GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);
			callOnHScript('goodNoteHit', [note]);

			if (!note.isSustainNote) {
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	public function spawnNoteSplashOnNote(note:Note) {
		if (ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if (strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		if (PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0)
			skin = PlayState.SONG.splashSkin;

		var hue:Float = 0;
		var sat:Float = 0;
		var brt:Float = 0;
		if (data > -1 && data < ClientPrefs.arrowHSV.length) {
			hue = ClientPrefs.arrowHSV[data][0] / 360;
			sat = ClientPrefs.arrowHSV[data][1] / 100;
			brt = ClientPrefs.arrowHSV[data][2] / 100;
			if (note != null) {
				skin = note.noteSplashTexture;
				hue = note.noteSplashHue;
				sat = note.noteSplashSat;
				brt = note.noteSplashBrt;
			}
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void {
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	var carTimer:FlxTimer;

	function fastCarDrive() {
		// trace('Car drive');
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		carTimer = new FlxTimer().start(2, function(tmr:FlxTimer) {
			resetFastCar();
			carTimer = null;
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;
	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void {
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void {
		if (trainSound.time >= 4700) {
			startedMoving = true;
			if (gf != null) {
				gf.playAnim('hairBlow');
				gf.specialAnim = true;
			}
		}

		if (startedMoving) {
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing) {
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void {
		if (gf != null) {
			gf.danced = false; // Sets head to the correct position once the animation ends
			gf.playAnim('hairFall');
			gf.specialAnim = true;
		}
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikefreak():Void {
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		if (!ClientPrefs.lowQuality)
			halloweenBG.animation.play('halloweem bg lightning strike');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if (boyfriend.animOffsets.exists('scared')) {
			boyfriend.playAnim('scared', true);
		}

		if (gf != null && gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
		}

		if (ClientPrefs.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if (!camZooming) { // Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}

		if (ClientPrefs.flashing) {
			halloweenWhite.alpha = 0.4;
			FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}

	function killHenchmen():Void {
		if (!ClientPrefs.lowQuality && ClientPrefs.violence && currentlyStage == 'limo') {
			if (limoKillingState < 1) {
				limoMetalPole.x = -400;
				limoMetalPole.visible = true;
				limoLight.visible = true;
				limoCorpse.visible = false;
				limoCorpseTwo.visible = false;
				limoKillingState = 1;
			}
		}
	}

	function resetLimoKill():Void {
		if (currentlyStage == 'limo') {
			limoMetalPole.x = -500;
			limoMetalPole.visible = false;
			limoLight.x = -500;
			limoLight.visible = false;
			limoCorpse.x = -500;
			limoCorpse.visible = false;
			limoCorpseTwo.x = -500;
			limoCorpseTwo.visible = false;
		}
	}

	var tankX:Float = 400;
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankAngle:Float = FlxG.random.int(-90, 45);

	function moveTank(?elapsed:Float = 0):Void {
		if (!inCutscene) {
			tankAngle += elapsed * tankSpeed;
			tankGround.angle = tankAngle - 90 + 15;
			tankGround.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
			tankGround.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
		}
	}

	override function destroy() {
		for (lua in luaArray) {
			lua.call('onDestroy', []);
			lua.stop();
		}
		luaArray = [];

		for (haxe in hscriptArray)
			{
				haxe.destroy();
			}
			hscriptArray = [];
	
		if (!ClientPrefs.controllerMode) {
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		FlxAnimationController.globalSpeed = 1;
		FlxG.sound.music.pitch = 1;
		super.destroy();
	}

	public static function cancelMusicFadeTween() {
		if (FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	var lastStepHit:Int = -1;

	override function stepHit() {
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate))) {
			resyncVocals();
		}

		if (curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		setOnHScript('curStep', curStep);
		callOnLuas('onStepHit', []);
		callOnHScript('stepHit', []);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	var lastBeatHit:Int = -1;

	override function beatHit() {
		super.beatHit();

		if (lastBeatHit >= curBeat) {
			// trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (curBeat % 32 == 0 && loopMode)
		{
			var randomLoopFloat = FlxMath.roundDecimal(FlxG.random.float(0.4, 3), 2);
			lerpSongSpeed(randomLoopFloat, 1);
		}

		if (generatedMusic) {
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		if (!sbEngineIconBounce) {
			iconP1.scale.set(1.2, 1.2);
			iconP2.scale.set(1.2, 1.2);
			
			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}


		if (sbEngineIconBounce) {
			if (curBeat % gfSpeed == 0) {
				if (curBeat % (gfSpeed * 2) == 0) {
					iconP1.scale.set(0.8, 0.8);
					iconP2.scale.set(1.2, 1.3);
					
					iconP1.angle = -15;
					iconP2.angle = 15;
				} else {
					iconP2.scale.set(0.8, 0.8);
					iconP1.scale.set(1.2, 1.3);
					
					iconP2.angle = -15;
					iconP1.angle = 15;
				}
			}
		}

		if (gf != null
			&& curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0
			&& gf.animation.curAnim != null
			&& !gf.animation.curAnim.name.startsWith("sing")
			&& !gf.stunned) {
			gf.dance();
		}
		if (curBeat % boyfriend.danceEveryNumBeats == 0
			&& boyfriend.animation.curAnim != null
			&& !boyfriend.animation.curAnim.name.startsWith('sing')
			&& !boyfriend.stunned) {
			boyfriend.dance();
		}
		if (curBeat % dad.danceEveryNumBeats == 0
			&& dad.animation.curAnim != null
			&& !dad.animation.curAnim.name.startsWith('sing')
			&& !dad.stunned) {
			dad.dance();
		}

		switch (currentlyStage) {
			case 'tank':
				if (!ClientPrefs.lowQuality)
					tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BGSprite) {
					spr.dance();
				});

			case 'school':
				if (!ClientPrefs.lowQuality) {
					bgGirls.dance();
				}

			case 'mall':
				if (!ClientPrefs.lowQuality) {
					upperBoppers.dance(true);
				}

				if (heyTimer <= 0)
					bottomBoppers.dance(true);
				santa.dance(true);

			case 'limo':
				if (!ClientPrefs.lowQuality) {
					grpLimoDancers.forEach(function(dancer:BackgroundDancer) {
						dancer.dance();
					});
				}

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0) {
					curLight = FlxG.random.int(0, phillyLightsColors.length - 1, [curLight]);
					phillyWindow.color = phillyLightsColors[curLight];
					phillyWindow.alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8 && !trainSound.playing) {
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (currentlyStage == 'spooky' && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset) {
			lightningStrikefreak();
		}
		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat); // DAWGG?????
		setOnHScript('curBeat', curBeat); //DAWGG?????
		callOnLuas('onBeatHit', []);
		callOnHScript('beatHit', []);

	}

	override function sectionHit() {
		super.sectionHit();

		if (SONG.notes[curSection] != null) {
			if (generatedMusic && !endingSong && !isCameraOnForcedPosition) {
				moveCameraSection();
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms) {
				FlxG.camera.zoom += 0.015 * camZoomingMult;
				camHUD.zoom += 0.03 * camZoomingMult;
			}

			if (SONG.notes[curSection].changeBPM) {
				Conductor.changeBPM(SONG.notes[curSection].bpm);
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[curSection].mustHitSection);
			setOnLuas('altAnim', SONG.notes[curSection].altAnim);
			setOnLuas('gfSection', SONG.notes[curSection].gfSection);
		}

		setOnLuas('curSection', curSection);
		setOnHScript('curSection', curSection);

		callOnLuas('onSectionHit', []);
		callOnHScript('sectionHit', []);

	}

	#if LUA_ALLOWED
	public function startLuasOnFolder(luaFile:String)
	{
		for (script in luaArray)
		{
			if(script.scriptName == luaFile) return false;
		}

		#if MODS_ALLOWED
		var luaToLoad:String = Paths.modFolders(luaFile);
		if(FileSystem.exists(luaToLoad))
		{
			luaArray.push(new FunkinLua(luaToLoad));
			return true;
		}
		else
		{
			luaToLoad = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
				return true;
			}
		}
		#elseif sys
		var luaToLoad:String = Paths.getPreloadPath(luaFile);
		if(OpenFlAssets.exists(luaToLoad))
		{
			luaArray.push(new FunkinLua(luaToLoad));
			return true;
		}
		#end
		return false;
	}
	#end

	#if HSCRIPT_ALLOWED
	public function startHScriptsNamed(scriptFile:String)
	{
		var scriptToLoad:String = Paths.modFolders(scriptFile);
		if(!FileSystem.exists(scriptToLoad))
			scriptToLoad = SUtil.getPath() + Paths.getPreloadPath(scriptFile);
		
		if(FileSystem.exists(scriptToLoad))
		{
			if (SScript.global.exists(scriptToLoad)) return false;
	
			initHScript(scriptToLoad);
			return true;
		}
		return false;
	}

	public function initHScript(file:String)
	{
		try
		{
			var newScript:HScript = new HScript(null, file);
			@:privateAccess
			if(newScript.parsingExceptions != null && newScript.parsingExceptions.length > 0)
			{
				@:privateAccess
				for (e in newScript.parsingExceptions)
					if(e != null)
				addTextToDebug('ERROR ON LOADING ($file): ${e.message.substr(0, e.message.indexOf('\n'))}', FlxColor.RED);
				newScript.destroy();
				return;
			}

			hscriptArray.push(newScript);
			if(newScript.exists('onCreate'))
			{
				var callValue = newScript.call('onCreate');
				if(!callValue.succeeded)
				{
					for (e in callValue.exceptions)
						if (e != null)
							addTextToDebug('ERROR ($file: onCreate) - ${e.message.substr(0, e.message.indexOf('\n'))}', FlxColor.RED);

					newScript.destroy();
					hscriptArray.remove(newScript);
					trace('failed to initialize sscript interp!!! ($file)');
				}
				else trace('initialized sscript interp successfully: $file');
			}
			
		}
		catch(e)
		{
			addTextToDebug('ERROR ($file) - ' + e.message.substr(0, e.message.indexOf('\n')), FlxColor.RED);
			var newScript:HScript = cast (SScript.global.get(file), HScript);
			if(newScript != null)
			{
				newScript.destroy();
				hscriptArray.remove(newScript);
			}
		}
	}
	#end

	public function callOnLuas(event:String, args:Array<Dynamic>, ignoreStops = true, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic
		{
		var returnVal = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [];

		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			var myValue = script.call(event, args);
			if(myValue == FunkinLua.Function_StopLua && !ignoreStops)
				break;
			
			if(myValue != null && myValue != FunkinLua.Function_Continue) {
				returnVal = myValue;
			}
		}
		#end
		return returnVal;
	}

	public function callOnHScript(funcToCall:String, args:Array<Dynamic> = null, ?ignoreStops:Bool = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic
		{
		var returnVal:Dynamic = FunkinLua.Function_Continue;

		#if HSCRIPT_ALLOWED
		if(exclusions == null) exclusions = new Array();
		if(excludeValues == null) excludeValues = new Array();
		excludeValues.push(FunkinLua.Function_Continue);

		var returnValue:Int = hscriptArray.length;
		if (returnValue < 1)
			return returnVal;

		for(i in 0...returnValue)
		{
			var script:HScript = hscriptArray[i];
			if(script == null || !script.exists(funcToCall) || exclusions.contains(script.origin))
				continue;

			var myValue:Dynamic = null;
			try
			{
				var callValue = script.call(funcToCall, args);
				if(!callValue.succeeded)
				{
					var e = callValue.exceptions[0];
					if(e != null)
						addTextToDebug('ERROR (${script.origin}: ${callValue.calledFunction}) - ' + e.message.substr(0, e.message.indexOf('\n')), FlxColor.RED);
				}
				else
				{
					myValue = callValue.returnValue;
					if((myValue == FunkinLua.Function_StopHScript || myValue == FunkinLua.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
					{
						returnVal = myValue;
						break;
					}
					
					if(myValue != null && !excludeValues.contains(myValue))
						returnVal = myValue;
				}
			}
		}
		return returnVal;
		#end
	}
	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
	}

	public function setOnHScript(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		#if HSCRIPT_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in hscriptArray) {
			if(exclusions.contains(script.origin))
				continue;

			script.set(variable, arg);
		}
		#end
	}
	
	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = isDad ? strumLineNotes.members[id] : playerStrums.members[id];

		if (spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function recalculateRating(badHit:Bool = false) {
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);

		setOnHScript('score', songScore);
		setOnHScript('misses', songMisses);
		setOnHScript('hits', songHits);

		var ret:Dynamic = callOnLuas('onRecalculateRating', [], false);
		var retHX:Dynamic = callOnHScript('recalculateRating', [], false);

		if(ret != FunkinLua.Function_Stop || retHX != FunkinLua.Function_Stop)
		{
			if(totalPlayed < 1) //Prevent divide by 0
				ratingName = '?';
			else
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotes / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				if(ratingPercent >= 1)
				{
					ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				}
				else
				{
					for (i in 0...ratingStuff.length-1)
					{
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
					}
				}
			}

			// Rating FC
			ratingFC = "";
			if (impressives > 0) ratingFC = LanguageHandler.impressiveFCDefaultTxt;
			if (sicks > 0) ratingFC = LanguageHandler.sickFCDefaultTxt;
			if (goods > 0) ratingFC = LanguageHandler.goodFCDefaultTxt;
			if (bads > 0 || freaks > 0) ratingFC = LanguageHandler.badFCDefaultTxt;
			if (songMisses > 0 && songMisses < 10) ratingFC = LanguageHandler.missesFCDefaultTxt;
			else if (songMisses >= 10) ratingFC = LanguageHandler.clearFCDefaultTxt;
			switch (ClientPrefs.gameStyle) {
				case 'Psych Engine':
					if (impressives > 0) ratingFC = LanguageHandler.impressiveFCDefaultTxt;
					if (sicks > 0) ratingFC = LanguageHandler.sickFCDefaultTxt;
					if (goods > 0) ratingFC = LanguageHandler.goodFCDefaultTxt;
					if (bads > 0 || freaks > 0) ratingFC = LanguageHandler.badFCDefaultTxt;
					if (songMisses > 0 && songMisses < 10) ratingFC = LanguageHandler.missesFCDefaultTxt;
					else if (songMisses >= 10) ratingFC = LanguageHandler.clearFCDefaultTxt;
						
				default:
					if (impressives > 0) ratingFC = LanguageHandler.impressiveFCSbTxt;
					if (sicks > 0) ratingFC = LanguageHandler.sickFCSbTxt;
					if (goods > 0) ratingFC = LanguageHandler.goodFCSbTxt;
					if (bads > 0 || freaks > 0) ratingFC = LanguageHandler.badFCSbTxt;
					if (songMisses > 0 && songMisses < 10) ratingFC = LanguageHandler.missesFCSbTxt;
					else if (songMisses >= 10) ratingFC = LanguageHandler.clearFCSbTxt;
			}
		}
		updateScore(badHit);
		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);

		if (ClientPrefs.judgementCounterStyle == 'Original' && ClientPrefs.gameStyle == 'SB Engine') {
			judgementCounterTxt.text = LanguageHandler.impressiveTxt + ${impressives} + LanguageHandler.sickTxt + ${sicks} + LanguageHandler.goodTxt + ${goods} + LanguageHandler.badTxt + ${bads} + LanguageHandler.freakTxt + ${freaks};
		} else if (ClientPrefs.judgementCounterStyle == 'Original' && ClientPrefs.gameStyle == 'Psych Engine') {
			judgementCounterTxt.text = LanguageHandler.impressiveTxt + ${impressives} + LanguageHandler.sickTxt + ${sicks} + LanguageHandler.goodTxt + ${goods} + LanguageHandler.badTxt + ${bads} + LanguageHandler.shitTxt + ${freaks};
		} else if (ClientPrefs.judgementCounterStyle == 'With Misses' && ClientPrefs.gameStyle == 'SB Engine') {
			judgementCounterTxt.text = LanguageHandler.impressiveTxt + ${impressives} + LanguageHandler.sickTxt + ${sicks} + LanguageHandler.goodTxt + ${goods} + LanguageHandler.badTxt + ${bads} + LanguageHandler.freakTxt + ${freaks} + LanguageHandler.comboBreakTxt + ${songMisses};
		} else if (ClientPrefs.judgementCounterStyle == 'With Misses' && ClientPrefs.gameStyle == 'Psych Engine') {
			judgementCounterTxt.text = LanguageHandler.impressiveTxt + ${impressives} + LanguageHandler.sickTxt + ${sicks} + LanguageHandler.goodTxt + ${goods} + LanguageHandler.badTxt + ${bads} + LanguageHandler.shitTxt + ${freaks} + LanguageHandler.songMissesTxt + ${songMisses};
		} else if (ClientPrefs.judgementCounterStyle == 'Better Judge' && ClientPrefs.gameStyle == 'SB Engine') {
			judgementCounterTxt.text = LanguageHandler.totalNoteHitTxt + ${totalNotes} + LanguageHandler.comboTxt + ${combo} + LanguageHandler.maxComboTxt + ${maxCombo} + LanguageHandler.npsJudgeTxt + ${nps} + LanguageHandler.extraImpressiveTxt + ${impressives} + LanguageHandler.sickTxt + ${sicks} + LanguageHandler.goodTxt + ${goods} + LanguageHandler.badTxt + ${bads} + LanguageHandler.freakTxt + ${freaks} + LanguageHandler.comboBreakTxt + ${songMisses};
		} else if (ClientPrefs.judgementCounterStyle == 'Better Judge' && ClientPrefs.gameStyle == 'Psych Engine') {
			judgementCounterTxt.text = LanguageHandler.totalNoteHitTxt + ${totalNotes} + LanguageHandler.comboTxt + ${combo} + LanguageHandler.maxComboTxt + ${maxCombo} +LanguageHandler.npsJudgeTxt + ${nps} + LanguageHandler.extraImpressiveTxt + ${impressives} + LanguageHandler.sickTxt + ${sicks} + LanguageHandler.goodTxt + ${goods} + LanguageHandler.badTxt + ${bads} + LanguageHandler.shitTxt + ${freaks} + LanguageHandler.songMissesTxt + ${songMisses};
		}
		setOnHScript('rating', ratingPercent);
		setOnHScript('ratingName', ratingName);
		setOnHScript('ratingFC', ratingFC);
	}

	function healthTween(amt:Float)
	{
		healthTweenFunction.cancel();
		healthTweenFunction = FlxTween.num(health, health + amt, 0.1, {ease: FlxEase.cubeInOut}, function(v:Float)
		{
			health = v;
		});
	}

	var curLight:Int = -1;
	var curLightEvent:Int = -1;
}
