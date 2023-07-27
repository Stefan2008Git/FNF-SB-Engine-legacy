package states;

import backend.ClientPrefs;
#if desktop
import backend.Discord.DiscordClient;
#end
import backend.MusicBeatState;
import backend.Paths;
import objects.Alphabet;
import states.MainMenuState;
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
import backend.Controls;
import flixel.addons.display.FlxBackdrop;
import flash.system.System;
import lime.app.Application;

using StringTools;

class GameExitState extends MusicBeatState {
	var options:Array<String> = ['Yes', 'No'];
	private var optionsSelect:FlxTypedGroup<Alphabet>;

	private static var currentlySelected:Int = 0;
	public static var menuBG:FlxSprite;
	public static var menuText:Alphabet;

	var purpleBackground:FlxSprite;
	var checker:FlxBackdrop;
	var alertMessage:String = "";

	function openSelectedState(label:String) {
		switch (label) {
			case 'Yes':
				Application.current.window.alert(alertMessage, "SB Engine v" + MainMenuState.sbEngineVersion);
				#if desktop
				DiscordClient.shutdown();
				#end
				System.exit(1);
			case 'No':
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleScreenState());
				Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion;
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	override function create() {
		#if desktop
		DiscordClient.changePresence("Game Closing Menu", null);
		#end

		purpleBackground = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		purpleBackground.scrollFactor.set();
		purpleBackground.setGraphicSize(Std.int(purpleBackground.width * 1.175));
		purpleBackground.updateHitbox();
		purpleBackground.screenCenter();
		purpleBackground.visible = !ClientPrefs.velocityBackground;
		purpleBackground.antialiasing = ClientPrefs.globalAntialiasing;
		purpleBackground.color = 0xFF800080;
		add(purpleBackground);

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

		menuText = new Alphabet(0, 0, "Quit the game?", true);
		menuText.screenCenter();
		menuText.y -= 150;
		menuText.alpha = 1;
		add(menuText);

		alertMessage += "Alert: " + "\nThanks for using SB Engine";

		optionsSelect = new FlxTypedGroup<Alphabet>();
		add(optionsSelect);

		for (i in 0...options.length) {
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true);
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			optionsSelect.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '>', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		add(selectorRight);

		changeSelection();

		#if android
		addVirtualPad(UP_DOWN, A);
		#end

		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			ClientPrefs.mainMenuStyle == 'Classic' ? MusicBeatState.switchState(new ClassicMainMenuState()) : MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT) {
			openSelectedState(options[currentlySelected]);
		}
	}

	function changeSelection(change:Int = 0) {
		currentlySelected += change;
		if (currentlySelected < 0)
			currentlySelected = options.length - 1;
		if (currentlySelected >= options.length)
			currentlySelected = 0;

		var value:Int = 0;

		for (item in optionsSelect.members) {
			item.targetY = value - currentlySelected;
			value++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}
