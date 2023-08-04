package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
#if (flixel < "5.3.0")
import flixel.sound.FlxSound;
#else
import flixel.system.FlxSound;
#end
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import lime.app.Application;
import flixel.FlxCamera;
import objects.Alphabet;
import objects.HealthIcon;
import backend.ClientPrefs;
import backend.CoolUtil;
import backend.Controls;
import backend.Controls.Control;
import backend.Conductor;
import backend.Highscore;
import backend.MusicBeatState;
import backend.MusicBeatSubstate;
import backend.Paths;
import backend.Song;
import backend.WeekData;
import states.MainMenuState;
import states.FreeplayState;
import states.PlayState;
import states.StoryModeState;
import states.editors.ChartingState;

class PauseSubState extends MusicBeatSubstate {
	var grpMenufreak:FlxTypedGroup<objects.Alphabet>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = [
		'Resume',
		'Restart Song',
		'Change Difficulty',
		'Options',
		'Chart Editor',
		'Exit to menu'
	];
	var difficultyChoices = [];
	var currentlySelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;

	public static var optionMenu:Bool;

	var skipTimeText:FlxText;
	var skipTimeTracker:Alphabet;
	var currentlyTime:Float = Math.max(0, Conductor.songPosition);

	var blackBackground:FlxSprite;
	var background:FlxSprite;
	var checker:FlxBackdrop;
	var songNameText:FlxText;
	var difficultyNameText:FlxText;
	var deathCounterText:FlxText;
	var chartingText:FlxText;

	public var iconP2:HealthIcon;
	
	public static var songName:String = '';

	public function new(x:Float, y:Float) {
		super();
		if (CoolUtil.difficulties.length < 2)
			menuItemsOG.remove('Change Difficulty'); // No need to change difficulty if there is only one!

		if (PlayState.chartingMode) {
			menuItemsOG.insert(2, 'Leave Charting Mode');

			var num:Int = 0;
			if (!PlayState.instance.startingSong) {
				num = 1;
				menuItemsOG.insert(3, 'Skip Time');
			}
			menuItemsOG.insert(3 + num, 'End Song');
			menuItemsOG.insert(4 + num, 'Toggle Practice Mode');
			menuItemsOG.insert(5 + num, 'Toggle Botplay');
		}
		menuItems = menuItemsOG;

		for (i in 0...CoolUtil.difficulties.length) {
			var diff:String = '' + CoolUtil.difficulties[i];
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');

		pauseMusic = new FlxSound();
		if (songName != null) {
			pauseMusic.loadEmbedded(Paths.music(songName), true, true);
		} else if (songName != 'None') {
			pauseMusic.loadEmbedded(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)), true, true);
		}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		blackBackground = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackBackground.alpha = 0;
		blackBackground.visible = ClientPrefs.velocityBackground;
		add(blackBackground);

		background = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		background.scrollFactor.set();
		background.setGraphicSize(Std.int(background.width * 1.175));
		background.updateHitbox();
		background.screenCenter();
		background.alpha = 0;
		background.visible = !ClientPrefs.velocityBackground;
		background.antialiasing = ClientPrefs.globalAntialiasing;
		if (ClientPrefs.themes == 'SB Engine') {
			background.color = 0xFF800080;
		}
		if (ClientPrefs.themes == 'Psych Engine') {
			background.color = 0xFF353535;
		}
		add(background);

		checker = new FlxBackdrop(Paths.image('checker'), XY);
		checker.scrollFactor.set(0.2, 0.2);
		checker.scale.set(0.7, 0.7);
		checker.screenCenter(X);
		checker.velocity.set(150, 80);
		checker.visible = ClientPrefs.velocityBackground;
		checker.antialiasing = ClientPrefs.globalAntialiasing;
		checker.alpha = 0;
		FlxTween.tween(checker, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(checker);

		songNameText = new FlxText(20, 15, 0, "", 32);
		songNameText.text += "Song: " + PlayState.SONG.song;
		songNameText.scrollFactor.set();
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine' | 'Better UI': songNameText.setFormat("VCR OSD Mono", 32);
			default: /* SB Engine */ songNameText.setFormat("Bahnschrift", 32);	
		}
		songNameText.updateHitbox();
		add(songNameText);

		difficultyNameText = new FlxText(20, 15 + 32, 0, "", 32);
		difficultyNameText.text += "Difficulty: " + CoolUtil.difficultyString();
		difficultyNameText.scrollFactor.set();
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine' | 'Better UI': difficultyNameText.setFormat("VCR OSD Mono", 32);
			default: /* SB Engine */ difficultyNameText.setFormat("Bahnschrift", 32);
		}
		difficultyNameText.updateHitbox();
		add(difficultyNameText);

		deathCounterText = new FlxText(20, 15 + 64, 0, "", 32);
		deathCounterText.text = "Death counter: " + PlayState.deathCounter;
		deathCounterText.scrollFactor.set();
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine' | 'Better UI': deathCounterText.setFormat("VCR OSD Mono", 32);
			default: /* SB Engine */ deathCounterText.setFormat("Bahnschrift", 32);
		}
		deathCounterText.updateHitbox();
		add(deathCounterText);

		iconP2 = new HealthIcon(PlayState.instance.dad.healthIcon, false);
		iconP2.setGraphicSize(Std.int(iconP2.width * 1.2));
		iconP2.updateHitbox();
		add(iconP2);

		practiceText = new FlxText(20, 15 + 101, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine' | 'Better UI': practiceText.setFormat("VCR OSD Mono", 32);
			default: /* SB Engine */ practiceText.setFormat("Bahnschrift", 32);
		}
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.instance.practiceMode;
		add(practiceText);

		chartingText = new FlxText(20, 15 + 101, 0, "CHARTING MODE", 32);
		chartingText.scrollFactor.set();
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine' | 'Better UI': chartingText.setFormat("VCR OSD Mono", 32);
			default: /* SB Engine */ chartingText.setFormat("Bahnschrift", 32);
		}
		chartingText.x = FlxG.width - (chartingText.width + 20);
		chartingText.y = FlxG.height - (chartingText.height + 20);
		chartingText.updateHitbox();
		chartingText.visible = PlayState.chartingMode;
		add(chartingText);

		deathCounterText.alpha = 0;
		difficultyNameText.alpha = 0;
		songNameText.alpha = 0;
		songNameText.x = FlxG.width - (songNameText.width + 20);
		difficultyNameText.x = FlxG.width - (difficultyNameText.width + 20);
		deathCounterText.x = FlxG.width - (deathCounterText.width + 20);
		iconP2.alpha = 0;
		
		iconP2.setPosition(FlxG.width - iconP2.width, FlxG.height - iconP2.height - 5);

		FlxTween.tween(blackBackground, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(background, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(checker, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(songNameText, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		FlxTween.tween(difficultyNameText, {alpha: 1, y: difficultyNameText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.9});
		FlxTween.tween(deathCounterText, {alpha: 1, y: deathCounterText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.11});
		FlxTween.tween(iconP2, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.13});

		grpMenufreak = new FlxTypedGroup<Alphabet>();
		add(grpMenufreak);

		regenerateMenu();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		#if android
		PlayState.chartingMode ? addVirtualPad(LEFT_FULL, A) : addVirtualPad(UP_DOWN, A);
		addPadCamera();
		#end
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;

	override function update(elapsed:Float) {
		cantUnpause -= elapsed;
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);
		updateSkipTextStuff();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP) {
			changeSelection(-1);
		}
		if (downP) {
			changeSelection(1);
		}

		var daSelected:String = menuItems[currentlySelected];
		switch (daSelected) {
			case 'Skip Time':
				if (controls.UI_LEFT_P) {
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					currentlyTime -= 1000;
					holdTime = 0;
				}
				if (controls.UI_RIGHT_P) {
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					currentlyTime += 1000;
					holdTime = 0;
				}

				if (controls.UI_LEFT || controls.UI_RIGHT) {
					holdTime += elapsed;
					if (holdTime > 0.5) {
						currentlyTime += 45000 * elapsed * (controls.UI_LEFT ? -1 : 1);
					}

					if (currentlyTime >= FlxG.sound.music.length)
						currentlyTime -= FlxG.sound.music.length;
					else if (currentlyTime < 0)
						currentlyTime += FlxG.sound.music.length;
					updateSkipTimeText();
				}
		}

		if (accepted && (cantUnpause <= 0 || !ClientPrefs.controllerMode)) {
			if (menuItems == difficultyChoices) {
				if (menuItems.length - 1 != currentlySelected && difficultyChoices.contains(daSelected)) {
					var name:String = PlayState.SONG.song;
					var valueSong = Highscore.formatSong(name, currentlySelected);
					PlayState.SONG = Song.loadFromJson(valueSong, name);
					PlayState.storyModeDifficulty = currentlySelected;
					MusicBeatState.resetState();
					FlxG.sound.music.volume = 0;
					PlayState.changedDifficulty = true;
					PlayState.chartingMode = false;
					return;
				}

				menuItems = menuItemsOG;
				regenerateMenu();
			}

			switch (daSelected) {
				case "Resume":
					close();
					Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Current song: " + PlayState.SONG.song;
				case 'Change Difficulty':
					menuItems = difficultyChoices;
					deleteSkipTimeText();
					regenerateMenu();
				case 'Toggle Practice Mode':
					PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
					PlayState.changedDifficulty = true;
					practiceText.visible = PlayState.instance.practiceMode;
				case "Restart Song":
					restartSong();
					Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Current song: " + PlayState.SONG.song;
				case "Leave Charting Mode":
					restartSong();
					PlayState.chartingMode = false;
					Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Current song: " + PlayState.SONG.song;
				case 'Skip Time':
					if (currentlyTime < Conductor.songPosition) {
						PlayState.startOnTime = currentlyTime;
						restartSong(true);
					} else {
						if (currentlyTime != Conductor.songPosition) {
							PlayState.instance.clearNotesBefore(currentlyTime);
							PlayState.instance.setSongTime(currentlyTime);
						}
						close();
					}
				case "End Song":
					close();
					PlayState.instance.finishSong(true);
					Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Current song: " + PlayState.SONG.song;
				case 'Toggle Botplay':
					PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
					PlayState.changedDifficulty = true;
					PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled;
					PlayState.instance.botplayTxt.alpha = 1;
					PlayState.instance.botplaySine = 0;
				case 'Options':
					optionMenu = true;
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;
					PlayState.instance.vocals.volume = 0;
					MusicBeatState.switchState(new options.OptionsState());
					Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Options Menu";
					if(ClientPrefs.pauseMusic != 'None')
					{
						FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)), pauseMusic.volume);
						FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.8);
						FlxG.sound.music.time = pauseMusic.time;
					}
				case 'Chart Editor':
					MusicBeatState.switchState(new states.editors.ChartingState());
					Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Chart Editor Menu";
					PlayState.chartingMode = true;
				case "Exit to menu":
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;
					WeekData.loadTheFirstEnabledMod();
					if (PlayState.isStoryMode) {
						MusicBeatState.switchState(new StoryModeState());
						Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Story Mode";
					} else {
						MusicBeatState.switchState(new FreeplayState());
						Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Freeplay Menu";
					}
					PlayState.cancelMusicFadeTween();
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
			}
		}
	}

	function deleteSkipTimeText() {
		if (skipTimeText != null) {
			skipTimeText.kill();
			remove(skipTimeText);
			skipTimeText.destroy();
		}
		skipTimeText = null;
		skipTimeTracker = null;
	}

	public static function restartSong(noTrans:Bool = false) {
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if (noTrans) {
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		} else {
			MusicBeatState.resetState();
		}
	}

	override function destroy() {
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void {
		currentlySelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (currentlySelected < 0)
			currentlySelected = menuItems.length - 1;
		if (currentlySelected >= menuItems.length)
			currentlySelected = 0;

		var optionFreak:Int = 0;

		for (item in grpMenufreak.members) {
			item.targetY = optionFreak - currentlySelected;
			optionFreak++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0) {
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));

				if (item == skipTimeTracker) {
					currentlyTime = Math.max(0, Conductor.songPosition);
					updateSkipTimeText();
				}
			}
		}
	}

	function regenerateMenu():Void {
		for (i in 0...grpMenufreak.members.length) {
			var obj = grpMenufreak.members[0];
			obj.kill();
			grpMenufreak.remove(obj, true);
			obj.destroy();
		}

		for (i in 0...menuItems.length) {
			var item = new Alphabet(90, 320, menuItems[i], true);
			item.isMenuItem = true;
			item.targetY = i;
			grpMenufreak.add(item);

			if (menuItems[i] == 'Skip Time') {
				skipTimeText = new FlxText(0, 0, 0, '', 64);

				switch (ClientPrefs.gameStyle) {
					case 'Psych Engine' | 'Better UI': skipTimeText.setFormat("VCR OSD Mono", 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					default: /* SB Engine */ skipTimeText.setFormat("Bahnschrift", 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				}

				skipTimeText.scrollFactor.set();
				skipTimeText.borderSize = 2;
				skipTimeTracker = item;
				add(skipTimeText);

				updateSkipTextStuff();
				updateSkipTimeText();
			}
		}
		currentlySelected = 0;
		changeSelection();
	}

	function updateSkipTextStuff() {
		if (skipTimeText == null || skipTimeTracker == null)
			return;

		skipTimeText.x = skipTimeTracker.x + skipTimeTracker.width + 60;
		skipTimeText.y = skipTimeTracker.y;
		skipTimeText.visible = (skipTimeTracker.alpha >= 1);
	}

	function updateSkipTimeText() {
		skipTimeText.text = FlxStringUtil.formatTime(Math.max(0, Math.floor(currentlyTime / 1000)), false)
			+ ' / '
			+ FlxStringUtil.formatTime(Math.max(0, Math.floor(FlxG.sound.music.length / 1000)), false);
	}
}