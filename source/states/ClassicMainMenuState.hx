package states;

#if desktop
import backend.Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
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
import states.editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import backend.ClientPrefs;
import backend.CoolUtil;
import backend.MusicBeatState;
import backend.Paths;
import backend.WeekData;
import objects.Alphabet;
import states.MainMenuState;
import shaders.ColorblindFilter;

using StringTools;

class ClassicMainMenuState extends MusicBeatState {
	public static var currentlySelected:Int = 0;

	private var camGame:FlxCamera;

	var options:Array<String> = ['Story Mode', 'Freeplay', #if (MODS_ALLOWED) 'Mods', #end 'Credits', 'Options'];

	var background:FlxSprite;
	var sbEngineVersionTxt:FlxText;
	var fnfVersionTxt:FlxText;
	var secretText:FlxText;
	var secretTextSine:Float = 0;
	var tipTextMargin:Float = 10;
	var tipTextScrolling:Bool = false;
	var tipBackground:FlxSprite;
	var tipText:FlxText;
	var isTweening:Bool = false;
	var lastString:String = '';
	var debugKeys:Array<FlxKey>;

	private var optionsSelect:FlxTypedGroup<Alphabet>;

	public static var menuBG:FlxSprite;

	var cameraFollow:FlxObject;
	var cameraFollowPosition:FlxObject;

	function openSelectedState(label:String) {
		switch (label) {
			case 'Story Mode':
				MusicBeatState.switchState(new StoryModeState());
				Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Story Mode";
			case 'Freeplay':
				MusicBeatState.switchState(new FreeplayState());
				Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Freeplay Menu";
			#if (MODS_ALLOWED)
			case 'Mods':
				MusicBeatState.switchState(new ModsMenuState());
				Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Mods Menu";
			#end
			case 'Credits':
				MusicBeatState.switchState(new CreditsState());
				Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Credits Menu";
			case 'Options':
				MusicBeatState.switchState(new options.OptionsState());
				Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Options Menu";
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

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
		DiscordClient.changePresence("In the classic main menu.", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();

		FlxG.cameras.reset(camGame);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (options.length - 4)), 0.1);
		background = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		background.scrollFactor.set();
		background.setGraphicSize(Std.int(background.width * 1.175));
		background.updateHitbox();
		background.screenCenter();
		background.antialiasing = ClientPrefs.globalAntialiasing;
		add(background);

		cameraFollow = new FlxObject(0, 0, 1, 1);
		cameraFollowPosition = new FlxObject(0, 0, 1, 1);
		add(cameraFollow);
		add(cameraFollowPosition);

		initOptions();

		#if android
		secretText = new FlxText(12, FlxG.height - 24, FlxG.width - 24, "Press BACK for the secret screen!", 12);
		#else
		secretText = new FlxText(12, FlxG.height - 24, FlxG.width - 24, "Press S for the secret screen!", 12);
		#end
		sbEngineVersionTxt = new FlxText(12, FlxG.height - 44, 0, "SB Engine v" + MainMenuState.sbEngineVersion, 16);
		fnfVersionTxt = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin v" + Application.current.meta.get('version'), 16);
		switch (ClientPrefs.gameStyle) {
			case 'SB Engine':
			    secretText.setFormat("Bahnschrift", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

			    sbEngineVersionTxt.setFormat("Bahnschrift", 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

			    fnfVersionTxt.setFormat("Bahnschrift", 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		    case 'Psych Engine':
			    secretText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

			    sbEngineVersionTxt.setFormat("VCR OSD Mono", 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		    	fnfVersionTxt.setFormat("VCR OSD Mono", 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		    case 'Better UI':
			    secretText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		
			    sbEngineVersionTxt.setFormat("VCR OSD Mono", 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

			    fnfVersionTxt.setFormat("VCR OSD Mono", 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}

		secretText.scrollFactor.set();
		sbEngineVersionTxt.scrollFactor.set();
		fnfVersionTxt.scrollFactor.set();
		add(secretText);
		add(sbEngineVersionTxt);
		add(fnfVersionTxt);

		selectorLeft = new Alphabet(0, 0, '> ', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, ' <', true);
		add(selectorRight);

		tipBackground = new FlxSprite();
		tipBackground.scrollFactor.set();
		tipBackground.alpha = 0.7;
		add(tipBackground);

		tipText = new FlxText(0, 0, 0, "");
		tipText.scrollFactor.set();
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine' | 'Better UI': tipText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER);
			default: tipText.setFormat("Bahnschrift", 24, FlxColor.WHITE, CENTER);
		}

		tipText.updateHitbox();
		add(tipText);

		tipBackground.makeGraphic(FlxG.width, Std.int((tipTextMargin * 2) + tipText.height), FlxColor.BLACK);

		changeSelection();
		tipTextStartScrolling();

		#if android
		addVirtualPad(UP_DOWN, A_B_C);
		virtualPad.y = -44;
		#end

		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
	}

	function initOptions() {
		optionsSelect = new FlxTypedGroup<Alphabet>();
		add(optionsSelect);

		for (i in 0...options.length) {
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true);
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			optionsSelect.add(optionText);
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (tipTextScrolling) {
			tipText.x -= elapsed * 130;
			if (tipText.x < -tipText.width)
			{
				tipTextScrolling = false;
				tipTextStartScrolling();
				changeTipText();
			}
		}

		if (secretText.visible) {
			secretTextSine += 150 * elapsed;
			secretText.alpha = 1 - Math.sin((Math.PI * secretTextSine) / 150);
		}

		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new TitleScreenState());
		}

		if (controls.ACCEPT) {
			FlxG.sound.play(Paths.sound('confirmMenu'));
			optionsSelect.forEach(function(optionsSelect:Alphabet) {
				FlxFlicker.flicker(optionsSelect, 1, 0.06, false, false, function(flick:FlxFlicker) {
					openSelectedState(options[currentlySelected]);
				});
			});
		}

		if (controls.ACCEPT && !ClientPrefs.flashing) {
			new FlxTimer().start(1, function(tmr:FlxTimer) {
				openSelectedState(options[currentlySelected]);
			});
		}

		#if (desktop || android)
		else if (FlxG.keys.anyJustPressed(debugKeys) #if android || virtualPad.buttonC.justPressed #end) {
			Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Mod Maker Menu";
			MusicBeatState.switchState(new MasterEditorMenu());
		}
		#end

		if (FlxG.keys.justPressed.S #if android || FlxG.android.justReleased.BACK #end) {
			FlxG.sound.play(Paths.sound('scrollMenu'));
			FlxG.sound.music.volume = 0;
			Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - You are founded a secret!";
			MusicBeatState.switchState(new DVDScreenState());
		}
	}

	function tipTextStartScrolling()
		{
			tipText.x = tipTextMargin;
			tipText.y = -tipText.height;
	
			new FlxTimer().start(1.0, function(timer:FlxTimer)
			{
				FlxTween.tween(tipText, {y: tipTextMargin}, 0.3);
				new FlxTimer().start(2.25, function(timer:FlxTimer)
				{
					tipTextScrolling = true;
				});
			});
		}

	function changeTipText() {
		var selectedText:String = '';
		var textArray:Array<String> = CoolUtil.coolTextFile(SUtil.getPath() + Paths.txt('funnyTips'));

		tipText.alpha = 1;
		isTweening = true;
		selectedText = textArray[FlxG.random.int(0, (textArray.length - 1))].replace('--', '\n');
		FlxTween.tween(tipText, {alpha: 0}, 1, {
			ease: FlxEase.linear,
			onComplete: function(freak:FlxTween) {
				if (selectedText != lastString) {
					tipText.text = selectedText;
					lastString = selectedText;
				} else {
					selectedText = textArray[FlxG.random.int(0, (textArray.length - 1))].replace('--', '\n');
					tipText.text = selectedText;
				}

				tipText.alpha = 0;

				FlxTween.tween(tipText, {alpha: 1}, 1, {
					ease: FlxEase.linear,
					onComplete: function(freak:FlxTween) {
						isTweening = false;
					}
				});
			}
		});
	}

	function changeSelection(change:Int = 0) {
		currentlySelected += change;
		if (currentlySelected < 0)
			currentlySelected = options.length - 1;
		if (currentlySelected >= options.length)
			currentlySelected = 0;

		var value:Int = 0;

		for (item in optionsSelect.members) {
			item.targetY = value - currentlySelected;
			value++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}
