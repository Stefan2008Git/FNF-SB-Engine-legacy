package android;

import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;
import android.FlxHitbox;
import android.FlxnewHitbox;
import android.AndroidControls.Config;
import android.FlxVirtualPad;

using StringTools;

class AndroidControlsMenu extends MusicBeatState
{
	var virtualPad:FlxVirtualPad;
	var hitbox:FlxHitbox;
	var newHitbox:FlxnewHitbox;
	var upPosition:FlxText;
	var downPosition:FlxText;
	var leftPosition:FlxText;
	var rightPosition:FlxText;
	var inputvari:PsychAlphabet;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var controlitems:Array<String> = ['Pad-Right','Pad-Left','Pad-Custom','Duo','Hitbox','Keyboard'];
	var curSelected:Int = 0;
	var buttonistouched:Bool = false;
	var bindbutton:FlxButton;
	var config:Config;
	var velocityBG:FlxBackdrop;

	override public function create():Void
	{
		super.create();
		
		config = new Config();
		curSelected = config.getcontrolmode();

		var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFFFA500;
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		velocityBG = new FlxBackdrop(Paths.image('velocity_background'));
		velocityBG.velocity.set(50, 50);
		add(velocityBG);

		var titleText:Alphabet = new Alphabet(75, 60, "Android Controls", true);
		add(titleText);

		virtualPad = new FlxVirtualPad(RIGHT_FULL, NONE, 0.75, ClientPrefs.globalAntialiasing);
		virtualPad.alpha = 0;
		add(virtualPad);

		hitbox = new FlxHitbox(0.75, ClientPrefs.globalAntialiasing);
		hitbox.visible = false;
		add(hitbox);
		
		newHitbox = new FlxNewHitbox();
		newHitbox.visible = false;
		add(newHitbox);

		inputvari = new PsychAlphabet(0, 50, controlitems[curSelected], false, false, 0.05, 0.8);
		inputvari.screenCenter(X);
		add(inputvari);

		var ui_tex = Paths.getSparrowAtlas('androidcontrols/menu/arrows');

		leftArrow = new FlxSprite(inputvari.x - 60, inputvari.y + 50);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		add(leftArrow);

		rightArrow = new FlxSprite(inputvari.x + inputvari.width + 10, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		add(rightArrow);

		upPosition = new FlxText(10, FlxG.height - 104, 0,"Button Up X:" + virtualPad.buttonUp.x +" Y:" + virtualPad.buttonUp.y, 16);
		upPosition.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		upPosition.borderSize = 2.4;
		add(upPosition);

		downPosition = new FlxText(10, FlxG.height - 84, 0,"Button Down X:" + virtualPad.buttonDown.x +" Y:" + virtualPad.buttonDown.y, 16);
		downPosition.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		downPosition.borderSize = 2.4;
		add(downPosition);

		leftPosition = new FlxText(10, FlxG.height - 64, 0,"Button Left X:" + virtualPad.buttonLeft.x +" Y:" + virtualPad.buttonLeft.y, 16);
		leftPosition.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		leftPosition.borderSize = 2.4;
		add(leftPosition);

		rightPosition = new FlxText(10, FlxG.height - 44, 0,"Button RIght x:" + virtualPad.buttonRight.x +" Y:" + virtualPad.buttonRight.y, 16);
		rightPosition.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		rightPosition.borderSize = 2.4;
		add(rightPosition);

		var tipText:FlxText = new FlxText(10, FlxG.height - 24, 0, 'Press BACK to Go Back to Options Menu', 16);
		tipText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipText.borderSize = 2;
		tipText.scrollFactor.set();
		add(tipText);

		changeSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		leftArrow.x = inputvari.x - 60;
		rightArrow.x = inputvari.x + inputvari.width + 10;
		inputvari.screenCenter(X);
		
		for (touch in FlxG.touches.list){		
			if(touch.overlaps(leftArrow) && touch.justPressed)
			{
				changeSelection(-1);
			}
			else if (touch.overlaps(rightArrow) && touch.justPressed)
			{
				changeSelection(1);
			}
			trackbutton(touch);
		}
		
		#if android
		if (FlxG.android.justReleased.BACK)
		{
			save();
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new options.OptionsState());
		}
		#end
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
	
		if (curSelected < 0)
			curSelected = controlitems.length - 1;
		if (curSelected >= controlitems.length)
			curSelected = 0;
	
		inputvari.changeText(controlitems[curSelected]);

		var daChoice:String = controlitems[Math.floor(curSelected)];

		switch (daChoice)
		{
				case 'Pad-Right':
					remove(virtualPad);
					virtualPad = new FlxVirtualPad(RIGHT_FULL, NONE, 0.75, ClientPrefs.globalAntialiasing);
					add(virtualPad);
				case 'Pad-Left':
					remove(virtualPad);
					virtualPad = new FlxVirtualPad(FULL, NONE, 0.75, ClientPrefs.globalAntialiasing);
					add(virtualPad);
				case 'Pad-Custom':
					remove(virtualPad);
					virtualPad = new FlxVirtualPad(RIGHT_FULL, NONE, 0.75, ClientPrefs.globalAntialiasing);
					add(virtualPad);
					loadcustom();
				case 'Duo':
					remove(virtualPad);
					virtualPad = new FlxVirtualPad(DUO, NONE, 0.75, ClientPrefs.globalAntialiasing);
					add(virtualPad);
				case 'Hitbox':
					virtualPad.alpha = 0;
				case 'Keyboard':
					remove(virtualPad);
					virtualPad.alpha = 0;
		}

		if (daChoice != "Hitbox")
		{
			hitbox.visible = false;
			newHitbox.visible = false;
		}
		else
		{
		if(ClientPrefs.hitboxmode != 'New'){
			hitbox.visible = true;
		     }else{
		       newHitbox.visible = true;
		     }
		}

		if (daChoice != "Pad-Custom")
		{
			upPosition.visible = false;
			downPosition.visible = false;
			leftPosition.visible = false;
			rightPosition.visible = false;
		}
		else
		{
			upPosition.visible = true;
			downPosition.visible = true;
			leftPosition.visible = true;
			rightPosition.visible = true;
		}
	}

	function trackbutton(touch:flixel.input.touch.FlxTouch){
		var daChoice:String = controlitems[Math.floor(curSelected)];

		if (daChoice == 'Pad-Custom'){
			if (buttonistouched){
				if (bindbutton.justReleased && touch.justReleased)
				{
					bindbutton = null;
					buttonistouched = false;
				}else 
				{
					movebutton(touch, bindbutton);
					setbuttontexts();
				}
			}
			else 
			{
				if (virtualPad.buttonUp.justPressed) {
					movebutton(touch, virtualPad.buttonUp);
				}
				
				if (virtualPad.buttonDown.justPressed) {
					movebutton(touch, virtualPad.buttonDown);
				}

				if (virtualPad.buttonRight.justPressed) {
					movebutton(touch, virtualPad.buttonRight);
				}

				if (virtualPad.buttonLeft.justPressed) {
					movebutton(touch, virtualPad.buttonLeft);
				}
			}
		}
	}

	function movebutton(touch:flixel.input.touch.FlxTouch, button:flixel.ui.FlxButton) {
		button.x = touch.x - virtualPad.buttonUp.width / 2;
		button.y = touch.y - virtualPad.buttonUp.height / 2;
		bindbutton = button;
		buttonistouched = true;
	}

	function setbuttontexts() {
		upPosition.text = "Button Up X:" + virtualPad.buttonUp.x +" Y:" + virtualPad.buttonUp.y;
		downPosition.text = "Button Down X:" + virtualPad.buttonDown.x +" Y:" + virtualPad.buttonDown.y;
		leftPosition.text = "Button Left X:" + virtualPad.buttonLeft.x +" Y:" + virtualPad.buttonLeft.y;
		rightPosition.text = "Button RIght x:" + virtualPad.buttonRight.x +" Y:" + virtualPad.buttonRight.y;
	}

	function save() {
		config.setcontrolmode(curSelected);
		var daChoice:String = controlitems[Math.floor(curSelected)];

		if (daChoice == 'Pad-Custom'){
			config.savecustom(virtualPad);
		}
	}

	function loadcustom():Void{
		virtualPad = config.loadcustom(virtualPad);	
	}
}
