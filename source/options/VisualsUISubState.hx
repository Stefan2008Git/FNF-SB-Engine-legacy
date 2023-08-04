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


using StringTools;

class VisualsUISubState extends BaseOptionsMenu {
	public function new() {
		title = 'Visuals and UI';
		rpcTitle = 'Visuals & UI Settings Menu'; // for Discord Rich Presence

		var option:Option = new Option('Flashing Lights', 
	        "Uncheck this if you're sensitive to flashing lights!", 'flashing', 'bool', true);
		addOption(option);

		var option:Option = new Option('FPS Counter', 'If unchecked, hides FPS Counter.', 'showFPS', 'bool', true);
		addOption(option);
		option.onChange = onChangeFPSCounter;

		var option:Option = new Option('Memory counter', 
		"If unchecked, hides memory's.\nRequest: You need to turn on FPS counter first!", 'memory', 'bool', false);
		addOption(option);

		var option:Option = new Option('Total Memory counter',
			"If unchecked, hides total memory's.\nRequest: You need to turn on FPS counter and Memory counter first!", 'totalMemory', 'bool', false);
		addOption(option);

		var option:Option = new Option('Engine version counter',
			"If unchecked, hides current SB and Psych Engine version.\nRequest: You need to turn on FPS counter first!", 'engineVersion', 'bool', false);
		addOption(option);

		var option:Option = new Option('Debug info counter', 
		    "If unchecked, hides debug info.\nRequest: You need to turn on FPS counter first!", 'debugInfo', 'bool', false);
		addOption(option);

		var option:Option = new Option('Rainbow FPS',
			"If checked, enables radnom color's for FPS.\nRequest: You need to turn on FPS counter first!\nWarning: Rainbow FPS maybe can be a little bit buggy!", 'rainbowFPS', 'bool', false);
		addOption(option);

		var option:Option = new Option('Velocity background', 
		    'If unchecked, this option is disabling velocity background for optimization.', 'velocityBackground', 'bool', true);
		addOption(option);

		var option:Option = new Option('Effects on objects',
			'If unchecked, this option is disabling every single effects on object for optimization.\nExample: Logo and girlfriend using FlxTrail',
			'objectEffects', 'bool', true);
		addOption(option);

		var option:Option = new Option('Pause Screen Song:', "What song do you prefer for the Pause Screen?", 'pauseMusic', 'string', 'Tea Time',
			['None', 'Breakfast', 'Tea Time']);
		addOption(option);
		option.onChange = onChangePauseMusic;

		var option:Option = new Option('Game engine type:', "What should the style on game do you you want to look like?", 'gameStyle', 'string', 'SB Engine',
			['SB Engine', 'Psych Engine', 'Better UI']);
		addOption(option);

		var option:Option = new Option('Simple Main Menu',
			'Change main menu style.\nOriginal - Original main menu with animated sprites.\nClassic - Basic main menu without sprites, but with alphabet text.',
			'mainMenuStyle', 'string', 'Original', // Credits:  Joalor64 (Creator of Joalor64 Engine Rewriten.)
			['Classic', 'Original']);
		addOption(option);

		var option:Option = new Option('Colorblind Filter',
			'You can set colorblind filter (makes the game more playable for colorblind people)\nCredits: notweuz (Creator of OS Engine.)', 'colorblindMode',
			'string', 'None', ['None', 'Deuteranopia', 'Protanopia', 'Tritanopia']);

		var option:Option = new Option('Themes:', 
		    'Change theme from different engines. More themes are coming very soon\nThis option is on alpha state, so maybe can be buggy.', 'themes',
		    'string', 'SB Engine', ['SB Engine', 'Psych Engine']);
		addOption(option);

		super();
	}

	var changedMusic:Bool = false;

	function onChangePauseMusic() {
		if (ClientPrefs.pauseMusic == 'None')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)));

		changedMusic = true;
	}

	override function destroy() {
		if (changedMusic)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		super.destroy();
	}

	function onChangeFPSCounter() {
		if (Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.showFPS;
	}
}
