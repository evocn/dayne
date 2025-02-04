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

        input_guy : *Collision_Tester;
    }
}

apply_inputs :: (using input: Input, game: *Game) {
    apply_inputs(input, game.input_guy);
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

        {
            using tester : *Collision_Tester = xx new_entity(.COLLISION_TESTER);

            width   = 16;
            height  = 16;

            initialize(*animation, "Frog-Walk");

            array_add(*entities, xx tester);

            array_add(*simulation.actors, *actor);

            input_guy = tester;
        }

        {
            for 0..10000 {
                {
                    using tester : *Solid_Tester = xx new_entity(.SOLID_TESTER);

                    width   = 16;
                    height  = 16;

                    x = it * width;
                    y = 64;

                    array_add(*entities, xx tester);

                    array_add(*simulation.solids, *solid);
                }
            }
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
