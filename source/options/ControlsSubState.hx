package options;

import states.MainMenuState;
import flixel.addons.transition.FlxTransitionableState;
import lime.utils.Assets;
import flixel.util.FlxSave;
import haxe.Json;

using StringTools;

class ControlsSubState extends MusicBeatSubstate {
	private static var currentlySelected:Int = 1;
	private static var curAlt:Bool = false;

	private static var defaultKey:String = LanguageHandler.defaultKeyTxt;

	private var bindLength:Int = 0;

	var optionFreak:Array<Dynamic> = [
		[LanguageHandler.notesTxt], 
		[LanguageHandler.leftNoteTxt, 'note_left'],
		[LanguageHandler.downNoteTxt, 'note_down'],
		[LanguageHandler.upNoteTxt, 'note_up'],
	    [LanguageHandler.rightNoteTxt, 'note_right'],
		[''],
		[LanguageHandler.uiTxt],
		[LanguageHandler.leftKeyTxt, 'ui_left'],
		[LanguageHandler.downKeyTxt, 'ui_down'],
		[LanguageHandler.upKeyTxt, 'ui_up'],
		[LanguageHandler.rightKeyTxt, 'ui_right'],
		[''],
		[LanguageHandler.resetKeyTxt, 'reset'],
		[LanguageHandler.acceptKeyTxt, 'accept'],
		[LanguageHandler.backKeyTxt, 'back'],
		[LanguageHandler.pauseKeyTxt, 'pause'],
		[''],
		[LanguageHandler.volumeTxt],
		[LanguageHandler.volumeMuteKeyTxt, 'volume_mute'],
		[LanguageHandler.volumeUpKeyTxt, 'volume_up'],
		[LanguageHandler.volumeDownKeyTxt, 'volume_down'],
		[''],
		[LanguageHandler.debugTxt],
		[LanguageHandler.debugKeyOneTxt, 'debug_1'],
		[LanguageHandler.debugKeyTwoTxt, 'debug_2']];

	private var optionsSelect:FlxTypedGroup<Alphabet>;
	private var grpInputs:Array<AttachedText> = [];
	private var grpInputsAlt:Array<AttachedText> = [];
	var rebindingKey:Bool = false;
	var nextAccept:Int = 5;
	var background:FlxSprite;
	var velocityBackground:FlxBackdrop;

	public function new() {
		super();

		background = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		switch (ClientPrefs.themes) {
			case 'SB Engine':
				background.color = 0xFF800080;
			
			case 'Psych Engine':
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

		optionsSelect = new FlxTypedGroup<Alphabet>();
		add(optionsSelect);

		defaultKey = LanguageHandler.defaultKeyTxt;

		optionFreak.push(['']);
		optionFreak.push([defaultKey]);

		for (i in 0...optionFreak.length) {
			var isCentered:Bool = false;
			var isDefaultKey:Bool = (optionFreak[i][0] == defaultKey);
			if (unselectableCheck(i, true)) {
				isCentered = true;
			}

			var optionText:Alphabet = new Alphabet(200, 300, optionFreak[i][0], (!isCentered || isDefaultKey));
			optionText.isMenuItem = true;
			if (isCentered) {
				optionText.screenCenter(X);
				optionText.y -= 55;
				optionText.startPosition.y -= 55;
			}
			optionText.changeX = false;
			optionText.distancePerItem.y = 60;
			optionText.targetY = i - currentlySelected;
			optionText.snapToPosition();
			optionsSelect.add(optionText);

			if (!isCentered) {
				addBindTexts(optionText, i);
				bindLength++;
				if (currentlySelected < 0)
					currentlySelected = i;
			}
		}
		changeSelection();
	}

	var leaving:Bool = false;
	var bindingTime:Float = 0;

	override function update(elapsed:Float) {
		if (!rebindingKey) {
			if (controls.UI_UP_P) {
				changeSelection(-1);
			}
			if (controls.UI_DOWN_P) {
				changeSelection(1);
			}
			if (controls.UI_LEFT_P || controls.UI_RIGHT_P) {
				changeAlt();
			}

			if (controls.BACK) {
				ClientPrefs.reloadControls();
				#if android
			    FlxTransitionableState.skipNextTransOut = true;
			    FlxG.resetState();
			    #else
			    close();
			    #end
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.8);
				Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Options Menu";
			}

			if (controls.ACCEPT && nextAccept <= 0) {
				if (optionFreak[currentlySelected][0] == defaultKey) {
					ClientPrefs.keyBinds = ClientPrefs.defaultKeys.copy();
					reloadKeys();
					changeSelection();
					FlxG.sound.play(Paths.sound('confirmMenu'));
				} else if (!unselectableCheck(currentlySelected)) {
					bindingTime = 0;
					rebindingKey = true;
					if (curAlt) {
						grpInputsAlt[getInputTextNum()].alpha = 0;
					} else {
						grpInputs[getInputTextNum()].alpha = 0;
					}
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
			}
		} else {
			var keyPressed:Int = FlxG.keys.firstJustPressed();
			if (keyPressed > -1) {
				var keysArray:Array<FlxKey> = ClientPrefs.keyBinds.get(optionFreak[currentlySelected][1]);
				keysArray[curAlt ? 1 : 0] = keyPressed;

				var opposite:Int = (curAlt ? 0 : 1);
				if (keysArray[opposite] == keysArray[1 - opposite]) {
					keysArray[opposite] = NONE;
				}
				ClientPrefs.keyBinds.set(optionFreak[currentlySelected][1], keysArray);

				reloadKeys();
				FlxG.sound.play(Paths.sound('confirmMenu'));
				rebindingKey = false;
			}

			bindingTime += elapsed;
			if (bindingTime > 5) {
				if (curAlt) {
					grpInputsAlt[currentlySelected].alpha = 1;
				} else {
					grpInputs[currentlySelected].alpha = 1;
				}
				FlxG.sound.play(Paths.sound('scrollMenu'));
				rebindingKey = false;
				bindingTime = 0;
			}
		}

		if (nextAccept > 0) {
			nextAccept -= 1;
		}
		super.update(elapsed);
	}

	function getInputTextNum() {
		var num:Int = 0;
		for (i in 0...currentlySelected) {
			if (optionFreak[i].length > 1) {
				num++;
			}
		}
		return num;
	}

	function changeSelection(change:Int = 0) {
		do {
			currentlySelected += change;
			if (currentlySelected < 0)
				currentlySelected = optionFreak.length - 1;
			if (currentlySelected >= optionFreak.length)
				currentlySelected = 0;
		} while (unselectableCheck(currentlySelected));

		var optionFreak:Int = 0;

		for (i in 0...grpInputs.length) {
			grpInputs[i].alpha = 0.6;
		}
		for (i in 0...grpInputsAlt.length) {
			grpInputsAlt[i].alpha = 0.6;
		}

		for (item in optionsSelect.members) {
			item.targetY = optionFreak - currentlySelected;
			optionFreak++;

			if (!unselectableCheck(optionFreak - 1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
					if (curAlt) {
						for (i in 0...grpInputsAlt.length) {
							if (grpInputsAlt[i].sprTracker == item) {
								grpInputsAlt[i].alpha = 1;
								break;
							}
						}
					} else {
						for (i in 0...grpInputs.length) {
							if (grpInputs[i].sprTracker == item) {
								grpInputs[i].alpha = 1;
								break;
							}
						}
					}
				}
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function changeAlt() {
		curAlt = !curAlt;
		for (i in 0...grpInputs.length) {
			if (grpInputs[i].sprTracker == optionsSelect.members[currentlySelected]) {
				grpInputs[i].alpha = 0.6;
				if (!curAlt) {
					grpInputs[i].alpha = 1;
				}
				break;
			}
		}
		for (i in 0...grpInputsAlt.length) {
			if (grpInputsAlt[i].sprTracker == optionsSelect.members[currentlySelected]) {
				grpInputsAlt[i].alpha = 0.6;
				if (curAlt) {
					grpInputsAlt[i].alpha = 1;
				}
				break;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	private function unselectableCheck(num:Int, ?checkDefaultKey:Bool = false):Bool {
		if (optionFreak[num][0] == defaultKey) {
			return checkDefaultKey;
		}
		return optionFreak[num].length < 2 && optionFreak[num][0] != defaultKey;
	}

	private function addBindTexts(optionText:Alphabet, num:Int) {
		var keys:Array<Dynamic> = ClientPrefs.keyBinds.get(optionFreak[num][1]);
		var text1 = new AttachedText(InputFormatter.getKeyName(keys[0]), 400, -55);
		text1.setPosition(optionText.x + 400, optionText.y - 55);
		text1.sprTracker = optionText;
		grpInputs.push(text1);
		add(text1);

		var text2 = new AttachedText(InputFormatter.getKeyName(keys[1]), 650, -55);
		text2.setPosition(optionText.x + 650, optionText.y - 55);
		text2.sprTracker = optionText;
		grpInputsAlt.push(text2);
		add(text2);
	}

	function reloadKeys() {
		while (grpInputs.length > 0) {
			var item:AttachedText = grpInputs[0];
			item.kill();
			grpInputs.remove(item);
			item.destroy();
		}
		while (grpInputsAlt.length > 0) {
			var item:AttachedText = grpInputsAlt[0];
			item.kill();
			grpInputsAlt.remove(item);
			item.destroy();
		}

		trace('Reloaded keys: ' + ClientPrefs.keyBinds);

		for (i in 0...optionsSelect.length) {
			if (!unselectableCheck(i, true)) {
				addBindTexts(optionsSelect.members[i], i);
			}
		}

		var optionFreak:Int = 0;
		for (i in 0...grpInputs.length) {
			grpInputs[i].alpha = 0.6;
		}
		for (i in 0...grpInputsAlt.length) {
			grpInputsAlt[i].alpha = 0.6;
		}

		for (item in optionsSelect.members) {
			item.targetY = optionFreak - currentlySelected;
			optionFreak++;

			if (!unselectableCheck(optionFreak - 1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
					if (curAlt) {
						for (i in 0...grpInputsAlt.length) {
							if (grpInputsAlt[i].sprTracker == item) {
								grpInputsAlt[i].alpha = 1;
							}
						}
					} else {
						for (i in 0...grpInputs.length) {
							if (grpInputs[i].sprTracker == item) {
								grpInputs[i].alpha = 1;
							}
						}
					}
				}
			}
		}
	}
}
