package options;

#if desktop
import backend.Discord.DiscordClient;
#end
import backend.MusicBeatState;
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
import lime.app.Application;
import backend.ClientPrefs;
import backend.Controls;
import backend.Paths;
import objects.Alphabet;
import states.ClassicMainMenuState;
import states.MainMenuState;
import states.PlayState;
import substates.PauseSubState;

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
	private static var currentlySelected:Int = 0;

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
				MusicBeatState.switchState(new options.NoteOffsetState());
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;
	var background:FlxSprite;
	var velocityBackground:FlxBackdrop;
	var androidControlsStyleTipText:FlxText;
	var customizeAndroidControlsTipText:FlxText;

	override function create() {
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		background = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		if (ClientPrefs.themes == 'SB Engine') {
			background.color = 0xFF800080;
		}
		if (ClientPrefs.themes == 'Psych Engine') {
			background.color = 0xFFea71fd;
		}
		background.screenCenter();
		background.antialiasing = ClientPrefs.globalAntialiasing;
		background.updateHitbox();
		add(background);

		velocityBackground = new FlxBackdrop(FlxGridOverlay.createGrid(30, 30, 60, 60, true, 0x3B161932, 0x0), XY);
		velocityBackground.velocity.set(FlxG.random.bool(50) ? 90 : -90, FlxG.random.bool(50) ? 90 : -90);
		velocityBackground.visible = ClientPrefs.velocityBackground;
		velocityBackground.alpha = 0;
		FlxTween.tween(velocityBackground, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(velocityBackground);

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
		androidControlsStyleTipText = new FlxText(10, FlxG.height - 44, 0, 'Press Y to customize your opacity for hitbox, virtual pads and hitbox style!', 16);
		customizeAndroidControlsTipText = new FlxText(10, FlxG.height - 24, 0, 'Press X to customize your android controls!', 16);
		switch (ClientPrefs.gameStyle) {
		    case 'SB Engine':
				androidControlsStyleTipText.setFormat("Bahnschrift", 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				customizeAndroidControlsTipText.setFormat("Bahnschrift", 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		    
		    case 'Psych Engine':
			    androidControlsStyleTipText.setFormat("VCR OSD Mono", 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			    customizeAndroidControlsTipText.setFormat("VCR OSD Mono", 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		    case 'Better UI':
			    androidControlsStyleTipText.setFormat("VCR OSD Mono", 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			    customizeAndroidControlsTipText.setFormat("VCR OSD Mono", 17, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}

		androidControlsStyleTipText.borderSize = 1.25;
		androidControlsStyleTipText.scrollFactor.set();
		customizeAndroidControlsTipText.borderSize = 1.25;
		customizeAndroidControlsTipText.scrollFactor.set();
		add(androidControlsStyleTipText);
		add(customizeAndroidControlsTipText);
		#end

		changeSelection();
		ClientPrefs.saveSettings();

		#if android
		addVirtualPad(UP_DOWN, A_B_X_Y);
		virtualPad.y = -44;
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
				Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Current song: " + PlayState.SONG.song;
				PauseSubState.optionMenu = false;
			} else {
				if (ClientPrefs.mainMenuStyle == 'Classic') {
					MusicBeatState.switchState(new ClassicMainMenuState());
					Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion;
				} else {
					MusicBeatState.switchState(new MainMenuState());
					Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion;
				}
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
			openSubState(new android.AndroidControlsSettingsSubState());
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
