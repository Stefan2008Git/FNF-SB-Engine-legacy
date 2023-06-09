package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;
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
import Controls;

using StringTools;

class OptionsState extends MusicBeatState {
	var options:Array<String> = [
		'Note Colors',
		'Controls',
		'Adjust Delay and Combo',
		'Graphics',
		'Visuals and UI',
		'Gameplay'
	];
	private var optionsSelect:FlxTypedGroup<Alphabet>;
	var tipText:FlxText;

	private static var currentlySelected:Int = 0;
	public static var menuBG:FlxSprite;

	function openSelectedSubstate(label:String) {
		switch (label) {
			case 'Note Colors':
				#if android
				removeVirtualPad();
				#end
				openSubState(new options.NotesSubState());
			case 'Controls':
				#if android
				removeVirtualPad();
				#end
				openSubState(new options.ControlsSubState());
			case 'Graphics':
				#if android
				removeVirtualPad();
				#end
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals and UI':
				#if android
				removeVirtualPad();
				#end
				openSubState(new options.VisualsUISubState());
			case 'Gameplay':
				#if android
				removeVirtualPad();
				#end
				openSubState(new options.GameplaySettingsSubState());
			case 'Adjust Delay and Combo':
				LoadingState.loadAndSwitchState(new options.NoteOffsetState());
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;
	var background:FlxSprite;
	var velocityBG:FlxBackdrop;

	override function create() {
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		background = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		background.color = 0xFF800080;
		background.screenCenter();
		background.antialiasing = ClientPrefs.globalAntialiasing;
		background.updateHitbox();
		add(background);

		velocityBG = new FlxBackdrop(Paths.image('velocity_background'));
		velocityBG.velocity.set(FlxG.random.bool(50) ? 90 : -90, FlxG.random.bool(50) ? 90 : -90);
		if (ClientPrefs.velocityBackground) {
			velocityBG.visible = true;
		} else {
			velocityBG.visible = false;
		}
		add(velocityBG);

		optionsSelect = new FlxTypedGroup<Alphabet>();
		add(optionsSelect);

		for (i in 0...options.length) {
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true);
			optionText.x = 128;
			optionText.screenCenter(Y);
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			optionsSelect.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '>', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		add(selectorRight);

		#if android
		tipText = new FlxText(10, FlxG.height - 24, 0, 'Press X to customize your android controls!', 16);
		tipText.setFormat("Bahnschrift", 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipText.borderSize = 1.25;
		tipText.scrollFactor.set();
		add(tipText);
		tipText = new FlxText(10, FlxG.height - 44, 0, 'Press Y to customize your hitbox mode!', 16);
		tipText.setFormat("Bahnschrift", 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipText.borderSize = 1.25;
		tipText.scrollFactor.set();
		add(tipText);
		#end

		changeSelection();
		ClientPrefs.saveSettings();

		#if android
		addVirtualPad(UP_DOWN, A_B_X_Y);
		virtualPad.y = -48;
		#end

		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
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
			if (PauseSubState.optionMenu) {
				MusicBeatState.switchState(new PlayState());
				PauseSubState.optionMenu = false;
			} else {
				if (ClientPrefs.mainMenuStyle == 'Classic')
					MusicBeatState.switchState(new ClassicMainMenuState());
				else
					MusicBeatState.switchState(new MainMenuState());
			}
		}

		if (controls.ACCEPT) {
			openSelectedSubstate(options[currentlySelected]);
		}

		#if android
		if (virtualPad.buttonX.justPressed) {
			#if android
			removeVirtualPad();
			#end
			openSubState(new android.AndroidControlsSubState());
		}
		if (virtualPad.buttonY.justPressed) {
			#if android
			removeVirtualPad();
			#end
			openSubState(new android.AndroidHitboxSelectorSubState());
		}
		#end
	}

	function changeSelection(change:Int = 0) {
		currentlySelected += change;
		if (currentlySelected < 0)
			currentlySelected = options.length - 1;
		if (currentlySelected >= options.length)
			currentlySelected = 0;

		var optionFreak:Int = 0;

		for (item in optionsSelect.members) {
			item.targetY = optionFreak - currentlySelected;
			optionFreak++;

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
