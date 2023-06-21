package options;

import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import options.*;
import flash.text.TextField;
import flixel.util.FlxSave;
import haxe.Json;
import sys.io.File;
import sys.FileSystem;

#if desktop
import meta.data.dependency.Discord.DiscordClient;
#end

using StringTools;

class ModsOptions extends MusicBeatState {
    private var mods:Array<String>;
    private var grpOptions:FlxTypedGroup<Alphabet>;
    private static var curSelected:Int = 0;
    public static var menuBG:FlxSprite;

    function openSelectedSubstate(label:String) {
        switch (label) {
            case 'Global':
                openSubState(new ModOptions());
            default:
                openSubState(new ModOptions(label));
        }
    }

    override function create() {
        mods = Paths.getModDirectories();
        mods.insert(0, 'Global');

        for (mod in mods) {
            if (!Paths.optionsExist(mod == 'Global' ? '' : mod)) {
                mods.remove(mod);
            }
        }

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        bg.color = 0xFFea71fd;
        bg.updateHitbox();

        bg.screenCenter();
        bg.antialiasing = ClientPrefs.globalAntialiasing;
        add(bg);

        grpOptions = new FlxTypedGroup<Alphabet>();
        add(grpOptions);

        for (i in 0...mods.length) {
            var optionText:Alphabet = new Alphabet(0, 0, mods[i], true);
            optionText.screenCenter();
            optionText.y += (80 * i) + 150;

            optionText.isMenuItem = true;
            optionText.targetY = i;
            optionText.alignment = CENTERED;
            optionText.distancePerItem.x = 0;
            optionText.startPosition.x = FlxG.width / 2;
            optionText.startPosition.y = 100;

            grpOptions.add(optionText);
        }

        changeSelection();

        super.create();
    }

    override function closeSubState() {
        super.closeSubState();
        ClientPrefs.saveSettings();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (controls.UI_UP_P || controls.UI_DOWN_P)
            changeSelection(controls.UI_UP_P ? -1 : 1);

        if (controls.BACK) {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            FlxTransitionableState.skipNextTransIn = true;
            FlxTransitionableState.skipNextTransOut = true;
            MusicBeatState.switchState(new OptionsState());
        }

        if (controls.ACCEPT) {
            openSelectedSubstate(mods[curSelected]);
        }
    }

    function changeSelection(change:Int = 0) {
        curSelected += change;
        if (curSelected < 0)
            curSelected = mods.length - 1;
        if (curSelected >= mods.length)
            curSelected = 0;

        var bullShit:Int = 0;

        for (item in grpOptions.members) {
            item.targetY = bullShit - curSelected;
            bullShit++;

            item.alpha = 0.6;
            if (item.targetY == 0) {
                item.alpha = 1;
            }
        }
        FlxG.sound.play(Paths.sound('scrollMenu'));
    }
}

typedef OptionData = {
    // ALL VALUES
    var name:String;
    var description:String;
    var saveKey:String;
    var type:String;
    var defaultValue:Dynamic;

    // STRING
    var options:Array<String>;
    // NUMBER
    var minValue:Dynamic;
    var maxValue:Dynamic;
    var changeValue:Dynamic;
    var scrollSpeed:Float;
    // BOTH STRING AND NUMBER
    var displayFormat:String;
}

class ModOptions extends BaseOptionsMenu {
    private var addedOptions:Array<Option>;
    private var modName:String;

    public function new(mod:String = '') {
        modName = mod;

        title = modName;
        rpcTitle = 'Mod Options Menu'; // for Discord Rich Presence

        var directory:String = modName == '' ? 'mods/options' : 'mods/$modName/options';
        directory = SUtil.getPath() + directory;

        if (FileSystem.exists(directory)) {
            for (file in FileSystem.readDirectory(directory)) {
                var path = haxe.io.Path.join([directory, file]);
                var save:FlxSave = new FlxSave();
                save.bind('options', modName == '' ? 'psychenginemods' : 'psychenginemods/$modName/');

                if (!FileSystem.isDirectory(path) && file.endsWith('.json')) {
                    var jsonFile:OptionData = cast Json.parse(File.getContent(path));
                    var defVal:Dynamic = getValuefromVariable(jsonFile.saveKey);
                    defVal = defVal == null ? defVal = jsonFile.defaultValue : defVal;

                    var option:SoftcodeOption = new SoftcodeOption(jsonFile.name, jsonFile.description, jsonFile.saveKey, jsonFile.type, defVal,
                        jsonFile.options);

                    option.displayFormat = quickTernary(jsonFile.displayFormat, '%v');

                    if (jsonFile.type == 'int' || jsonFile.type == 'float' || jsonFile.type == 'percent') {
                        option.minValue = jsonFile.minValue;
                        option.maxValue = jsonFile.maxValue;
                        option.changeValue = quickTernary(jsonFile.changeValue, 1);
                        option.scrollSpeed = quickTernary(jsonFile.scrollSpeed, 50);
                    }

                    addOption(option);
                };
            };
        };

        super();
    }

    override function closeState() {
        var save:FlxSave = new FlxSave();
        var dir = (modName == '' ? 'psychenginemods' : 'psychenginemods/$modName/');

        save.bind('options', dir);

        for (option in optionsArray) {
            option.setModValue(option.getModValue());
        }

        save.flush();
        super.closeState();
    };

    private function quickTernary(variable:Dynamic, defaultValue:Dynamic):Dynamic {
        return variable != null ? variable : defaultValue;
    }
    private function getValuefromVariable(variable:Dynamic) {
        return ClientPrefs.getValueFromSave(variable);
    }
}

class SoftcodeOption extends Option
{
    private var emulatedValue:Dynamic = null;

    override function getValue():Dynamic {
        return emulatedValue;
    }

    override function setValue(value:Dynamic) {
        return emulatedValue = value;
    }
}
