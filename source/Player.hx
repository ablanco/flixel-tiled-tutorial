package ;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxAngle;
import flixel.FlxObject;

class Player extends FlxSprite {
    public var speed:Float = 200;

    public function new(X:Float=0, Y:Float=0) {
        super(X, Y);

        loadGraphic(AssetPaths.player__png, true, 16, 16);
        setFacingFlip(FlxObject.LEFT, false, false);
        setFacingFlip(FlxObject.RIGHT, true, false);
        animation.add("lr", [4, 5], 6, false);
        animation.add("u", [7, 8], 6, false);
        animation.add("d", [1, 2], 6, false);

        drag.x = drag.y = 1600;
        // Change the hitbox so he can make it through doors and such
        setSize(8, 14);
        offset.set(4, 2);
    }

    override public function update():Void {
        updateMovement();

        super.update();
    }

    private function updateMovement():Void {
        var _up:Bool = false;
        var _down:Bool = false;
        var _left:Bool = false;
        var _right:Bool = false;

        _up = FlxG.keys.anyPressed(["UP", "W"]);
        _down = FlxG.keys.anyPressed(["DOWN", "S"]);
        _left = FlxG.keys.anyPressed(["LEFT", "A"]);
        _right = FlxG.keys.anyPressed(["RIGHT", "D"]);

        if (_up && _down) { _up = _down = false; }
        if (_left && _right) { _left = _right = false; }

        if ( _up || _down || _left || _right) {
            var mA:Float = 0;
            if (_up) {
                mA = -90;
                if (_left) {
                    mA -= 45;
                } else if (_right) {
                    mA += 45;
                }
                facing = FlxObject.UP;
            } else if (_down) {
                mA = 90;
                if (_left) {
                    mA += 45;
                } else if (_right) {
                    mA -= 45;
                }
                facing = FlxObject.DOWN;
            } else if (_left) {
                mA = 180;
                facing = FlxObject.LEFT;
            } else if (_right) {
                mA = 0;
                facing = FlxObject.RIGHT;
            }

            FlxAngle.rotatePoint(speed, 0, 0, 0, mA, velocity);

            if (velocity.x != 0 || velocity.y != 0) {
                // If the player is moving (velocity is not 0 for either axis),
                // we need to change the animation to match their facing
                switch(facing) {
                    case FlxObject.LEFT, FlxObject.RIGHT:
                        animation.play("lr");
                    case FlxObject.UP:
                        animation.play("u");
                    case FlxObject.DOWN:
                        animation.play("d");
                }
            }
        }
    }
}
