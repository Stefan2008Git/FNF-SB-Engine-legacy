package options;

#if desktop
import backend.Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import backend.ClientPrefs;
import backend.Controls;
import backend.Paths;
import objects.Note;
import objects.StrumNote;
#if android
import android.Hardware;
#end

using StringTools;

class GameplaySettingsSubState extends BaseOptionsMenu {
	var noteOptionID:Int = -1;
	var notes:FlxTypedGroup<StrumNote>;
	var notesTween:Array<FlxTween> = [];
	var noteY:Float = 90;

	public function new() {
		title = 'Gameplay Settings';
		rpcTitle = 'Gameplay Settings Menu'; // for Discord Rich Presence

		// for note skins
		notes = new FlxTypedGroup<StrumNote>();
		for (i in 0...Note.colArray.length)
		{
			var note:StrumNote = new StrumNote(370 + (560 / Note.colArray.length) * i, -200, i, 0);
			note.centerOffsets();
			note.centerOrigin();
			note.playAnim('static');
			notes.add(note);
		}

		// options

		var noteSkins:Array<String> = Paths.mergeAllTextsNamed('images/noteSkins/list.txt', 'shared');
		if(noteSkins.length > 0)
		{
			if(!noteSkins.contains(ClientPrefs.noteSkin))
				ClientPrefs.noteSkin = ClientPrefs.noteSkin; //Reset to default if saved noteskin couldnt be found

			noteSkins.insert(0, ClientPrefs.noteSkin); //Default skin always comes first
			var option:Option = new Option('Note Skins:',
				"Select your prefered Note skin.",
				'noteSkin',
				'string',
				noteSkins);
			addOption(option);
			option.onChange = onChangeNoteSkin;
			noteOptionID = optionsArray.length - 1;
		}
		
		var noteSplashes:Array<String> = Paths.mergeAllTextsNamed('images/noteSplashes/list.txt', 'shared');
		if(noteSplashes.length > 0)
		{
			if(!noteSplashes.contains(ClientPrefs.splashSkin))
				ClientPrefs.splashSkin = ClientPrefs.splashSkin; //Reset to default if saved splashskin couldnt be found

			noteSplashes.insert(0, ClientPrefs.splashSkin); //Default skin always comes first
			var option:Option = new Option('Note Splashes:',
				"Select your prefered Note Splash variation or turn it off.",
				'splashSkin',
				'string',
				noteSplashes);
			addOption(option);
		}

		var option:Option = new Option('Controller Mode', 'Check this if you want to play with\na controller instead of using your Keyboard.',
			'controllerMode', 'bool', #if android true #else false #end);
		addOption(option);

		var option:Option = new Option('Note Splashes', "If unchecked, hitting \"Sick!\" notes won't show particles.", 'noteSplashes', 'bool', true);
		addOption(option);

		var option:Option = new Option('Opponent note glow', "If unchecked, when opponent hit note its not gonna show glow.", 'opponentArrowGlow', 'bool',
			true);
		addOption(option);

		var option:Option = new Option('Hide HUD', 'If checked, hides most HUD elements.', 'hideHud', 'bool', false);
		addOption(option);

		var option:Option = new Option('Hide Watermark', 'If checked, hides watermark with song name, difficulty name and SB Engine version.',
			'hideWatermark', 'bool', false);
		addOption(option);

		var option:Option = new Option('Hide Judgement Counter', 'If checked, hides Judgement Counter.', 'hideJudgementCounter', 'bool', false);
		addOption(option);

		// I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Downscroll', // Name
			'If checked, notes go Down instead of Up, simple enough.', // Description
			'downScroll', // Save data variable name
			'bool', // Variable type
			false); // Default value
		addOption(option);

		var option:Option = new Option('Middlescroll', 'If checked, your notes get centered.', 'middleScroll', 'bool', false);
		addOption(option);

		var option:Option = new Option('Opponent Notes', 'If unchecked, opponent notes get hidden.', 'opponentStrums', 'bool', true);
		addOption(option);

		var option:Option = new Option('Ghost Tapping', "If checked, you won't get misses from pressing keys\nwhile there are no notes able to be hit.",
			'ghostTapping', 'bool', true);
		addOption(option);

		var option:Option = new Option('Disable Reset Button', "If checked, pressing Reset won't do anything.", 'noReset', 'bool', false);
		addOption(option);

		var option:Option = new Option('Camera Zooms', "If unchecked, the camera won't zoom in on a beat hit.", 'camZooms', 'bool', true);
		addOption(option);

		var option:Option = new Option('Score Text Zoom on Hit', "If unchecked, disables the Score text zooming\neverytime you hit a note.", 'scoreZoom',
			'bool', true);
		addOption(option);

		var option:Option = new Option('Results screen',
			"If checked, you will have results screen about your rating, accruracy and rating name when you finish the song.", 'resultsScreen', 'bool', false);
		addOption(option);

		var option:Option = new Option('Combo Stacking',
			"If unchecked, Ratings and Combo won't stack, saving on System Memory and making them easier to read", 'comboStacking', 'bool', true);
		addOption(option);

		var option:Option = new Option('Show time bar',
			"If unchecked, this is gonna unshow time bar on gameplay.", 'showTimeBar', 'bool', true);
		addOption(option);

		var option:Option = new Option('Less lag',
		    "If checked, this is gonna hide your rating counter using botplay.\nIf you enable without botplay, the results can be really weirdo.", 'lessLag', 'bool', false);
		addOption(option);

		var option:Option = new Option('Show playback rate decimal',
		    "If checked, this is gonna show how much do you have deciman on speed for song", 'playbackRateDecimal', 'bool', 'false');
		addOption(option);

		#if android
		var option:Option = new Option('Vibrations', "If unchecked, your phone will not vibrate.", 'vibration', 'bool', true);
		addOption(option);
		option.onChange = onChangeVibration;
		#end

		var option:Option = new Option('Time Bar:', "What should the Time Bar display?", 'timeBarType', 'string', 'Time Left',
			['Time Left', 'Time Elapsed', 'Song Name', 'Song Name + Time', 'Modern Time', 'Modern Time Elapsed', 'Disabled']);
		addOption(option);

		var option:Option = new Option('Watermark style:', "What should the watermark style display?", 'watermarkStyle', 'string', 'SB Engine',
			['SB Engine', 'Kade Engine', 'Dave and Bambi']);
		addOption(option);

		var option:Option = new Option('Health Bar Transparency', 'How much transparent should the health bar and icons be.', 'healthBarAlpha', 'percent', 1);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option('Hitsound Volume', 'Funny notes does \"Tick!\" when you hit them."', 'hitsoundVolume', 'percent', 0);
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = onChangeHitsoundVolume;

		var option:Option = new Option('Rating Offset', 'Changes how late/early you have to hit for a "Sick!"\nHigher values mean you have to hit later.',
			'ratingOffset', 'int', 0);
		option.displayFormat = '%vms';
		option.scrollSpeed = 20;
		option.minValue = -30;
		option.maxValue = 30;
		addOption(option);

		var option:Option = new Option('Sick! Hit Window', 'Changes the amount of time you have\nfor hitting a "Sick!" in milliseconds.', 'sickWindow', 'int',
			45);
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 15;
		option.maxValue = 45;
		addOption(option);

		var option:Option = new Option('Good Hit Window', 'Changes the amount of time you have\nfor hitting a "Good" in milliseconds.', 'goodWindow', 'int',
			90);
		option.displayFormat = '%vms';
		option.scrollSpeed = 30;
		option.minValue = 15;
		option.maxValue = 90;
		addOption(option);

		var option:Option = new Option('Bad Hit Window', 'Changes the amount of time you have\nfor hitting a "Bad" in milliseconds.', 'badWindow', 'int', 135);
		option.displayFormat = '%vms';
		option.scrollSpeed = 60;
		option.minValue = 15;
		option.maxValue = 135;
		addOption(option);

		var option:Option = new Option('Safe Frames', 'Changes how many frames you have for\nhitting a note earlier or late.', 'safeFrames', 'float', 10);
		option.scrollSpeed = 5;
		option.minValue = 2;
		option.maxValue = 10;
		option.changeValue = 0.1;
		addOption(option);

		super();
	}

	override function changeSelection(change:Int = 0)
	{
		super.changeSelection(change);
		
		if(noteOptionID < 0) return;

		for (i in 0...Note.colArray.length)
		{
			var note:StrumNote = notes.members[i];
			if(notesTween[i] != null) notesTween[i].cancel();
			if(curSelected == noteOptionID)
				notesTween[i] = FlxTween.tween(note, {y: noteY}, Math.abs(note.y / (200 + noteY)) / 3, {ease: FlxEase.quadInOut});
			else
				notesTween[i] = FlxTween.tween(note, {y: -200}, Math.abs(note.y / (200 + noteY)) / 3, {ease: FlxEase.quadInOut});
		}
	}

	function onChangeNoteSkin()
	{
		notes.forEachAlive(function(note:StrumNote) {
			changeNoteSkin(note);
			note.centerOffsets();
			note.centerOrigin();
		});
	}

	function changeNoteSkin(note:StrumNote)
	{
		var skin:String = Note.defaultNoteSkin;
		var customSkin:String = skin + Note.getNoteSkinPostfix();
		if(Paths.fileExists('images/$customSkin.png', IMAGE)) skin = customSkin;

		note.texture = skin; //Load texture and anims
		note.reloadNote();
		note.playAnim('static');
	}

	function onChangeHitsoundVolume() {
		FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
	}

	#if android
	function onChangeVibration() {
		if (ClientPrefs.vibration) {
			Hardware.vibrate(500);
		}
	}
	#end
}
