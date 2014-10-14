package ;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
#if mobile
import flixel.ui.FlxVirtualPad;
#end

using flixel.util.FlxSpriteUtil;


/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState {
    public var player:Player;
    private var _map:TiledLevel;
    private var _hud:HUD;
    private var _money:Int = 0;
    private var _health:Int = 3;
    private var _inCombat:Bool = false;
    private var _combatHud:CombatHUD;
    private var _ending:Bool;
    private var _won:Bool;
    private var _sndCoin:FlxSound;
    #if mobile
    public static var virtualPad:FlxVirtualPad;
    #end

    /**
     * Function that is called up when to state is created to set it up.
     */
    override public function create():Void {
        // Load the level's tilemaps
        _map = new TiledLevel("assets/data/room-001.tmx");
        // Add tilemaps
        add(_map.foregroundTiles);
        add(_map.backgroundTiles);
        // Load player objects
        _map.loadObjects(this);
        // Add coins and player
        _sndCoin = FlxG.sound.load(AssetPaths.coin__wav);
        add(_map.coins);
        add(player);
        // Add enemies
        add(_map.enemies);
        // Make the camera follow the player
        FlxG.camera.follow(player, FlxCamera.STYLE_TOPDOWN, 1);
        // Prepare the HUD
        _hud = new HUD();
        add(_hud);
        // And the combat
        _combatHud = new CombatHUD();
        add(_combatHud);
        // Virtual gamepad for mobile platforms
        #if mobile
        virtualPad = new FlxVirtualPad(FULL, NONE);
        add(virtualPad);
        #end
        // If there is a mouse cursor, hide it
        #if !FLX_NO_MOUSE
        FlxG.mouse.visible = false;
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

        player = FlxDestroyUtil.destroy(player);
        // _map = FlxDestroyUtil.destroy(_map);
        _hud = FlxDestroyUtil.destroy(_hud);
        _combatHud = FlxDestroyUtil.destroy(_combatHud);
        _sndCoin = FlxDestroyUtil.destroy(_sndCoin);
        #if mobile
        virtualPad = FlxDestroyUtil.destroy(virtualPad);
        #end
    }

    /**
     * Function that is called once every frame.
     */
    override public function update():Void {
        super.update();

        if (_ending) { return; }

        if (!_inCombat) {
            // Collide with foreground tile layer
            _map.collideWithLevel(player);
            // Pickup coins
            FlxG.overlap(player, _map.coins, playerTouchCoin);

            // Make enemies collide with walls and such
            for (enemy in _map.enemies) {
                _map.collideWithLevel(enemy);
            }
            // Check if the enemies see the player
            _map.enemies.forEachAlive(checkEnemyVision);
            // Start a fight
            FlxG.overlap(player, _map.enemies, playerTouchEnemy);
        } else {
            if (!_combatHud.visible) {
                // Combat finished
                _health = _combatHud.playerHealth;
                _hud.updateHUD(_health, _money);
                if (_combatHud.outcome == DEFEAT) {
                    _ending = true;
                    FlxG.camera.fade(FlxColor.BLACK, .33, false, doneFadeOut);
                } else {
                    if (_combatHud.outcome == VICTORY) {
                        _combatHud.e.kill();
                        if (_combatHud.e.etype == 1) {
                            // Boss was defeated
                            _won = true;
                            _ending = true;
                            FlxG.camera.fade(FlxColor.BLACK, .33, false, doneFadeOut);
                        }
                    } else {
                        _combatHud.e.flicker();
                    }
                }
                _inCombat = false;
                #if mobile
                virtualPad.visible = true;
                #end
                player.active = true;
                _map.enemies.active = true;
            }
        }
    }

    private function playerTouchCoin(player:Player, coin:Coin):Void {
        if (player.alive && player.exists && coin.alive && coin.exists) {
            coin.kill();
            _sndCoin.play(true);
            _money++;
            _hud.updateHUD(_health, _money);
        }
    }

    private function playerTouchEnemy(P:Player, E:Enemy):Void {
        if (P.alive && P.exists && E.alive && E.exists && !E.isFlickering()) {
            _inCombat = true;
            player.active = false;
            _map.enemies.active = false;
            #if mobile
            virtualPad.visible = false;
            #end
            _combatHud.initCombat(_health, E);
        }
    }

    private function checkEnemyVision(e:Enemy):Void {
        e.seesPlayer = true;
        for (obstacle in _map.collidableTileLayers) {
            if (obstacle.ray(e.getMidpoint(), player.getMidpoint())) {
                e.seesPlayer = e.seesPlayer && true;
            } else {
                e.seesPlayer = false;
            }
        }
        if (e.seesPlayer) {
            e.playerPos.copyFrom(player.getMidpoint());
        }
    }

    private function doneFadeOut():Void {
        FlxG.switchState(new GameOverState(_won, _money));
    }
}
