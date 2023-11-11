package options;

import lime.utils.Assets;
import flixel.util.FlxSave;
import haxe.Json;
import states.ClassicMainMenuState;
import states.LoadingState;
import states.MainMenuState;
import substates.PauseSubState;

using StringTools;

class OptionsState extends MusicBeatState {
	var options:Array<String> = [
		'Adjust Delay and Combo',
		'Controls',
		'Gameplay',
		'Graphics',
		'Note Colors',
		'Visuals and UI'
	];

	private var optionsSelect:FlxTypedGroup<Alphabet>;
	private static var currentlySelected:Int = 0;
	private var cameraGame:FlxCamera;

	function openSelectedSubstate(label:String) {
		switch (label) {
			case 'Adjust Delay and Combo':
				LoadingState.loadAndSwitchState(new options.NoteOffsetState());
				Application.current.window.title = "Friday Night Funkin: SB Engine v" + MainMenuState.sbEngineVersion + " - Options Menu (Adjusting Delay and Combo)";
			case 'Controls':
				#if android
				removeVirtualPad();
				#end
				openSubState(new options.ControlsSubState());
				Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Options Menu (Controls Menu)";
			case 'Gameplay':
				#if android
				removeVirtualPad();
				#end
				openSubState(new options.GameplaySettingsSubState());
				Application.current.window.title = "Friday Night Funkin: SB Engine v" + MainMenuState.sbEngineVersion + " - Options Menu (Gameplay Settings Menu)";
			case 'Graphics':
				#if android
				removeVirtualPad();
				#end
				openSubState(new options.GraphicsSettingsSubState());
				Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Options Menu (Graphics Settings Menu)";
			case 'Note Colors':
				#if android
				removeVirtualPad();
				#end
				openSubState(new options.NotesSubState());
				Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Options Menu (Note Colors Menu)";
			case 'Visuals and UI':
				#if android
				removeVirtualPad();
				#end
				openSubState(new options.VisualsUISubState());
				Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Options Menu (Visuals & UI Settings Menu)";
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;
	var background:FlxSprite;
	var velocityBackground:FlxBackdrop;
	var tipBackground:FlxSprite;
	var tipText:FlxText;
	var tipTextMargin:Float = 10;
	var androidControlsStyleTipText:FlxText;
	var customizeAndroidControlsTipText:FlxText;
	var cameraFollow:FlxObject;
	var cameraFollowPosition:FlxObject;

	override function create() {
		Paths.clearStoredMemory();

		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		cameraGame = new FlxCamera();
		FlxG.cameras.reset(cameraGame);
		FlxG.cameras.setDefaultDrawTarget(cameraGame, true);

		var yScroll:Float = Math.max(0.25 - (0.05 * (options.length - 4)), 0.1);
		background = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		switch (ClientPrefs.themes) {
			case 'SB Engine':
				background.color = 0xFF800080;
			
			case 'Psych Engine':
				background.color = 0xFFea71fd;
		}
		background.scrollFactor.set(0, yScroll);
		background.screenCenter();
		background.antialiasing = ClientPrefs.globalAntialiasing;
		background.updateHitbox();
		add(background);

		velocityBackground = new FlxBackdrop(FlxGridOverlay.createGrid(30, 30, 60, 60, true, 0x3B161932, 0x0), XY);
		velocityBackground.velocity.set(FlxG.random.bool(50) ? 90 : -90, FlxG.random.bool(50) ? 90 : -90);
		velocityBackground.visible = ClientPrefs.velocityBackground;
		add(velocityBackground);

		cameraFollow = new FlxObject(0, 0, 1, 1);
		cameraFollowPosition = new FlxObject(0, 0, 1, 1);
		add(cameraFollow);
		add(cameraFollowPosition);

		optionsSelect = new FlxTypedGroup<Alphabet>();
		add(optionsSelect);

		for (i in 0...options.length) {
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true);
			optionText.x = 128;
			optionText.screenCenter(Y);
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			optionsSelect.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '>', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		add(selectorRight);

		tipBackground = new FlxSprite(0, FlxG.height - 18).makeGraphic(Std.int(FlxG.width), 55, 0xFF000000);
		tipBackground.scrollFactor.set();
		tipBackground.alpha = 0;
		tipBackground.y = 100;
		FlxTween.tween(tipBackground, {y: tipBackground.y -100, alpha: 0.7}, 1, {ease: FlxEase.circOut, startDelay: 0.3});
		add(tipBackground);

		tipText = new FlxText(800, 1, FlxG.width - 800, "");
		tipText.scrollFactor.set();
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine': tipText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER);
			default: tipText.setFormat("Bahnschrift", 24, FlxColor.WHITE, CENTER);
		}
		tipText.updateHitbox();
		tipText.screenCenter(X);
		tipText.alpha = 0;
		tipText.y += 400;
		FlxTween.tween(tipText, {y: tipText.y -400, alpha: 0.7}, 1, {ease: FlxEase.circOut, startDelay: 0.3});
		add(tipText);

		#if android
		androidControlsStyleTipText = new FlxText(10, FlxG.height - 44, 0, 'Press Y to customize your opacity for hitbox, virtual pads and hitbox style!', 16);
		customizeAndroidControlsTipText = new FlxText(10, FlxG.height - 24, 0, 'Press X to customize your android controls!', 16);
		switch (ClientPrefs.gameStyle) {
		    case 'Psych Engine':
			    androidControlsStyleTipText.setFormat("VCR OSD Mono", 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			    customizeAndroidControlsTipText.setFormat("VCR OSD Mono", 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			
			default:
				androidControlsStyleTipText.setFormat("Bahnschrift", 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				customizeAndroidControlsTipText.setFormat("Bahnschrift", 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}

		androidControlsStyleTipText.borderSize = 1.25;
		androidControlsStyleTipText.scrollFactor.set();
		customizeAndroidControlsTipText.borderSize = 1.25;
		customizeAndroidControlsTipText.scrollFactor.set();
		add(androidControlsStyleTipText);
		add(customizeAndroidControlsTipText);
		#end

		Paths.clearUnusedMemory();

		changeSelection();
		ClientPrefs.saveSettings();

		#if android
		addVirtualPad(UP_DOWN, A_B_X_Y);
		virtualPad.y = -44;
		#end

		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
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
			if (PauseSubState.optionMenu) {
				MusicBeatState.switchState(new PlayState());
				Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Current song: " + PlayState.SONG.song;
				PauseSubState.optionMenu = false;
				FlxG.sound.music.volume = 0;
			} else {
				ClientPrefs.mainMenuStyle == 'Classic' ? MusicBeatState.switchState(new ClassicMainMenuState()) : MusicBeatState.switchState(new MainMenuState());
			    Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion;
			}
		}

		if (controls.ACCEPT) {
			openSelectedSubstate(options[currentlySelected]);
			FlxTween.tween(FlxG.sound.music, {volume: 0.5}, 0.8);
		}

		#if android
		if (virtualPad.buttonX.justPressed) {
			#if android
			removeVirtualPad();
			#end
			openSubState(new android.AndroidControlsSubState());
		}
		if (virtualPad.buttonY.justPressed) {
			#if android
			removeVirtualPad();
			#end
			openSubState(new android.AndroidControlsSettingsSubState());
		}
		#end

		if (FlxG.keys.justPressed.B #if android || FlxG.android.justReleased.BACK #end) {
			FlxG.sound.music.stop();
			FlxG.sound.playMusic(Paths.sound('rumble'), 0.8, false, null);
	
			FlxG.camera.shake(0.015, 3, function()
			{
				FlxG.camera.flash();
				var objects:Array<FlxSprite> = new Array<FlxSprite>();
	
				for (characters in optionsSelect)
				{
					characters.velocity.set(new FlxRandom().float(-100, 250), new FlxRandom().float(-100, 250));
					characters.angularVelocity = 80;
					characters.screenCenter();
					objects.push(characters);
				}

				for (character1 in selectorLeft)
				{
					character1.velocity.set(new FlxRandom().float(-100, 250), new FlxRandom().float(-100, 250));
					character1.angularVelocity = 80;
					character1.screenCenter();
					objects.push(character1);
				}

				for (character1 in selectorRight)
				{
					character1.velocity.set(new FlxRandom().float(-100, 250), new FlxRandom().float(-100, 250));
					character1.angularVelocity = 80;
					character1.screenCenter();
					objects.push(character1);
				}

				FlxG.sound.music.stop();
				FlxG.sound.playMusic(Paths.sound('ambience'), 1, false, null);
	
				background.color = FlxColor.ORANGE;
				new FlxTimer().start(4, function(timer:FlxTimer)
				{
					for (object in objects)
						{
							object.angularVelocity = 0;
							object.velocity.set();
							FlxTween.tween(object, {x: (FlxG.width / 2) - (object.width), y: (FlxG.height / 2) - (object.height)}, 1, {ease: FlxEase.backOut});
						}
						FlxG.camera.shake(0.05, 3);
									
							FlxG.sound.music.stop();
							FlxG.sound.playMusic(Paths.sound('rumble'), 0.8, false, null);
							FlxG.sound.play(Paths.sound('piecedTogether'), 1, false, null, true);
					
							FlxG.camera.fade(FlxColor.WHITE, 3, false, function() 
							{
								FlxG.camera.shake(0.1, 0.5);
	
								FlxG.sound.play(Paths.sound('confirmMenu'), function()
								{
								new FlxTimer().start(1, function(timer:FlxTimer)
								{
									#if android
									removeVirtualPad();
									#end
								openSubState(new options.VisualsUISubState());
							});
						});
					});
				});
			});
		}
	}

	function changeSelection(change:Int = 0) {
		currentlySelected += change;
		if (currentlySelected < 0)
			currentlySelected = options.length - 1;
		if (currentlySelected >= options.length)
			currentlySelected = 0;

		switch (options[currentlySelected]) {
			case 'Note Colors': tipText.text = "Change your note colors.";
			case 'Controls': tipText.text = "Change your keybinds on your keyboard.";
			case 'Graphics': tipText.text = "Change graphics settings";
			case 'Visuals and UI': tipText.text = "Change some ui stuff outside from engine.";
			case 'Gameplay': tipText.text = "Change hud and objects for better experience.";
			case 'Adjust Delay and Combo': tipText.text = "Ajust rating position for offset";
		}

		var optionFreak:Int = 0;

		for (item in optionsSelect.members) {
			item.targetY = optionFreak - currentlySelected;
			optionFreak++;

			item.alpha = 0.6;
			var alphabetItem:Float = 0;
			if (item.targetY == 0) {
				item.alpha = 1;
				if (optionsSelect.members.length > 4) {
					alphabetItem = optionsSelect.members.length * 8;
				}
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
				cameraFollow.setPosition(item.getGraphicMidpoint().x, item.getGraphicMidpoint().y - alphabetItem);
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}