// Dayne
// Dungeon
// December 2024

Dungeon :: struct {
    width   :: 4;
    height  :: 4;

    rooms : [width * height] Room;
    current : int;
}

make_dungeon :: (all_rooms : Table(string, Room_Data)) -> Dungeon {
    using dungeon : Dungeon;

    for * room, index : rooms {
        col :=          index % width;
        row := height - index / width;

        room_data := table_find_pointer(*all_rooms, "test");
        assert(room_data != null);

        room_from_text(room, room_data.layout.*);
        room.spawn_point = room_data.spawn_point;
        break;
    }

    return dungeon;
}
