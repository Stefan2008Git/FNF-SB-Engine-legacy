package states;

import flixel.FlxObject;
import flixel.util.FlxSort;
import flixel.ui.FlxBar;

#if AWARDS_ALLOWED
class AwardsMenuState extends MusicBeatState
{
	public var currentlySelected:Int = 0;

	var background:FlxSprite;
	var velocityBackground:FlxBackdrop;
	public var options:Array<Dynamic> = [];
	public var groupOptions:FlxSpriteGroup;
	var spr:FlxSprite;
	var bigBox:FlxSprite;
	var miniBox:FlxSprite;
	public var awardNameText:FlxText;
	public var descriptionText:FlxText;
	public var progressTxt:FlxText;
	public var progressBarBackground:FlxSprite;
	public var progressBar:FlxBar;

	var camFollow:FlxObject;

	var MAX_PER_ROW:Int = 4;

	override function create()
	{
		Paths.clearStoredMemory();

		#if desktop
		DiscordClient.changePresence("In the Awards Menu", null);
		#end

		// prepare award list
		for (award => data in awards.awards)
		{
			var unlocked:Bool = awards.isUnlocked(award);
			if(data.hidden != true || unlocked)
				options.push(makeaward(award, data, unlocked));
		}

		// TO DO: check for mods

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		FlxG.camera.follow(camFollow, null, 0);
		FlxG.camera.scroll.y = -FlxG.height;

        background = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		background.antialiasing = ClientPrefs.globalAntialiasing;
		background.setGraphicSize(Std.int(background.width * 1.1));
		background.updateHitbox();
		background.screenCenter();
		background.scrollFactor.set();
		switch (ClientPrefs.themes) {
			case 'SB Engine':
				background.color = 0xFF800080;
			
			case 'Psych Engine':
				background.color = 0xFF0033FF;
		}
		add(background);

		velocityBackground = new FlxBackdrop(FlxGridOverlay.createGrid(30, 30, 60, 60, true, 0x3B161932, 0x0), XY);
		velocityBackground.velocity.set(FlxG.random.bool(50) ? 90 : -90, FlxG.random.bool(50) ? 90 : -90);
		velocityBackground.visible = ClientPrefs.velocityBackground;
		add(velocityBackground);

		groupOptions = new FlxSpriteGroup();
		groupOptions.scrollFactor.x = 0;

		options.sort(sortByID);
		for (option in options)
		{
			var globalAntialiasing:Bool = ClientPrefs.globalAntialiasing;
			var graphic = null;
			if(option.unlocked)
			{
				var image:String = 'awards/' + option.name;
				if(Paths.fileExists('images/$image-pixel.png', IMAGE))
				{
					graphic = Paths.image('$image-pixel');
					globalAntialiasing = false;
				}
				else graphic = Paths.image(image);

				if(graphic == null) graphic = Paths.image('unknownMod');
			}
			else graphic = Paths.image('awards/lockedAward');

			spr = new FlxSprite(0, Math.floor(groupOptions.members.length / MAX_PER_ROW) * 180).loadGraphic(graphic);
			spr.scrollFactor.x = 0;
			spr.screenCenter(X);
			spr.x += 180 * ((groupOptions.members.length % MAX_PER_ROW) - MAX_PER_ROW/2) + spr.width / 2 + 15;
			spr.ID = groupOptions.members.length;
			spr.antialiasing = globalAntialiasing;
			groupOptions.add(spr);
		}

		bigBox = new FlxSprite(0, -30).makeGraphic(1, 1, FlxColor.BLACK);
		box.scale.set(groupOptions.width + 60, groupOptions.height + 60);
		box.updateHitbox();
		box.alpha = 0.6;
		box.scrollFactor.x = 0;
		box.screenCenter(X);
		add(box);
		add(groupOptions);

		miniBox = new FlxSprite(0, 570).makeGraphic(1, 1, FlxColor.BLACK);
		miniBox.scale.set(FlxG.width, FlxG.height - bigBox.y);
		miniBox.updateHitbox();
		miniBox.alpha = 0.6;
		miniBox.scrollFactor.set();
		add(miniBox);
		
		awardNameText = new FlxText(50, miniBox.y + 10, FlxG.width - 100, "", 32);
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine':
				awardNameText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
			
			default:
				awardNameText.setFormat("Bahnschrift", 32, FlxColor.WHITE, CENTER);
		}
		awardNameText.scrollFactor.set();

		descriptionText = new FlxText(50, awardNameText.y + 40, FlxG.width - 100, "", 24);
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine':
				descriptionText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER);
			
			default:
				descriptionText.setFormat("Bahnschrift", 24, FlxColor.WHITE, CENTER);
		}
		descriptionText.scrollFactor.set();

		progressBarBackground = new FlxSprite(0, descriptionText.y + 50).loadGraphic(Paths.image('awards/awardsProgressBarBG'));
		progressBarBackground.screenCenter(X);
		progressBarBackground.scrollFactor.set();
		progressBarBackground.sprTracker = progressBar;

		progressBar = new FlxBar(0, descriptionText.y + 50);
		progressBar.screenCenter(X);
		progressBar.scrollFactor.set();
		progressBar.enabled = false;
		progressBar.createFilledBar(0xFF000000, 0xFF800080);
		insert(members.indexOf(progressBarBackground), progressBar);
		
		progressTxt = new FlxText(50, progressBar.y - 6, FlxG.width - 100, "", 32);
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine':
				progressTxt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			
			default:
				progressTxt.setFormat("Bahnschrift", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		progressTxt.scrollFactor.set();
		progressTxt.borderSize = 2;

		add(progressBarBackground);
		add(progressBar);
		add(progressTxt);
		add(descriptionText);
		add(awardNameText);
		
        Paths.clearUnusedMemory();

		#if android
		addVirtualPad(LEFT_FULL, A_B_C);
		#end

		_changeSelection();

		super.create();
	}

	function makeAward(award:String, data:Awards, unlocked:Bool, mod:String = null)
	{
		var unlocked:Bool = awards.isUnlocked(award);
		return {
			name: award,
			displayName: unlocked ? data.name : '???',
			description: data.description,
			currentlyProgress: data.maxScore > 0 ? awards.getScore(award) : 0,
			maxProgress: data.maxScore > 0 ? data.maxScore : 0,
			decimalProgress: data.maxScore > 0 ? data.maxDecimals : 0,
			unlocked: unlocked,
			ID: data.ID,
			mod: mod
		};
	}

	public static function sortByID(Obj1:Dynamic, Obj2:Dynamic):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.ID, Obj2.ID);

	var goingBack:Bool = false;
	override function update(elapsed:Float) {
		if(!goingBack && options.length > 1)
		{
			var add:Int = 0;
			if (controls.UI_LEFT_P) add = -1;
			else if (controls.UI_RIGHT_P) add = 1;

			if(add != 0)
			{
				var oldRow:Int = Math.floor(currentlySelected / MAX_PER_ROW);
				var rowSize:Int = Std.int(Math.min(MAX_PER_ROW, options.length - oldRow * MAX_PER_ROW));
				
				currentlySelected += add;
				var curRow:Int = Math.floor(currentlySelected / MAX_PER_ROW);
				if(currentlySelected >= options.length) curRow++;

				if(curRow != oldRow)
				{
					if(curRow < oldRow) currentlySelected += rowSize;
					else currentlySelected = currentlySelected -= rowSize;
				}
				_changeSelection();
			}

			if(options.length > MAX_PER_ROW)
			{
				var add:Int = 0;
				if (controls.UI_UP_P) add = -1;
				else if (controls.UI_DOWN_P) add = 1;

				if(add != 0)
				{
					var diff:Int = currentlySelected - (Math.floor(currentlySelected / MAX_PER_ROW) * MAX_PER_ROW);
					currentlySelected += add * MAX_PER_ROW;
					//trace('Before correction: $currentlySelected');
					if(currentlySelected < 0)
					{
						currentlySelected += Math.ceil(options.length / MAX_PER_ROW) * MAX_PER_ROW;
						if(currentlySelected >= options.length) currentlySelected -= MAX_PER_ROW;
						//trace('Pass 1: $currentlySelected');
					}
					if(currentlySelected >= options.length)
					{
						currentlySelected = diff;
						//trace('Pass 2: $currentlySelected');
					}

					_changeSelection();
				}
			}
			
			if(controls.RESET #if android || virtualPad.buttonC.pressed #end && (options[currentlySelected].unlocked || options[currentlySelected].currentlyProgress > 0))
			{
				#if android
			    removeVirtualPad();
			    #end
				openSubState(new ResetAwardsSubstate());
				FlxTween.tween(FlxG.sound.music, {volume: 0.4}, 0.8);
			}
		}

		FlxG.camera.followLerp = FlxMath.bound(elapsed * 9 / (FlxG.updateFramerate / 60), 0, 1);

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			ClientPrefs.mainMenuStyle == 'Classic' ? MusicBeatState.switchState(new ClassicMainMenuState()) : MusicBeatState.switchState(new MainMenuState());
			Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion;
			goingBack = true;
		}
		super.update(elapsed);
	}

	public var barTween:FlxTween = null;
	function _changeSelection()
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		var hasProgress = options[currentlySelected].maxProgress > 0;
		awardNameText.text = options[currentlySelected].displayName;
		descriptionText.text = options[currentlySelected].description;
		progressTxt.visible = progressBar.visible = hasProgress;

		if(barTween != null) barTween.cancel();

		if(hasProgress)
		{
			var val1:Float = options[currentlySelected].currentlyProgress;
			var val2:Float = options[currentlySelected].maxProgress;
			progressTxt.text = CoolUtil.floorDecimal(val1, options[currentlySelected].decimalProgress) + ' / ' + CoolUtil.floorDecimal(val2, options[currentlySelected].decimalProgress);

			barTween = FlxTween.tween(progressBar, {percent: (val1 / val2) * 100}, 0.5, {ease: FlxEase.quadOut,
				onComplete: function(twn:FlxTween) progressBar.updateBar(),
				onUpdate: function(twn:FlxTween) progressBar.updateBar()
			});
		}
		else progressBar.percent = 0;

		var maxRows = Math.floor(groupOptions.members.length / MAX_PER_ROW);
		if(maxRows > 0)
		{
			var camY:Float = FlxG.height / 2 + (Math.floor(currentlySelected / MAX_PER_ROW) / maxRows) * Math.max(0, groupOptions.height - FlxG.height / 2 - 50) - 100;
			camFollow.setPosition(0, camY);
		}
		else camFollow.setPosition(0, groupOptions.members[currentlySelected].getGraphicMidpoint().y - 100);

		groupOptions.forEach(function(spr:FlxSprite) {
			spr.alpha = 0.6;
			if(spr.ID == currentlySelected) spr.alpha = 1;
		});
	}
}

class ResetAwardsSubstate extends MusicBeatSubstate
{
	var onYes:Bool = false;
	var yesText:Alphabet;
	var noText:Alphabet;

	public function new()
	{
		super();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);
		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});

		var text:Alphabet = new Alphabet(0, 180, "Reset award:", true);
		text.screenCenter(X);
		text.scrollFactor.set();
		add(text);
		
		var state:AwardsMenuState = cast FlxG.state;
		var text:FlxText = new FlxText(50, text.y + 90, FlxG.width - 100, state.options[state.currentlySelected].displayName, 40);
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine':
				text.setFormat("VCR OSD Mono", 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			
			default:
				text.setFormat("Bahnschrift", 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		text.scrollFactor.set();
		text.borderSize = 2;
		add(text);
		
		yesText = new Alphabet(0, text.y + 120, 'Yes', true);
		yesText.screenCenter(X);
		yesText.x -= 200;
		yesText.scrollFactor.set();
		for(letter in yesText.letters) letter.color = FlxColor.RED;
		add(yesText);
		noText = new Alphabet(0, text.y + 120, 'No', true);
		noText.screenCenter(X);
		noText.x += 200;
		noText.scrollFactor.set();
		add(noText);

		#if android
		addVirtualPad(LEFT_RIGHT, A);
		addPadCamera();
		#end

		updateOptions();
	}

	override function update(elapsed:Float)
	{
		if(controls.BACK)
		{
			#if android
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
			#else
			close();
			#end
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.8);
			return;
		}

		super.update(elapsed);

		if(controls.UI_LEFT_P || controls.UI_RIGHT_P) {
			onYes = !onYes;
			updateOptions();
		}

		if(controls.ACCEPT)
		{
			if(onYes)
			{
				var state:AwardsMenuState = cast FlxG.state;
				var option:Dynamic = state.options[state.currentlySelected];

				awards.variables.remove(option.name);
				awards.awardsUnlocked.remove(option.name);
				option.unlocked = false;
				option.currentlyProgress = 0;
				option.name = state.awardNameText.text = '???';
				if(option.maxProgress > 0) state.progressTxt.text = '0 / ' + option.maxProgress;
				state.groupOptions.members[state.currentlySelected].loadGraphic(Paths.image('awards/lockedaward'));
				state.groupOptions.members[state.currentlySelected].antialiasing = ClientPrefs.globalAntialiasing;

				if(state.progressBar.visible)
				{
					if(state.barTween != null) state.barTween.cancel();
					state.barTween = FlxTween.tween(state.progressBar, {percent: 0}, 0.5, {ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween) state.progressBar.updateBar(),
						onUpdate: function(twn:FlxTween) state.progressBar.updateBar()
					});
				}
				Awards.save();
				FlxG.save.flush();

				FlxG.sound.play(Paths.sound('cancelMenu'));
			}
			close();
			return;
		}
	}

	function updateOptions() {
		var scales:Array<Float> = [0.75, 1];
		var alphas:Array<Float> = [0.6, 1.25];
		var confirmInt:Int = onYes ? 1 : 0;

		yesText.alpha = alphas[confirmInt];
		yesText.scale.set(scales[confirmInt], scales[confirmInt]);
		noText.alpha = alphas[1 - confirmInt];
		noText.scale.set(scales[1 - confirmInt], scales[1 - confirmInt]);
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}
#end