package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxGradient;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import lime.app.Application;
#if windows
import Discord.DiscordClient;
#end
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
#if cpp
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class Cache extends FlxState
{	
	public static var bitmapData:Map<String,FlxGraphic>;
	public static var bitmapData2:Map<String,FlxGraphic>;
	var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 1, 0xFFAB6F00);
	var splash:FlxSprite;
	var loadingSpeen:FlxSprite;
	var text:FlxText;
	var randomTxt:FlxText;
	
	var isTweening:Bool = false;
	var lastString:String = '';

	var images = [];
	var music = [];

	override function create()
	{
	
		FlxG.mouse.visible = true;

		FlxG.worldBounds.set(0,0);

		bitmapData = new Map<String,FlxGraphic>();
		bitmapData2 = new Map<String,FlxGraphic>();
		
		super.create();
		

		splash = new FlxSprite().loadGraphic(Paths.image("logo"));
		splash.screenCenter();
		splash.y -= 30;
		splash.antialiasing = true;
		add(splash);
		
		gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x553D0468, 0xFFFFA500], 1, 90, true);
		gradientBar.y = FlxG.height - gradientBar.height;
		add(gradientBar);
		gradientBar.scrollFactor.set(0, 0);
		
		var bottomPanel:FlxSprite = new FlxSprite(0, FlxG.height - 100).makeGraphic(FlxG.width, 100, 0xFF000000);
		bottomPanel.alpha = 0.5;
		add(bottomPanel);	
		
		randomTxt = new FlxText(20, FlxG.height - 80, 1000, "", 26);
		randomTxt.scrollFactor.set();
		randomTxt.setFormat("VCR OSD Mono", 26, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(randomTxt);
		
		loadingSpeen = new FlxSprite().loadGraphic(Paths.image("loading_speen"));
		loadingSpeen.screenCenter(X);
		loadingSpeen.y = Math.ffloor(splash.y + splash.height + 45);
		loadingSpeen.angularVelocity = 180;
		loadingSpeen.antialiasing = true;
		add(loadingSpeen);
		
		text = new FlxText(200, 730, 0, "SB Engine is loading. Please wait...");
		text.setFormat("VCR OSD Mono", 40, FlxColor.WHITE, RIGHT);
		text.updateHitbox();
		text.screenCenter(X);
		text.x = Math.ffloor(text.x);
		text.y = Math.ffloor(splash.y + splash.height + 45);
		text.antialiasing = true;
		//add(text);

		#if cpp
		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/characters")))
		{
			if (!i.endsWith(".png"))
				continue;
			images.push(i);
		}

		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/songs")))
		{
			music.push(i);
		}
		#end

		sys.thread.Thread.create(() -> {
			cache();
		});

		super.create();
	}
	
	var selectedSomethin:Bool = false;
	var timer:Float = 0;
	
	override function update(elapsed:Float) 
	{
		if (!selectedSomethin){
			if (isTweening){
				randomTxt.screenCenter(X);
				timer = 0;
			}else{
				randomTxt.screenCenter(X);
				timer += elapsed;
				if (timer >= 3)
				{
					changeText();
				}
			}
		}
		super.update(elapsed);
	}

	function cache()
	{
		#if !linux

		for (i in images)
		{
			var replaced = i.replace(".png","");
			var data:BitmapData = BitmapData.fromFile("assets/shared/images/characters/" + i);
			var graph = FlxGraphic.fromBitmapData(data);
			graph.persist = true;
			graph.destroyOnNoUse = false;
			bitmapData.set(replaced,graph);
			trace(i);
		}

		for (i in music)
		{
			trace(i);
		}

		#end
		FlxG.switchState(new TitleState());
	}
	
	function changeText()
	{
		var selectedText:String = '';
		var textArray:Array<String> = CoolUtil.coolTextFile(Paths.txt('sbEngineTip'));

		randomTxt.alpha = 1;
		isTweening = true;
		selectedText = textArray[FlxG.random.int(0, (textArray.length - 1))].replace('--', '\n');
		FlxTween.tween(randomTxt, {alpha: 0}, 1, {
			ease: FlxEase.linear,
			onComplete: function(freak:FlxTween)
			{
				if (selectedText != lastString)
				{
					randomTxt.text = selectedText;
					lastString = selectedText;
				}
				else
				{
					selectedText = textArray[FlxG.random.int(0, (textArray.length - 1))].replace('--', '\n');
					randomTxt.text = selectedText;
				}

				randomTxt.alpha = 0;

				FlxTween.tween(randomTxt, {alpha: 1}, 1, {
					ease: FlxEase.linear,
					onComplete: function(freak:FlxTween)
					{
						isTweening = false;
					}
				});
			}
		});
	}
}