package states;

#if desktop
import backend.Discord.DiscordClient;
#end
import states.editors.ChartingState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.effects.FlxFlicker;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import lime.app.Application;
import backend.ClientPrefs;
import backend.CoolUtil;
import backend.MusicBeatState;
import backend.Highscore;
import backend.Song;
import backend.Paths;
import backend.WeekData;
import objects.Alphabet;
import objects.HealthIcon;
import states.MainMenuState;
import states.PlayState;
import substates.GameplayChangersSubstate;
import substates.ResetScoreSubState;

#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

class FreeplayState extends MusicBeatState {
	var songs:Array<SongMetaData> = [];

	var selector:FlxText;

	private static var currentlySelected:Int = 0;

	var currentlyDifficulty:Int = -1;

	private static var lastDifficultyName:String = '';

	var scoreBackground:FlxSprite;
	var scoreText:FlxText;
	var difficultyText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var groupSongs:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<HealthIcon> = [];

	var background:FlxSprite;
	var velocityBackground:FlxBackdrop;
	var intendedColor:Int;
	var colorTween:FlxTween;

	override function create() {
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...WeekData.weeksList.length) {
			if (weekIsLocked(WeekData.weeksList[i]))
				continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length) {
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);

			for (song in leWeek.songs) {
				var colors:Array<Int> = song[2];
				if (colors == null || colors.length < 3) {
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		WeekData.loadTheFirstEnabledMod();

		background = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		background.antialiasing = ClientPrefs.globalAntialiasing;
		background.screenCenter();
		add(background);

		velocityBackground = new FlxBackdrop(FlxGridOverlay.createGrid(30, 30, 60, 60, true, 0x3B161932, 0x0), XY);
		velocityBackground.velocity.set(FlxG.random.bool(50) ? 90 : -90, FlxG.random.bool(50) ? 90 : -90);
		velocityBackground.visible = ClientPrefs.velocityBackground;
		velocityBackground.alpha = 0;
		FlxTween.tween(velocityBackground, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(velocityBackground);

		groupSongs = new FlxTypedGroup<Alphabet>();
		add(groupSongs);

		for (i in 0...songs.length) {
			var songText:Alphabet = new Alphabet(90, 320, songs[i].songName, true);
			songText.isMenuItem = true;
			songText.targetY = i - currentlySelected;
			groupSongs.add(songText);

			var maxWidth = 980;
			if (songText.width > maxWidth) {
				songText.scaleX = maxWidth / songText.width;
			}
			songText.snapToPosition();

			Paths.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);
		}
		WeekData.setDirectoryFromWeek();
		scoreText = new FlxText(FlxG.width - 250, 5, 0, "", 32);
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine' | 'Better UI': scoreText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
			default: scoreText.setFormat("Bahnschrift", 32, FlxColor.WHITE, RIGHT);
		}
		add(scoreText);

		scoreBackground = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 92, 0xFF000000);
		scoreBackground.alpha = 0.6;
		add(scoreBackground);

		difficultyText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		difficultyText.font = scoreText.font;
		add(difficultyText);

		if (currentlySelected >= songs.length) currentlySelected = 0;
		background.color = songs[currentlySelected].color;
		intendedColor = background.color;

		if (lastDifficultyName == '') lastDifficultyName = CoolUtil.defaultDifficulty;
		currentlyDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));

		changeSelection();
		changeDifficulty();

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		var textBackground:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBackground.alpha = 0.6;
		add(textBackground);

		#if PRELOAD_ALL
		#if android
		var leText:String = "Press X to listen to the Song / Press C to open the Gameplay Changers Menu / Press Y to Reset your Score and Accuracy.";
		var size:Int = 16;
		#else
		var leText:String = "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 16;
		#end
		#else
		var leText:String = "Press C to open the Gameplay Changers Menu / Press Y to Reset your Score and Accuracy.";
		var size:Int = 18;
		#end
		var text:FlxText = new FlxText(textBackground.x, textBackground.y + 4, FlxG.width, leText, size);
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine' | 'Better UI': text.setFormat("VCR OSD Mono", size, FlxColor.WHITE, CENTER);
			default: text.setFormat("Bahnschrift", size, FlxColor.WHITE, CENTER);
		}

		text.scrollFactor.set();
		add(text);

		#if android
		addVirtualPad(LEFT_FULL, A_B_C_X_Y_Z);
		#end

		super.create();
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int) {
		songs.push(new SongMetaData(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked
			&& leWeek.weekBefore.length > 0
			&& (!StoryModeState.weekCompleted.exists(leWeek.weekBefore) || !StoryModeState.weekCompleted.get(leWeek.weekBefore)));
	}

	var instPlaying:Int = -1;

	public static var vocals:FlxSound = null;

	var holdTime:Float = 0;

	override function update(elapsed:Float) {
		if (FlxG.sound.music.volume < 0.7) {
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if (ratingSplit.length < 2) { // No decimals, add an empty space
			ratingSplit.push('');
		}

		while (ratingSplit[1].length < 2) { // Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE #if android || virtualPad.buttonX.justPressed #end;
		var ctrl = FlxG.keys.justPressed.CONTROL #if android || virtualPad.buttonC.justPressed #end;

		var shiftMult:Int = 1;
		if (FlxG.keys.pressed.SHIFT #if android || virtualPad.buttonZ.pressed #end)
			shiftMult = 3;

		if (songs.length > 1) {
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
					changeDifficulty();
				}
			}
		}

		if (controls.UI_LEFT_P)
			changeDifficulty(-1);
		else if (controls.UI_RIGHT_P)
			changeDifficulty(1);
		else if (upP || downP)
			changeDifficulty();

		if (controls.BACK) {
			persistentUpdate = false;
			if (colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if (ClientPrefs.mainMenuStyle == 'Classic') {
				MusicBeatState.switchState(new ClassicMainMenuState());
			    Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion;
			} else {
				MusicBeatState.switchState(new MainMenuState());
			    Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion;
			}
		}

		if (ctrl) {
			#if android
			removeVirtualPad();
			#end
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		} else if (space) {
			if (instPlaying != currentlySelected) {
				#if PRELOAD_ALL
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;
				Paths.currentModDirectory = songs[currentlySelected].folder;
				var valueSong:String = Highscore.formatSong(songs[currentlySelected].songName.toLowerCase(), currentlyDifficulty);
				PlayState.SONG = Song.loadFromJson(valueSong, songs[currentlySelected].songName.toLowerCase());
				if (PlayState.SONG.needsVoices)
					vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
				else
					vocals = new FlxSound();

				FlxG.sound.list.add(vocals);
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
				vocals.play();
				vocals.persist = true;
				vocals.looped = true;
				vocals.volume = 0.7;
				instPlaying = currentlySelected;
				#end
			}
		} else if (accepted) {
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[currentlySelected].songName);
			var valueSong:String = Highscore.formatSong(songLowercase, currentlyDifficulty);
			trace(valueSong);

			PlayState.SONG = Song.loadFromJson(valueSong, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyModeDifficulty = currentlyDifficulty;

			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			if (colorTween != null) {
				colorTween.cancel();
			}

			if (FlxG.keys.pressed.SHIFT #if android || virtualPad.buttonZ.pressed #end) {
				LoadingState.loadAndSwitchState(new ChartingState());
			} else {
				LoadingState.loadAndSwitchState(new PlayState());
				Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Current song: " + PlayState.SONG.song;
			}

			FlxG.sound.music.volume = 0;
			destroyFreeplayVocals();
		} else if (controls.RESET #if android || virtualPad.buttonY.justPressed #end) {
			#if android
			removeVirtualPad();
			#end
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[currentlySelected].songName, currentlyDifficulty, songs[currentlySelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if (vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDifficulty(change:Int = 0) {
		currentlyDifficulty += change;

		if (currentlyDifficulty < 0)
			currentlyDifficulty = CoolUtil.difficulties.length - 1;
		if (currentlyDifficulty >= CoolUtil.difficulties.length)
			currentlyDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[currentlyDifficulty];

		#if !switch
		intendedScore = Highscore.getScore(songs[currentlySelected].songName, currentlyDifficulty);
		intendedRating = Highscore.getRating(songs[currentlySelected].songName, currentlyDifficulty);
		#end

		PlayState.storyModeDifficulty = currentlyDifficulty;
		difficultyText.text = '< ' + CoolUtil.difficultyString() + ' >';
		positionHighscore();
	}

	function changeSelection(change:Int = 0, playSound:Bool = true) {
		if (playSound)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		currentlySelected += change;

		if (currentlySelected < 0)
			currentlySelected = songs.length - 1;
		if (currentlySelected >= songs.length)
			currentlySelected = 0;

		var newColor:Int = songs[currentlySelected].color;
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

		// selector.y = (70 * currentlySelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[currentlySelected].songName, currentlyDifficulty);
		intendedRating = Highscore.getRating(songs[currentlySelected].songName, currentlyDifficulty);
		#end

		var optionFreak:Int = 0;

		for (i in 0...iconArray.length) {
			iconArray[i].alpha = 0.6;
		}

		iconArray[currentlySelected].alpha = 1;

		for (item in groupSongs.members) {
			item.targetY = optionFreak - currentlySelected;
			optionFreak++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0) {
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}

		Paths.currentModDirectory = songs[currentlySelected].folder;
		PlayState.storyWeek = songs[currentlySelected].week;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if (diffStr != null)
			diffStr = diffStr.trim(); // freak you HTML5

		if (diffStr != null && diffStr.length > 0) {
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0) {
				if (diffs[i] != null) {
					diffs[i] = diffs[i].trim();
					if (diffs[i].length < 1)
						diffs.remove(diffs[i]);
				}
				--i;
			}

			if (diffs.length > 0 && diffs[0].length > 0) {
				CoolUtil.difficulties = diffs;
			}
		}

		if (CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty)) {
			currentlyDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		} else {
			currentlyDifficulty = 0;
		}

		var newPosition:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		// trace('Position of: ' + lastDifficultyName + ' is ' + newPosition);
		if (newPosition > -1) {
			currentlyDifficulty = newPosition;
		}
	}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBackground.scale.x = FlxG.width - scoreText.x + 6;
		scoreBackground.x = FlxG.width - (scoreBackground.scale.x / 2);
		difficultyText.x = Std.int(scoreBackground.x + (scoreBackground.width / 2));
		difficultyText.x -= difficultyText.width / 2;
	}
}

class SongMetaData {
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int) {
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if (this.folder == null)
			this.folder = '';
	}
}
