package options;

import lime.utils.Assets;
import flixel.util.FlxSave;
import haxe.Json;
import openfl.Lib;

using StringTools;

class GraphicsSettingsSubState extends BaseOptionsMenu {
	public function new() {
		title = 'Graphics';
		rpcTitle = 'Graphics Settings Menu'; // for Discord Rich Presence

		// I'd suggest using "Low Quality" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Low Quality', // Name
			'If checked, disables some background details,\ndecreases loading times and improves performance.', // Description
			'lowQuality', // Save data variable name
			'bool', // Variable type
			false); // Default value
		addOption(option);

		var option:Option = new Option('Anti-Aliasing', 'If unchecked, disables anti-aliasing, increases performance\nat the cost of sharper visuals.',
			'globalAntialiasing', 'bool', true);
		option.onChange = onChangeAntiAliasing;
		addOption(option);

		var option:Option = new Option('Shaders on lua', // Name
			'If unchecked, disables lua shaders.\nIt\'s used for some visual effects, and also CPU intensive for weaker PCs and Android phones.\nOriginal lua shaders maked on old version of Psych Engine', // Description
			'shaders', // Save data variable name
			'bool', // Variable type
			true); // Default value
		addOption(option);

		var option:Option = new Option('GPU Caching', 'If checked, this is gonna cache your graphic card.\nDont enable if you have bad graphic driver on your device!', 'gpuCaching', 'bool', false);
		addOption(option);

		#if !html5 // Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync freak enabled by default, idk
		var option:Option = new Option('Framerate', "Changed framerate for your experience.", 'framerate', 'int', 60);
		addOption(option);

		option.minValue = 60;
		option.maxValue = 240;
		option.displayFormat = '%v FPS';
		option.onChange = onChangeFramerate;
		#end

		super();
	}

	function onChangeAntiAliasing() {
		for (sprite in members) {
			var sprite:Dynamic = sprite; // Make it check for FlxSprite instead of FlxBasic
			var sprite:FlxSprite = sprite; // Don't judge me ok
			if (sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) {
				sprite.antialiasing = ClientPrefs.globalAntialiasing;
			}
		}
	}

	function onChangeFramerate() {
		if (ClientPrefs.framerate > FlxG.drawFramerate) {
			FlxG.updateFramerate = ClientPrefs.framerate;
			FlxG.drawFramerate = ClientPrefs.framerate;
		} else {
			FlxG.drawFramerate = ClientPrefs.framerate;
			FlxG.updateFramerate = ClientPrefs.framerate;
		}
	}
}
