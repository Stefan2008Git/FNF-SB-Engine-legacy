package states;

import flixel.addons.effects.FlxTrail;
#if desktop
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.Json;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import options.GraphicsSettingsSubState;
// import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxTimer;
import openfl.Assets;
import lime.app.Application;
import backend.MusicBeatState;
import objects.Alphabet;
import shaders.ColorSwap;
import backend.ClientPrefs;
import backend.Conductor;
import backend.CoolUtil;
import backend.Highscore;
import backend.Paths;
import backend.PlayerSettings;
import backend.WeekData;
import states.MainMenuState;
import states.FreeplayState;
import states.StoryModeState;

using StringTools;

typedef TitleData = {
	titlex:Float,
	titley:Float,
	startx:Float,
	starty:Float,
	gfx:Float,
	gfy:Float,
	backgroundSprite:String,
	bpm:Int
}

class TitleScreenState extends MusicBeatState {
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 1, 0xFF800080);
	var credGroup:FlxGroup;
	var credTextfreak:Alphabet;
	var textGroup:FlxGroup;
	var checker:FlxBackdrop;

	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];

	var Timer:Float = 0;
	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var mustUpdate:Bool = false;

	var titleJSON:TitleData;

	public static var updateVersion:String = '';

	override public function create():Void {
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if LUA_ALLOWED
		Paths.pushGlobalMods();
		#end
		// Just to load a mod on start up if ya got one. For mods that change the menu music and bg
		WeekData.loadTheFirstEnabledMod();

		// trace(path, FileSystem.exists(path));

		/*#if (polymod && !html5)
			if (sys.FileSystem.exists('mods/')) {
				var folders:Array<String> = [];
				for (file in sys.FileSystem.readDirectory('mods/')) {
					var path = haxe.io.Path.join(['mods/', file]);
					if (sys.FileSystem.isDirectory(path)) {
						folders.push(file);
					}
				}
				if(folders.length > 0) {
					polymod.Polymod.init({modRoot: "mods", dirs: folders});
				}
			}
			#end */

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextfreak());

		// DEBUG optionFreak

		swagShader = new ColorSwap();
		super.create();

		FlxG.save.bind('funkin', 'ninjamuffin99');

		ClientPrefs.loadPrefs();

		Highscore.load();

		// IGNORE THIS!!!
		titleJSON = Json.parse(Paths.getTextFromFile('images/gfDanceTitle.json'));

		if (!initialized) {
			if (FlxG.save.data != null && FlxG.save.data.fullscreen) {
				FlxG.fullscreen = FlxG.save.data.fullscreen;
				// trace('LOADED FULLSCREEN SETTING!!');
			}
			persistentUpdate = true;
			persistentDraw = true;
		}

		if (FlxG.save.data.weekCompleted != null) {
			StoryModeState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if (FlxG.save.data.flashing == null && !FlashingScreenState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingScreenState());
		} else {
			if (initialized)
				startIntro();
			else {
				new FlxTimer().start(1, function(tmr:FlxTimer) {
					startIntro();
				});
			}
		}
		#end
	}

	var fridayNightFunkinLogo:FlxSprite;
	var beginTween:FlxTween;
	var fridayNightFunkinLogoTrail:FlxTrail;
	var gfDance:FlxSprite;
	var gfDanceTrail:FlxTrail;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var swagShader:ColorSwap = null;

	function startIntro() {
		if (!initialized) {
			if (FlxG.sound.music == null) {
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			}
		}

		persistentUpdate = true;

		swagShader = new ColorSwap();

		Conductor.changeBPM(titleJSON.bpm);
		persistentUpdate = true;

		var background:FlxSprite = new FlxSprite();

		if (titleJSON.backgroundSprite != null && titleJSON.backgroundSprite.length > 0 && titleJSON.backgroundSprite != "none") {
			background.loadGraphic(Paths.image(titleJSON.backgroundSprite));
			add(background);
		} else {
			background.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			add(background);

			checker = new FlxBackdrop(Paths.image('checker'), XY);
			checker.scrollFactor.set(0.2, 0.2);
			checker.scale.set(0.7, 0.7);
			checker.screenCenter(X);
			checker.velocity.set(FlxG.random.bool(50) ? 90 : -90, FlxG.random.bool(50) ? 90 : -90);
			checker.visible = ClientPrefs.velocityBackground;
			checker.antialiasing = ClientPrefs.globalAntialiasing;
			checker.alpha = 0;
			FlxTween.tween(checker, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
			add(checker);
		}
		add(background);

		fridayNightFunkinLogo = new FlxSprite(titleJSON.titlex, titleJSON.titley);
		fridayNightFunkinLogo.frames = Paths.getSparrowAtlas('logoBumpin');
		fridayNightFunkinLogo.antialiasing = ClientPrefs.globalAntialiasing;
		fridayNightFunkinLogo.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		fridayNightFunkinLogo.animation.play('bump');
		fridayNightFunkinLogo.updateHitbox();
		if (ClientPrefs.objectEffects) {
			fridayNightFunkinLogo.alpha = 0;
			fridayNightFunkinLogo.scale.x = 0;
			fridayNightFunkinLogo.scale.y = 0;
		} else {
			fridayNightFunkinLogo.alpha = 1;
			fridayNightFunkinLogo.scale.x = 1;
			fridayNightFunkinLogo.scale.y = 1;
		}
		add(fridayNightFunkinLogo);
		fridayNightFunkinLogo.shader = swagShader.shader;

		if (ClientPrefs.objectEffects) {
			fridayNightFunkinLogoTrail = new FlxTrail(fridayNightFunkinLogo, 24, 0, 0.4, 0.02);
		} else {
			fridayNightFunkinLogoTrail = new FlxTrail(fridayNightFunkinLogo, 0, 0, 0, 0);
		}
		add(fridayNightFunkinLogoTrail);

		gfDance = new FlxSprite(titleJSON.gfx, titleJSON.gfy);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = ClientPrefs.globalAntialiasing;
		if (ClientPrefs.objectEffects) {
			gfDance.alpha = 0;
			gfDance.scale.x = 0;
			gfDance.scale.y = 0;
		} else {
			gfDance.alpha = 1;
			gfDance.scale.x = 1;
			gfDance.scale.y = 1;
		}
		add(gfDance);
		gfDance.shader = swagShader.shader;

		if (ClientPrefs.objectEffects) {
			gfDanceTrail = new FlxTrail(gfDance, 24, 0, 0.4, 0.02);
		} else {
			gfDanceTrail = new FlxTrail(gfDance, 0, 0, 0, 0);
		}
		add(gfDanceTrail);

		gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00060A4D, 0xFF800080], 2, true);
		gradientBar.y = FlxG.height - gradientBar.height;
		gradientBar.scale.y = 0;
		gradientBar.updateHitbox();
		add(gradientBar);
		FlxTween.tween(gradientBar, {'scale.y': 1.3}, 8, {ease: FlxEase.quadInOut});

		titleText = new FlxSprite(titleJSON.startx, titleJSON.starty);
		#if (desktop || android && MODS_ALLOWED)
		var path = SUtil.getPath() + "mods/" + Paths.currentModDirectory + "/images/titleEnter.png";
		// trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)) {
			path = SUtil.getPath() + "mods/images/titleEnter.png";
		}
		// trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)) {
			path = SUtil.getPath() + "assets/images/titleEnter.png";
		}
		// trace(path, FileSystem.exists(path));
		titleText.frames = FlxAtlasFrames.fromSparrow(BitmapData.fromFile(path), File.getContent(StringTools.replace(path, ".png", ".xml")));
		#else
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		#end
		var animFrames:Array<FlxFrame> = [];
		@:privateAccess {
			titleText.animation.findByPrefix(animFrames, "ENTER IDLE");
			titleText.animation.findByPrefix(animFrames, "ENTER FREEZE");
		}

		if (animFrames.length > 0) {
			newTitle = true;

			titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
			titleText.animation.addByPrefix('press', ClientPrefs.flashing ? "ENTER PRESSED" : "ENTER FREEZE", 24);
		} else {
			newTitle = false;

			titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
			titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		}
		titleText.antialiasing = ClientPrefs.globalAntialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextfreak = new Alphabet(0, 0, "", true);
		credTextfreak.screenCenter();

		credTextfreak.visible = false;

		FlxTween.tween(credTextfreak, {y: credTextfreak.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;
	}

	function getIntroTextfreak():Array<Array<String>> {
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray) {
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	override function update(elapsed:Float) {
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		Timer += 1;
		gradientBar.updateHitbox();
		gradientBar.y = FlxG.height - gradientBar.height;

		if (FlxG.keys.justPressed.ESCAPE #if android || FlxG.android.justReleased.BACK #end) {
			MusicBeatState.switchState(new GameExitState());
		}

		if (FlxG.keys.justPressed.F) {
			FlxG.fullscreen = !FlxG.fullscreen;
		}
		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list) {
			if (touch.justPressed) {
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null) {
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (newTitle) {
			titleTimer += CoolUtil.boundTo(elapsed, 0, 1);
			if (titleTimer > 2)
				titleTimer -= 2;
		}

		// EASTER EGG

		if (initialized && !transitioning && skippedIntro) {
			if (pressedEnter) {
				var timer:Float = titleTimer;
				if (timer >= 1)
					timer = (-timer) + 2;

				timer = FlxEase.quadInOut(timer);

				titleText.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
				titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
			}

			if (pressedEnter) {
				titleText.color = FlxColor.WHITE;
				titleText.alpha = 1;

				if (titleText != null)
					titleText.animation.play('press');

				FlxG.camera.flash(ClientPrefs.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
				FlxTween.tween(fridayNightFunkinLogo, {x: -700}, 2, {
					ease: FlxEase.backInOut,
					type: ONESHOT,
					onComplete: function(twn:FlxTween) fridayNightFunkinLogo.kill()
				});
				FlxTween.tween(fridayNightFunkinLogo, {alpha: 0}, 1.3, {
					ease: FlxEase.backInOut,
					type: ONESHOT,
					onComplete: function(twn:FlxTween) {
						fridayNightFunkinLogo.kill();
					}
				});
				FlxTween.tween(gfDance, {x: 1350}, 2, {
					ease: FlxEase.backInOut,
					type: ONESHOT,
					onComplete: function(twn:FlxTween) gfDance.kill()
				});
				FlxTween.tween(gfDance, {alpha: 0}, 1.3, {
					ease: FlxEase.backInOut,
					type: ONESHOT,
					onComplete: function(twn:FlxTween) {
						gfDance.kill();
					}
				});
				FlxTween.tween(titleText, {y: 700}, 2, {
					ease: FlxEase.backInOut,
					type: ONESHOT,
					onComplete: function(twn:FlxTween) titleText.kill()
				});
				FlxTween.tween(titleText, {alpha: 0}, 1.3, {
					ease: FlxEase.backInOut,
					type: ONESHOT,
					onComplete: function(twn:FlxTween) {
						titleText.kill();
					}
				});
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;

				MainMenuState.firstStart = true;
				MainMenuState.finishedFunnyMove = false;

				if (FlxG.keys.justPressed.ESCAPE #if android || FlxG.android.justReleased.BACK #end) {
					FlxG.sound.play(Paths.sound('cancelMenu'));
					MusicBeatState.switchState(new GameExitState());
					Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Game Exit Menu";
				}

				new FlxTimer().start(1, function(tmr:FlxTimer) {
					if (ClientPrefs.mainMenuStyle == 'Classic')
						MusicBeatState.switchState(new ClassicMainMenuState());
					else {
						MusicBeatState.switchState(new MainMenuState());
					}
					closedState = true;
				});
			}
		}

		if (initialized && pressedEnter && !skippedIntro) {
			skipIntro();
		}

		if (swagShader != null) {
			if (controls.UI_LEFT)
				swagShader.hue -= elapsed * 0.1;
			if (controls.UI_RIGHT)
				swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0) {
		for (i in 0...textArray.length) {
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
			money.screenCenter(X);
			FlxTween.quadMotion(money, -300, -100, 30 + (i * 70), 150 + (i * 130), 100 + (i * 70), 80 + (i * 130), 0.4, true, {ease: FlxEase.quadInOut});
			if (credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0) {
		if (textGroup != null && credGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true);
			coolText.x = -1500;
			FlxTween.quadMotion(coolText, -300, -100, 10
				+ (textGroup.length * 40), 150
				+ (textGroup.length * 130), 30
				+ (textGroup.length * 40),
				80
				+ (textGroup.length * 130), 0.4, true, {
					ease: FlxEase.quadInOut
				});
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText() {
		while (textGroup.members.length > 0) {
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0;

	public static var closedState:Bool = false;

	override function beatHit() {
		super.beatHit();
		if (fridayNightFunkinLogo != null)
			fridayNightFunkinLogo.animation.play('bump', true);

		if (gfDance != null) {
			danceLeft = !danceLeft;
			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}

		if (!closedState) {
			sickBeats++;
			switch (sickBeats) {
				case 1:
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					FlxG.sound.music.fadeIn(4, 0, 0.7);
				case 2:
					createCoolText(['SB Engine by'], 15);
				case 4:
					addMoreText('Stefan2008', 15);
					addMoreText('MaysLastPlay', 15);
					addMoreText('Fearester', 15);
				case 5:
					deleteCoolText();
				case 6:
					createCoolText(['Forked', 'From'], -40);
				case 8:
					addMoreText('Psych Engine v' + MainMenuState.psychEngineVersion, -40);
				case 9:
					deleteCoolText();
				case 10:
					createCoolText([curWacky[0]]);
				case 12:
					addMoreText(curWacky[1]);
				case 13:
					deleteCoolText();
				case 14:
					addMoreText('Friday');
				case 15:
					addMoreText('Night');
				case 16:
					addMoreText('Funkin');
				case 17:
					addMoreText('SB');
				case 18:
					addMoreText('Engine');

				case 19:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;

	function skipIntro():Void {
		if (!skippedIntro) {
			{
				remove(credGroup);
				FlxG.camera.flash(FlxColor.WHITE, 4);
				if (ClientPrefs.objectEffects) {
					FlxTween.tween(fridayNightFunkinLogo, {y: -100}, 1.4, {ease: FlxEase.expoInOut});
				} else {
					FlxTween.tween(fridayNightFunkinLogo, {y: -100}, 1.4, {ease: FlxEase.expoInOut});
				}
				if (ClientPrefs.objectEffects) {
					FlxTween.tween(fridayNightFunkinLogo, {alpha: 1}, 0.75, {ease: FlxEase.quadInOut});
					beginTween = FlxTween.tween(fridayNightFunkinLogo.scale, {x: 1, y: 1}, 0.75, {ease: FlxEase.quadInOut});
					FlxTween.tween(gfDance, {alpha: 1}, 0.75, {ease: FlxEase.quadInOut});
					beginTween = FlxTween.tween(gfDance.scale, {x: 1, y: 1}, 0.75, {ease: FlxEase.quadInOut});
				} else {
					FlxTween.tween(fridayNightFunkinLogo, {alpha: 0}, 0, {ease: FlxEase.quadInOut});
					beginTween = FlxTween.tween(fridayNightFunkinLogo.scale, {x: 0, y: 0}, 0, {ease: FlxEase.quadInOut});
					FlxTween.tween(gfDance, {alpha: 0}, 0, {ease: FlxEase.quadInOut});
					beginTween = FlxTween.tween(gfDance.scale, {x: 0, y: 0}, 0, {ease: FlxEase.quadInOut});
				}

				fridayNightFunkinLogo.angle = -4;

				new FlxTimer().start(0.01, function(tmr:FlxTimer) {
					if (fridayNightFunkinLogo.angle == -4)
						FlxTween.angle(fridayNightFunkinLogo, fridayNightFunkinLogo.angle, 4, 4, {ease: FlxEase.quartInOut});
					if (fridayNightFunkinLogo.angle == 4)
						FlxTween.angle(fridayNightFunkinLogo, fridayNightFunkinLogo.angle, -4, 4, {ease: FlxEase.quartInOut});
				}, 0);
				FlxG.camera.flash(FlxColor.WHITE, 3);
				{
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					FlxG.sound.music.fadeIn(4, 0, 0.7);
					transitioning = false;
				};
			}
		} else {
			remove(credGroup);
			FlxG.camera.flash(FlxColor.WHITE, 4);
		}
		skippedIntro = true;
	}
}
