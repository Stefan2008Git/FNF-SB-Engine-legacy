package states;

#if desktop
import backend.Discord.DiscordClient;
#end
import backend.ClientPrefs;
import backend.MusicBeatState;
import backend.Paths;
import states.MainMenuState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;

class FlashingScreenState extends MusicBeatState {
	public static var leftState:Bool = false;

	var background:FlxSprite;
	var velocityBackground:FlxBackdrop;
	var warningText:FlxText;
	var warningTextTween:FlxTween;

	override function create() {
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		FlxG.sound.playMusic(Paths.music('warningScreenMusic'), 0.5);

		super.create();

		#if desktop
	    // Updating Discord Rich Presence
	    DiscordClient.changePresence("Warning screen", null);
	    #end

		background = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		background.scrollFactor.set();
		background.updateHitbox();
		background.screenCenter();
		background.antialiasing = ClientPrefs.globalAntialiasing;
		background.color = 0xFF353535;
		add(background);

		velocityBackground = new FlxBackdrop(FlxGridOverlay.createGrid(30, 30, 60, 60, true, 0x3B161932, 0x0), XY);
		velocityBackground.velocity.set(FlxG.random.bool(50) ? 90 : -90, FlxG.random.bool(50) ? 90 : -90);
		velocityBackground.visible = ClientPrefs.velocityBackground;
		add(velocityBackground);

		#if android
		warningText = new FlxText(0, 0, FlxG.width,
			"WARNING:\nBe careful when you touch the phone fast! \nYou can break your phone screen if you do that, also\nFNF': SB Engine contains lua shaders and flashing lights.\n\n"
			+ "FNF': SB Engine are modified Psych Engine with some changes and additions and wasn't meant to be an attack on ShadowMario"
			+ " and/or any other modmakers out there. I'm not aiming for replacing what Friday Night Funkin': Psych Engine was, is and will be."
			+
			" It's made for fun and from the love for the game itself. All of the comparisons between this and other mods are purely coincidental, unless stated otherwise.\n\n"
			+
			"Now with that out of the way, I hope you'll enjoy this FNF mod.\nFunk all the way.\nPress A to proceed.\nPress B to ignore this message.\nCurrent SB Engine version: "
			+ MainMenuState.sbEngineVersion
			+ "",
			32);
		#else
		warningText = new FlxText(0, 0, FlxG.width,
		"WARNING:\nFNF': SB Engine contains lua shaders and flashing lights.\n\n"
			+ "FNF': SB Engine are modified Psych Engine with some changes and additions and wasn't meant to be an attack on ShadowMario"
			+ " and/or any other modmakers out there. I'm not aiming for replacing what Friday Night Funkin': Psych Engine was, is and will be."
			+
			" It's made for fun and from the love for the game itself. All of the comparisons between this and other mods are purely coincidental, unless stated otherwise.\n\n"
			+

			"Now with that out of the way, I hope you'll enjoy this FNF mod.\nFunk all the way.\nPress ENTER to proceed.\nPress ESCAPE to ignore this message.\nCurrent SB Engine version it's: "
			+ MainMenuState.sbEngineVersion
			+ "",
			32);
		#end
		warningText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		warningText.borderSize = 2.4;
		warningText.screenCenter(Y);
		warningText.alpha = 0;
		warningText.scale.x = 0;
		warningText.scale.y = 0;
		add(warningText);

		#if android
		addVirtualPad(NONE, A_B);
		#end

		FlxTween.tween(warningText, {alpha: 1}, 0.75, {ease: FlxEase.quadInOut});
		warningTextTween = FlxTween.tween(warningText.scale, {x: 1, y: 1}, 0.75, {ease: FlxEase.quadInOut});
	}

	override function update(elapsed:Float) {
		if (!leftState) {
			var back:Bool = controls.BACK;
			if (controls.ACCEPT || back) {
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				if (!back) {
					ClientPrefs.flashing = false;
					ClientPrefs.saveSettings();
					FlxG.sound.play(Paths.sound('confirmMenu'));
					#if android
					FlxTween.tween(virtualPad, {alpha: 0}, 1);
					#end
					FlxTween.tween(background, {alpha: 0}, 0.25, {startDelay: 0.25});
					FlxTween.tween(warningText, {alpha: 0}, 0.25, {startDelay: 0.25});
					FlxTween.tween(warningText.scale, {x: 1.5, y: 1.5}, .5,
						{ease: FlxEase.quadIn, onComplete: (_) -> new FlxTimer().start(0.5, (t) -> MusicBeatState.switchState(new TitleScreenState()))});
					FlxTween.tween(velocityBackground, {alpha: 0}, 0.25, {startDelay: 0.25});
					FlxTween.tween(FlxG.sound.music, {volume: 0}, 0.8);
				} else {
					FlxG.sound.play(Paths.sound('cancelMenu'));
					#if android
					FlxTween.tween(virtualPad, {alpha: 0}, 1);
					#end
					FlxTween.tween(background, {alpha: 0}, 0.25, {startDelay: 0.25});
					FlxTween.tween(warningText, {alpha: 0}, 0.25, {startDelay: 0.25});
					FlxTween.tween(warningText.scale, {x: 0, y: 0}, .5,
						{ease: FlxEase.quadIn, onComplete: (_) -> new FlxTimer().start(0.5, (t) -> MusicBeatState.switchState(new TitleScreenState()))});
					FlxTween.tween(velocityBackground, {alpha: 0}, 0.25, {startDelay: 0.25});
					FlxTween.tween(FlxG.sound.music, {volume: 0}, 0.8);
				}
			}
		}
		super.update(elapsed);
	}
}
