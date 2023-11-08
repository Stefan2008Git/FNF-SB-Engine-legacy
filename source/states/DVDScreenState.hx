package states;

using StringTools;

class DVDScreenState extends MusicBeatState {

	// I have no clue why it exist - PurSnake

    var background:FlxSprite;
    var dvdIcon:FlxSprite;

    var colors = [
        [255, 255, 255],
        [6, 219, 22],
        [4, 151, 221],
        [244, 154, 94],
        [243, 95, 206],
        [33, 169, 141]
    ];
    var currentlyColor:Int = 0;

    override function create() 
    {
        if (ClientPrefs.toastCore) Main.toast.create('You are founded the secret easter egg', 0xFF00FF44, 'Congratulations');
        Paths.clearStoredMemory();

        #if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Founded a secret.", null);
		#end

        background = new FlxSprite().loadGraphic(Paths.image('menuArrows'));
		background.scrollFactor.set();
		background.updateHitbox();
		background.screenCenter();
		background.antialiasing = ClientPrefs.globalAntialiasing;
		add(background);

        dvdIcon = new FlxSprite(0, 0);
        dvdIcon.loadGraphic(Paths.image('dvdIcon'));
        dvdIcon.setGraphicSize(200, 5);
        dvdIcon.scale.y = dvdIcon.scale.x;
        dvdIcon.updateHitbox();
        dvdIcon.velocity.set(135, 95);
        dvdIcon.setColorTransform(0, 0, 0, 1, 255, 255, 255);
        dvdIcon.antialiasing = ClientPrefs.globalAntialiasing;
        add(dvdIcon);

        Paths.clearUnusedMemory();

        super.create();
    }

    override function update(elapsed:Float) 
    {
        if (FlxG.keys.justPressed.ESCAPE #if android || FlxG.android.justReleased.BACK #end) {
            ClientPrefs.mainMenuStyle == 'Classic' ? MusicBeatState.switchState(new ClassicMainMenuState()) : MusicBeatState.switchState(new MainMenuState());
			Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion;
        }

        if (dvdIcon.x > FlxG.width - dvdIcon.width || dvdIcon.x < 0) {
            dvdIcon.velocity.x = -dvdIcon.velocity.x;
            switchColor();
            FlxG.sound.play(Paths.sound('hittingCorner'));
        } 
        if (dvdIcon.y > FlxG.height - dvdIcon.height || dvdIcon.y < 0) {
            dvdIcon.velocity.y = -dvdIcon.velocity.y;
            switchColor();
            FlxG.sound.play(Paths.sound('hittingCorner'));
        }
            
        super.update(elapsed);
      
    }

    function switchColor() 
    {
        currentlyColor = (currentlyColor + 1) % colors.length;
        dvdIcon.setColorTransform(0, 0, 0, 1, colors[currentlyColor][0], colors[currentlyColor][1], colors[currentlyColor][2]);
    }
}
