package backend;

#if sys
import Sys.sleep;
#end
#if desktop
import discord_rpc.DiscordRpc;
#end
#if LUA_ALLOWED
import llua.Lua;
import llua.State;
#end
import states.MainMenuState;

using StringTools;

class DiscordClient {
	public static var isInitialized:Bool = false;

	public function new() {
		#if desktop
		trace("Discord Client it's starting...");
		DiscordRpc.start({
			clientID: "1059518348196597831",
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		trace("Discord Client it's started.");

		while (true) {
			DiscordRpc.process();
			#if sys
			sleep(2);
			#end
		}

		DiscordRpc.shutdown();
		#end
	}

	public static function check()
	{
		if(!ClientPrefs.discordRPC)
		{
			if(DiscordClient.isInitialized) DiscordClient.shutdown();
			DiscordClient.isInitialized = false;
		}
		else DiscordClient.start();
	}

	public static function start()
	{
		if (!DiscordClient.isInitialized && ClientPrefs.discordRPC) {
			DiscordClient.initialize();
			Application.current.window.onClose.add(function() {
				DiscordClient.shutdown();
			});
		}
	}

	public static function shutdown() {
		DiscordRpc.shutdown();
	}

	static function onReady() {
		DiscordRpc.presence({
			details: "Welcome to FNF': SB Engine",
			state: null,
			largeImageKey: 'icon',
			largeImageText: "FNF': SB Engine",
			smallImageKey: 'ministefan',
			smallImageText: 'Creator: Stefan2008'
		});
	}

	static function onError(_code:Int, _message:String) {
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String) {
		trace('Disconnected! $_code : $_message');
	}

	public static function initialize() {
		var DiscordDaemon = sys.thread.Thread.create(() -> {
			new DiscordClient();
		});
		trace("Discord Client it's initialized");
		isInitialized = true;
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float) {
		var startTimestamp:Float = if (hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0) {
			endTimestamp = startTimestamp + endTimestamp;
		}

		DiscordRpc.presence({details: details,
			state: state,
			largeImageKey: 'icon',
			largeImageText: "Engine version: " + MainMenuState.sbEngineVersion + " (PE " + MainMenuState.psychEngineVersion + ") ",
			smallImageKey: 'ministefan',
			smallImageText: "Creator: Stefan2008",
			startTimestamp: Std.int(startTimestamp / 1000),
			endTimestamp: Std.int(endTimestamp / 1000)
		});
	}

	#if LUA_ALLOWED
	public static function addLuaCallbacks(lua:State) {
		Lua_helper.add_callback(lua, "changePresence",
			function(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float) {
				changePresence(details, state, smallImageKey, hasStartTimestamp, endTimestamp);
			});
	}
	#end
}
