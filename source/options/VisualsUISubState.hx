package options;

import substates.PauseSubState;
import lime.utils.Assets;
import flixel.util.FlxSave;
import haxe.Json;

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

		var option:Option = new Option ('Total FPS', 
		'If unchecked, hides second FPS\nRequest: You need to turn on FPS counter first!', 'totalFPS', 'bool', false);
		addOption(option);

		var option:Option = new Option('Memory counter', 
		"If unchecked, hides memorys.\nRequest: You need to turn on FPS counter first!", 'memory', 'bool', false);
		addOption(option);

		var option:Option = new Option('Total Memory counter',
			"If unchecked, hides total memorys.\nRequest: You need to turn on FPS counter first!", 'totalMemory', 'bool', false);
		addOption(option);

		var option:Option = new Option('Engine version counter',
			"If unchecked, hides current SB and Psych Engine version.\nRequest: You need to turn on FPS counter first!", 'engineVersion', 'bool', false);
		addOption(option);

		var option:Option = new Option('Toast core',
		    "If unchecked, disables toast core.", 'toastCore', 'bool', true);
		addOption(option);
		option.onChange = function() {
            if (ClientPrefs.toastCore) Main.toast.create('Toast core', 0xFF00FF15, 'Enabled');
            else Main.toast.create('Toast core', 0xFFFF0000, 'Disabled.');
        }

		var option:Option = new Option('Velocity background', 
		    'If unchecked, this option is disabling velocity background for optimization.', 'velocityBackground', 'bool', true);
		addOption(option);

		var option:Option = new Option('Objects',
			'If unchecked, this option is disabling every single object for optimization.\nExample: Logo and girlfriend using FlxTrail',
			'objects', 'bool', true);
		addOption(option);

		var option:Option = new Option('Pause Screen Song:', "What song do you prefer for the Pause Screen?", 'pauseMusic', 'string', 'Tea Time',
			['None', 'Breakfast', 'Tea Time']);
		addOption(option);
		option.onChange = onChangePauseMusic;

		var option:Option = new Option('Main Menu Song:', "What song do you prefer for the Main Menu Screen?", 'mainMenuMusic', 'string', 'FNF',
			['FNF', 'SB Engine', 'Future']);
		addOption(option);
		option.onChange = onChangeMainMenuMusic;

		var option:Option = new Option('Game engine type:', "What should the style on game do you you want to look like?", 'gameStyle', 'string', 'SB Engine',
			['SB Engine', 'Psych Engine']);
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

	var mainMenuMusicChanged:Bool = false;
	function onChangeMainMenuMusic()
	{
		if (ClientPrefs.mainMenuMusic != 'FNF') FlxG.sound.playMusic(Paths.music('freakyMenu-' + ClientPrefs.mainMenuMusic));
		if (ClientPrefs.mainMenuMusic == 'FNF') FlxG.sound.playMusic(Paths.music('freakyMenu'));
		mainMenuMusicChanged = true;
	}


	override function destroy() {
		if (changedMusic && !PauseSubState.optionMenu) FlxG.sound.playMusic(Paths.music('freakyMenu-' + ClientPrefs.mainMenuMusic));
		super.destroy();
	}

	function onChangeFPSCounter() {
		if (Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.showFPS;
	}
}
