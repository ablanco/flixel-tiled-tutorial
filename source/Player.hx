package ;

import flixel.FlxSprite;
import flixel.util.FlxColor;

class Player extends FlxSprite {
    public function new(X:Float=0, Y:Float=0) {
        super(X, Y);
        makeGraphic(16, 16, FlxColor.BLUE);
    }
}
