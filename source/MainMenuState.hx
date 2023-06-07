package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import lime.app.Application;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState {
	public static var sbEngineVersion:String = '2.6.0';
	public static var psychEngineVersion:String = '0.6.2';
	public static var currentlySelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;

	var optionSelect:Array<String> = ['story_mode', 'freeplay', #if MODS_ALLOWED 'mods', #end 'credits', 'options'];

	var background:FlxSprite;
	var purple:FlxSprite;
	var velocityBG:FlxBackdrop;
	var buttonBackground:FlxSprite;
	var sbEngineLogo:FlxSprite;
	var versionSb:FlxText;
	var versionPsych:FlxText;
	var versionFnf:FlxText;
	var debugKeys:Array<FlxKey>;

	var cameraFollow:FlxObject;
	var cameraFollowPosition:FlxObject;

	override function create() {
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();
		if (ClientPrefs.colorblindMode != null)
			ColorblindFilter.applyFiltersOnGame();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();

		FlxG.cameras.reset(camGame);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionSelect.length - 4)), 0.1);
		background = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		background.scrollFactor.set();
		background.setGraphicSize(Std.int(background.width * 1.175));
		background.updateHitbox();
		background.screenCenter();
		background.antialiasing = ClientPrefs.globalAntialiasing;
		add(background);

		purple = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		purple.scrollFactor.set();
		purple.setGraphicSize(Std.int(purple.width * 1.175));
		purple.updateHitbox();
		purple.screenCenter();
		purple.visible = false;
		purple.antialiasing = ClientPrefs.globalAntialiasing;
		purple.color = 0xFF800080;
		add(purple);

		velocityBG = new FlxBackdrop(Paths.image('velocity_background'));
		velocityBG.velocity.set(FlxG.random.bool(50) ? 90 : -90, FlxG.random.bool(50) ? 90 : -90);
		if (ClientPrefs.velocityBackground) {
			velocityBG.visible = true;
		} else {
			velocityBG.visible = false;
		}
		add(velocityBG);

		buttonBackground = new FlxSprite(-120).loadGraphic(Paths.image('buttonBackground'));
		buttonBackground.setGraphicSize(Std.int(background.width * 1.175));
		buttonBackground.updateHitbox();
		buttonBackground.screenCenter();
		buttonBackground.antialiasing = ClientPrefs.globalAntialiasing;
		add(buttonBackground);

		cameraFollow = new FlxObject(0, 0, 1, 1);
		cameraFollowPosition = new FlxObject(0, 0, 1, 1);
		add(cameraFollow);
		add(cameraFollowPosition);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;

		for (i in 0...optionSelect.length) {
			var offset:Float = 108 - (Math.max(optionSelect.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140) + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionSelect[i]);
			menuItem.animation.addByPrefix('idle', optionSelect[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionSelect[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItem.x += 290;
			menuItems.add(menuItem);
			var scr:Float = (optionSelect.length - 4) * 0.135;
			if (optionSelect.length < 6)
				scr = 0;
			menuItem.scrollFactor.set();
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.updateHitbox();
		}

		versionSb = new FlxText(12, FlxG.height - 64, 0, "SB Engine v" + sbEngineVersion + " (Modified Psych Engine)", 16);
		versionSb.scrollFactor.set();
		versionSb.setFormat("Bahnschrift", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionSb);
		versionPsych = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 16);
		versionPsych.scrollFactor.set();
		versionPsych.setFormat("Bahnschrift", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionPsych);
		versionFnf = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 16);
		versionFnf.scrollFactor.set();
		versionFnf.setFormat("Bahnschrift", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionFnf);

		sbEngineLogo = new FlxSprite(-130, 120).loadGraphic(Paths.image('sbEngineLogo'));
		sbEngineLogo.antialiasing = ClientPrefs.globalAntialiasing;
		add(sbEngineLogo);

		FlxTween.angle(sbEngineLogo, sbEngineLogo.angle, -10, 2, {ease: FlxEase.quartInOut});

		new FlxTimer().start(2, function(tmr:FlxTimer) {
			if (sbEngineLogo.angle == -10)
				FlxTween.angle(sbEngineLogo, sbEngineLogo.angle, 10, 2, {ease: FlxEase.quartInOut});
			else
				FlxTween.angle(sbEngineLogo, sbEngineLogo.angle, -10, 2, {ease: FlxEase.quartInOut});
		}, 0);

		changeItem();

		#if android
		addVirtualPad(UP_DOWN, A_B_C);
		virtualPad.y = -48;
		#end

		super.create();
	}

	var selectedSomething:Bool = false;

	override function update(elapsed:Float) {
		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1)); // funny camera

		if (FlxG.sound.music.volume < 0.8) {
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		cameraFollowPosition.setPosition(FlxMath.lerp(cameraFollowPosition.x, cameraFollow.x, lerpVal),
			FlxMath.lerp(cameraFollowPosition.y, cameraFollow.y, lerpVal));

		if (!selectedSomething) {
			if (controls.UI_UP_P) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK) {
				selectedSomething = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT) {
				selectedSomething = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				if (ClientPrefs.flashing)
					FlxFlicker.flicker(purple, 1.1, 0.15, false);

				menuItems.forEach(function(spr:FlxSprite) {
					if (currentlySelected != spr.ID) {
						FlxTween.tween(spr, {x: 1200}, 2, {
							ease: FlxEase.backInOut,
							type: ONESHOT,
							onComplete: function(twn:FlxTween) {
								spr.kill();
							}
						});
						FlxTween.tween(spr, {alpha: 0}, 1.3, {
							ease: FlxEase.backInOut,
							type: ONESHOT,
							onComplete: function(twn:FlxTween) {
								spr.kill();
							}
						});
					} else {
						FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker) {
							var daChoice:String = optionSelect[currentlySelected];

							switch (daChoice) {
								case 'story_mode':
									MusicBeatState.switchState(new StoryMenuState());
								case 'freeplay':
									MusicBeatState.switchState(new FreeplayState());
								#if MODS_ALLOWED
								case 'mods':
									MusicBeatState.switchState(new ModsMenuState());
								#end
								case 'credits':
									MusicBeatState.switchState(new CreditsState());
								case 'options':
									LoadingState.loadAndSwitchState(new options.OptionsState());
							}
						});
					}
				});
			}
			#if (desktop || android)
			else if (FlxG.keys.anyJustPressed(debugKeys) #if android || virtualPad.buttonC.justPressed #end) {
				selectedSomething = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite) {});
	}

	function changeItem(huh:Int = 0) {
		currentlySelected += huh;

		if (currentlySelected >= menuItems.length)
			currentlySelected = 0;
		if (currentlySelected < 0)
			currentlySelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite) {
			spr.animation.play('idle');
			spr.offset.y = 0;
			spr.updateHitbox();

			if (spr.ID == currentlySelected) {
				spr.animation.play('selected');
				spr.offset.x = 0.15 * (spr.frameWidth / 2 + 180);
				spr.offset.y = 0.15 * spr.frameHeight;
				FlxG.log.add(spr.frameWidth);
			}
		});
	}

	override function beatHit() {
		super.beatHit();

		if (FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms && curBeat % 1 == 0) // the funni camera zoom each beat
			FlxG.camera.zoom += 0.015;
	}
}
