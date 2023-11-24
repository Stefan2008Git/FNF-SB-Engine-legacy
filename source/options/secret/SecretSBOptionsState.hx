package options.secret;

import states.MainMenuState;

class SecretSBOptionsState extends MusicBeatState {
	var option:Array<Array<String>> = [
		['Debug Menu', LanguageHandler.debugMenu]
	];

	private var optionSelect:FlxTypedGroup<Alphabet>;
	private static var currentlySelected:Int = 0;
	private var cameraGame:FlxCamera;

	function openSelectedSubstate(optionName:String) {
		switch (optionName) {
			case 'Debug Menu':
				openSubState(new options.secret.SecretDebugSubstate());
				#if android
				removeVirtualPad();
				#end
				Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Secret Options Menu (Debugging)";
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;
	var background:FlxSprite;
	var velocityBackground:FlxBackdrop;
    var alphabetStatement:FlxSprite;
	var cameraFollow:FlxObject;
	var cameraFollowPosition:FlxObject;

	override function create() {
        if (ClientPrefs.toastCore) Main.toast.create('You are entered to', 0xFF464646, 'Secret Debug mode');
		Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Secret Options Menu";
		Paths.clearStoredMemory();

        FlxG.sound.playMusic(Paths.music('warningScreenMusic'), 0.5);

		#if desktop
		DiscordClient.changePresence("In the Secret Debug Option", null);
		#end

		cameraGame = new FlxCamera();
		FlxG.cameras.reset(cameraGame);
		FlxG.cameras.setDefaultDrawTarget(cameraGame, true);

		var yScroll:Float = Math.max(0.25 - (0.05 * (option.length - 4)), 0.1);
		background = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		background.color = 0xFF353535;
		background.scrollFactor.set(0, yScroll);
		background.screenCenter();
		background.antialiasing = ClientPrefs.globalAntialiasing;
		background.updateHitbox();
		add(background);

		velocityBackground = new FlxBackdrop(FlxGridOverlay.createGrid(30, 30, 60, 60, true, 0x3BAAAAAA, 0x0), XY);
		velocityBackground.velocity.set(FlxG.random.bool(50) ? 90 : -90, FlxG.random.bool(50) ? 90 : -90);
		velocityBackground.visible = ClientPrefs.velocityBackground;
		add(velocityBackground);

        alphabetStatement = FlxSpriteUtil.drawRoundRect(new FlxSprite(450, 40).makeGraphic(340, 440, FlxColor.TRANSPARENT), 0, 0, 340, 440, 15, 15, FlxColor.BLACK);
		alphabetStatement.alpha = 0.6;
        alphabetStatement.screenCenter(Y);
        add(alphabetStatement);

		cameraFollow = new FlxObject(0, 0, 1, 1);
		cameraFollowPosition = new FlxObject(0, 0, 1, 1);
		add(cameraFollow);
		add(cameraFollowPosition);

		optionSelect = new FlxTypedGroup<Alphabet>();
		add(optionSelect);

        for (i in 0...option.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, option[i][1], true);
			optionText.screenCenter();
			optionText.y += (100 * (i - (option.length / 2))) + 50;
			optionSelect.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '-->', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<--', true);
		add(selectorRight);

		Paths.clearUnusedMemory();
        changeSelection();
		ClientPrefs.saveSettings();

		#if android
		addVirtualPad(NONE, A_B);
		#end

		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
            FlxG.sound.playMusic(Paths.music('freakyMenu-' + ClientPrefs.mainMenuMusic), 1, true);
            Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Options Menu";
			MusicBeatState.switchState(new options.OptionsState());
		}

		if (controls.ACCEPT) {
			openSelectedSubstate(option[currentlySelected][0]);
		}
    }

    function changeSelection(change:Int = 0) {
		currentlySelected += change;
		if (currentlySelected < 0)
			currentlySelected = option.length - 1;
		if (currentlySelected >= option.length)
			currentlySelected = 0;

		var alphabetValue:Int = 0;

		for (item in optionSelect.members) {
			item.targetY = alphabetValue - currentlySelected;
			alphabetValue++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
				selectorLeft.x = item.x - 80;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
	}
}
