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

		// Make the camera follow the player
		FlxG.camera.follow(player, FlxCamera.STYLE_TOPDOWN, 1);

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
	}

	private function playerTouchCoin(player:Player, coin:Coin):Void {
		if (player.alive && player.exists && coin.alive && coin.exists) {
			coin.kill();
		}
	}
}
