package states;

#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import lime.utils.Assets;

using StringTools;

class CreditsState extends MusicBeatState {
	var currentlySelected:Int = -1;

	private var optionSelect:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<String>> = [];

	var background:FlxSprite;
	var velocityBackground:FlxBackdrop;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;
	var descBox:AttachedSprite;

	var offsetThing:Float = -75;

	override function create() {
		Paths.clearStoredMemory();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Credits Menus", null);
		#end

		persistentUpdate = true;
		background = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		background.screenCenter();
		add(background);

		velocityBackground = new FlxBackdrop(FlxGridOverlay.createGrid(30, 30, 60, 60, true, 0x3B161932, 0x0), XY);
		velocityBackground.velocity.set(FlxG.random.bool(50) ? 90 : -90, FlxG.random.bool(50) ? 90 : -90);
		velocityBackground.visible = ClientPrefs.velocityBackground;
		add(velocityBackground);

		optionSelect = new FlxTypedGroup<Alphabet>();
		add(optionSelect);

		#if MODS_ALLOWED
		var path:String = SUtil.getPath() + 'modsList.txt';
		if (FileSystem.exists(path)) {
			var leMods:Array<String> = CoolUtil.coolTextFile(path);
			for (i in 0...leMods.length) {
				if (leMods.length > 1 && leMods[0].length > 0) {
					var modSplit:Array<String> = leMods[i].split('|');
					if (!Paths.ignoreModFolders.contains(modSplit[0].toLowerCase()) && !modsAdded.contains(modSplit[0])) {
						if (modSplit[1] == '1')
							pushModCreditsToList(modSplit[0]);
						else
							modsAdded.push(modSplit[0]);
					}
				}
			}
		}

		var arrayOfFolders:Array<String> = Paths.getModDirectories();
		arrayOfFolders.push('');
		for (folder in arrayOfFolders) {
			pushModCreditsToList(folder);
		}
		#end

		var creditName:Array<Array<String>> = [
			// Name - Icon name - Description - Link - BG Color
			[LanguageHandler.sbEngineTeamTxt],
			['Stefan2008', 'stefan', LanguageHandler.stefan2008Description, 'https://www.youtube.com/channel/UC9Nwf21GbaEm_h0Ka9gxZjQ', '800080'],
			['Nury', 'nury', LanguageHandler.nuryDescription, 'https://youtube.com/@Nuury06', '8A8AFF'],
			['Hutaro', 'hutaroz', LanguageHandler.hutarozDescription, 'https://youtube.com/@hutaroz?si=1-qCf4MucDxMpL12', 'F8F58F'],
			['MaysLastPlay', 'mays', LanguageHandler.maysLastPlayDescription, 'https://www.youtube.com/channel/UCjTi9Hfl1Eb5Bgk5gksmsbA', '5E99DF'],
			['Fearester2008', 'fearester', LanguageHandler.fearester2008Description, 'https://www.youtube.com/@fearester1282', '04435a'],
			['SunBurntTails', 'sun', LanguageHandler.sunBurntTailsDescription, 'https://www.youtube.com/channel/UCooFjEgVBZyTSx_hbcnqclw', '3E813A' ],
			['Ali Alafandy', 'ali', LanguageHandler.aliAlafandyDescription, 'https://youtube.com/channel/UClK5uzYLZDUZmbI6O56J-QA', '00008b'],
			['Luiz Felipe Play', 'luiz', LanguageHandler.luizFelipePlayDescription, 'https://www.youtube.com/channel/UCb0odiyqDCKje8rlBZGvKBg', '59d927'],
			[''],
			[LanguageHandler.specialCreditsTxt],
			['Stefan Ro 123', 'stefan-ro123', LanguageHandler.stefanRo123Description, 'https://www.youtube.com/channel/UCXVxTNqqrrHLGw_6ulzhfzQ', 'fc0000'],
			['Elgatosinnombre', 'elgatosinnombre', LanguageHandler.elgatosinnobreDescription, 'https://www.youtube.com/channel/UCQ7CD5-XkoFMlXbeX_9qG3w', '964B00'],
			['Sussy Sam', 'sam', LanguageHandler.sussySamDescription, 'https://www.youtube.com/@sussysam6789', '964B00'],
			['Lizzy Strawbery', 'lizzy', LanguageHandler.lizzyStrawberyDescription, 'https://www.youtube.com/@LizzyStrawberry', 'ff03d9'],
			['Joalor64', 'joalor', LanguageHandler.joalor64Description, 'https://www.youtube.com/channel/UC4tRMRL_iAHX5n1qQpHibfg', '00FFF6'],
			['JustXale', 'xale', LanguageHandler.justXaleDescription, 'https://github.com/JustXale', 'f7a300'],
			['SquidBowl', 'tinki', LanguageHandler.squidBowlDescription, 'https://www.youtube.com/@squidbowl', '964B00'],
			['Jordan Santiago', 'jordan', LanguageHandler.jordanSantiagoDescription, 'https://www.youtube.com/@JordanSantiago', '5E99DF'],
			['CoreDev', 'core', LanguageHandler.coreDevDescription, 'https://twitter.com/core5570r', '005FAD'],
			['TomyGamy', 'tomy', LanguageHandler.tomyGamyDescription, 'https://www.youtube.com/c/TomyGamy', 'DBC400'],
			['MarioMaster', 'mario', LanguageHandler.marioMasterDescription, 'https://www.youtube.com/channel/UC65m-_5tbYFJ7oRqZzpFBJw', 'fc0000'],
			['NF | Beihu', 'beihu', LanguageHandler.nfBeihuDescription, 'https://www.youtube.com/@beihu235', '964B00'],
			['M.A. Jigsaw77', 'jigsaw', LanguageHandler.maJigsaw77Description, 'https://www.youtube.com/channel/UC2Sk7vtPzOvbVzdVTWrribQ', '444444'],
			['Goldie', 'goldie', LanguageHandler.goldieDescription, 'https://www.youtube.com/channel/UCjTi9Hfl1Eb5Bgk5gksmsbA', '444444'],
			[''],
			['Psych Engine Team'],
			['Shadow Mario', 'shadowmario', 'Main Programmer of Psych Engine', 'https://twitter.com/Shadow_Mario_', '444444'],
			['RiverOaken', 'river', 'Main Artist/Animator of Psych Engine', 'https://twitter.com/RiverOaken', 'B42F71'],
			[''],
			['Former Engine Member'],
			['bb-panzu', 'bb', 'Ex-Programmer of Psych Engine', 'https://twitter.com/bbsub3', '3E813A'],
			[''],
			['Engine Contributors'],
			['iFlicky', 'flicky', 'Composer of Psync and Tea Time\nMade the Dialogue Sounds', 'https://twitter.com/flicky_i', '9E29CF'],
			['SqirraRNG', 'sqirra', 'Crash Handler and Base code for\nChart Editor\'s Waveform', 'https://twitter.com/gedehari', 'E1843A'],
			['EliteMasterEric',	'mastereric', 'Runtime Shaders support', 'https://twitter.com/EliteMasterEric', 'FFBD40'],
			['PolybiusProxy', 'proxy', '.MP4 Video Loader Library (hxCodec)', 'https://twitter.com/polybiusproxy', 'DCD294'],
			['KadeDev', 'kade', 'Fixed some cool stuff on Chart Editor\nand other PRs', 'https://twitter.com/kade0912', '64A250'],
			['Keoiki', 'keoiki', 'Note Splash Animations', 'https://twitter.com/Keoiki_', 'D2D2D2'],
			['Nebula the Zorua', 'nebula', 'LUA JIT Fork and some Lua reworks', 'https://twitter.com/Nebula_Zorua', '7D40B2'],
			['Smokey', 'smokey', 'Sprite Atlas Support', 'https://twitter.com/Smokey_5_', '483D92'],
			[''],
			["Funkin' Crew"],
			['ninjamuffin99', 'ninjamuffin99', "Main Programmer of Friday Night Funkin'", 'https://twitter.com/ninja_muffin99', 'CF2D2D'],
			['PhantomArcade', 'phantomarcade', "Main Animator of Friday Night Funkin'", 'https://twitter.com/PhantomArcade3K', 'FADC45'],
			['evilsk8r', 'evilsk8r', "Main Artist of Friday Night Funkin'", 'https://twitter.com/evilsk8r', '5ABD4B'],
			['kawaisprite', 'kawaisprite', "Main Composer of Friday Night Funkin'", 'https://twitter.com/kawaisprite', '378FC7']
		];

		for (i in creditName) {
			creditsStuff.push(i);
		}

		for (i in 0...creditsStuff.length) {
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(FlxG.width / 2, 300, creditsStuff[i][0], !isSelectable);
			optionText.isMenuItem = true;
			optionText.targetY = i;
			optionText.changeX = false;
			optionText.snapToPosition();
			optionSelect.add(optionText);

			if (isSelectable) {
				if (creditsStuff[i][5] != null) {
					Paths.currentModDirectory = creditsStuff[i][5];
				}

				var str:String = 'credits/unknownIcon';
				if (Paths.image('credits/' + creditsStuff[i][1]) != null) str = 'credits/' + creditsStuff[i][1];
				var icon:AttachedSprite = new AttachedSprite(str);
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;

				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
				Paths.currentModDirectory = '';

				if (currentlySelected == -1)
					currentlySelected = i;
			} else
				optionText.alignment = CENTERED;
		}

		descBox = new AttachedSprite();
		switch (ClientPrefs.themes) {
			case 'SB Engine':
				descBox.makeGraphic(1, 1, FlxColor.PURPLE);
			
			case 'Psych Engine':
				descBox.makeGraphic(1, 1, FlxColor.BLACK);
		}
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine': descText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			default: descText.setFormat("Bahnschrift", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		descText.scrollFactor.set();
		descBox.sprTracker = descText;
		add(descText);

		Paths.clearUnusedMemory();

		background.color = getCurrentBGColor();
		intendedColor = background.color;
		changeSelection();

		#if android
		addVirtualPad(UP_DOWN, A_B);
		#end

		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;

	override function update(elapsed:Float) {
		if (FlxG.sound.music.volume < 0.7) {
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!quitting) {
			if (creditsStuff.length > 1) {
				var shiftMult:Int = 1;
				if (FlxG.keys.pressed.SHIFT)
					shiftMult = 3;

				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;

				if (upP) {
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (downP) {
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if (controls.UI_DOWN || controls.UI_UP) {
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if (holdTime > 0.5 && checkNewHold - checkLastHold > 0) {
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}
			}

			if (controls.ACCEPT && (creditsStuff[currentlySelected][3] == null || creditsStuff[currentlySelected][3].length > 4)) {
				CoolUtil.browserLoad(creditsStuff[currentlySelected][3]);
			}
			if (controls.BACK) {
				if (colorTween != null) {
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				ClientPrefs.mainMenuStyle == 'Classic' ? MusicBeatState.switchState(new ClassicMainMenuState()) : MusicBeatState.switchState(new MainMenuState());
			    Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion;
				quitting = true;
			}
		}

		for (item in optionSelect.members) {
			if (!item.bold) {
				var lerpVal:Float = CoolUtil.boundTo(elapsed * 12, 0, 1);
				if (item.targetY == 0) {
					var lastX:Float = item.x;
					item.screenCenter(X);
					item.x = FlxMath.lerp(lastX, item.x - 70, lerpVal);
				} else {
					item.x = FlxMath.lerp(item.x, 200 + -40 * Math.abs(item.targetY), lerpVal);
				}
			}
		}
		super.update(elapsed);
	}

	var moveTween:FlxTween = null;

	function changeSelection(change:Int = 0) {
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			currentlySelected += change;
			if (currentlySelected < 0)
				currentlySelected = creditsStuff.length - 1;
			if (currentlySelected >= creditsStuff.length)
				currentlySelected = 0;
		} while (unselectableCheck(currentlySelected));

		var newColor:Int = getCurrentBGColor();
		if (newColor != intendedColor) {
			if (colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(background, 1, background.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		var creditsSelect:Int = 0;

		for (item in optionSelect.members) {
			item.targetY = creditsSelect - currentlySelected;
			creditsSelect++;

			if (!unselectableCheck(creditsSelect - 1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}

		descText.text = creditsStuff[currentlySelected][2];
		descText.y = FlxG.height - descText.height + offsetThing - 60;

		if (moveTween != null)
			moveTween.cancel();
		moveTween = FlxTween.tween(descText, {y: descText.y + 75}, 0.25, {ease: FlxEase.sineOut});

		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();
	}

	#if MODS_ALLOWED
	private var modsAdded:Array<String> = [];

	function pushModCreditsToList(folder:String) {
		if (modsAdded.contains(folder))
			return;

		var creditsFile:String = null;
		if (folder != null && folder.trim().length > 0)
			creditsFile = Paths.mods(folder + '/data/credits.txt');
		else
			creditsFile = Paths.mods('data/credits.txt');

		if (FileSystem.exists(creditsFile)) {
			var firstarray:Array<String> = File.getContent(creditsFile).split('\n');
			for (i in firstarray) {
				var arr:Array<String> = i.replace('\\n', '\n').split("::");
				if (arr.length >= 5)
					arr.push(folder);
				creditsStuff.push(arr);
			}
			creditsStuff.push(['']);
		}
		modsAdded.push(folder);
	}
	#end

	function getCurrentBGColor() {
		var bgColor:String = creditsStuff[currentlySelected][4];
		if (!bgColor.startsWith('0x')) {
			bgColor = '0xFF' + bgColor;
		}
		return Std.parseInt(bgColor);
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}
