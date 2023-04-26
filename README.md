# Friday Night Funkin': SB Engine
![](https://raw.githubusercontent.com/Stefan2008Git/FNF-SB-Engine/main/documents/SB-Engine.png)

[![GitHub all releases downloaded](https://img.shields.io/github/downloads/Stefan2008Git/FNF-SB-Engine/total?style=flat-square)](https://github.com/Stefan2008Git/FNF-SB-Engine/releases)

Used and coded on: [Psych Engine](https://gamebanana.com/mods/309789).
## SB Engine Credits:
* Stefan2008 - Programmer
* MaysLastPlay - Collaborator
* Fearester - Second Collaborator

### Psych Engine Credits:
* Shadow Mario - Programmer
* RiverOaken - Artist
* Yoshubs - Assistant Programmer
* bbpanzu - Ex-Programmer
* Yoshubs - New Input System
* SqirraRNG - Crash Handler and Base code for Chart Editor's Waveform
* KadeDev - Fixed some cool stuff on Chart Editor and other PRs
* iFlicky - Composer of Psync and Tea Time, also made the Dialogue Sounds
* PolybiusProxy - .MP4 Video Loader Library (hxCodec)
* Keoiki - Note Splash Animations
* Smokey - Sprite Atlas Support
* Nebula the Zorua - LUA JIT Fork and some Lua reworks


# Welcome to SB Engine - (Modified Psych Engine) with some change's and addition: 
### What SB Engine has added and changed?
# Changed main menu: 
![](https://raw.githubusercontent.com/Stefan2008Git/FNF-SB-Engine/main/documents/Example_1.png)

# Changed master editor menu:
![](https://raw.githubusercontent.com/Stefan2008Git/FNF-SB-Engine/main/documents/Example_2.png)

# Added accruracy and watermark:
![](https://raw.githubusercontent.com/Stefan2008Git/FNF-SB-Engine/main/documents/Example_3.png)

# Added lua shader's. Here are 2 example's. Note: You need to enable "Shaders on lua" on graphic option's! [Thanks Lizzy Strawberry](https://www.youtube.com/@LizzyStrawberry):
### Bloom effect:
![](https://raw.githubusercontent.com/Stefan2008Git/FNF-SB-Engine/main/documents/Example_4.png)
### Glitch effect:
![](https://raw.githubusercontent.com/Stefan2008Git/FNF-SB-Engine/main/documents/Example_5.png)

# Added GL Render on FPS text:
![](https://raw.githubusercontent.com/Stefan2008Git/FNF-SB-Engine/main/documents/Example_7.png)

# Changed "####" to "Freak":
![](https://raw.githubusercontent.com/Stefan2008Git/FNF-SB-Engine/main/documents/Example_6.png)

## Building and compiling

THESE INSTRUCTIONS ARE FOR COMPILING THE GAME'S SOURCE CODE!!!

IF YOU WANT TO JUST DOWNLOAD AND INSTALL AND PLAY THE GAME NORMALLY, GO TO GAMEBANANA TO DOWNLOAD THE GAME FOR ANDROID, MAC, LINUX AND WINDOWS!!

https://gamebanana.com/tools/10824

IF YOU WANT TO COMPILE THE GAME YOURSELF, CONTINUE READING!!!

### Installing the Required Programs

1. [Install Haxe 4.2.5](https://haxe.org/download/version/4.2.5/) (Download 4.2.5 instead of 4.3.0 because 4.3.0 is broken and is not working with the game...)
2. [Install HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/) after downloading Haxe

Other installations you'd need are the additional libraries, a fully updated list will be in `Project.xml` in the project root. Currently, these are all of the things you need to install:

``haxelib install lime 7.9.0``

``haxelib install openfl 9.1.0``

``haxelib install flixel``

``haxelib run lime setup flixel``

``haxelib run lime setup``

``haxelib install flixel-tools``

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
