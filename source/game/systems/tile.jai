// Dayne
// Tile
// December 2024

Tile :: struct {
    using solid : Solid;
    sprite_frame: int;
    index : int;
}

draw :: (using tile: Tile) {
    draw_sprite_relative_to_collider(
        collider, "level-sheet", sprite_frame, false, use_color_override = true, color_override = green
    );
}

draw_debug :: (using tile: Tile) {
    draw(collider, color=random_color_from_seed(xx index));
}

//
// Templates.
//

tile_templates : struct {
    empty :: Tile.{
        solid.width = 0,
        solid.height = 0,
        sprite_frame = 0,
    };

    block :: Tile.{
        solid.width  = TILE_SIZE,
        solid.height = TILE_SIZE,
        sprite_frame = 15,
    };

    half :: Tile.{
        solid.width  = TILE_SIZE,
        solid.height = TILE_SIZE / 2,
        solid.one_way = true,
        sprite_frame = 4,
    };

    ladder :: Tile.{
        solid.width  = TILE_SIZE,
        solid.height = TILE_SIZE,
        solid.collidable = false,
        sprite_frame = 16,
    };

    goal :: Tile.{
        solid.width  = TILE_SIZE,
        solid.height = TILE_SIZE,
        solid.collidable = false,
        sprite_frame = 17,
    };
}

tile_template_from_character :: (tile: *Tile, char: u8) {
    if char == {
        case #char "0"; tile.* = tile_templates.empty;
        case #char "1"; tile.* = tile_templates.block;
        case #char "H"; tile.* = tile_templates.half;
        case #char "L"; tile.* = tile_templates.ladder;
        case #char "G"; tile.* = tile_templates.goal;
        case; {
            print("Bad level template. %\n", char);
        }
    }
}
