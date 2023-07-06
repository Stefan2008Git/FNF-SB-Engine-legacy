package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;
import lime.app.Application;

using StringTools;

class DVDScreenState extends MusicBeatState {

    var dvdLogo:FlxSprite;

    var colors = [
        [255, 255, 255],
        [6, 219, 22],
        [4, 151, 221],
        [244, 154, 94],
        [243, 95, 206],
        [33, 169, 141]
    ];
    var curColor:Int = 0;

    override function create() 
    {
        Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

        dvdLogo = new FlxSprite(0, 0);
        dvdLogo.loadGraphic(Paths.image('dvdIcon'));
        dvdLogo.setGraphicSize(200, 5);
        dvdLogo.scale.y = dvdLogo.scale.x;
        dvdLogo.updateHitbox();
        dvdLogo.velocity.set(135, 95);
        dvdLogo.setColorTransform(0, 0, 0, 1, 255, 255, 255);
        dvdLogo.antialiasing = ClientPrefs.globalAntialiasing;
        add(dvdLogo);
    
        super.create();
    }

    override function update(elapsed:Float) 
    {
        if (FlxG.keys.justPressed.ESCAPE #if android || FlxG.android.justReleased.BACK #end) {
            if (ClientPrefs.mainMenuStyle == 'Classic') {
				MusicBeatState.switchState(new ClassicMainMenuState());
                FlxG.sound.playMusic(Paths.music('freakyMenu'));
			    Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion;
			} else {
				MusicBeatState.switchState(new MainMenuState());
                FlxG.sound.playMusic(Paths.music('freakyMenu'));
			    Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion;
			}
        }

        if (dvdLogo.x > FlxG.width - dvdLogo.width || dvdLogo.x < 0) {
            dvdLogo.velocity.x = -dvdLogo.velocity.x;
            switchColor();
            FlxG.sound.play(Paths.sound('Metronome_Tick'));
        } 
        if (dvdLogo.y > FlxG.height - dvdLogo.height || dvdLogo.y < 0) {
            dvdLogo.velocity.y = -dvdLogo.velocity.y;
            switchColor();
            FlxG.sound.play(Paths.sound('Metronome_Tick'));
        }
            
        super.update(elapsed);
      
    }

    function switchColor() 
    {
        curColor = (curColor + 1) % colors.length;
        dvdLogo.setColorTransform(0, 0, 0, 1, colors[curColor][0], colors[curColor][1], colors[curColor][2]);
    }
}
