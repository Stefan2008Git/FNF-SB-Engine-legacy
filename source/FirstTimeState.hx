package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class FirstTimeState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	override function create()
	{
		FlxTween.tween(Application.current.window, {y: lol}, 0.5, {ease: FlxEase.circOut});

		#if desktop
		DiscordClient.changePresence("First time on Unknown Engine.", null);
		#end

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.ORANGE);
		add(bg);

		warnText = new FlxText(0, 0, FlxG.width,
			"Welcome note:\nWelcome to Friday Night Funkin': SB Engine.\n\n"
			+ "This is fork of the Psych Engine with some changes and more."
			+ "Friday Night Funkin is was maked by: ninjaaMuffin99, PhantomArcade, evilsk8r and KawaiSprite."
			+ " It was made for fun and from the love for the game itself. All of the comparisons between this and other mods are purely coincidental, unless stated otherwise.\n\n"
			+ "Now with that out of the way, I hope you'll enjoy this FNF mod.\nFunk all the way.\nPress ENTER to proceed",
			32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		warnText.screenCenter(Y);
		add(warnText);

		#if android
		addVirtualPad(NONE, A_B);
		#end

		super.create();	
	}

	override function update(elapsed:Float)
	{
		var no:Bool = false;
		sinMod += 0.007;
		warnText.y = Math.sin(sinMod) * 60 + 100;

		if (FlxG.keys.justPressed.ENTER)
		{
			ClientPrefs.firstTime = false;
			leftState = true;
			ClientPrefs.saveSettings();
			FlxG.switchState(new Cache());
		}

		super.update(elapsed);
	}
}