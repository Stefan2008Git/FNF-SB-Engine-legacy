package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.addons.display.FlxBackdrop;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxGradient;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import lime.app.Application;
import openfl.display.BitmapData;
import openfl.utils.Assets;
import haxe.Exception;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.FlxState;
import flixel.math.FlxRect;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import lime.system.ThreadPool;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class CacheState extends FlxState {
	var checker:FlxBackdrop;
	var sbEngineLogo:FlxSprite;
	var beginTween:FlxTween;
	var endTween:FlxTween;
	var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 1, 0xFF800080);
	var bottomPanel:FlxSprite;
	var randomTxt:FlxText;
	var loadingSpeen:FlxSprite;
	var loadingTxt:FlxText;

	var isTweening:Bool = false;
	var lastString:String = '';

	override function create() {
		FlxG.worldBounds.set(0, 0);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Starting game...", null);
		#end

		super.create();

		checker = new FlxBackdrop(Paths.image('checker'));
		checker.scrollFactor.set();
		checker.scale.set(0.7, 0.7);
		checker.screenCenter(X);
		checker.velocity.set(150, 80);
		if (ClientPrefs.velocityBackground) {
			checker.visible = true;
		} else {
			checker.visible = false;
		}
		checker.antialiasing = ClientPrefs.globalAntialiasing;
		add(checker);

		sbEngineLogo = new FlxSprite().loadGraphic(Paths.image("sbEngineLogo"));
		sbEngineLogo.screenCenter();
		sbEngineLogo.y -= 60;
		sbEngineLogo.antialiasing = ClientPrefs.globalAntialiasing;
		sbEngineLogo.alpha = 0;
		sbEngineLogo.scale.x = 0;
		sbEngineLogo.scale.y = 0;
		add(sbEngineLogo);

		gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x553D0468, 0xFF800080], 1, 90, true);
		gradientBar.y = FlxG.height - gradientBar.height;
		add(gradientBar);
		gradientBar.scrollFactor.set(0, 0);

		bottomPanel = new FlxSprite(0, FlxG.height - 100).makeGraphic(FlxG.width, 100, 0xFF000000);
		bottomPanel.alpha = 0.5;
		add(bottomPanel);

		randomTxt = new FlxText(20, FlxG.height - 80, 1000, "", 26);
		randomTxt.scrollFactor.set();
		randomTxt.setFormat("Bahnschrift", 26, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(randomTxt);

		loadingSpeen = new FlxSprite().loadGraphic(Paths.image("loading_speen"));
		loadingSpeen.screenCenter(X);
		loadingSpeen.setGraphicSize(Std.int(loadingSpeen.width * 0.89));
		loadingSpeen.x = FlxG.width - 91;
		loadingSpeen.y = FlxG.height - 91;
		loadingSpeen.angularVelocity = 180;
		loadingSpeen.antialiasing = ClientPrefs.globalAntialiasing;
		add(loadingSpeen);

		loadingTxt = new FlxText(12, FlxG.height - 30, 0, "", 8);
		loadingTxt.scrollFactor.set();
		loadingTxt.setFormat("Bahnschrift", 25, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		loadingTxt.borderSize = 1.25;
		loadingTxt.text = " Loading... ";
		add(loadingTxt);

		FlxTween.tween(sbEngineLogo, {alpha: 1}, 0.75, {ease: FlxEase.quadInOut});
		beginTween = FlxTween.tween(sbEngineLogo.scale, {x: 1, y: 1}, 0.75, {ease: FlxEase.quadInOut});

		#if (desktop || android)
		FlxG.mouse.visible = false;
		#end

		new FlxTimer().start(15, function(tmr:FlxTimer) {
			FlxG.switchState(new TitleState());
		});

		super.create();
	}

	var selectedSomething:Bool = false;

	var timer:Float = 0;

	override function update(elapsed:Float) {
		if (!selectedSomething) {
			if (isTweening) {
				randomTxt.screenCenter(X);
				timer = 0;
			} else {
				randomTxt.screenCenter(X);
				timer += elapsed;
				if (timer >= 3) {
					changeText();
				}
			}
		}
		super.update(elapsed);
	}

	function changeText() {
		var selectedText:String = '';
		var textArray:Array<String> = CoolUtil.coolTextFile(SUtil.getPath() + Paths.txt('sbEngineTip'));

		randomTxt.alpha = 1;
		isTweening = true;
		selectedText = textArray[FlxG.random.int(0, (textArray.length - 1))].replace('--', '\n');
		FlxTween.tween(randomTxt, {alpha: 0}, 1, {
			ease: FlxEase.linear,
			onComplete: function(freak:FlxTween) {
				if (selectedText != lastString) {
					randomTxt.text = selectedText;
					lastString = selectedText;
				} else {
					selectedText = textArray[FlxG.random.int(0, (textArray.length - 1))].replace('--', '\n');
					randomTxt.text = selectedText;
				}

				randomTxt.alpha = 0;

				FlxTween.tween(randomTxt, {alpha: 1}, 1, {
					ease: FlxEase.linear,
					onComplete: function(freak:FlxTween) {
						isTweening = false;
					}
				});
			}
		});
	}
}
