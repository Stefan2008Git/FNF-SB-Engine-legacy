package;

import flixel.FlxG;
import flixel.util.FlxSave;

using StringTools;

class ModOptionSaver extends ClientPrefs {
	public static function addSave(name:String, value:Dynamic):Void {
		FlxG.save.data[name] = value;
	}

	public static function getValueFromSave(name:String):Dynamic {
		if (FlxG.save.data[name] != null) {
			return FlxG.save.data[name];
		}
		return null;
	}
}