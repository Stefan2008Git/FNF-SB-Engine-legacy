package states;

import flixel.addons.transition.FlxTransitionableState;
import states.MainMenuState;

using StringTools;

class GalleryScreenState extends MusicBeatState
{
    var itemGroup:FlxTypedGroup<GalleryImage>;
    var imagePaths:Array<String>;
    var imageDescriptions:Array<String>;
    var imageTitle:Array<String>;
    var linkOpen:Array<String>;
    var currentIndex:Int = 0;
    var descriptionText:FlxText;
    var titleText:FlxText;
    var background:FlxSprite;
    var velocityBackground:FlxBackdrop;
    var imageSprite:FlxSprite;
    var bg:FlxSprite;
    var backspace:FlxSprite;
    var intendedColor:Int;
	var colorTween:FlxTween;
    var imagePath:String = "gallery/";
    var openLink:String;

    override public function create():Void
    {
        if (ClientPrefs.toastCore) Main.toast.create('You are entered to gallery basemant', 0xFF00FF44, 'There is some images for watching');
        Paths.clearStoredMemory();

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

        background = new FlxSprite(10, 50).loadGraphic(Paths.image("gallery/ui/void"));
        background.setGraphicSize(Std.int(background.width * 1));
        background.screenCenter();
        add(background);

        velocityBackground = new FlxBackdrop(FlxGridOverlay.createGrid(30, 30, 60, 60, true, 0x3B161932, 0x0), XY);
		velocityBackground.velocity.set(FlxG.random.bool(50) ? 90 : -90, FlxG.random.bool(50) ? 90 : -90);
		velocityBackground.visible = ClientPrefs.velocityBackground;
		velocityBackground.velocity.set(-10, 0);
		add(velocityBackground);

        background = new FlxSprite(10, 50).loadGraphic(Paths.image("gallery/ui/bars"));
        background.setGraphicSize(Std.int(background.width * 1));
        background.screenCenter();
        add(background);

        imagePaths = ["sbEngineLogo", "newBoyfriendIcons", "newLemonMonsterIcons"];
        imageDescriptions = ["Stefan Beta Engine then? Nolstalgia i think :(.", "Beep bop bap!", "And im gonna eat your girlfriend >:)!"];
        imageTitle = ["New current SB Engine Logo", "New byofriend icons (Made by Nury btw)", "Another leak? (Made by Nury again btw!)"];

        itemGroup = new FlxTypedGroup<GalleryImage>();

        for (id => i in imagePaths) {
            var newItem = new GalleryImage();
            newItem.loadGraphic(Paths.image(imagePath + i));
            newItem.ID = id;
            itemGroup.add(newItem);
        }
        
        add(itemGroup);

        descriptionText = new FlxText(50, -100, FlxG.width - 100, imageDescriptions[currentIndex]);
        descriptionText.setFormat(null, 25, 0xffffff, "center");
        descriptionText.screenCenter();
        descriptionText.y += 250;
        switch (ClientPrefs.gameStyle) {
            case 'Psych Engine': descriptionText.setFormat("VCR OSD Mono", 32, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			default: descriptionText.setFormat("Bahnschrift", 32, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        }
        add(descriptionText);

        titleText = new FlxText(50, 50, FlxG.width - 100, imageTitle[currentIndex]);
        titleText.screenCenter(X);
        titleText.setFormat(null, 40, 0xffffff, "center");
        switch (ClientPrefs.gameStyle) {
            case 'Psych Engine': titleText.setFormat("VCR OSD Mono", 32, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			default: titleText.setFormat("Bahnschrift", 32, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        }
        add(titleText);

        backspace = new FlxSprite(-0, 560);
        backspace.frames = Paths.getSparrowAtlas('gallery/ui/backspace');
        backspace.animation.addByPrefix('backspace to exit white0', "backspace to exit white0", 24);
        backspace.animation.play('backspace to exit white0');
        backspace.updateHitbox();
        add(backspace);

        Paths.clearUnusedMemory();
        
        persistentUpdate = true;
        changeSelection();

        #if android
        addVirtualPad(LEFT_RIGHT, A_B);
        #end

        super.create();
        CustomFadeTransition.nextCamera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
    }
    

    var allowInputs:Bool = true;
    
override public function update(elapsed:Float):Void
{
    super.update(elapsed);

    if ((controls.UI_LEFT_P || controls.UI_RIGHT_P) && allowInputs) {
        changeSelection(controls.UI_LEFT_P ? -1 : 1);
        FlxG.sound.play(Paths.sound("scrollMenu"));
    }
    
    if (controls.BACK && allowInputs)
    {
        allowInputs = false;
        FlxG.sound.play(Paths.sound('cancelMenu'));
        ClientPrefs.mainMenuStyle == 'Classic' ? MusicBeatState.switchState(new ClassicMainMenuState()) : MusicBeatState.switchState(new MainMenuState());
        Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion;
        backspace.animation.addByPrefix('backspace to exit', "backspace to exit", 12);
        backspace.animation.play('backspace to exit');
    }
    
    // Handle opening the link when the desired input (e.g., ENTER) is detected
    if (controls.ACCEPT && allowInputs)
    {
        CoolUtil.browserLoad(openLink);
    }
}

    private function changeSelection(i = 0) {
    currentIndex = FlxMath.wrap(currentIndex + i, 0, imageTitle.length - 1);
    descriptionText.text = imageDescriptions[currentIndex];
    titleText.text = imageTitle[currentIndex]; 

        var linkOpen:Array<String> = [
            "https://www.youtube.com/@Nuury06",  // Image 1 Link
            "https://www.youtube.com/@Nuury06",  // Image 2 Link
            "https://www.youtube.com/@Nuury06",  // Image 3 Link
            // Add other links here for each image
        ];

    openLink = linkOpen[currentIndex];

    var change = 0;
    for (item in itemGroup) {
        item.posX = change++ - currentIndex;
        item.alpha = item.ID == currentIndex ? 1 : 0.6;
        }
    }
}

class GalleryImage extends FlxSprite {
    public var posX:Float = 0;
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        x = FlxMath.lerp(x, (FlxG.width - width) / 2 + posX * 780, CoolUtil.boundTo(elapsed * 3, 0, 1));
    }
}