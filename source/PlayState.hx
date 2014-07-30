package ;

import flixel.FlxState;

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
		// Load player objects
		_map.loadObjects(this);
		add(player);
		// Add background tiles after adding level objects, so these tiles render on top of player
		add(_map.backgroundTiles);

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
	}
}
