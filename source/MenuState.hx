package ;

import flash.system.System;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

using flixel.util.FlxSpriteUtil;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState {
    private var _btnPlay:FlxButton;
    private var _txtTitle:FlxText;
    private var _btnOptions:FlxButton;
    #if desktop
    private var _btnExit:FlxButton;
    #end

    /**
     * Function that is called up when to state is created to set it up.
     */
    override public function create():Void {
        _txtTitle = new FlxText(20, 0, 0, 'HaxeFlixel\nTutorial\nGame', 22);
        _txtTitle.alignment = 'center';
        _txtTitle.screenCenter(true, false);
        add(_txtTitle);

        _btnPlay = new FlxButton(0, 0, 'Play', clickPlay);
        _btnPlay.x = (FlxG.width / 2) - _btnPlay.width - 10;
        _btnPlay.y = FlxG.height - _btnPlay.height - 10;
        _btnPlay.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
        add(_btnPlay);

        _btnOptions = new FlxButton(0, 0, 'Options', clickOptions);
        _btnOptions.x = (FlxG.width / 2) + 10;
        _btnOptions.y = FlxG.height - _btnOptions.height - 10;
        add(_btnOptions);
        _btnOptions.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);

        #if desktop
        _btnExit = new FlxButton(FlxG.width - 28, 8, "X", clickExit);
        _btnExit.loadGraphic(AssetPaths.button__png, true, 20, 20);
        add(_btnExit);
        #end

        FlxG.camera.fade(FlxColor.BLACK, .33, true);
        super.create();
    }

    /**
     * Function that is called when this state is destroyed - you might want to
     * consider setting all objects this state uses to null to help garbage collection.
     */
    override public function destroy():Void {
        super.destroy();

        _txtTitle = FlxDestroyUtil.destroy(_txtTitle);
        _btnPlay = FlxDestroyUtil.destroy(_btnPlay);
        _btnOptions = FlxDestroyUtil.destroy(_btnOptions);
        #if desktop
        _btnExit = FlxDestroyUtil.destroy(_btnExit);
        #end
    }

    /**
     * Function that is called once every frame.
     */
    override public function update():Void {
        super.update();
    }

    private function clickPlay():Void {
        FlxG.camera.fade(FlxColor.BLACK, .33, false, function() {
            FlxG.switchState(new PlayState());
        });
    }

    private function clickOptions():Void {
        FlxG.camera.fade(FlxColor.BLACK, .33, false, function() {
            FlxG.switchState(new OptionsState());
        });
    }

    #if desktop
    private function clickExit():Void {
        System.exit(0);
    }
    #end
}
