package states.editors;

import flixel.addons.transition.FlxTransitionableState;
import flixel.system.FlxSound;
#if MODS_ALLOWED
import sys.FileSystem;
#end
import states.MainMenuState;
import states.FreeplayState;
import states.LoadingState;

using StringTools;

class MasterEditorMenu extends MusicBeatState {
	var options:Array<String> = [
		'Character Editor',
		'Chart Editor',
		'Credits Editor',
		'Dialogue Editor',
		'Dialogue Portrait Editor',
		'Menu Character Editor',
		'Week Editor'
	];
	private var grpTexts:FlxTypedGroup<Alphabet>;
	private var directories:Array<String> = [null];

	private var currentlySelected = 0;
	private var currentlyDirectory = 0;
	private var directoryTxt:FlxText;

	var background:FlxSprite;
	var imageInfoBackground:FlxSprite;
	var tipText:FlxText;
	var characterEditor:FlxSprite;
	var chartEditor:FlxSprite;
	var dialogueEditor:FlxSprite;
	var dialoguePortraitEditor:FlxSprite;
	var menuCharacterEditor:FlxSprite;
	var weekEditor:FlxSprite;
	var velocityBackground:FlxBackdrop;

	var textBackground:FlxSprite;

	override function create() {
		if (ClientPrefs.toastCore) Main.toast.create('Welcome to Master Editor Menu', 0xFF00FF44, 'Go make some mods :)');
		Paths.clearStoredMemory();

		FlxG.camera.bgColor = FlxColor.BLACK;
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Master Edior Menu", null);
		#end

		background = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		background.scrollFactor.set();
		switch (ClientPrefs.themes) {
			case 'SB Engine':
				background.color = 0xFF800080;
			
			case 'Psych Engine':
				background.color = 0xFF353535;
		}
		add(background);

		velocityBackground = new FlxBackdrop(FlxGridOverlay.createGrid(30, 30, 60, 60, true, 0x3B161932, 0x0), XY);
		velocityBackground.velocity.set(FlxG.random.bool(50) ? 90 : -90, FlxG.random.bool(50) ? 90 : -90);
		velocityBackground.visible = ClientPrefs.velocityBackground;
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

		tipText = new FlxText(FlxG.width - 250, 5, 0, "", 32);
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine': tipText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			default: tipText.setFormat("Bahnschrift", 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		add(tipText);

		switch (ClientPrefs.themes) {
			case 'SB Engine':
		        imageInfoBackground = new FlxSprite(tipText.x - 6, 0).makeGraphic(1, 250, 0xFFFF00FF);

			case 'Psych Engine':
		        imageInfoBackground = new FlxSprite(tipText.x - 6, 0).makeGraphic(1, 250, 0xFF000000);
		}
		imageInfoBackground.alpha = 0.6;
		add(imageInfoBackground);

		characterEditor = new FlxSprite(1030, 55).loadGraphic(Paths.image('editors/characterEditor'));
		characterEditor.scrollFactor.set();
		characterEditor.visible = false;
		characterEditor.antialiasing = ClientPrefs.globalAntialiasing;
		characterEditor.scale.set(2, 2);
		add(characterEditor);

		chartEditor = new FlxSprite(1050, 70).loadGraphic(Paths.image('editors/chartEditor'));
		chartEditor.scrollFactor.set();
		chartEditor.visible = false;
		chartEditor.antialiasing = ClientPrefs.globalAntialiasing;
		chartEditor.scale.set(2, 2);
		add(chartEditor);

		dialogueEditor = new FlxSprite(1020, 70).loadGraphic(Paths.image('editors/dialogueEditor'));
		dialogueEditor.scrollFactor.set();
		dialogueEditor.visible = false;
		dialogueEditor.antialiasing = ClientPrefs.globalAntialiasing;
		dialogueEditor.scale.set(2, 2);
		add(dialogueEditor);

		dialoguePortraitEditor = new FlxSprite(966, 70).loadGraphic(Paths.image('editors/dialoguePortraitEditor'));
		dialoguePortraitEditor.scrollFactor.set();
		dialoguePortraitEditor.visible = false;
		dialoguePortraitEditor.antialiasing = ClientPrefs.globalAntialiasing;
		dialoguePortraitEditor.scale.set(2, 2);
		add(dialoguePortraitEditor);

		menuCharacterEditor = new FlxSprite(968, 70).loadGraphic(Paths.image('editors/menuCharacterEditor'));
		menuCharacterEditor.scrollFactor.set();
		menuCharacterEditor.visible = false;
		menuCharacterEditor.antialiasing = ClientPrefs.globalAntialiasing;
		menuCharacterEditor.scale.set(2, 2);
		add(menuCharacterEditor);

		weekEditor = new FlxSprite(1057, 70).loadGraphic(Paths.image('editors/weekEditor'));
		weekEditor.scrollFactor.set();
		weekEditor.visible = false;
		weekEditor.antialiasing = ClientPrefs.globalAntialiasing;
		weekEditor.scale.set(2, 2);
		add(weekEditor);

		#if MODS_ALLOWED
		switch (ClientPrefs.themes) {
			case 'SB Engine':
				textBackground = new FlxSprite(0, FlxG.height - 42).makeGraphic(FlxG.width, 42, 0xFF800080);
			
			case 'Psych Engine':
				textBackground = new FlxSprite(0, FlxG.height - 42).makeGraphic(FlxG.width, 42, 0xFF353535);
		}
		textBackground.alpha = 0.6;
		add(textBackground);

		directoryTxt = new FlxText(textBackground.x, textBackground.y + 4, FlxG.width, '', 32);
		switch (ClientPrefs.gameStyle) {
            case 'Psych Engine':
			    directoryTxt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
			
			default:
				directoryTxt.setFormat("Bahnschrift", 32, FlxColor.WHITE, CENTER);
		}

		directoryTxt.scrollFactor.set();
		add(directoryTxt);

		Paths.clearUnusedMemory();

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
			ClientPrefs.mainMenuStyle == 'Classic' ? MusicBeatState.switchState(new ClassicMainMenuState()) : MusicBeatState.switchState(new MainMenuState());
            Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion;
		}

		if (controls.ACCEPT) {
			switch (options[currentlySelected]) {
				case 'Character Editor':
					LoadingState.loadAndSwitchState(new CharacterEditorState(Character.DEFAULT_CHARACTER, false));
					Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Character Editor Menu";
				case 'Chart Editor': // felt it would be cool maybe
					LoadingState.loadAndSwitchState(new ChartingState(), false);
					Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Chart Editor Menu";
				case 'Credits Editor':
					MusicBeatState.switchState(new CreditsEditorState());
					Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Credits Editor Menu";
				case 'Dialogue Editor':
					LoadingState.loadAndSwitchState(new DialogueEditorState(), false);
					Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Dialogue Editor Menu";
				case 'Dialogue Portrait Editor':
					LoadingState.loadAndSwitchState(new DialogueCharacterEditorState(), false);
					Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Dialogue Portrait Editor Menu";
				case 'Menu Character Editor':
					MusicBeatState.switchState(new MenuCharacterEditorState());
					Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Menu Character Editor Menu";
				case 'Week Editor':
					MusicBeatState.switchState(new WeekEditorState());
					Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Week Editor Menu";
			}
			FlxG.sound.music.volume = 0;
			#if PRELOAD_ALL
			FreeplayState.destroyFreeplayVocals();
			#end
		}

		var optionValue:Int = 0;
		for (item in grpTexts.members) {
			item.targetY = optionValue - currentlySelected;
			optionValue++;

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

		switch (options[currentlySelected]) {
			case 'Character Editor':
				tipText.text = "Make a new character!";
				characterEditor.visible = true;
	            chartEditor.visible = false;
	            dialogueEditor.visible = false;
	            dialoguePortraitEditor.visible = false;
				menuCharacterEditor.visible = false;
	            weekEditor.visible = false;
			
			case 'Chart Editor':
				tipText.text = "Make a new chart!";
				characterEditor.visible = false;
	            chartEditor.visible = true;
	            dialogueEditor.visible = false;
	            dialoguePortraitEditor.visible = false;
				menuCharacterEditor.visible = false;
	            weekEditor.visible = false;
			
			case 'Credits Editor':
				tipText.text = "Make a new credit!";
				characterEditor.visible = false;
	            chartEditor.visible = false;
	            dialogueEditor.visible = false;
	            dialoguePortraitEditor.visible = false;
				menuCharacterEditor.visible = false;
	            weekEditor.visible = false;
			
			case 'Dialogue Editor':
				tipText.text = "Make a new dialogue!";
				characterEditor.visible = false;
	            chartEditor.visible = false;
	            dialogueEditor.visible = true;
	            dialoguePortraitEditor.visible = false;
				menuCharacterEditor.visible = false;
	            weekEditor.visible = false;
			
			case 'Dialogue Portrait Editor':
				tipText.text = "Make a new dialogue character!";
				characterEditor.visible = false;
	            chartEditor.visible = false;
	            dialogueEditor.visible = false;
	            dialoguePortraitEditor.visible = true;
				menuCharacterEditor.visible = false;
	            weekEditor.visible = false;
			
			case 'Menu Character Editor':
				tipText.text = "Make a new menu character!";
				characterEditor.visible = false;
	            chartEditor.visible = false;
	            dialogueEditor.visible = false;
	            dialoguePortraitEditor.visible = false;
				menuCharacterEditor.visible = true;
	            weekEditor.visible = false;
			
			case 'Week Editor':
				tipText.text = "Make a new week!";
				characterEditor.visible = false;
	            chartEditor.visible = false;
	            dialogueEditor.visible = false;
	            dialoguePortraitEditor.visible = false;
				menuCharacterEditor.visible = false;
	            weekEditor.visible = true;
		}
		makeTipTextLong();
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

	private function makeTipTextLong() {
		tipText.x = FlxG.width - tipText.width - 6;

		imageInfoBackground.scale.x = FlxG.width - tipText.x + 6;
		imageInfoBackground.x = FlxG.width - (imageInfoBackground.scale.x / 2);
	}
}
