package ;

import flixel.FlxG;
import flixel.group.FlxGroup;

import flixel.addons.editors.tiled.TiledMap;

class TiledLevel extends TiledMap {

    // For each "Tile Layer" in the map, you must define a "tileset" property
    // which contains the name of a tile sheet image used to draw tiles in that
    // layer (without file extension). The image file must be located in the
    // directory specified bellow.
    private inline static var c_PATH_LEVEL_TILESHEETS = "assets/images/";

    public var walls:FlxGroup;

    public function new(tiledLevel:Dynamic) {
        super(tiledLevel);

        walls = new FlxGroup();

        FlxG.camera.setBounds(0, 0, fullWidth, fullHeight, true);

        // Load Tile Maps
        for (tileLayer in layers) {
            // TODO
        }
    }
}
