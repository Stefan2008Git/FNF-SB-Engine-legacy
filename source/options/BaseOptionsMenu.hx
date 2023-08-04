package options;

#if desktop
import backend.Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.transition.FlxTransitionableState;
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
import flash.geom.Rectangle;
import backend.ClientPrefs;
import backend.Controls;
import backend.MusicBeatSubstate;
import backend.Paths;
import objects.Alphabet;
import objects.CheckboxThingie;
import objects.AttachedText;

using StringTools;

class BaseOptionsMenu extends MusicBeatSubstate {
	private var curOption:Option = null;
	private var currentlySelected:Int = 0;
	private var optionsArray:Array<Option>;

	private var optionsSelect:FlxTypedGroup<objects.Alphabet>;
	private var checkboxGroup:FlxTypedGroup<CheckboxThingie>;
	private var grpTexts:FlxTypedGroup<AttachedText>;

	private var descBox:FlxSprite;
	private var descText:FlxText;

	var background:FlxSprite;
	var velocityBackground:FlxBackdrop;

	public var title:String;
	public var rpcTitle:String;

	public function new() {
		super();

		if (title == null)
			title = 'Options';
		if (rpcTitle == null)
			rpcTitle = 'Options Menu';

		#if desktop
		DiscordClient.changePresence(rpcTitle, null);
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
		add(background);

		velocityBackground = new FlxBackdrop(FlxGridOverlay.createGrid(30, 30, 60, 60, true, 0x3B161932, 0x0), XY);
		velocityBackground.velocity.set(FlxG.random.bool(50) ? 90 : -90, FlxG.random.bool(50) ? 90 : -90);
		velocityBackground.visible = ClientPrefs.velocityBackground;
		velocityBackground.alpha = 0;
		FlxTween.tween(velocityBackground, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(velocityBackground);

		// avoids lagspikes while scrolling through menus!
		optionsSelect = new FlxTypedGroup<Alphabet>();
		add(optionsSelect);

		grpTexts = new FlxTypedGroup<AttachedText>();
		add(grpTexts);

		checkboxGroup = new FlxTypedGroup<CheckboxThingie>();
		add(checkboxGroup);

		descBox = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		descBox.alpha = 0.6;
		add(descBox);

		var titleText:Alphabet = new Alphabet(75, 40, title, true);
		titleText.scaleX = 0.6;
		titleText.scaleY = 0.6;
		titleText.alpha = 0.4;
		add(titleText);

		descText = new FlxText(50, 600, 1180, "", 32);
		switch (ClientPrefs.gameStyle) {
		    case 'SB Engine':
			    descText.setFormat("Bahnschrift", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		    case 'Psych Engine':
			    descText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		    case 'Better UI':
			    descText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		for (i in 0...optionsArray.length) {
			var optionText:Alphabet = new Alphabet(290, 260, optionsArray[i].name, false);
			optionText.isMenuItem = true;
			/*optionText.forceX = 300;
				optionText.yMult = 90; */
			optionText.targetY = i;
			optionsSelect.add(optionText);

			if (optionsArray[i].type == 'bool') {
				var checkbox:CheckboxThingie = new CheckboxThingie(optionText.x - 105, optionText.y, optionsArray[i].getValue() == true);
				checkbox.sprTracker = optionText;
				checkbox.ID = i;
				checkboxGroup.add(checkbox);
			} else {
				optionText.startPosition.x -= 80;
				// optionText.xAdd -= 80;
				var valueText:AttachedText = new AttachedText('' + optionsArray[i].getValue(), optionText.width + 80);
				valueText.sprTracker = optionText;
				valueText.copyAlpha = true;
				valueText.ID = i;
				grpTexts.add(valueText);
				optionsArray[i].setChild(valueText);
			}
		}

		changeSelection();
		reloadCheckboxes();

		#if android
		addVirtualPad(LEFT_FULL, A_B_C);
		addPadCamera();
		#end
	}

	public function addOption(option:Option) {
		if (optionsArray == null || optionsArray.length < 1)
			optionsArray = [];
		optionsArray.push(option);
	}

	var nextAccept:Int = 5;
	var holdTime:Float = 0;
	var holdValue:Float = 0;

	override function update(elapsed:Float) {
		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controls.BACK) {
			#if android
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
			#else
			close();
			#end
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}

		if (nextAccept <= 0) {
			var usesCheckbox = true;
			if (curOption.type != 'bool') {
				usesCheckbox = false;
			}

			if (usesCheckbox) {
				if (controls.ACCEPT) {
					FlxG.sound.play(Paths.sound('scrollMenu'));
					curOption.setValue((curOption.getValue() == true) ? false : true);
					curOption.change();
					reloadCheckboxes();
				}
			} else {
				if (controls.UI_LEFT || controls.UI_RIGHT) {
					var pressed = (controls.UI_LEFT_P || controls.UI_RIGHT_P);
					if (holdTime > 0.5 || pressed) {
						if (pressed) {
							var add:Dynamic = null;
							if (curOption.type != 'string') {
								add = controls.UI_LEFT ? -curOption.changeValue : curOption.changeValue;
							}

							switch (curOption.type) {
								case 'int' | 'float' | 'percent':
									holdValue = curOption.getValue() + add;
									if (holdValue < curOption.minValue)
										holdValue = curOption.minValue;
									else if (holdValue > curOption.maxValue)
										holdValue = curOption.maxValue;

									switch (curOption.type) {
										case 'int':
											holdValue = Math.round(holdValue);
											curOption.setValue(holdValue);

										case 'float' | 'percent':
											holdValue = FlxMath.roundDecimal(holdValue, curOption.decimals);
											curOption.setValue(holdValue);
									}

								case 'string':
									var num:Int = curOption.curOption; // lol
									if (controls.UI_LEFT_P)
										--num;
									else
										num++;

									if (num < 0) {
										num = curOption.options.length - 1;
									} else if (num >= curOption.options.length) {
										num = 0;
									}

									curOption.curOption = num;
									curOption.setValue(curOption.options[num]); // lol
									// trace(curOption.options[num]);
							}
							updateTextFrom(curOption);
							curOption.change();
							FlxG.sound.play(Paths.sound('scrollMenu'));
						} else if (curOption.type != 'string') {
							holdValue += curOption.scrollSpeed * elapsed * (controls.UI_LEFT ? -1 : 1);
							if (holdValue < curOption.minValue)
								holdValue = curOption.minValue;
							else if (holdValue > curOption.maxValue)
								holdValue = curOption.maxValue;

							switch (curOption.type) {
								case 'int':
									curOption.setValue(Math.round(holdValue));

								case 'float' | 'percent':
									curOption.setValue(FlxMath.roundDecimal(holdValue, curOption.decimals));
							}
							updateTextFrom(curOption);
							curOption.change();
						}
					}

					if (curOption.type != 'string') {
						holdTime += elapsed;
					}
				} else if (controls.UI_LEFT_R || controls.UI_RIGHT_R) {
					clearHold();
				}
			}

			if (controls.RESET #if android || virtualPad.buttonC.justPressed #end) {
				for (i in 0...optionsArray.length) {
					var leOption:Option = optionsArray[i];
					leOption.setValue(leOption.defaultValue);
					if (leOption.type != 'bool') {
						if (leOption.type == 'string') {
							leOption.curOption = leOption.options.indexOf(leOption.getValue());
						}
						updateTextFrom(leOption);
					}
					leOption.change();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				reloadCheckboxes();
			}
		}

		if (nextAccept > 0) {
			nextAccept -= 1;
		}
		super.update(elapsed);
	}

	function updateTextFrom(option:Option) {
		var text:String = option.displayFormat;
		var val:Dynamic = option.getValue();
		if (option.type == 'percent')
			val *= 100;
		var def:Dynamic = option.defaultValue;
		option.text = text.replace('%v', val).replace('%d', def);
	}

	function clearHold() {
		if (holdTime > 0.5) {
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		holdTime = 0;
	}

	function changeSelection(change:Int = 0) {
		currentlySelected += change;
		if (currentlySelected < 0)
			currentlySelected = optionsArray.length - 1;
		if (currentlySelected >= optionsArray.length)
			currentlySelected = 0;

		descText.text = optionsArray[currentlySelected].description;
		descText.screenCenter(Y);
		descText.y += 270;

		var optionFreak:Int = 0;

		for (item in optionsSelect.members) {
			item.targetY = optionFreak - currentlySelected;
			optionFreak++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
			}
		}
		for (text in grpTexts) {
			text.alpha = 0.6;
			if (text.ID == currentlySelected) {
				text.alpha = 1;
			}
		}

		descBox.setPosition(descText.x - 10, descText.y - 10);
		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();

		curOption = optionsArray[currentlySelected]; // shorter lol
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function reloadCheckboxes() {
		for (checkbox in checkboxGroup) {
			checkbox.daValue = (optionsArray[checkbox.ID].getValue() == true);
		}
	}
}
