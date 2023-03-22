package;

import lime.app.Application;
import flixel.FlxG;
import Discord.DiscordClient;

using StringTools;

class FirstCheckState extends MusicBeatState
{
	var isDebug:Bool = false;

	override public function create()
	{
		FlxG.mouse.visible = false;

		ClientPrefs.loadDefaultKeys();
		ClientPrefs.loadPrefs();

		super.create();

		#if debug
		isDebug = true;
		#end
	}

	override public function update(elapsed:Float)
	{		
		#if desktop
		#if CHECK_FOR UPDATES
		if (InternetConnection.isAvailable() && !isDebug)
		{
			var http = new haxe.Http("https://raw.githubusercontent.com/Stefan2008Git/FNF-SB-Engine/main/gitVersion.txt");
			var returnedData:Array<String> = [];

			http.onData = function(data:String)
			{
				returnedData[0] = data.substring(0, data.indexOf(';'));
				returnedData[1] = data.substring(data.indexOf('-'), data.length);

				if (!Application.current.meta.get('version').contains(returnedData[0].trim())
					&& !OutdatedState.leftState
					&& MainMenuState.nightly == "")
				{
					trace('Its outdated! ' + returnedData[0] + ' != ' + Application.current.meta.get('version'));
					OutOfDate.needVer = returnedData[0];
					OutOfDate.changelog = returnedData[1];

					FlxG.switchState(new OutdatedState());
				}
				else
				{	
					switch (ClientPrefs.firstTime)
					{
						case true:
							FlxG.switchState(new FirstTimeState());
						case false:
							FlxG.switchState(new TitleState());
					}
				}
			}
		#end

			http.onError = function(error)
			{
				trace('Error: $error');
				switch (ClientPrefs.firstTime)
				{
					case true:
						FlxG.switchState(new FirstTimeState());
					case false:
						FlxG.switchState(new TitleState());
				}
			}

			http.request();
		{
			trace('Offline mode');
			switch (ClientPrefs.firstTime)
			{
				case true:
					FlxG.switchState(new FirstTimeState());
				case false:
					FlxG.switchState(new TitleState());
			}
		}
        #else {
		trace('HTML5 mode');
		switch (ClientPrefs.firstTime)
			{
				case true:
					FlxG.switchState(new FirstTimeState());
				case false:
					FlxG.switchState(new TitleState());
			}
        }
		#end
	}
}