package states.editors;

#if desktop
import backend.Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.system.FlxSound;
import lime.app.Application;
#if MODS_ALLOWED
import sys.FileSystem;
#end
import backend.MusicBeatState;
import backend.Paths;
import backend.ClientPrefs;
import backend.WeekData;
import objects.Alphabet;
import objects.Character;
import states.MainMenuState;
import states.FreeplayState;
import states.LoadingState;

using StringTools;

class MasterEditorMenu extends MusicBeatState {
	var options:Array<String> = [
		'Week Editor',
		'Menu Character Editor',
		'Dialogue Editor',
		'Dialogue Portrait Editor',
		'Character Editor',
		'Chart Editor'
	];
	private var grpTexts:FlxTypedGroup<Alphabet>;
	private var directories:Array<String> = [null];

	private var currentlySelected = 0;
	private var currentlyDirectory = 0;
	private var directoryTxt:FlxText;

	var background:FlxSprite;
	var velocityBackground:FlxBackdrop;

	var textBackground:FlxSprite;

	override function create() {
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		FlxG.camera.bgColor = FlxColor.BLACK;
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Editors Main Menu", null);
		#end

		background = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		background.scrollFactor.set();
		if (ClientPrefs.themes == 'SB Engine') {
			background.color = 0xFF800080;
		}
		if (ClientPrefs.themes == 'Psych Engine') {
			background.color = 0xFF353535;
		}
		add(background);

		velocityBackground = new FlxBackdrop(FlxGridOverlay.createGrid(30, 30, 60, 60, true, 0x3B161932, 0x0), XY);
		velocityBackground.velocity.set(FlxG.random.bool(50) ? 90 : -90, FlxG.random.bool(50) ? 90 : -90);
		velocityBackground.visible = ClientPrefs.velocityBackground;
		velocityBackground.alpha = 0;
		FlxTween.tween(velocityBackground, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(velocityBackground);

		grpTexts = new FlxTypedGroup<Alphabet>();
		add(grpTexts);

		grpTexts = new FlxTypedGroup<Alphabet>();
		add(grpTexts);

		for (i in 0...options.length) {
			var leText:Alphabet = new Alphabet(90, 320, options[i], true);
			leText.isMenuItem = true;
			leText.targetY = i;
			grpTexts.add(leText);
			leText.snapToPosition();
		}

		#if MODS_ALLOWED
		if (ClientPrefs.themes == 'SB Engine') {
		    textBackground = new FlxSprite(0, FlxG.height - 42).makeGraphic(FlxG.width, 42, 0xFF800080);
		}
		if (ClientPrefs.themes == 'Psych Engine') {
		    textBackground = new FlxSprite(0, FlxG.height - 42).makeGraphic(FlxG.width, 42, 0xFF353535);
		}
		textBackground.alpha = 0.6;
		add(textBackground);

		directoryTxt = new FlxText(textBackground.x, textBackground.y + 4, FlxG.width, '', 32);
		switch (ClientPrefs.gameStyle) {
			case 'SB Engine':
				directoryTxt.setFormat("Bahnschrift", 32, FlxColor.WHITE, CENTER);

            case 'Psych Engine':
			    directoryTxt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);

			case 'Better UI':
			    directoryTxt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		}

		directoryTxt.scrollFactor.set();
		add(directoryTxt);

		for (folder in Paths.getModDirectories()) {
			directories.push(folder);
		}

		var found:Int = directories.indexOf(Paths.currentModDirectory);
		if (found > -1)
			currentlyDirectory = found;
		changeDirectory();
		#end
		changeSelection();

		FlxG.mouse.visible = false;

		#if android
		addVirtualPad(LEFT_FULL, A_B);
		#end

		super.create();
	}

	override function update(elapsed:Float) {
		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}
		#if MODS_ALLOWED
		if (controls.UI_LEFT_P) {
			changeDirectory(-1);
		}
		if (controls.UI_RIGHT_P) {
			changeDirectory(1);
		}
		#end

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if (ClientPrefs.mainMenuStyle == 'Classic') {
				MusicBeatState.switchState(new ClassicMainMenuState());
			    Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion;
			} else {
				MusicBeatState.switchState(new MainMenuState());
			    Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion;
			}
		}

		if (controls.ACCEPT) {
			switch (options[currentlySelected]) {
				case 'Character Editor':
					LoadingState.loadAndSwitchState(new CharacterEditorState(Character.DEFAULT_CHARACTER, false));
					Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Character Editor Menu";
				case 'Week Editor':
					MusicBeatState.switchState(new WeekEditorState());
					Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Week Editor Menu";
				case 'Menu Character Editor':
					MusicBeatState.switchState(new MenuCharacterEditorState());
					Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Menu Character Editor Menu";
				case 'Dialogue Portrait Editor':
					LoadingState.loadAndSwitchState(new DialogueCharacterEditorState(), false);
					Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Dialogue Portrait Editor Menu";
				case 'Dialogue Editor':
					LoadingState.loadAndSwitchState(new DialogueEditorState(), false);
					Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Dialogue Editor Menu";
				case 'Chart Editor': // felt it would be cool maybe
					LoadingState.loadAndSwitchState(new ChartingState(), false);
					Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Chart Editor Menu";
			}
			FlxG.sound.music.volume = 0;
			#if PRELOAD_ALL
			FreeplayState.destroyFreeplayVocals();
			#end
		}

		var optionFreak:Int = 0;
		for (item in grpTexts.members) {
			item.targetY = optionFreak - currentlySelected;
			optionFreak++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0) {
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0) {
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		currentlySelected += change;

		if (currentlySelected < 0)
			currentlySelected = options.length - 1;
		if (currentlySelected >= options.length)
			currentlySelected = 0;
	}

	#if MODS_ALLOWED
	function changeDirectory(change:Int = 0) {
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		currentlyDirectory += change;

		if (currentlyDirectory < 0)
			currentlyDirectory = directories.length - 1;
		if (currentlyDirectory >= directories.length)
			currentlyDirectory = 0;

		WeekData.setDirectoryFromWeek();
		if (directories[currentlyDirectory] == null || directories[currentlyDirectory].length < 1)
			directoryTxt.text = '< No Mod Directory Loaded >';
		else {
			Paths.currentModDirectory = directories[currentlyDirectory];
			directoryTxt.text = '< Loaded Mod Directory: ' + Paths.currentModDirectory + ' >';
		}
		directoryTxt.text = directoryTxt.text.toUpperCase();
	}
	#end
}
