package android;

#if desktop
import backend.Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
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
import backend.Controls;
import options.BaseOptionsMenu;
import options.Option;
import openfl.Lib;

using StringTools;

class AndroidControlsSettingsSubState extends BaseOptionsMenu {
	public function new() {
		title = 'Android settings for virtual pads and hitbox';
		rpcTitle = 'Virtual pads and hitbox Menu';

		var option:Option = new Option('Hitbox Style:', "Choose your hitbox style how are want to look like on gameplay.", 'hitboxSelection', 'string',
			'Original', ['Original', 'New']); // Credits: MarioMaster (Created hitbox selector)
		addOption(option);

		var option:Option = new Option('Hitbox Opacity:', 'Change hitbox opacity\nNote: (Using to much opacity its gonna be so weird on gameplay!)',
			'hitboxAlpha', 'float', 0.2); // Credits: MarioMaster (Created hitbox opacity)
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option('Virtual pad Opacity:', 'Changes virtual pad opacity', 'virtualPadAlpha', 'float',
			0.5); // Credits: MarioMaster (Created hitbox opacity)
		option.scrollSpeed = 1.6;
		option.minValue = 0.1;
		option.maxValue = 1;
		option.changeValue = 0.01;
		option.decimals = 2;
		addOption(option);

		var option:Option = new Option('Space Extend',
			"Allow Extend Space Control. --Made by NF | Beihu", // Credits: NF | Beihu (Created hitbox space)
			'hitboxSpace',
			'bool',
			true);
		  addOption(option);
		  
		var option:Option = new Option('Space Location:',
			"Choose Space Control Location. --Made by NF | Beihu", // Credits: NF | Beihu (Created hitbox space)
			'hitboxSpaceLocation',
			'string',
			'Bottom',
			['Bottom', 'Middle', 'Top']);
		  addOption(option);  

		super();
	}
}
