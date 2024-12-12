// Dayne
// Room
// December 2024

Room :: struct {
    width   :: 20;
    height  :: 20;

    tiles : [width * height] Tile;
    spawn_point : Pair;
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

register :: (using room : *Room) {
    for * tile, index : tiles {
        col :=          index % width;
        row := height - index / width - 1;

        // Set colliders up
        {
            if tile.width != 0 && tile.height != 0 {
                tile.x = TILE_SIZE * col;
                tile.y = TILE_SIZE * row;

                array_add(*game.simulation.solids, *tile.solid);
            }
        }
    }
}

unregister :: (using room : *Room) {
    for tile : tiles {
        if tile.width != 0 && tile.height != 0 {
            array_unordered_remove_by_value(*game.simulation.solids, *tile.solid);
        }
    }
}

//
// Templates.
//

room_from_text :: (using room: *Room, template: string) {
    no_newlines := replace(template, "\n", "",, temp);

    for char, index : no_newlines {
        tile_template_from_character(*room.tiles[index], char);
        room.tiles[index].index = index;
    }
}


Room_Data :: struct {
    spawn_point : Pair;
    layout : *string;
}

instantiate_room_data :: () -> Table(string, Room_Data) {
    all_rooms : Table(string, Room_Data);

    table_add(*all_rooms,
        "test",
        Room_Data.{
            spawn_point = Pair.{153, 112},
            layout = *room_layouts[0],
        }
    );

    return all_rooms;
}

room_layouts :: string.[
#string one_one
00000000000000000000
00000000000000000000
01010101010101010101
00000000000000000000
10000000000000000001
00000000000000000000
10101010101010101010
00000000000000000000
00000000111100000000
00000000000000000000
00011100000000111000
00000000000000000000
11000000000000000011
00000001111110000000
00000000000000000000
00111100000000111100
00000000000000000000
00000000000000000000
00011100111100111000
00000000000000000000
one_one
,
];

// Ensure that all templates fit the size of the room + newlines.
#run {
    expected_string_length :: Room.width * Room.height + Room.height;

    for template : room_layouts {
        if template.count != expected_string_length {
            print("This room template is the wrong length. We expect them to be % but your template is %.\n", template.count, expected_string_length);
            print("%\n", template);
            assert(false);
        }
    }
}
