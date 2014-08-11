package ;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxCamera;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState {
	public var player:Player;
	private var _map:TiledLevel;
	private var _hud:HUD;
	private var _money:Int = 0;
	private var _health:Int = 3;

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
		add(_map.coins);
		add(player);
		// Add enemies
		add(_map.enemies);
		// Make the camera follow the player
		FlxG.camera.follow(player, FlxCamera.STYLE_TOPDOWN, 1);
		// Prepare the HUD
		_hud = new HUD();
		add(_hud);

		super.create();
	}

	/**
	 * Function that is called when this state is destroyed - you might want to
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void {
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void {
		super.update();

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
	}

	private function playerTouchCoin(player:Player, coin:Coin):Void {
		if (player.alive && player.exists && coin.alive && coin.exists) {
			coin.kill();
			_money++;
			_hud.updateHUD(_health, _money);
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
}
