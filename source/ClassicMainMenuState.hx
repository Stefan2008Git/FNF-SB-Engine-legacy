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

class ClassicMainMenuState extends MusicBeatState {
	public static var currentlySelected:Int = 0;

	private var camGame:FlxCamera;

	var options:Array<String> = ['Story Mode', 'Freeplay', #if (MODS_ALLOWED) 'Mods', #end 'Credits', 'Options'];

	var orange:FlxSprite;
	var alphaMainMenuText:FlxText;
	var debugKeys:Array<FlxKey>;

	private var grpOptions:FlxTypedGroup<Alphabet>;

	public static var menuBG:FlxSprite;

	var cameraFollow:FlxObject;
	var cameraFollowPosition:FlxObject;

	function openSelectedSubstate(label:String) {
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

		cameraFollow = new FlxObject(0, 0, 1, 1);
		cameraFollowPosition = new FlxObject(0, 0, 1, 1);
		add(cameraFollow);
		add(cameraFollowPosition);

		initOptions();

		alphaMainMenuText = new FlxText(12, FlxG.height - 24, 0, " Friday Night Funkin' v" + Application.current.meta.get('version'), 16);
		alphaMainMenuText.scrollFactor.set();
		alphaMainMenuText.setFormat("Bahnschrift", 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(alphaMainMenuText);

		selectorLeft = new Alphabet(0, 0, '>', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		add(selectorRight);

		changeSelection();

		#if android
		addVirtualPad(UP_DOWN, A_B_C);
		virtualPad.y = -48;
		#end

		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
	}

	function initOptions() {
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length) {
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true);
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);
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
			MusicBeatState.switchState(new TitleState());
		}

		if (controls.ACCEPT) {
			FlxG.sound.play(Paths.sound('confirmMenu'));
			if (ClientPrefs.flashing)
				FlxFlicker.flicker(orange, 1.1, 0.15, false);
			grpOptions.forEach(function(grpOptions:Alphabet) {
				FlxFlicker.flicker(grpOptions, 1, 0.06, false, false, function(flick:FlxFlicker) {
					openSelectedSubstate(options[currentlySelected]);
				});
			});
		}

		if (controls.ACCEPT && !ClientPrefs.flashing) {
			new FlxTimer().start(1, function(tmr:FlxTimer) {
				openSelectedSubstate(options[currentlySelected]);
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

		for (item in grpOptions.members) {
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
