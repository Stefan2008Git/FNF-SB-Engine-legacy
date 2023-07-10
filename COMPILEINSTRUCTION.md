THESE INSTRUCTIONS ARE FOR COMPILING THE GAME'S SOURCE CODE!!!

IF YOU WANT TO JUST DOWNLOAD AND INSTALL AND PLAY THE GAME NORMALLY, GO TO GAMEBANANA TO DOWNLOAD THE GAME FOR ANDROID, MAC, LINUX AND WINDOWS!!

https://gamebanana.com/tools/10824

IF YOU WANT TO COMPILE THE GAME YOURSELF, CONTINUE READING!!!

### Installing the Required Programs

1. [Install Haxe 4.2.5](https://haxe.org/download/version/4.2.5/) (Download 4.2.5 instead of 4.3.0 because 4.3.0 is broken and is not working with the game...)
2. [Install HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/) after downloading Haxe

Other installations you'd need are the additional libraries, a fully updated list will be in `Project.xml` in the project root. Currently, these are all of the things you need to install:

``haxelib install hxcpp 4.2.1``

``haxelib install lime``

``haxelib install openfl``

``haxelib install flixel``

``haxelib install flixel-addons``

``haxelib install hxCodec 2.5.1``

``haxelib install hscript``

``haxelib install hxcpp-debug-server``

  So for each of those type `haxelib install [library]` so library like `haxelib install openfl 9.1.0`

You'll also need to install a couple things that involve Gits. To do this, you need to do a few things first.
1. Download [git-scm](https://git-scm.com/downloads). Works for Windows, Mac, and Linux, just select your build.
2. Follow instructions to install the application properly.
3. Run `haxelib git linc_luajit https://github.com/nebulazorua/linc_luajit` to install Lua stuff.
4. Run `haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc` to install Discord RPC.

You should have everything ready for compiling the game! Follow the guide below to continue!

### Compiling game
NOTE: If you see any messages relating to deprecated packages, ignore them. They're just warnings that don't affect compiling

Once you have all those installed, it's pretty easy to compile the game. You just need to run `lime test windows -debug` in the root of the project to build and run the windows version
