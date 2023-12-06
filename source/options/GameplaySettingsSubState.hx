package options;

import lime.utils.Assets;
import flixel.util.FlxSave;
import haxe.Json;
#if android
import android.Hardware;
#end

using StringTools;

class GameplaySettingsSubState extends BaseOptionsMenu {
	public function new() {
		title = 'Gameplay Settings';
		rpcTitle = 'Gameplay Settings Menu'; // for Discord Rich Presence

		var option:Option = new Option('Controller Mode', 'Check this if you want to play with\na controller instead of using your Keyboard.', 'controllerMode', 'bool', #if android true #else false #end);
		addOption(option);

		var option:Option = new Option('Note Splashes', "If unchecked, hitting \"Sick!\" notes won't show particles.", 'noteSplashes', 'bool', true);
		addOption(option);

		var option:Option = new Option('Opponent note glow', "If unchecked, when opponent hit note its not gonna show glow.", 'opponentArrowGlow', 'bool', true);
		addOption(option);

		var option:Option = new Option('Hide HUD', 'If checked, hides most HUD elements.', 'hideHud', 'bool', false);
		addOption(option);

		var option:Option = new Option('Watermark', 'If unchecked, hides watermark with song name, difficulty name and SB Engine version.',
			'watermark', 'bool', true);
		addOption(option);

		var option:Option = new Option('Judgement Counter', 'If unchecked, hides Judgement Counter.', 'judgementCounter', 'bool', true);
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

		var option:Option = new Option('Score Text Zoom on Hit', "If unchecked, disables the Score text zooming\neverytime you hit a note.", 'scoreZoom', 'bool', true);
		addOption(option);

		var option:Option = new Option('Judgement Text Zoom on Hit', "If unchecked, disables the Judgement Counter text zooming\neverytime you hit a note.", 'judgementZoom', 'bool', true);
		addOption(option);

		#if desktop
		var option:Option = new Option('Show Keybinds on start', "If unchecked, disables to show keybind text when arrows gonna to start tween.", 'showKeybindsOnStart',  'bool', true);
		addOption(option);
		#end

		var option:Option = new Option('Icon bounce', "If unchecked, disables icon bounce for SB Engine HUD only.", 'iconBounce',  'bool', true);
		addOption(option);

		var option:Option = new Option('Health tween',  "If unchecked, disables health tween and reverts to normal state for health.", 'healthTween', 'bool', true);
		addOption(option);

		var option:Option = new Option('Rating images', "If unckecked, disables rating images.", 'ratingImages', 'bool', true);
		addOption(option);

		var option:Option = new Option('Results screen',
			"If checked, you will have results screen about your rating, accruracy and rating name when you finish the song.", 'resultsScreen', 'bool', false);
		addOption(option);

		var option:Option = new Option('Combo Stacking',
			"If unchecked, Ratings and Combo won't stack, saving on System Memory and making them easier to read", 'comboStacking', 'bool', true);
		addOption(option);

		var option:Option = new Option('Missed Combo Stacking',
			"If unchecked, Missed Combo won't stack, saving on System Memory and making them easier to read", 'missedComboStacking', 'bool', true);
		addOption(option);

		var option:Option = new Option('Show time bar',
			"If unchecked, this is gonna unshow time bar on gameplay.", 'showTimeBar', 'bool', true);
		addOption(option);

		var option:Option = new Option('Show playback speed decimal',
		    "If checked, this is gonna show how much do you have deciman on speed for song", 'playbackRateDecimal', 'bool', 'false');
		addOption(option);

		var option:Option = new Option('Show time percent',
		    "If checked, this is gonna show how much do you have percent for song time", 'timePercent', 'bool', 'true');
		addOption(option);

		var option:Option = new Option('Song intro card', 'If unchecked, this is gonna hides song intro card.', 'songIntro', 'bool', 'true');
		addOption(option);

		var option:Option = new Option('Miss sound',
		    "If unchecked, this is gonna disable sound when you are missing the note.", 'missSound', 'bool', 'true');
		addOption(option);

		var option:Option = new Option('Average Miliseconds',
		    "If unchecked, this is gonna hides Miliseconds \"(ms)\" when you hit a note on average.", 'averageMiliseconds', 'bool', 'true');
		addOption(option);

		var option:Option = new Option('Lane Underlay',
		    "If checked, this options is gonna make to show black background to make your game to focus on notes when are you playing a song.", 'laneunderlay', 'bool', false);
		addOption(option);

		var option:Option = new Option('Random engine names',
		    "If checked, this options is gonna make to show random engine names (aka. Usernames for example) instead of SB.", 'randomEngineNames', 'bool', false);
		addOption(option);

		var option:Option = new Option('Less CPU controller',
		    "If checked, this options is gonna make cpu controller (aka. Botplay) less laggy", 'lessCpuController', 'bool', false);
		addOption(option);

		var option:Option = new Option('Camera movement',
		    "If checked, this options is gonna make camera movementable when you are hitting the note", 'cameraMovement', 'bool', false);
		addOption(option);

		var option:Option = new Option('Botplay text on time bar',
		    "If unchecked, this options is gonna hide the botplay text from time bar\nto show normal time bar", 'botplayOnTimebar', 'bool', false);
		addOption(option);

		var option:Option = new Option('Quick note angle spin',
			"If unckecked, this option is gonna make note spinnable on go counter from Bambi Purgatory\nNOTE: If WhatsDown wants me top remove hims code, i will to do that!", 'noteAngleSpin', 'bool', true);
		addOption(option);

		var option:Option = new Option('Health Color on time bar',
			"If ckecked, the time bar color from purple will change the opponent health bar color from icon", 'colorBars', 'bool', false);
		addOption(option);

		var option:Option = new Option('Sine alpha',
			"If unckecked, the object txt is gonna to do alpha sine with elapsed", 'objectTxtSine', 'bool', true);
		addOption(option);

		#if android
		var option:Option = new Option('Vibrations', "If unchecked, your phone will not vibrate.", 'vibration', 'bool', true);
		addOption(option);
		option.onChange = onChangeVibration;
		#end

		var option:Option = new Option('Time Bar:', "What should the Time Bar display?", 'timeBarType', 'string', 'Time Elapsed',
			['Time Left', 'Time Elapsed', 'Song Name', 'Song Name + Time', 'Modern Time', 'Disabled']);
		addOption(option);

		var option:Option = new Option('Watermark style:', "What should the watermark style display?", 'watermarkStyle', 'string', 'SB Engine',
			['SB Engine', 'Kade Engine']);
		addOption(option);

		var option:Option = new Option('Judgement style:', "What should the judgement style display?", 'judgementCounterStyle', 'string', 'Original',
			['Original', 'With Misses', 'Better Judge']);
		addOption(option);

		var option:Option = new Option('Health Bar Transparency', 'How much transparent should the health bar and icons be?', 'healthBarAlpha', 'percent', 1);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option('Lane Underlay Transparency', 'How much transparent should the lane underlay be?', 'laneunderlayAlpha', 'percent', 1);
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

		var option:Option = new Option('Impressive Hit Window', 'Changes the amount of time you have\nfor hitting a "Impressive" in milliseconds.', 'impressiveWindow', 'int',
			25);
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 1;
		option.maxValue = 20;
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

		var option:Option = new Option('% Decimals: ',
			"The amount of decimals you want for your Song Percentage. (0 means no decimals)",
			'timePercentValue',
			'int',
			2);
		addOption(option);

		option.minValue = 0;
		option.maxValue = 50;
		option.displayFormat = '%v Decimals';

		super();
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
