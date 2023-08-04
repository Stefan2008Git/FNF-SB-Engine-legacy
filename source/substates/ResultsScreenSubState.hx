package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import backend.ClientPrefs;
import backend.CoolUtil;
import backend.MusicBeatState;
import backend.MusicBeatSubstate;
import backend.Paths;
import objects.HealthIcon;
import states.FreeplayState;
import states.StoryModeState;
import states.PlayState;

class ResultsScreenSubState extends MusicBeatSubstate {
	var background:FlxSprite;
	var resultsText:FlxText;
	var results:FlxText;
	var songNameText:FlxText;
	var difficultyNameTxt:FlxText;
	var judgementCounterTxt:FlxText;
	var pressEnterTxt:FlxText;
	var pressEnterTxtSine:Float = 0;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	public function new(daResults:Array<Int>, campaignScore:Int, songMisses:Int, ratingPercent:Float, ratingName:String) {
		super();

		background = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		background.color = 0xFF353535;
		background.scrollFactor.set();
		background.updateHitbox();
		background.screenCenter();
		background.alpha = 0;
		background.antialiasing = ClientPrefs.globalAntialiasing;
		add(background);

		resultsText = new FlxText(5, 0, 0, 'RESULTS', 72);
		resultsText.scrollFactor.set();
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine' | 'Better UI': resultsText.setFormat("VCR OSD Mono", 48, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			default: /*"SB Engine"*/ resultsText.setFormat("Bahnschrift", 48, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}

		resultsText.updateHitbox();
		add(resultsText);

		results = new FlxText(5, resultsText.height, FlxG.width, '', 48);
		results.scrollFactor.set();
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine' | 'Better UI': results.text = 'Sicks: ' + daResults[0] + '\nGoods: ' + daResults[1] + '\nBads: ' + daResults[2] + '\n####s: ' + daResults[3];
				results.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				
			default: /*"SB Engine"*/ results.text = 'Sicks: ' + daResults[0] + '\nGoods: ' + daResults[1] + '\nBads: ' + daResults[2] + '\nFreaks: ' + daResults[3];
				results.setFormat("Bahnschrift", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}


		results.updateHitbox();
		add(results);

		songNameText = new FlxText(0, 155, 0, '', 124);
		songNameText.text = "Song: " + PlayState.SONG.song;
		songNameText.scrollFactor.set();
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine' | 'Better UI': songNameText.setFormat("VCR OSD Mono", 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			default: /*"SB Engine"*/ songNameText.setFormat("Bahnschrift", 72, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		songNameText.updateHitbox();
		songNameText.screenCenter(X);
		add(songNameText);

		difficultyNameTxt = new FlxText(0, 155 + songNameText.height, 0, '', 100);
		difficultyNameTxt.text = "Difficulty: " + CoolUtil.difficultyString();
		difficultyNameTxt.scrollFactor.set();
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine' | 'Better UI': difficultyNameTxt.setFormat("VCR OSD Mono", 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			default: /*"SB Engine"*/ difficultyNameTxt.setFormat("Bahnschrift", 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}

		difficultyNameTxt.updateHitbox();
		difficultyNameTxt.screenCenter(X);
		add(difficultyNameTxt);

		judgementCounterTxt = new FlxText(0, difficultyNameTxt.y + difficultyNameTxt.height + 45, FlxG.width, '', 86);
		judgementCounterTxt.text = 'Score: ' + campaignScore + '\nMisses: ' + songMisses + '\nAccuracy: ' + ratingPercent + '%\nRating: ' + ratingName;
		judgementCounterTxt.scrollFactor.set();
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine' | 'Better UI': judgementCounterTxt.setFormat("VCR OSD Mono", 36, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			default: /*"SB Engine"*/ judgementCounterTxt.setFormat("Bahnschrift", 36, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}

		judgementCounterTxt.updateHitbox();
		judgementCounterTxt.screenCenter(X);
		add(judgementCounterTxt);

		#if android
		pressEnterTxt = new FlxText(400, 650, FlxG.width - 800, "[Tap on A button to continue]", 32);
		#else
		pressEnterTxt = new FlxText(400, 650, FlxG.width - 800, "[Press ENTER to continue]", 32);
		#end
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine' | 'Better UI': pressEnterTxt.setFormat("VCR OSD Mono", 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			default: /*"SB Engine"*/ pressEnterTxt.setFormat("Bahnschrift", 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}

		pressEnterTxt.scrollFactor.set();
		pressEnterTxt.visible = true;
		add(pressEnterTxt);

		iconP1 = new HealthIcon(PlayState.instance.boyfriend.healthIcon, true);
		iconP1.setGraphicSize(Std.int(iconP1.width * 1.2));
		iconP1.updateHitbox();
		add(iconP1);

		iconP2 = new HealthIcon(PlayState.instance.dad.healthIcon, false);
		iconP2.setGraphicSize(Std.int(iconP2.width * 1.2));
		iconP2.updateHitbox();
		add(iconP2);

		resultsText.alpha = 0;
		results.alpha = 0;
		songNameText.alpha = 0;
		difficultyNameTxt.alpha = 0;
		judgementCounterTxt.alpha = 0;
		iconP1.alpha = 0;
		iconP2.alpha = 0;
		pressEnterTxt.alpha = 0;

		iconP1.setPosition(FlxG.width - iconP1.width - 10, FlxG.height - iconP1.height - 15);
		iconP2.setPosition(10, iconP1.y);

		FlxTween.tween(background, {alpha: 0.7}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(resultsText, {alpha: 1, y: 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.2});
		FlxTween.tween(songNameText, {alpha: 1, y: songNameText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.2});
		FlxTween.tween(difficultyNameTxt, {alpha: 1, y: difficultyNameTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.4});
		FlxTween.tween(results, {alpha: 1, y: results.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.6});
		FlxTween.tween(judgementCounterTxt, {alpha: 1, y: judgementCounterTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.6});
		FlxTween.tween(iconP1, {alpha: 1, y: FlxG.height - iconP1.height - 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.8});
		FlxTween.tween(iconP2, {alpha: 1, y: FlxG.height - iconP2.height - 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.8});
		FlxTween.tween(pressEnterTxt, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.10});

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		#if android
		addVirtualPad(NONE, A);
		#end
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (pressEnterTxt.visible) {
			pressEnterTxtSine += 150 * elapsed;
			pressEnterTxt.alpha = 1 - Math.sin((Math.PI * pressEnterTxtSine) / 150);
		}

		if(PlayState.instance.boyfriend.healthIcon == null)
			iconP1.changeIcon('bf');
	
			if(PlayState.instance.dad.healthIcon == null)
				iconP2.changeIcon('bf');

		if (FlxG.keys.justPressed.ENTER #if android || virtualPad.buttonA.justPressed #end) {
			PlayState.isStoryMode ? MusicBeatState.switchState(new StoryModeState()) : MusicBeatState.switchState(new FreeplayState());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}
	}
}
