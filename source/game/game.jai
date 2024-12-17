// Dayne
// Game
// November 2024

#load "entity.jai";
#load "entities/basic.jai";
#load "entities/guy.jai";
#load "entities/platform.jai";

#load "systems/dungeon.jai";
#load "systems/room.jai";
#load "systems/tile.jai";

#load "physics/physics.jai";

Game :: struct {
    using constants : struct {
    }

    using data : struct {
    }

    using internals : struct {
        arena : Flat_Pool;
    }

    using state : struct {
        simulation: Simulation;

        entities    : [..] *Entity;
        p1 : *Guy;
        dungeon : Dungeon;
    }

    camera : struct {
        position : Pair;
        zoom : int;
    }
}

initialize :: (using game: *Game) {
    // Create Entities
    {
        {
            using basic : *Basic = xx new_entity(.BASIC);

            width  = 16;
            height = 16;
            x = PIXEL_WIDTH - TILE_SIZE;
            y = PIXEL_HEIGHT - TILE_SIZE;
            facing_left = true;

            initialize(*animation, "Frog-Idle");

            array_add(*entities, xx basic);
        }

        {
            using guy : *Guy = xx new_entity(.GUY);

            width  = 14;
            height = 14;

            y = 16;

            initialize(*animations.idle,    "Bird-Idle",    speed = 0.2);
            initialize(*animations.walk,    "Bird-Dance",   speed = 0.3);
            initialize(*animations.jump,    "Bird-Jump");
            initialize(*animations.glide,   "Bird-Glide");
            initialize(*animations.fall,    "Bird-Fall");
            animation = *animations.idle;

            array_add(*simulation.actors, *guy.actor);

            array_add(*entities, xx guy);
            p1 = guy;
        }

        {
            using dungeon;

            all_rooms := instantiate_room_data();
            dungeon = make_dungeon(all_rooms);

            register(*rooms[current]);
        }

    }

    // Real Initialize stuff
    {
        camera.position = .{};
        camera.zoom = 1;

        p1.position = dungeon.rooms[dungeon.current].spawn_point;
    }
}

apply_input :: (using game: *Game, input: Input) {
    apply_input(p1, input);
}

update :: (using game: *Game, dt: float) {
    // Camera
    {
        //camera.position = get_camera_centered_on_position(p1.position);
        camera.position = .{};
    }

    // Entities
    for entity : entities {
        update(entity, dt);
    }
}

get_camera_centered_on_position :: (position : Pair) -> Pair {
    from_the_left   := PIXEL_WIDTH / 2;
    from_the_bottom := PIXEL_WIDTH / 6;

    result := Pair.{
        x = position.x - from_the_left,
        y = position.y - from_the_bottom,
    };

    return result;
}

/*
// For overworld
level_extents :: Collider.{.{0, 0}, Level.width * Room.width * TILE_SIZE, Level.height * Room.height * TILE_SIZE};
get_camera_centered_on_position_within_extents :: (position : Pair, extents: Collider) -> Pair {
    // How much leeway you get on either side of the extents.
    threshold :: PIXEL_WIDTH / 3;

    result : Pair;

    result.y = 0;
    result.x = position.x - threshold;

    result.x = clamp(result.x, extents.x, extents.width - PIXEL_WIDTH);

    return result;
}
*/
