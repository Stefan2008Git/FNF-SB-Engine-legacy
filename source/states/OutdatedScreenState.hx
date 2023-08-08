package states;

#if desktop
import backend.Discord.DiscordClient;
#end
import backend.ClientPrefs;
import backend.CoolUtil;
import backend.MusicBeatState;
import backend.Paths;
import states.MainMenuState;
import states.TitleScreenState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;

class OutdatedScreenState extends MusicBeatState {
	public static var leftState:Bool = false;

	var background:FlxSprite;
	var velocityBackground:FlxBackdrop;
	var warningText:FlxText;
	var warningTextTween:FlxTween;

	override function create() {
        Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

        FlxG.sound.playMusic(Paths.music('warningScreenMusic'), 0.5);

		super.create();

        #if desktop
	    // Updating Discord Rich Presence
	    DiscordClient.changePresence("Warning Menu", null);
	    #end

		background = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		background.scrollFactor.set();
		background.updateHitbox();
		background.screenCenter();
		background.antialiasing = ClientPrefs.globalAntialiasing;
		background.color = 0xFF353535;
		add(background);

		velocityBackground = new FlxBackdrop(FlxGridOverlay.createGrid(30, 30, 60, 60, true, 0x3B161932, 0x0), XY);
		velocityBackground.velocity.set(FlxG.random.bool(50) ? 90 : -90, FlxG.random.bool(50) ? 90 : -90);
		velocityBackground.visible = ClientPrefs.velocityBackground;
		add(velocityBackground);

		#if android
		warningText = new FlxText(0, 0, FlxG.width,
			"Hello player, unfortunalety it's seem's like looks you're are running an   \n
			outdated version of SB Engine (" + MainMenuState.sbEngineVersion + "),\n
			please update to " + TitleScreenState.updateVersion + "!\n
            Press A to go on Gamebanana site.\n
			Press B to proceed anyway.\n
			\n
			Thank you for using modified fork of Psych Engine v " + MainMenuState.psychEngineVersion + "! ",
			32);
		#else
		warningText = new FlxText(0, 0, FlxG.width,
			"Hello player, unfortunalety it's seem's like looks you're are running an   \n
			outdated version of SB Engine (" + MainMenuState.sbEngineVersion + "),\n
			please update to " + TitleScreenState.updateVersion + "!\n
            Press ENTER to go on Gamebanana site.\n
			Press ESCAPE to proceed anyway.\n
			\n
			Thank you for using modified fork of Psych Engine v" + MainMenuState.psychEngineVersion + "! ",
			32);
		#end
		warningText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		warningText.borderSize = 2.4;
		warningText.screenCenter(Y);
		warningText.alpha = 0;
		warningText.scale.x = 0;
		warningText.scale.y = 0;
		add(warningText);

        #if android
		addVirtualPad(NONE, A_B);
		#end

        FlxTween.tween(warningText, {alpha: 1}, 0.75, {ease: FlxEase.quadInOut});
		warningTextTween = FlxTween.tween(warningText.scale, {x: 1, y: 1}, 0.75, {ease: FlxEase.quadInOut});
	}

    override function update(elapsed:Float)
        {
            if(!leftState) {
                if (controls.ACCEPT) {
                    leftState = true;
                    CoolUtil.browserLoad("https://gamebanana.com/tools/10824");
                }
                else if(controls.BACK) {
                    leftState = true;
                }
    
                if(leftState)
                {
                    FlxG.sound.play(Paths.sound('cancelMenu'));
                    FlxTween.tween(warningText, {alpha: 0}, 1, {
                        onComplete: function (twn:FlxTween) {
                            MusicBeatState.switchState(new MainMenuState());
                        }
                    });
                }
            }
            super.update(elapsed);
        }
    }