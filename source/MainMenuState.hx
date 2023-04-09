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
import flixel.util.FlxColor;
import lime.app.Application;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var sbEngineVersion:String = '2.3.0'; //This is also used for Discord RPC
	public static var psychEngineVersion:String = '0.6.2';
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	
	var optionSelect:Array<String> = [
		'story_mode',
		'freeplay',
		'credits',
		'options'
	];

	var orange:FlxSprite;
	var velocityBG:FlxBackdrop;
	var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 300, 0xFF885902);
	var debugKeys:Array<FlxKey>;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

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
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set();
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		orange = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		orange.scrollFactor.set();
		orange.setGraphicSize(Std.int(orange.width * 1.175));
		orange.updateHitbox();
		orange.screenCenter();
		orange.visible = false;
		orange.antialiasing = ClientPrefs.globalAntialiasing;
		orange.color = 0xFFFFA500;
		add(orange);
		
		// orange.scrollFactor.set();

		gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x55AE59E4, 0xFFFFA500], 1, 90, true);
		gradientBar.y = FlxG.height - gradientBar.height;
		add(gradientBar);
		gradientBar.scrollFactor.set(0, 0);

		velocityBG = new FlxBackdrop(Paths.image('velocity_background'));
		velocityBG.velocity.set(50, 50);
		add(velocityBG);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionSelect.length > 6) {
			scale = 6 / optionSelect.length;
		}*/

		for (i in 0...optionSelect.length)
		{
			var offset:Float = 108 - (Math.max(optionSelect.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionSelect[i]);
			menuItem.animation.addByPrefix('idle', optionSelect[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionSelect[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			FlxTween.tween(menuItem, {x: menuItem.width / 4 + (i * 120) - 30}, 1.3, {ease: FlxEase.expoInOut});
			menuItems.add(menuItem);
			var scr:Float = (optionSelect.length - 4) * 0.135;
			if (optionSelect.length < 6)
				scr = 0;
			menuItem.scale.set(0.8, 0.8);
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		}

		var versionSb:FlxText = new FlxText(12, FlxG.height - 64, 0, "SB Engine version: " + sbEngineVersion, 16);
		versionSb.scrollFactor.set();
		versionSb.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionSb);
		var versionPsych:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine version: " + psychEngineVersion, 16);
		versionPsych.scrollFactor.set();
		versionPsych.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionPsych);
		var versionFnf:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' version: " + Application.current.meta.get('version'), 16);
		versionFnf.scrollFactor.set();
		versionFnf.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionFnf);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if android
		addVirtualPad(UP_DOWN, A_B_C);
		virtualPad.y = -48;
		#end

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);
	
					if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						changeItem((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(orange, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionSelect[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
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
			else if (FlxG.keys.anyJustPressed(debugKeys) #if android || virtualPad.buttonC.justPressed #end)
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end

			if (FlxG.keys.pressed.CONTROL #if android || FlxG.android.justReleased.BACK #end) {
				MusicBeatState.switchState(new ModsMenuState());
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
			{
				if (spr.ID == curSelected)
				{
					camFollow.y = FlxMath.lerp(camFollow.y, spr.getGraphicMidpoint().y, camLerp / (ClientPrefs.framerate / 60));
					camFollow.x = spr.getGraphicMidpoint().x;
				}
			});
	
			super.update(elapsed);
		}
	
		function changeItem(huh:Int = 0)
		{
			curSelected += huh;
	
			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
	
			menuItems.forEach(function(spr:FlxSprite)
			{
				spr.animation.play('idle');
				spr.updateHitbox();
	
				if (spr.ID == curSelected)
				{
					spr.animation.play('selected');
					var add:Float = 0;
					if (menuItems.length > 4)
					{
						add = menuItems.length * 8;
					}
					// camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
					// spr.centerOffsets();
				}
			});
		}
	}
	