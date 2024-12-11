// Dayne
// Game
// November 2024

#load "entity.jai";
#load "entities/basic.jai";
#load "entities/guy.jai";
#load "entities/platform.jai";

#load "systems/level.jai";
#load "systems/level-generator.jai";

#load "physics/physics.jai";

Game :: struct {
    using constants : struct {
    }

    using data : struct {
    }

    using internals : struct {
        arena : Flat_Pool;

        debug : Debug;
    }

    using state : struct {
        simulation: Simulation;

        entities    : [..] *Entity;
        p1 : *Guy;
        level : Level;
    }

    camera : struct {
        position : Pair;
        zoom : int;
    }
}

initialize :: (using game: *Game) {
    {
        camera.position = .{};
        camera.zoom = 1;
    }

    // Create Entities
    {
        /*
        {
            using basic : *Basic = xx new_entity(.BASIC);

            width  = 16;
            height = 16;

            initialize(*animation, "Frog-Idle");

            array_add(*entities, xx basic);
        }
        */

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
            level = generate_level();
        }

        {
            using platform : *Platform = xx new_entity(.PLATFORM);

            width  = 64;
            height = 16;

            array_add(*simulation.solids, *platform.solid);

            array_add(*entities, xx platform);
        }
    }
}

apply_input :: (using game: *Game, input: Input) {
    apply_input(p1, input);
}

update :: (using game: *Game, dt: float) {
    {
        reset(*debug);
    }

    // Camera
    {
        camera.position = get_camera_centered_on_position_within_level_extents(p1.position, level);
    }

    // Entities
    for entity : entities {
        update(entity, dt);
    }
}

get_camera_centered_on_position_within_level_extents :: (position : Pair, level : Level) -> Pair {
    // How much leeway you get on either side of the level.
    threshold :: PIXEL_WIDTH / 3;
    level_extents :: Collider.{.{0, 0}, Level.ROOM_COUNT * Room.WIDTH * TILE_SIZE, Room.HEIGHT * TILE_SIZE};

    result : Pair;

    result.y = 0;
    result.x = position.x - threshold;

    result.x = clamp(result.x, level_extents.x, level_extents.width - PIXEL_WIDTH);

    return result;
}
