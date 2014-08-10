package ;

import haxe.io.Path;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;
import flixel.tile.FlxTilemap;

import flixel.text.FlxText;

import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectGroup;

class TiledLevel extends TiledMap {
    // For each "Tile Layer" in the map, you must define a "tileset" property
    // which contains the name of a tile sheet image used to draw tiles in that
    // layer (without file extension). The image file must be located in the
    // directory specified bellow.
    private inline static var c_PATH_LEVEL_TILESHEETS = "assets/images/";

    // Array of tilemaps used for collision
    public var foregroundTiles:FlxGroup;
    public var backgroundTiles:FlxGroup;
    public var collidableTileLayers:Array<FlxTilemap>;
    public var coins:FlxTypedGroup<Coin>;
    public var enemies:FlxTypedGroup<Enemy>;

    public function new(tiledLevel:Dynamic) {
        super(tiledLevel);

        foregroundTiles = new FlxGroup();
        backgroundTiles = new FlxGroup();

        FlxG.camera.setBounds(0, 0, fullWidth, fullHeight, true);

        // Load Tile Maps
        for (tileLayer in layers) {
            // Get the tileset name used for this layer
            var tileSheetName:String = tileLayer.properties.get("tileset");
            if (tileSheetName == null) {
                throw "'tileset' property not defined for the '" +
                    tileLayer.name + "' layer. Please add the property to " +
                    "the layer.";
            }

            // Look for the tileset
            var tileSet:TiledTileSet = null;
            for (ts in tilesets) {
                if (ts.name == tileSheetName) {
                    tileSet = ts;
                    break;
                }
            }
            if (tileSet == null) {
                throw "Tileset '" + tileSheetName + " not found. Did you " +
                    "mispell the 'tilesheet' property in " + tileLayer.name +
                    "' layer?";
            }

            // Load the tiles image
            var imagePath = new Path(tileSet.imageSource);
            var processedPath = c_PATH_LEVEL_TILESHEETS + imagePath.file +
                "." + imagePath.ext;

            // Create the map itself (one per layer)
            var tilemap:FlxTilemap = new FlxTilemap();
            tilemap.widthInTiles = width;
            tilemap.heightInTiles = height;
            tilemap.loadMap(tileLayer.tileArray, processedPath,
                tileSet.tileWidth, tileSet.tileHeight, 0, tileSet.firstGID,
                1, 1);

            // Classify it based on collision property
            if (tileLayer.properties.contains("nocollide")) {
                backgroundTiles.add(tilemap);
            } else {
                if (collidableTileLayers == null) {
                    collidableTileLayers = new Array<FlxTilemap>();
                }

                foregroundTiles.add(tilemap);
                collidableTileLayers.push(tilemap);
            }
        }
    }

    public function loadObjects(state:PlayState) {
        for (group in objectGroups) {
            for (o in group.objects) {
                loadObject(o, group, state);
            }
        }
    }

    private function loadObject(o:TiledObject, g:TiledObjectGroup, state:PlayState) {
        var x:Int = o.x;
        var y:Int = o.y;

        // Objects in Tiled are aligned bottom-left (top-left in flixel)
        if (o.gid != -1) {
            y -= g.map.getGidOwner(o.gid).tileHeight;
        }

        switch (o.type.toLowerCase()) {
            case "player_start":
                state.player = new Player(x, y);
            case "coin":
                if (coins == null) {
                    coins = new FlxTypedGroup<Coin>();
                }
                coins.add(new Coin(x + 4, y + 4));
            case "enemy":
                if (enemies == null) {
                    enemies = new FlxTypedGroup<Enemy>();
                }
                enemies.add(new Enemy(x, y, Std.parseInt(o.custom.get("etype"))));
        }
    }

    public function collideWithLevel(obj:FlxObject, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool {
        if (collidableTileLayers != null) {
            for (map in collidableTileLayers) {
                // IMPORTANT: Always collide the map with objects, not the
                // other way around. This prevents odd collision errors
                // (collision separation code off by 1 px).
                if (FlxG.overlap(map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate)) {
                    return true;
                }
            }
        }
        return false;
    }
}
