package states;

import flixel.addons.transition.FlxTransitionableState;
import states.editors.MasterEditorMenu;
import states.MainMenuState;

using StringTools;

class ClassicMainMenuState extends MusicBeatState {
	public static var currentlySelected:Int = 0;

	private var camGame:FlxCamera;

	var options:Array<String> = ['Story Mode', 'Freeplay', #if (MODS_ALLOWED) 'Mods', #end 'Credits', 'Options'];

	var background:FlxSprite;
	var sbEngineVersion:FlxText;
	var psychEngineVersion:FlxText;
	var fridayNightFunkinVersion:FlxText;
	var galleryText:FlxText;
	var galleryTextSine:Float = 0;
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

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

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

	override function create() {
		Paths.clearStoredMemory();

		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();
		if (ClientPrefs.colorblindMode != null)
			ColorblindFilter.applyFiltersOnGame();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Classic Main Menus.", null);
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
	    galleryText = new FlxText(12, FlxG.height - 44, FlxG.width - 24, "Press Y for gallery basemant!", 12);
		secretText = new FlxText(12, FlxG.height - 24, FlxG.width - 24, "Press BACK for secret screen!", 12);
		#else
		galleryText = new FlxText(12, FlxG.height - 44, FlxG.width - 24, "Press G for gallery basemant!", 12);
		secretText = new FlxText(12, FlxG.height - 24, FlxG.width - 24, "Press S for secret screen!", 12);
		#end
		sbEngineVersion = new FlxText(12, FlxG.height - 64, 0, "SB Engine v" + MainMenuState.sbEngineVersion + " (Modified Psych Engine)", 16);
		psychEngineVersion = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + MainMenuState.psychEngineVersion, 16);
		fridayNightFunkinVersion = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + MainMenuState.fnfEngineVersion, 16);
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine':
				galleryText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				secretText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				sbEngineVersion.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				psychEngineVersion.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				fridayNightFunkinVersion.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

			default:
				galleryText.setFormat("Bahnschrift", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				secretText.setFormat("Bahnschrift", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				sbEngineVersion.setFormat("Bahnschrift", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				psychEngineVersion.setFormat("Bahnschrift", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				fridayNightFunkinVersion.setFormat("Bahnschrift", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		galleryText.scrollFactor.set();
		secretText.scrollFactor.set();
		sbEngineVersion.scrollFactor.set();
		psychEngineVersion.scrollFactor.set();
		fridayNightFunkinVersion.scrollFactor.set();
		add(galleryText);
		add(secretText);
		add(sbEngineVersion);
		add(psychEngineVersion);
		add(fridayNightFunkinVersion);

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
			case 'Psych Engine': tipText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER);
			default: tipText.setFormat("Bahnschrift", 24, FlxColor.WHITE, CENTER);
		}

		tipText.updateHitbox();
		add(tipText);

		tipBackground.makeGraphic(FlxG.width, Std.int((tipTextMargin * 2) + tipText.height), FlxColor.BLACK);

		Paths.clearUnusedMemory();

		changeSelection();
		tipTextStartScrolling();

		#if android
		addVirtualPad(UP_DOWN, A_B_X_Y);
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

		if (galleryText.visible) {
			galleryTextSine += 150 * elapsed;
			galleryText.alpha = 1 - Math.sin((Math.PI * galleryTextSine) / 150);
		}

		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new TitleState());
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
		else if (FlxG.keys.anyJustPressed(debugKeys) #if android || virtualPad.buttonX.justPressed #end) {
			Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Mod Maker Menu";
			MusicBeatState.switchState(new MasterEditorMenu());
		}
		#end

		if (FlxG.keys.justPressed.S #if android || FlxG.android.justReleased.BACK #end) {
			FlxG.sound.play(Paths.sound('scrollMenu'));
			Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - You are founded a secret!";
			MusicBeatState.switchState(new DVDScreenState());
		}

		if (FlxG.keys.justPressed.G #if android || virtualPad.buttonY.justPressed #end) {
			FlxG.sound.play(Paths.sound('scrollMenu'));
			Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Gallery Menus";
			MusicBeatState.switchState(new GalleryScreenState());
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
