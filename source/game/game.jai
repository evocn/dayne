// Dayne
// Game
// November 2024

#load "entity.jai";
#load "entities/basic.jai";
#load "entities/platformer/guy.jai";
#load "entities/platformer/platform.jai";

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
            using platform : *Platform = xx new_entity(.PLATFORM);

            width  = 64;
            height = 16;

            array_add(*simulation.solids, *platform.solid);

            array_add(*entities, xx platform);
        }

        {
            using platform : *Platform = xx new_entity(.PLATFORM);

            width  = 64;
            height = 16;

            x = 96;
            y = 32;

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

    for entity : entities {
        update(entity, dt);
    }
}
