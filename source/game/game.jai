// Dayne
// Game
// November 2024

#load "entity.jai";

Game :: struct {
    using constants : struct {
    }

    using internals : struct {
        arena : Flat_Pool;

        simulation: Simulation;
        entities    : [..] *Entity;
    }

    using state : struct {
        camera : struct {
            position : Pair;
            zoom : int;
        }

        the_hero : *Hero;
    }
}

apply_inputs :: (using input: Input, game: *Game) {
    apply_inputs(input, game.the_hero);
}

initialize :: (using game: *Game) {
    // Create Entities
    {
        /*
        {
            using basic : *Basic = xx new_entity(.BASIC);

            width  = 16;
            height = 16;

            y = PIXEL_HEIGHT - height;

            initialize(*animation, "Frog-Idle");

            array_add(*entities, xx basic);
        }
        */

        // @TODO: Make a "Prop" entity.
        {
            using basic : *Basic = xx new_entity(.BASIC);

            width  = 16;
            height = 128;

            x = 32;

            initialize(*animation, "Monolith");

            array_add(*entities, xx basic);
        }

        {
            using hero : *Hero = xx new_entity(.HERO);

            width  = 16;
            height = 32;

            x = PIXEL_WIDTH / 2 - width;

            idle := table_add(*animations, "idle", .{});
            initialize(idle, "Monk-Idle", speed = 0.2);

            walk := table_add(*animations, "walk", .{});
            initialize(walk, "Monk-Walk", speed = 0.6);

            point := table_add(*animations, "point", .{});
            initialize(point, "Monk-Point", speed = 1.0);

            animation = idle;

            array_add(*entities, xx hero);

            the_hero = hero;
        }
    }

    // State
    {
        camera.position = .{};
        camera.zoom = 1;
    }
}

simulate :: (using game: *Game, dt: float) {
    for entity : entities {
        update(entity, dt);
    }

    debug_print(tprint("Simulated % entities", entities.count), yellow);
    debug_print(tprint("Camera: %", camera), yellow);
}

finalize :: (using game: *Game) {
    reset(*arena, overwrite_memory=true);
    reset(*simulation);
}
