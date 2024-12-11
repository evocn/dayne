// Dayne
// Level
// December 2024

Level :: struct {
    ROOM_COUNT :: 3;
    rooms : [ROOM_COUNT] Room;
}

draw :: (using level: Level) {
    for room : rooms {
        draw(room);
    }
}

draw_debug :: (using level: Level) {
    for room : rooms {
        draw_debug(room);
    }
}

//
//
//

Room :: struct {
    WIDTH :: 10;
    HEIGHT :: 12;

    tiles : [WIDTH * HEIGHT] Tile;
}

draw :: (using room : Room) {
    for tile : tiles {
        draw(tile);
    }
}

draw_debug :: (using room : Room) {
    for tile : tiles {
        draw_debug(tile);
    }
}

//
//
//

Tile :: struct {
    using solid : Solid;
    sprite_frame: int;
}

draw :: (using tile: Tile) {
    draw_sprite_relative_to_collider(
        collider, "level-sheet", sprite_frame, false,
    );
}

draw_debug :: (using tile: Tile) {
    draw(collider, color=white);
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

tile_template_from_character :: (char: u8) -> Tile {
    if char == {
        case #char "0"; return tile_templates.empty;
        case #char "1"; return tile_templates.block;
        case #char "H"; return tile_templates.half;
        case #char "L"; return tile_templates.ladder;
        case #char "G"; return tile_templates.goal;
        case; {
            print("Bad level template. %\n", char);
            return .{};
        }
    }
}
