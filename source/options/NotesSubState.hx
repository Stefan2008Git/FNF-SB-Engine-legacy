package options;

import states.MainMenuState;
import flixel.addons.transition.FlxTransitionableState;
import lime.utils.Assets;
import flixel.util.FlxSave;
import haxe.Json;

using StringTools;

class NotesSubState extends MusicBeatSubstate
{
	private static var currentlySelected:Int = 0;
	private static var typeSelected:Int = 0;
	private var grpNumbers:FlxTypedGroup<Alphabet>;
	private var grpNotes:FlxTypedGroup<FlxSprite>;
	private var shaderArray:Array<ColorSwap> = [];
	var currentlyValue:Float = 0;
	var holdTime:Float = 0;
	var nextAccept:Int = 5;

	var background:FlxSprite;
	var velocityBackground:FlxBackdrop;
	var blackBG:FlxSprite;
	var hsbText:Alphabet;
	var resetText:FlxText;

	var posX = 250;
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

		blackBG = new FlxSprite(posX - 25).makeGraphic(870, 200, FlxColor.BLACK);
		blackBG.alpha = 0.4;
		add(blackBG);

		velocityBackground = new FlxBackdrop(FlxGridOverlay.createGrid(30, 30, 60, 60, true, 0x3B161932, 0x0), XY);
		velocityBackground.velocity.set(FlxG.random.bool(50) ? 90 : -90, FlxG.random.bool(50) ? 90 : -90);
		velocityBackground.visible = ClientPrefs.velocityBackground;
		velocityBackground.alpha = 0;
		FlxTween.tween(velocityBackground, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(velocityBackground);

		grpNotes = new FlxTypedGroup<FlxSprite>();
		add(grpNotes);
		grpNumbers = new FlxTypedGroup<Alphabet>();
		add(grpNumbers);

		#if android
		resetText = new FlxText(12, FlxG.height - 40, LanguageHandler.resetNoteColorTxtAndroid, 80);
		#else
		resetText = new FlxText(12, FlxG.height - 40, LanguageHandler.resetNoteColorTxt, 80);
		#end
		switch (ClientPrefs.gameStyle) {
            case 'Psych Engine':
			    resetText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER);
			
			default:
				resetText.setFormat("Bahnschrift", 24, FlxColor.WHITE, CENTER);
		}
		add(resetText);

		for (i in 0...ClientPrefs.arrowHSV.length) {
			var yPos:Float = (165 * i) + 35;
			for (j in 0...3) {
				var optionText:Alphabet = new Alphabet(posX + (225 * j) + 250, yPos + 60, Std.string(ClientPrefs.arrowHSV[i][j]), true);
				grpNumbers.add(optionText);
			}

			var note:FlxSprite = new FlxSprite(posX - 70, yPos);
			note.frames = Paths.getSparrowAtlas('NOTE_assets', 'shared');
			var animations:Array<String> = ['purple0', 'blue0', 'green0', 'red0'];
			note.animation.addByPrefix('idle', animations[i]);
			note.animation.play('idle');
			note.antialiasing = ClientPrefs.globalAntialiasing;
			grpNotes.add(note);

			var newShader:ColorSwap = new ColorSwap();
			note.shader = newShader.shader;
			newShader.hue = ClientPrefs.arrowHSV[i][0] / 360;
			newShader.saturation = ClientPrefs.arrowHSV[i][1] / 100;
			newShader.brightness = ClientPrefs.arrowHSV[i][2] / 100;
			shaderArray.push(newShader);
		}

		hsbText = new Alphabet(0, 0, LanguageHandler.hsbTxt, false);
		hsbText.scaleX = 0.6;
		hsbText.scaleY = 0.6;
		add(hsbText);

		changeSelection();

		#if android
		addVirtualPad(LEFT_FULL, A_B_C);
		#end
	}

	var changingNote:Bool = false;
	var hsbTextOffsets:Array<Float> = [240, 90];
	override function update(elapsed:Float) {
		if(changingNote) {
			if(holdTime < 0.5) {
				if (controls.UI_LEFT_P) {
					updateValue(-1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				} else if(controls.UI_RIGHT_P) {
					updateValue(1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				} else if(controls.RESET #if android || virtualPad.buttonC.justPressed #end) {
					resetValue(currentlySelected, typeSelected);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				if (controls.UI_LEFT_R || controls.UI_RIGHT_R) {
					holdTime = 0;
				} else if(controls.UI_LEFT || controls.UI_RIGHT) {
					holdTime += elapsed;
				}
			} else {
				var add:Float = 90;
				switch(typeSelected) {
					case 1 | 2: add = 50;
				}
				if(controls.UI_LEFT) {
					updateValue(elapsed * -add);
				} else if(controls.UI_RIGHT) {
					updateValue(elapsed * add);
				}
				if(controls.UI_LEFT_R || controls.UI_RIGHT_R) {
					FlxG.sound.play(Paths.sound('scrollMenu'));
					holdTime = 0;
				}
			}
		} else {
			if (controls.UI_UP_P) {
				changeSelection(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (controls.UI_DOWN_P) {
				changeSelection(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (controls.UI_LEFT_P) {
				changeType(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (controls.UI_RIGHT_P) {
				changeType(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if(controls.RESET #if android || virtualPad.buttonC.justPressed #end) {
				for (i in 0...3) {
					resetValue(currentlySelected, i);
				}
				FlxG.camera.flash(FlxColor.BLACK, 1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (controls.ACCEPT && nextAccept <= 0) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changingNote = true;
				holdTime = 0;
				for (i in 0...grpNumbers.length) {
					var item = grpNumbers.members[i];
					item.alpha = 0;
					if ((currentlySelected * 3) + typeSelected == i) {
						item.alpha = 1;
					}
				}
				for (i in 0...grpNotes.length) {
					var item = grpNotes.members[i];
					item.alpha = 0;
					if (currentlySelected == i) {
						item.alpha = 1;
					}
				}
				super.update(elapsed);
				return;
			}
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 9.6, 0, 1);
		for (i in 0...grpNotes.length) {
			var item = grpNotes.members[i];
			var intendedPos:Float = posX - 70;
			if (currentlySelected == i) {
				item.x = FlxMath.lerp(item.x, intendedPos + 100, lerpVal);
			} else {
				item.x = FlxMath.lerp(item.x, intendedPos, lerpVal);
			}
			for (j in 0...3) {
				var item2 = grpNumbers.members[(i * 3) + j];
				item2.x = item.x + 265 + (225 * (j % 3)) - (30 * item2.letters.length) / 2;
				if(ClientPrefs.arrowHSV[i][j] < 0) {
					item2.x -= 20;
				}
			}

			if(currentlySelected == i) {
				hsbText.setPosition(item.x + hsbTextOffsets[0], item.y - hsbTextOffsets[1]);
			}
		}

		if (controls.BACK || (changingNote && controls.ACCEPT)) {
			changeSelection();
			if(!changingNote) {
				close();
				grpNumbers.forEachAlive(function(spr:Alphabet) {
					spr.alpha = 0;
				});
				grpNotes.forEachAlive(function(spr:FlxSprite) {
					spr.alpha = 0;
				});
				#if android
			    FlxTransitionableState.skipNextTransOut = true;
			    FlxG.resetState();
			    #else
			    close();
			    #end
			}
			changingNote = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.8);
			Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Options Menu";
		}

		if(nextAccept > 0) {
			nextAccept -= 1;
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0) {
		currentlySelected += change;
		if (currentlySelected < 0)
			currentlySelected = ClientPrefs.arrowHSV.length-1;
		if (currentlySelected >= ClientPrefs.arrowHSV.length)
			currentlySelected = 0;

		currentlyValue = ClientPrefs.arrowHSV[currentlySelected][typeSelected];
		updateValue();

		for (i in 0...grpNumbers.length) {
			var item = grpNumbers.members[i];
			item.alpha = 0.6;
			if ((currentlySelected * 3) + typeSelected == i) {
				item.alpha = 1;
			}
		}
		for (i in 0...grpNotes.length) {
			var item = grpNotes.members[i];
			item.alpha = 0.6;
			item.scale.set(1, 1);
			if (currentlySelected == i) {
				item.alpha = 1;
				item.scale.set(1.2, 1.2);
				hsbText.setPosition(item.x + hsbTextOffsets[0], item.y - hsbTextOffsets[1]);
				blackBG.y = item.y - 20;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function changeType(change:Int = 0) {
		typeSelected += change;
		if (typeSelected < 0)
			typeSelected = 2;
		if (typeSelected > 2)
			typeSelected = 0;

		currentlyValue = ClientPrefs.arrowHSV[currentlySelected][typeSelected];
		updateValue();

		for (i in 0...grpNumbers.length) {
			var item = grpNumbers.members[i];
			item.alpha = 0.6;
			if ((currentlySelected * 3) + typeSelected == i) {
				item.alpha = 1;
			}
		}
	}

	function resetValue(selected:Int, type:Int) {
		currentlyValue = 0;
		ClientPrefs.arrowHSV[selected][type] = 0;
		switch (type) {
			case 0:
				shaderArray[selected].hue = 0;
			case 1:
				shaderArray[selected].saturation = 0;
			case 2:
				shaderArray[selected].brightness = 0;
		}

		var item = grpNumbers.members[(selected * 3) + type];
		item.text = '0';

		var add = (40 * (item.letters.length - 1)) / 2;
		for (letter in item.letters) {
			letter.offset.x += add;
		}
	}

	function updateValue(change:Float = 0) {
		currentlyValue += change;
		var roundedValue:Int = Math.round(currentlyValue);
		var max:Float = 180;
		switch (typeSelected) {
			case 1 | 2:
				max = 100;
		}

		if (roundedValue < -max) {
			currentlyValue = -max;
		} else if (roundedValue > max) {
			currentlyValue = max;
		}
		roundedValue = Math.round(currentlyValue);
		ClientPrefs.arrowHSV[currentlySelected][typeSelected] = roundedValue;

		switch (typeSelected) {
			case 0:
				shaderArray[currentlySelected].hue = roundedValue / 360;
			case 1:
				shaderArray[currentlySelected].saturation = roundedValue / 100;
			case 2:
				shaderArray[currentlySelected].brightness = roundedValue / 100;
		}

		var item = grpNumbers.members[(currentlySelected * 3) + typeSelected];
		item.text = Std.string(roundedValue);
		var add = (40 * (item.letters.length - 1)) / 2;
		for (letter in item.letters) {
			letter.offset.x += add;
			if (roundedValue < 0)
				letter.offset.x += 10;
		}
	}
}