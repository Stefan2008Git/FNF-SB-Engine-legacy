package states.editors;

#if desktop
import backend.Discord.DiscordClient;
#end

#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import lime.utils.Assets;
#if android
import android.flixel.FlxButton;
#else
import flixel.ui.FlxButton;
#end
import flixel.ui.FlxSpriteButton;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flash.net.FileFilter;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.utils.Assets as OpenFlAssets;
import openfl.utils.ByteArray;
import states.MainMenuState;
import states.editors.MasterEditorMenu;
import substates.Prompt;

using StringTools;

class CreditsEditorState extends MusicBeatState
{
	var currentlySelected:Int = -1;

	private var groupOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<String>> = [];
	private var blockPressWhileTypingOn:Array<FlxUIInputText> = [];
	public var ignoreWarnings = false;

	public var camGame:FlxCamera;
	public var camUI:FlxCamera;
	public var camOther:FlxCamera;

	var background:FlxSprite;
	var velocityBackground:FlxBackdrop;
	var descriptionText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;
	var descriptionBox:AttachedSprite;
	var UI_box:FlxUITabMenu;

	var offsetThing:Float = -75;
	
	var text:String = "";

	override function create()
	{
		FlxG.sound.playMusic(Paths.music('offsetSong'), 0.5);
		Paths.clearStoredMemory();
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Credits Editor Menu", null);
		#end

		persistentUpdate = true;
		background = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(background);
		background.screenCenter();

		velocityBackground = new FlxBackdrop(FlxGridOverlay.createGrid(30, 30, 60, 60, true, 0x3B161932, 0x0), XY);
		velocityBackground.velocity.set(FlxG.random.bool(50) ? 90 : -90, FlxG.random.bool(50) ? 90 : -90);
		velocityBackground.visible = ClientPrefs.velocityBackground;
		add(velocityBackground);
		FlxG.mouse.visible = true;
		
		groupOptions = new FlxTypedGroup<Alphabet>();
		add(groupOptions);
		
		camGame = new FlxCamera();
		camUI = new FlxCamera();
		camOther = new FlxCamera();
		camUI.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camUI, false);
		FlxG.cameras.add(camOther, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		CustomFadeTransition.nextCamera = camOther;

		var tabs = [
			{name: 'Credits', label: 'Credits'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.cameras = [camUI];
		UI_box.resize(270, 380);
		UI_box.x = 940;
		UI_box.y = 25;
		UI_box.scrollFactor.set();
		add(UI_box);
		UI_box.selected_tab = 0;

		#if !android
		text = "W/S or Up/Down - Change selected item
		\nEnter - Apply changes
		\nSpace - Get selected item data
		\nDelete - Delete selected item
		\nR - Reset inputs
		\n1 - Add title
		\n2 - Add credit";
		#else
		text = "Up/down buttons - Change selected item
		\nA button - Apply changes
		\nX button - Get selected item data
		\nY button - Delete selected item
		\nZ button - Reset inputs
		\nC button - Add title
		\nB button - Add credit";
		#end

		var tipTextArray:Array<String> = text.split('\n');
		for (i in 0...tipTextArray.length) {
			var tipText:FlxText = new FlxText(UI_box.x, UI_box.y + UI_box.height + 8, 0, tipTextArray[i], 14);
			tipText.y += i * 9;
			switch (ClientPrefs.gameStyle) {
				case 'Psych Engine': tipText.setFormat("VCR OSD Mono", 14, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				default: tipText.setFormat("Bahnschrift", 14, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			}
			tipText.borderSize = 1;
			tipText.scrollFactor.set();
			add(tipText);
			tipText.cameras = [camUI];
		}

		addCreditsUI();

		creditsStuff = templateArray();

		descriptionBox = new AttachedSprite();
		switch (ClientPrefs.themes) {
			case 'SB Engine':
				descriptionBox.makeGraphic(1, 1, FlxColor.PURPLE);
			
			case 'Psych Engine':
				descriptionBox.makeGraphic(1, 1, FlxColor.BLACK);
		}
		descriptionBox.xAdd = -10;
		descriptionBox.yAdd = -10;
		descriptionBox.alphaMult = 0.6;
		descriptionBox.alpha = 0.6;
		add(descriptionBox);

		descriptionText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
		switch (ClientPrefs.gameStyle) {
			case 'Psych Engine': descriptionText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			default: descriptionText.setFormat("Bahnschrift", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		descriptionText.scrollFactor.set();
		//descriptionText.borderSize = 2.4;
		descriptionBox.sprTracker = descriptionText;
		add(descriptionText);

		Paths.clearUnusedMemory();
		descriptionBox.cameras = [camUI];
		descriptionText.cameras = [camUI];
	
		updateCreditObjects();

		background.color = getCurrentBGColor();
		intendedColor = background.color;
		changeSelection();

		#if android
		addVirtualPad(UP_DOWN, A_B_C_X_Y_Z);
		addPadCamera();
		#end
		
		super.create();
	}

	// Title inputs vars
	var titleInput:FlxUIInputText;
	var titleJump:FlxUICheckBox;
	// Credits inputs vars
	var creditNameInput:FlxUIInputText;
	var iconInput:FlxUIInputText;
	var iconExistCheck:FlxSprite;
	var descInput:FlxUIInputText;
	var linkInput:FlxUIInputText;
	var colorInput:FlxUIInputText;
	var colorSquare:FlxSprite;

	function addCreditsUI():Void
	{
		var yDist:Float = 20;
		titleInput = new FlxUIInputText(60, 20, 180, '', 8);
		titleInput.focusGained = () -> FlxG.stage.window.textInputEnabled = true;
		titleJump = new FlxUICheckBox(20, titleInput.y + yDist, null, null, 'Space betwen titles', 110);
		titleJump.textX += 3;
		titleJump.textY += 4;
		if (FlxG.save.data.jumpTitle == null) FlxG.save.data.jumpTitle = true;
		titleJump.checked = FlxG.save.data.jumpTitle;
		titleJump.callback = function()
		{
			FlxG.save.data.jumpTitle = titleJump.checked;
		};
		var titleAdd:FlxButton = new FlxButton(20, titleJump.y + yDist + 10, "Add Title", function()
		{
			addTitle();
		});

		blockPressWhileTypingOn.push(titleInput);

		creditNameInput = new FlxUIInputText(60, titleInput.y + 100, 180, '', 8);
		creditNameInput.focusGained = () -> FlxG.stage.window.textInputEnabled = true;
		iconInput = new FlxUIInputText(60, creditNameInput.y + yDist, 155, '', 8);
		iconInput.focusGained = () -> FlxG.stage.window.textInputEnabled = true;
		iconExistCheck = new FlxSprite(iconInput.x + 165, iconInput.y).makeGraphic(15, 15, 0xFFFFFFFF);
		descInput = new FlxUIInputText(100, iconInput.y + yDist, 140, '', 8);
		descInput.focusGained = () -> FlxG.stage.window.textInputEnabled = true;
		linkInput = new FlxUIInputText(60, descInput.y + yDist, 180, '', 8);
		linkInput.focusGained = () -> FlxG.stage.window.textInputEnabled = true;
		colorInput = new FlxUIInputText(60, linkInput.y + yDist, 70, '', 8);
		colorInput.focusGained = () -> FlxG.stage.window.textInputEnabled = true;
		colorSquare = new FlxSprite(colorInput.x + 80, colorInput.y).makeGraphic(15, 15, 0xFFFFFFFF);
		var getIconColor:FlxButton = new FlxButton(colorSquare.x + 23, colorSquare.y - 2, "Get Icon Color", function()
			{
				var icon:String;
				if(iconInput.text != null && iconInput.text.length > 0) icon = iconInput.text;
				else icon = creditsStuff[currentlySelected][1];

				var pathIcon:String;
				if(Paths.fileExists('images/credits/' + icon + '.png', IMAGE)) pathIcon = 'credits/' + icon;
				else pathIcon = 'credits/unknownIcon';

				var iconSprite:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image(pathIcon));				
				var daColor:String = StringTools.hex(CoolUtil.dominantColor(iconSprite)).substring(2, this.length);
				colorInput.text = daColor;

				iconSprite.kill();
				iconSprite = null;
				iconColorShow();
			});
		var creditAdd:FlxButton = new FlxButton(20, colorInput.y + yDist + 10, "Add credit", function()
		{
			addCredit();
		});
		
		blockPressWhileTypingOn.push(creditNameInput);
		blockPressWhileTypingOn.push(iconInput);
		blockPressWhileTypingOn.push(linkInput);
		blockPressWhileTypingOn.push(descInput);
		blockPressWhileTypingOn.push(colorInput);
		
		var resetAll:FlxButton = new FlxButton(50, 300, "Reset all", function()
		{
			openSubState(new Prompt('This action will clear current progress.\n\nProceed?', 0, function(){
				creditsStuff = templateArray();
				updateCreditObjects();
				currentlySelected = 1;
				changeSelection();
			}, null,ignoreWarnings));
		});
		resetAll.color = FlxColor.RED;
		resetAll.label.color = FlxColor.WHITE;
		var loadFile:FlxButton = new FlxButton(resetAll.x, resetAll.y + 25, "Load Credits", function()
		{
			loadCredits();
		});
		var saveFile:FlxButton = new FlxButton(loadFile.x + 90, loadFile.y, "Save Credits", function()
		{
			saveCredits();
		});

		var tab_group_credits = new FlxUI(null, UI_box);
		tab_group_credits.name = "Credits";

		tab_group_credits.add(titleInput);
		tab_group_credits.add(new FlxText(titleInput.x - 40, titleInput.y, 0, 'Title:'));
		tab_group_credits.add(titleJump);

		tab_group_credits.add(creditNameInput);
		tab_group_credits.add(iconInput);
		tab_group_credits.add(makeSquareBorder(iconExistCheck, 18));
		tab_group_credits.add(iconExistCheck);
		tab_group_credits.add(descInput);
		tab_group_credits.add(linkInput);
		tab_group_credits.add(colorInput);
		tab_group_credits.add(makeSquareBorder(colorSquare, 18));
		tab_group_credits.add(colorSquare);
		tab_group_credits.add(getIconColor);
		tab_group_credits.add(new FlxText(creditNameInput.x - 40, creditNameInput.y, 0, 'Name:'));
		tab_group_credits.add(new FlxText(iconInput.x - 40, iconInput.y, 0, 'Icon:'));
		tab_group_credits.add(new FlxText(descInput.x - 80, descInput.y, 0, 'Description:'));
		tab_group_credits.add(new FlxText(linkInput.x - 40, linkInput.y, 0, 'Link:'));
		tab_group_credits.add(new FlxText(colorInput.x - 40, colorInput.y, 0, 'Color:'));
		tab_group_credits.add(titleAdd);
		tab_group_credits.add(creditAdd);

		tab_group_credits.add(loadFile);
		tab_group_credits.add(saveFile);
		tab_group_credits.add(resetAll);

		UI_box.addGroup(tab_group_credits);
		showIconExist(iconInput.text);
	}

	function updateCreditObjects(){
		if(creditsStuff != null && creditsStuff.length > 0){
			for (i in 0...iconArray.length){
				iconArray[i].kill();
			}
			iconArray = [];
			for (option in groupOptions){
				option.kill();
			}
			groupOptions.clear();
		}

		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(FlxG.width / 2, 300, creditsStuff[i][0], !isSelectable);
			optionText.isMenuItem = true;
			optionText.targetY = i - currentlySelected;

			optionText.ID = i;
			optionText.changeX = false;
			optionText.snapToPosition();
			groupOptions.add(optionText);

			if(isSelectable) {
				if(creditsStuff[i][5] != null)
				{
					Paths.currentModDirectory = creditsStuff[i][5];
				}

				var icon:AttachedSprite;
				if(Paths.fileExists('images/credits/' + creditsStuff[i][1] + '.png', IMAGE)) icon = new AttachedSprite('credits/' + creditsStuff[i][1]);
				else {
					icon = new AttachedSprite('credits/unknownIcon'); // If icon didnt load it will load the unknow icon.
					if(creditsStuff[i][1] == null || creditsStuff[i][1] == '') icon = new AttachedSprite('credits/unknownIcon');
				}

				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;
	
				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
				Paths.currentModDirectory = '';

				if(currentlySelected == -1) currentlySelected = i;
			}
			else optionText.alignment = CENTERED;
		}
	}

	function addCredit(){
		var daData:Array<String> = [];
		daData.push('User');
		daData.push('');
		daData.push('Description here...');
		daData.push('');
		daData.push('e1e1e1');

		pushAtPos(currentlySelected + 1, daData);

		updateCreditObjects();
		changeSelection();
	}

	function addTitle(){
		var daData:Array<String> = [];
		daData.push('Title');
		pushAtPos(currentlySelected + 1, daData);

		if(titleJump.checked){
			var daData:Array<String> = [];
			pushAtPos(currentlySelected + 1, daData);
		}

		updateCreditObjects();
		changeSelection();
	}

	function dataGoToInputs(){
		if(curSelIsTitle){
			titleInput.text = creditsStuff[currentlySelected][0];
		} else {
			creditNameInput.text = creditsStuff[currentlySelected][0];
			iconInput.text = creditsStuff[currentlySelected][1];
			descInput.text = creditsStuff[currentlySelected][2];
			linkInput.text = creditsStuff[currentlySelected][3];
			colorInput.text = creditsStuff[currentlySelected][4];
			showIconExist(iconInput.text);
			iconColorShow();
		}
	}
	
	function cleanInputs(){
		titleInput.text = '';
		creditNameInput.text = '';
		iconInput.text = '';
		descInput.text = '';
		linkInput.text = '';
		colorInput.text = '';
		showIconExist(iconInput.text);
		iconColorShow();
	}

	function setItemData(){
		if(curSelIsTitle){
			if(titleInput.text != null && titleInput.text.length > 0) creditsStuff[currentlySelected][0] = titleInput.text;
			else creditsStuff[currentlySelected][0] = 'Title';
		} else {
			if(creditNameInput.text != null && creditNameInput.text.length > 0) creditsStuff[currentlySelected][0] = creditNameInput.text;
			else creditsStuff[currentlySelected][0] = 'User';
	
			creditsStuff[currentlySelected][1] = iconInput.text;		
	
			if(descInput.text != null && descInput.text.length > 0) creditsStuff[currentlySelected][2] = descInput.text;
			else creditsStuff[currentlySelected][2] = 'Description here...';
	
			creditsStuff[currentlySelected][3] = linkInput.text;
			
			if(colorInput.text != null && colorInput.text.length > 0) {
				creditsStuff[currentlySelected][4] = colorInput.text;
			} else { creditsStuff[currentlySelected][4] = 'e1e1e1'; }
		}
	}

	function deleteSelItem(){
		if(currentlySelected == 0 || creditsStuff.length <= 1) return; // you trying to delete the first title? why dont you edit it...
		var daStuff:Array<Array<String>> = [];
		for(i in 0...creditsStuff.length){
			if(!unselectableCheck(currentlySelected)){
				if(i != currentlySelected){
					daStuff.push(creditsStuff[i]);
				}
			} else {
				var creditThing:Bool = true;
				if(nullCheck(currentlySelected - 1)){ // remove space betwen title's
					var u:Int = currentlySelected - 1;
					if(i == u) creditThing = false;
				}

				if(i != currentlySelected && creditThing){
					daStuff.push(creditsStuff[i]);
				}
			}
		}
		creditsStuff = daStuff;

		if(currentlySelected > (creditsStuff.length - 1)) currentlySelected = creditsStuff.length;
		do {
			currentlySelected -= 1;
		} while(nullCheck(currentlySelected));
		
		currentlySelected += 1;
		updateCreditObjects();
		changeSelection(-1);
	}

	function templateArray(){
		return([
			['Title'],
			['User', '', 'Description here...',	'',	'e1e1e1']
		]);
	}

	function pushAtPos(pos:Int, data:Array<String>){
		var daStuff:Array<Array<String>> = [];
		for(i in 0...creditsStuff.length){
			if(i == pos){
				daStuff.push(data);
			}
			daStuff.push(creditsStuff[i]);
		}
		if(pos == creditsStuff.length){
			daStuff.push(data);
		}
		creditsStuff = daStuff;
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var blockInput:Bool = false;
		for (inputText in blockPressWhileTypingOn) {
			if(inputText.hasFocus) {
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				blockInput = true;
				break;
			}
		}		

		if(!quitting && !blockInput)
		{
			if(creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if (controls.UI_UP)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (controls.UI_DOWN)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if((FlxG.keys.justPressed.S || FlxG.keys.justPressed.DOWN) || (FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP))
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}
			}

			if (FlxG.keys.justPressed.ENTER #if android || virtualPad.buttonA.justPressed #end) {
				setItemData();
				updateCreditObjects();
				changeSelection();
			}

			if (FlxG.keys.justPressed.SPACE #if android || virtualPad.buttonX.justPressed #end) {
				dataGoToInputs();
			}

			if (FlxG.keys.justPressed.DELETE #if android || virtualPad.buttonY.justPressed #end) {
				deleteSelItem();
			}

			if (FlxG.keys.pressed.R #if android || virtualPad.buttonZ.justPressed #end){
				cleanInputs();
			}

			if (FlxG.keys.justPressed.ONE #if android || virtualPad.buttonC.justPressed #end) {
				addTitle();
			}
			if (FlxG.keys.justPressed.TWO #if android || virtualPad.buttonB.justPressed #end) {
				addCredit();
			}

			if (FlxG.keys.justPressed.BACKSPACE || FlxG.keys.justPressed.ESCAPE #if android || FlxG.android.justReleased.BACK #end)
			{
				if(colorTween != null) {
					colorTween.cancel();
				}
				FlxG.mouse.visible = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new states.editors.MasterEditorMenu());
				Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Mod Maker Menu";
				FlxG.sound.playMusic(Paths.music('freakyMenu-' + ClientPrefs.mainMenuMusic));
				quitting = true;
			}
		}
		if (blockInput){
			if (FlxG.keys.justPressed.ENTER) {
				for (i in 0...blockPressWhileTypingOn.length) {
					if(blockPressWhileTypingOn[i].hasFocus) {
						blockPressWhileTypingOn[i].hasFocus = false;
					}
				}
			}
		}
		
		for (item in groupOptions.members)
		{
			if (!item.bold)
			{
				item.x = 200;
			}
		}
		super.update(elapsed);
	}

	var moveTween:FlxTween = null;
	var curSelIsTitle:Bool = false;
	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(change != 0 && playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			currentlySelected += change;
			if (currentlySelected < 0)
				currentlySelected = creditsStuff.length - 1;
			if (currentlySelected >= creditsStuff.length)
				currentlySelected = 0;
		} while(nullCheck(currentlySelected));

		if(unselectableCheck(currentlySelected)) curSelIsTitle = true;
		else curSelIsTitle = false;

		var newColor:Int;
		if(unselectableCheck(currentlySelected)) newColor =  Std.parseInt('0xFFe1e1e1');
		else newColor =  getCurrentBGColor();

		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(background, 1, background.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}
		
		var alphabetValue:Int = 0;
		for (item in groupOptions.members)
		{
			item.targetY = alphabetValue - currentlySelected;
			alphabetValue++;

			if(!nullCheck(alphabetValue-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}
		
		descriptionText.text = creditsStuff[currentlySelected][2];
		descriptionBox.visible = !unselectableCheck(currentlySelected);	
		descriptionText.visible = !unselectableCheck(currentlySelected);

		if(change != 0){
			descriptionText.y = FlxG.height - descriptionText.height + offsetThing - 60;
			if(moveTween != null) moveTween.cancel();
			moveTween = FlxTween.tween(descriptionText, {y : descriptionText.y + 75}, 0.25, {ease: FlxEase.sineOut});
		}

		descriptionBox.setGraphicSize(Std.int(descriptionText.width + 20), Std.int(descriptionText.height + 25));
		descriptionBox.updateHitbox();
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
	private function nullCheck(num:Int):Bool {
		if(creditsStuff[num].length <= 1 && creditsStuff[num][0].length <= 0) return true;
		return false;
	}

	function getCurrentBGColor() {
		var backgroundColor:String = creditsStuff[currentlySelected][4];
		if(!backgroundColor.startsWith('0x')) {
			backgroundColor = '0xFF' + backgroundColor;
		}
		return Std.parseInt(backgroundColor);
	}

	function makeSquareBorder(object:FlxSprite, size:Int){ // Just to make color squares look a little nice and easier to see
		var x:Float = object.x;
		var y:Float = object.y;
		var offset:Float = 1.5;

		var border:FlxSprite = new FlxSprite(x - offset, y - offset).makeGraphic(size, size, 0xFF000000);
		return(border);
	}

	function showIconExist(text:String){
		var daColor:Int;
		if(text.length == 0){
			daColor = Std.parseInt('0xFFFFC31E'); // no input then
		} else {
			if(!Paths.fileExists('images/credits/' + text + '.png', IMAGE)) daColor = Std.parseInt('0xFFFF004C'); // icon not found
			else daColor = Std.parseInt('0xFF00FF37'); // icon was found
		}
		iconExistCheck.color = daColor;
	}

	function iconColorShow(){
		if(colorInput.text.length > 10) return;
		var daColor:Int;
		if(colorInput.text != null && colorInput.text.length > 0) {

			if(!colorInput.text.startsWith('0xFF')) {
				daColor = Std.parseInt('0xFF' + colorInput.text);
			} else { daColor = Std.parseInt(colorInput.text); }
			
		} else { daColor = Std.parseInt('0xFFe1e1e1'); }
		colorSquare.color = daColor;
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if(id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText)) {
			if(sender == iconInput) {
				showIconExist(iconInput.text);
			}
			if(sender == colorInput) {
				iconColorShow();
			}
		}
	}

	// Save & Load functions
	var _file:FileReference;
	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved file.");
	}

	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving file");
	}

	function saveCredits() {
		var daStuff:Array<String> = [];
		for(i in 0...creditsStuff.length){
			daStuff.push(creditsStuff[i].join('::'));
		}

		var data:String = daStuff.join('\n');

		if (data.length > 0)
		{
			#if android
			SUtil.saveContent("credits", ".txt", data.trim());
			#else
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data, "credits.txt");
			#end
		}
	}

	function loadCredits() {
		var txtFilter:FileFilter = new FileFilter('TXT', 'txt');
		_file = new FileReference();
		_file.addEventListener(Event.SELECT, onLoadComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file.browse([txtFilter]);
	}
	
	var loadError:Bool = false;
	function onLoadComplete(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);

		#if sys
		var fullPath:String = null;
		@:privateAccess
		if(_file.__path != null) fullPath = _file.__path;

		if(fullPath != null) {
			var rawTxt:String = File.getContent(fullPath);
			if(rawTxt != null) {
				creditsStuff = [];
				var firstarray:Array<String> = rawTxt.split('\n');
				for(i in firstarray)
				{
					var arr:Array<String> = i.replace('\\n', '\n').split("::");
					creditsStuff.push(arr);
				}
					
				updateCreditObjects();
				changeSelection();
				return;
			}
		}
		loadError = true;
		_file = null;
		#else
		trace("File couldn't be loaded! You aren't on Desktop, are you?");
		#end
	}

	function onLoadCancel(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		trace("Cancelled file loading.");
	}
	
	function onLoadError(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		trace("Problem loading file");
	}
}
