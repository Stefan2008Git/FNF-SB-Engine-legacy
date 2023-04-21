package options;

#if desktop
import Discord.DiscordClient;
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
import Controls;

using StringTools;

class NotesSubState extends MusicBeatSubstate
{
	private static var curSelected:Int = 0;
	private static var typeSelected:Int = 0;
	private var grpNumbers:FlxTypedGroup<Alphabet>;
	private var grpNotes:FlxTypedGroup<FlxSprite>;
	private var shaderArray:Array<ColorSwap> = [];
	var curValue:Float = 0;
	var holdTime:Float = 0;
	var nextAccept:Int = 5;

    var velocityBG:FlxBackdrop;
	var blackBG:FlxSprite;
	var hsbText:Alphabet;
	var positionX = 230;

	public function new() {
		super();
		
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFFFA500;
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		blackBG = new FlxSprite(positionX - 25).makeGraphic(1140, 200, FlxColor.BLACK);
		blackBG.alpha = 0.4;
		add(blackBG);

		velocityBG = new FlxBackdrop(Paths.image('velocity_background'));
		velocityBG.velocity.set(50, 50);
		add(velocityBG);

		grpNotes = new FlxTypedGroup<FlxSprite>();
		add(grpNotes);
		grpNumbers = new FlxTypedGroup<Alphabet>();
		add(grpNumbers);

		#if android
		var resetText:FlxText = new FlxText(12, FlxG.height - 40, "Press C to reset selected note.", 80);
		#else
		var resetText:FlxText = new FlxText(12, FlxG.height - 40, "Press RESET to reset selected note.", 80);
		#end
		resetText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER);
		add(resetText);

		if (ClientPrefs.arrowHSV.length != 9) {
			ClientPrefs.arrowHSV = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]];
		}
		//trace (ClientPrefs.arrowHSV.length);
		for (i in 0...ClientPrefs.arrowHSV.length) {
			var yPos:Float = (80 * i) - 40;
			for (j in 0...3) {
				var optionText:Alphabet = new Alphabet(0, yPos + 60, Std.string(ClientPrefs.arrowHSV[i][j]), true, false, 0.05, 0.8);
				optionText.x = positionX + (225 * j) + 250;
				optionText.ID = i;
				grpNumbers.add(optionText);
			}

			var note:FlxSprite = new FlxSprite(positionX, yPos);
			note.frames = Paths.getSparrowAtlas('NOTE_assets');
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

		hsbText = new Alphabet(0, 0, "Hue    Saturation  Brightness", false, false, 0, 0.65);
		hsbText.x = positionX + 330;
		add(hsbText);

		changeSelection();

		#if android
		addVirtualPad(LEFT_FULL, A_B_C);
		#end

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	var changingNote:Bool = false;
	var angleTween:FlxTween;
	var scaleTween:FlxTween;
	var lastSelected:Int = 99;
	override function update(elapsed:Float) {
		var valueOption = 0;
		var lerpVal:Float = CoolUtil.clamp(elapsed * 9.6, 0, 1);
		for (i in 0...grpNumbers.length) {
			var item = grpNumbers.members[i];
			var scaledY = FlxMath.remapToRange(item.ID, 0, 1, 0, 1.3);
			item.y = FlxMath.lerp(item.y, (scaledY * 165) + 270 + 60, lerpVal);
			item.x = FlxMath.lerp(item.x, (item.ID * 20) + 90 + positionX + (225 * valueOption + 250), lerpVal);
			valueOption++;
			if (valueOption == 3) valueOption = 0;
		}
		for (i in 0...grpNotes.length) {
			var item = grpNotes.members[i];
			var scaledY = FlxMath.remapToRange(item.ID, 0, 1, 0, 1.3);
			item.y = FlxMath.lerp(item.y, (scaledY * 165) + 270, lerpVal);
			item.x = FlxMath.lerp(item.x, (item.ID * 20) + 90, lerpVal);
			if (i == curSelected) {
				hsbText.y = item.y - 70;
				blackBG.y = item.y - 20;
				blackBG.x = item.x - 20;
				if (lastSelected != curSelected) {
					lastSelected = curSelected;
					if (angleTween != null) angleTween.cancel();
					angleTween = null;
					if (scaleTween != null) scaleTween.cancel();
					scaleTween = null;
					item.scale.set(0.78,0.78);
					angleTween = FlxTween.angle(item, -12, 12, 2, {ease: FlxEase.quadInOut, type: FlxTweenType.PINGPONG});
					scaleTween = FlxTween.tween(item, {"scale.x": 0.92, "scale.y": 0.92}, 1, {ease: FlxEase.quadInOut, type: FlxTweenType.PINGPONG});
				}
			} else {
				item.scale.set(0.6,0.6);
				item.angle = 0;
			}
		}

		if(changingNote) {
			if(holdTime < 0.5) {
				if(controls.UI_LEFT_P) {
					updateValue(-1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				} else if(controls.UI_RIGHT_P) {
					updateValue(1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				} else if(controls.RESET #if android || virtualPad.buttonC.justPressed #end) {
					resetValue(curSelected, typeSelected);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				if(controls.UI_LEFT_R || controls.UI_RIGHT_R) {
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
					resetValue(curSelected, i);
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
					if ((curSelected * 3) + typeSelected == i) {
						item.alpha = 1;
					}
				}
				for (i in 0...grpNotes.length) {
					var item = grpNotes.members[i];
					item.alpha = 0;
					if (curSelected == i) {
						item.alpha = 1;
					}
				}
				super.update(elapsed);
				return;
			}
		}

		if ((controls.BACK) || (changingNote && (controls.ACCEPT))) {
			if(!changingNote) {
				#if android
				FlxTransitionableState.skipNextTransOut = true;
				FlxG.resetState();
				#else
				close();
				#end
			} else {
				changeSelection();
			}
			changingNote = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}

		if(nextAccept > 0) {
			nextAccept -= 1;
		}
		super.update(elapsed);
	}

	override function destroy() {
		if (angleTween != null) angleTween.cancel();
		angleTween = null;
		if (scaleTween != null) scaleTween.cancel();
		scaleTween = null;
		super.destroy();
	}

	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = ClientPrefs.arrowHSV.length-1;
		if (curSelected >= ClientPrefs.arrowHSV.length)
			curSelected = 0;

		curValue = ClientPrefs.arrowHSV[curSelected][typeSelected];
		updateValue();

		var freakOption = 0;
		var valueOption = 0;
		//var currow;
		var freakOption2 = 0;
		for (i in 0...grpNumbers.length) {
			var item = grpNumbers.members[i];
			item.alpha = 0.6;
			if ((curSelected * 3) + typeSelected == i) {
				item.alpha = 1;
			}
			item.ID = freakOption - curSelected;
			valueOption++;
			if (valueOption == 3) {
				valueOption = 0;
				freakOption++;
			}
		}
		for (i in 0...grpNotes.length) {
			var item = grpNotes.members[i];
			item.alpha = 0.6;
			item.scale.set(0.5, 0.5);
			if (curSelected == i) {
				item.alpha = 1;
				item.scale.set(0.6, 0.6);
				hsbText.y = item.y - 40;
				blackBG.y = item.y + 28;
			}
			item.ID = freakOption2 - curSelected;
			freakOption2++;
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function changeType(change:Int = 0) {
		typeSelected += change;
		if (typeSelected < 0)
			typeSelected = 2;
		if (typeSelected > 2)
			typeSelected = 0;

		curValue = ClientPrefs.arrowHSV[curSelected][typeSelected];
		updateValue();

		for (i in 0...grpNumbers.length) {
			var item = grpNumbers.members[i];
			item.alpha = 0.6;
			if ((curSelected * 3) + typeSelected == i) {
				item.alpha = 1;
			}
		}
	}

	function resetValue(selected:Int, type:Int) {
		curValue = 0;
		ClientPrefs.arrowHSV[selected][type] = 0;
		switch(type) {
			case 0: shaderArray[selected].hue = 0;
			case 1: shaderArray[selected].saturation = 0;
			case 2: shaderArray[selected].brightness = 0;
		}

		var item = grpNumbers.members[(selected * 3) + type];
		item.changeText('0');
		item.offset.x = (40 * (item.lettersArray.length - 1)) / 2;
	}
	function updateValue(change:Float = 0) {
		curValue += change;
		var roundedValue:Int = Math.round(curValue);
		var max:Float = 180;
		switch(typeSelected) {
			case 1 | 2: max = 100;
		}

		if(roundedValue < -max) {
			curValue = -max;
		} else if(roundedValue > max) {
			curValue = max;
		}
		roundedValue = Math.round(curValue);
		ClientPrefs.arrowHSV[curSelected][typeSelected] = roundedValue;

		switch(typeSelected) {
			case 0: shaderArray[curSelected].hue = roundedValue / 360;
			case 1: shaderArray[curSelected].saturation = roundedValue / 100;
			case 2: shaderArray[curSelected].brightness = roundedValue / 100;
		}

		var item = grpNumbers.members[(curSelected * 3) + typeSelected];
		item.changeText(Std.string(roundedValue));
		item.offset.x = (40 * (item.lettersArray.length - 1)) / 2;
		if(roundedValue < 0) item.offset.x += 10;
	}
}