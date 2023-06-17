package;

#if desktop
import Discord.DiscordClient;
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
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class ClassicMainMenuState extends MusicBeatState {
	public static var currentlySelected:Int = 0;

	private var camGame:FlxCamera;

	var options:Array<String> = ['Story Mode', 'Freeplay', #if (MODS_ALLOWED) 'Mods', #end 'Credits', 'Options'];

	var background:FlxSprite;
	var sbEngineVersionTxt:FlxText;
	var fnfVersionTxt:FlxText;
	var debugKeys:Array<FlxKey>;

	private var optionsSelect:FlxTypedGroup<Alphabet>;

	public static var menuBG:FlxSprite;

	var cameraFollow:FlxObject;
	var cameraFollowPosition:FlxObject;

	function openSelectedState(label:String) {
		switch (label) {
			case 'Story Mode':
				MusicBeatState.switchState(new StoryMenuState());
			case 'Freeplay':
				MusicBeatState.switchState(new FreeplayState());
			#if (MODS_ALLOWED)
			case 'Mods':
				MusicBeatState.switchState(new ModsMenuState());
			#end
			case 'Credits':
				MusicBeatState.switchState(new CreditsState());
			case 'Options':
				MusicBeatState.switchState(new options.OptionsState());
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

		if (ClientPrefs.gameStyle == 'SB Engine') {
			sbEngineVersionTxt = new FlxText(12, FlxG.height - 44, 0, "SB Engine v" + MainMenuState.sbEngineVersion, 16);
			sbEngineVersionTxt.scrollFactor.set();
			sbEngineVersionTxt.setFormat("Bahnschrift", 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			fnfVersionTxt = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin v" + Application.current.meta.get('version'), 16);
			fnfVersionTxt.scrollFactor.set();
			fnfVersionTxt.setFormat("Bahnschrift", 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}

		if (ClientPrefs.gameStyle == 'Psych Engine') {
			sbEngineVersionTxt = new FlxText(12, FlxG.height - 44, 0, "SB Engine v" + MainMenuState.sbEngineVersion, 16);
			sbEngineVersionTxt.scrollFactor.set();
			sbEngineVersionTxt.setFormat("VCR OSD Mono", 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			fnfVersionTxt = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin v" + Application.current.meta.get('version'), 16);
			fnfVersionTxt.scrollFactor.set();
			fnfVersionTxt.setFormat("VCR OSD Mono", 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}

		if (ClientPrefs.gameStyle == 'Better UI') {
			sbEngineVersionTxt = new FlxText(12, FlxG.height - 44, 0, "SB Engine v" + MainMenuState.sbEngineVersion, 16);
			sbEngineVersionTxt.scrollFactor.set();
			sbEngineVersionTxt.setFormat("VCR OSD Mono", 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			fnfVersionTxt = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin v" + Application.current.meta.get('version'), 16);
			fnfVersionTxt.scrollFactor.set();
			fnfVersionTxt.setFormat("VCR OSD Mono", 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}

		sbEngineVersionTxt.scrollFactor.set();
		fnfVersionTxt.scrollFactor.set();
		add(sbEngineVersionTxt);
		add(fnfVersionTxt);

		selectorLeft = new Alphabet(0, 0, '> ', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, ' <', true);
		add(selectorRight);

		changeSelection();

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
			MusicBeatState.switchState(new MasterEditorMenu());
		}
		#end
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
