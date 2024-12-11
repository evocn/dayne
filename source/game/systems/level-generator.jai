// Dayne
// Level Generator
// December 2024

generate_level :: () -> Level {
    using level : Level;

    for * room, room_index : rooms {
        template := random_choice(room_templates);
        room_from_template(room, template);

        room_base_x_offset := room_index * TILE_SIZE * Room.WIDTH;
        for * tile, index : room.tiles {
            if tile.width == 0 || tile.height == 0 then continue;

            x_position_in_room := TILE_SIZE * (index % Room.WIDTH);
            tile.x = room_base_x_offset + x_position_in_room;
            tile.y = TILE_SIZE * (index / Room.WIDTH);

            array_add(*game.simulation.solids, *tile.solid);
        }
    }

    return level;
}

//
// Templates.
//

room_from_template :: (room: *Room, template: string) {
    no_newlines := replace(template, "\n", "",, temp);

    for char, index : no_newlines {
        room.tiles[index] = tile_template_from_character(char);
    }
}

room_templates :: string.[
#string end
00000G0000
0000111000
0000000000
0110000000
0000000000
0000111100
0000000000
0000000000
0000111000
0000000000
0110000000
0000000000
end
,

#string end
0000000000
0000000000
0001111000
0000000000
0000000000
0001111000
0000000000
0000000000
0001111000
0000000000
0000000000
0001111000
end
,

#string end
0000100000
0000100000
0000100000
0000100000
0000000000
0000000000
0000000000
0000000000
0000100000
0000100000
0000100000
0000100000
end
,
];

// Ensure that all templates fit the size of the room + newlines.
#run {
    expected_string_length :: Room.WIDTH * Room.HEIGHT + Room.HEIGHT;

    for template : room_templates {
        if template.count != expected_string_length {
            print("This room template is the wrong length. We expect them to be % but your template is %.\n", template.count, expected_string_length);
            print("%\n", template);
            assert(false);
        }
    }
}
