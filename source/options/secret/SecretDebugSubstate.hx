package options.secret;

import flixel.addons.transition.FlxTransitionableState;

class SecretDebugSubstate extends BaseOptionsMenu
{
    public function new() {
        title = 'Secret Debug Menu';
		rpcTitle = 'In Secret Debug Menu'; // for Discord Rich Presence

        var option:Option = new Option('Debug info counter', 
		    "If unchecked, hides debug info.\nRequest: You need to turn on FPS counter first!", 'debugInfo', 'bool', false);
		addOption(option);

		var option:Option = new Option('Rainbow FPS',
			"If checked, enables radnom colors for FPS.\nRequest: You need to turn on FPS counter first!", 'rainbowFPS', 'bool', false);
		addOption(option);

        var option:Option = new Option("Skip Transitions",
			"If checked, skips the transition animations between screens.", 'skipFadeTransition', 'bool', false);
		addOption(option);

		var option:Option = new Option('Auto pause',
		    "If uncecked, the game will stop your process if you are outside from game", 'autoPause', 'bool', true);
		addOption(option);

        #if desktop
		var option:Option = new Option('Discord RPC',
		    'If unchecked, this to prevent accidental leaks, it will hide the Application from your \"Playing\" box on Discord',
			'discordRPC', 'bool', true);
		addOption(option);
		#end

        super();
    }
}