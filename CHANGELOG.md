# Changelog
All notable changes will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.8.0] - 01.09.2023
- Now SB Engine is using new HaxeFlixel 5.3x stuff because the old one was crashing without any reason to enter the game. Some fixes did by: @MemeHovy for Sound stuff and other things. (SWITCHED AND BRAND NEW!)
- EDITED THE ENTIRE SOURCE CODE TO LOOK LIKE 0.7 (BRAND NEW!)


Question about new folder organization from Psych Engine 0.7:

A: It's lua stuff are still working like 0.6, 0.6.1, 0.6.2 and 0.6.3?

B: Yes, i just imported all states and other stuff to work like older versions of Psych Engine possible.

A: Can i still use shaders from Psych Engine 0.5.1 with shaders and wiggle effect too?

B: Yeah, you can still use it. I tried.

A: It's this engine optimized little bit for better experience then before?

B: Since i edited the entire source code to look like Psych Engine 0.7, yeah. Now SB Engine it's using little bit memory for better experience.

A: It's all states and substates working perfectly with this new folder organization from older version of SB Engine?

B: Yeah. Every single state and substate is working perfectly without any problems.

A: It's Android build also working perfectly with this new organization?

B: Ofcourse it is. Now you can play little bit better with folder organization on Android build.
- Removed loading screen from game forever! (REMOVED!)
Added music for flashing screen from Baldi Basic Classic Remastered and added back VCR OSD Mono! (BRAND NEW!)
- Added easter egg, radnom tip text from Joalor64 Engine on default and classic main menu. To get easter egg, press on Android "BACK" on navigation bar and for PC press "S" key from YoshiCrafter Engine. (BRAND NEW!)
- Added to show text for options what you need to use if you forget. Credits: VPsych Engine (Modifed Vietnam Psych Engine fork) (BRAND NEW!)
- Added themes on engine, but this option it's on alpha state, so maybe can be little bit buggy. Now you can get color from Psych Engine if you are interested. (BRAND NEW!)
Showcase:

  SB Engine:

    - Background color for main menu if you have enabled flashing lights = PURPLE
    - Background color for options = PURPLE
    - Background color for master editor menu = PURPLE
    - Background color for gameplay changers and pause menu = PURPLE
    - Background color for chart editor and play chart editor = PURPLE
    - Background color for Android controls menu = PURPLE


 - Psych Engine:

   - Background color for main menu if you have enabled flashing lights = MAGENTA
   - Background color for options = MAGENTA
   - Background color for master editor menu = BLACK
   - Background color for gameplay changers and pause menu = BLACK
   - Background color for chart editor and play chart editor = BLACK AND RADNOM COLOR
   - Background color for Android controls menu = RADNOM COLOR

- Added changes for note color menu. (BRAND NEW!)

Changes:

 - When you press up or down, notes gonna have some angle from Psych Engine 0.4.2
- Alphabet is little bit broken when you change color, but it's gonna be fixed on full release

- "velocityBG" is now renamed to "velocityBackground" for better name. Removed sprite for velocity background and is using FlxGridOverlay for better experience. (BRAND NEW!)
- Added new changes for song (BRAND NEW!)
 - Changes:

 - New health bar overlay is here. Used from SaraHUD file.

  - "sbEngineIconBounce" is now renamed to "casseteGirlIconBounce" for better name.

  - "SB Engine" ui now has have brand new icon bounce and fixed for "SB Engine" watermak style position
  - "Better UI" now has have Cassete girl icon bounce for better experience and score text scale
  - Added winning icons from Grafex Engine
  - Added new rating system for different game engine style

- Fixed opponent icon position for better experience on pause menu. (BRAND NEW!)
- Added opponent and boyfriend trail option on chart editor from Grafex Engine (BRAND NEW!)
- Added health bar overlay on character editor. Position will be fixed soon on full release of engine. (BRAND NEW!)
- Added for dodge mechanics to hitbox. [To work, is requred to be "Space extended" option enabled to work and you need to select "New" hitbox style] and change hitbox space position to your choice. (BRAND NEW!)
- Fixed video handler crash for Android using different hxCodec repository
- Added back old application icon from original game
- Added back old fade transitionn when you switch state

- Removed background when you start engine and timer is little bit changed for sound  (REMOVAL!)
- Added back "LoadingState" instead "MusicBeatState" because it's doesn't loading assets from shared folder! Now you can disable boyfriend and girlfriend simply pressing option "Effects on option" and time bar is big and color for bar is green! (ADDITION!)
- Added brand new FPS option: "Total FPS". It's gonna show how much do you have maximum FPS. Credits: huy1234th: Creator of VPsych-Engine (BRAND NEW!)
- Re-organized little bit master editor menu to letter. (BRAND NEW!)
- Added extra time bar types from JS Engine. JS Engine made by: @JordanSantiago 
- Removed the virtual pad button on results creen becase it's breaking the entire engine (It's using now touch screen option) and background will be little bit visible. (REMOVAL!)
- Added to show playback speed. It can be turned on/off btw (BRAND NEW!)
- Added GPU Caching (BRAND NEW!)
- Added HScript support, but it's W.I.P unfortunalety. (BRAND NEW!)
- Removed health bar overlay from game completely!!!! (REMOVAL!)
- Added music on editors (Not on chart editor!) (BRAND NEW!)

## [2.7.0] - 05.07.2023
- Hxcpp 4.2.1 it's here if you want to compile source code for color background issue. (CHANGED!)
- Added back internal audio for Android. (NOTE: This is gonna have 2 builds!) (ADDED BACK!)
- Added intro sound when you enter to game. Credits: Nico Nextbots (BRAND NEW!)
- Added "Special Credits" tab on Credits menu for special peoples. "Android support" tab it's removed and replaced to "Special credits" tab (NEW!)
- Now you can enable/disable timebar if you want for gameplay. (BRAND NEW!)
- Watermark style it's here and health bar overlay from Grafex Engine. (BRAND NEW!)
Styles:

SB Engine: From 2.2.0 version to 2.3.0 (Note: Position of watermark it's broken, so it's gonna be fixed on next release).
Kade Engine: Song name, difficulty name, SB Engine version and Psych Engine version
Dave and Bambi: Song name and health bar overlay from Dave and Bambi too.

- Time bar it's added when you want to test your chart inside Chart Editor, but you can change time bar type and disable/enable time bar if you want too. Same when you want to change to gameplay. (BRAND NEW!)
- Added custom application title when you select other state. (Note: Only works on PC build). (BRAND NEW!)

## [2.6.0] - 23.06.2023
- NEW officialy SB Engine logo is here. Maked by: Nurry. Subscribe to her, beacuse she is best artist and she is new official artist🥳.
- Alphabet V2 from Psych Engine 0.6.3 it's here!
- Added better loading screen. When you open the game, now it's gonna show pop up logo and loading time it's now 20 seconds. After when loading is finished, it's gonna fade black background.
- "FlashingState" it's now renamed to: "FlashingScreenState" for better name. Added new better desing when you press enter or back. (CHANGED AND BRAND NEW)
- "TitleState" it's now renamed to: "TitleScreenState" for better name. Removed completely unsused Psych Engine easter eggs. Added trail on logo and girlfriend, but it can be laggy, but you can disable that option to remove lag. (CHANGED AND BRAND NEW)
- New better main menu. Now when you press enter on title screen it's gonna menu buttons to be down like from Kade Engine. (BRAND NEW!)
- Options text it's now on left position for better experience.
- Added brand new changes for Android controls. Credits: MarioMaster. (BRAND NEW):
Now you can select your hitbox:
"Classic": old sprites and "New": new hitbox without sprites, but with button recreated on code!
You can now setup your opacity for hitbox (It's working on old and new hitbox)
Virtual pad opacity:
Now you can change opacity on your virtual pad for invisibilty. Credits for VS Tails.EXE V2 Android port:
Maximum value for opacity it's: 1
To change your opacity for virtual pads and hitbox style, press on options menu button "Y", but for android controls press "X"
- Added brand new options: "Velocity backgrounds" and "Effects on object" (BRAND NEW!):
Now you can disable velocity background on "Visual and UI" options for little optimization.
If you have lag on title screen with trail, you can disable on "Visual and UI" if you have lag too
- Added option to disable/enable opponent arrow glow. (BRAND NEW)
If you want to look like from OG Friday Night Funkin game
- Added long time support for 25+ minutes. Credits: Codename Engine
- Added new game engine style! (BRAAAAAAAAAAAAAAAAAAAAAAAND NEW!):
Now you can enable custom HUD style from different engine's and it's gonna change font too:

SB Engine:
Font: Bahnscrifht
Score text: SB Engine version
Icon bounce: From OS Engine
Icon bounce speed: 20
Time bar style: Big time bar with purple color
Autoplay text: "[AUTOPLAY]"
Position of autoplay: Kade Engine
Autoplay speed of sine: 120
Rating stuff: SB Engine system

Psych Engine:
Font: VCR OSD Mono
Sore text: Basic Psych Engine
Icon bounce: From Psych Engine
Icon bounce speed: 9
Time bar style: Small time bar with white color
Autoplay text: "BOTPLAY"
Position of autoplay: Psych Engine
Autoplay speed of sine: 180
Rating stuff: Psych Engine system

Better UI:
Font: VCR OSD Mono
Score text: Similar with Kade Engine
NPS it's here
Health counter it's here from: Grafex Engine
MS text and average it's here from: OS Engine
Time bar style: Dave and Bambi time bar style with opponent health bar color (It can be buggy when it's changing a character, but okay)
Autoplay text: "[CpuControlled]"
Position of autoplay: Kade Engine
Rating stuff: Kade Engine

- New shaders are here (BRAND NEW!)
You need to enable option on "Graphics" option to work. Same for PE 0.5.1 shaders
Shaders are called: "Wiggle effect". Similar from Hortas Edition V3
To add it on .lua, you need to put this:
function onCreate() makeLuaSprite('background', 'test', -900, -300) setLuaSpriteScrollFactor('background', 0, 0) addWiggleEffect('background', 'shaderName') addLuaSprite('background', false) end
Actrually for value shaderName on addWiggleEffect('background', 'shaderName') you can use this shaders:

flagEffect

dreamyEffect

heatWaveHorizontalEffect

heatWaveVerticalEffect

wavyEffect

## [2.5.0] - 25.05.2023
### Changelogs
- VCR OSD Mono it's now replaced with Bahnschrift font. (CHANGED!)
- Orange color it's now replaced with purple. (CHANGED!)
- REMOVED WEEK 7 CUSTSCENE SPRITES FROM GAME TO GIVE A LITTLE BIT FREE STORAGE FROM GAME! (REMOVED!)
- Added x32 bits on game for Android using old Hxcpp version. Fixed by: MaysLastPlays
- New icon for Stefan2008 (Me) on credits menu. Maked by TheDarkCris, recolored by Stefan2008 (Me) (CHANGED!)
- Added a new custom splash screen when you enter on game. (BRAND NEW!)
- Added checker background on loading screen and fixed the for Android it's not show tips (NEW AND FIXED!)
- Added a brand new flashing screen with background and changed text :))
- New custom title screen, Maked when you press ENTER to be invisible and it's cool. Credits: Micd'UP Engine (BRAND NEW!)
- New custom fade transition speed, to look like from: Forever Engine (BRAND NEW!)
- New custom main menu with SB Engine logo and tween main menu button when you press it. Credits for VS Bambi: Strident Crisis for cool tween and for background tho. (BRAND NEW!)
- New better way to have a small lag. The old alpha main menu without any animated sprite's, but only with alphabet. To have old classic main menu, go to options - visual ui and just simply press left ot right to change it. "Classic - Basic main menu without any animated sprite, but only with alphabet" and "Original - Original main menu". Credits: Joalor64-Engine-Rewrite (BRAND NEW!)
- FPS recreation to basic game. New FPS feature:

    - New way better to turn on/off memory (BRAND NEW!)
    - Fixed memory peak (FIXED!)
    - Added rainbow FPS (BRAND NEW FEATURE!)
    - GL render it's now replaced with debug info (It's showing state and substate now) (BRAND NEW AND CHANGED!)
- Colorblind mode it's here. Credits: OS Engine (BRAND NEW!)
- What's added when you playing song:

    - Added results screen when you finish song. (BRAND NEW FEATURE!)
    - Now you can use options on pause menu. Credits: OS Engine (BRAND NEW!)
    - New way better to change time bar style. Go to options - gameplay and find "SB Engine time bar style". If you check, you will have SB Engine time bar or if you uncheck, you will have basic Psych Engine time bar color and style. (BRAND NEW FEATURE!)
    - If you want to turn off judgement counter and watermark, than go to option - gameplay and find 2 options: "Hide judgement counter" and "Hide watermark. (NEW!)
    - "[AUTOPLAY] is disabled" text it's removed completely beacuse it's buggy and unfixable (REMOVED!)
- Added exit menu. Go to title screen and press for Android "BACK" to go on exit menu, for PC press ESC. OS Engine (BRAND NEW!)


## [2.4.0] - 12.04.2023

### Changelogs 
-Added checker background, logo angle on title screen from Kade Engine :D. (NEW!)
- Added back mods menu button and state too. (CHANGED!)
- Added note angle and flash camera when you reset value color for notes colors options. Credits for: DENPA Engine
- Added a small changes for freeplay menu. (CHANGED!)
- Added back watermark, but fixed the position for downscroll users, added judgement counter, added when you have disabled autoplay it's showing: "[AUTOPLAY] is disabled!", but if you have enabled autoplay it's showing normally and maked the position for autoplay to look like Kade Engine. (BRAND NEW!)
- New SB Engine logo added by me (Stefan2008). (BRAND NEW!)
- New icon app maked by me (Stefan2008). (BRAND NEW!)
## [2.3.0] - 12.04.2023

### Changelogs
- Fixed the scroll thing for Chart editor to Android (BUGFIX)
- Added a new change's for crash handler. It's showing engine version (NEW)
- Removed internal audio support from game (REMOVED)

## [2.2.0] - 02.04.2023
### Changelogs
- Added a loading screen with some radnom tip, gradient bar and logo
- Added a transparent gradient bar on title screen
- Added velocity background and removed camera thing from main menu
- Fixed bug with options, game over screen and pause menu it's not crashing anymore
- Added a engine version, memory peak and added back to normal FPS
- Added a "Difficulty" tab box. Now you can load easily chart's when you have difficulty name. It's automaticlly load if you have correct song name and difficulty
- Added some small changes on feeeplay menu
- Added Psych Engine version, SB Engine version, changed watermark text position, added a icon bounce from OS Engine and changed HUD
- Added playback stuff from 0.6.3 latest version and lua stuff too
- Fixed the Android issue with crashing when you want to play mods song and some shaders are not working on Android, only all lua shaders are working on PC
- Added internal support for low SDK devices on Android. Now you need to enable permission to manage your permission
- Fixed the bug it's not showing a "Chart Editor" text on pause screen menu

## [2.1.0] - 05.03.2023
### Changelogs
- Changed main menu
- Changed master editor menu
- Added acruracy and watermark
- Added fixed shader's.
- Added GL Render on FPS
- REMOVED OLD OS ENGINE BUILD'S!
