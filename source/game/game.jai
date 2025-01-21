// Dayne
// Game
// November 2024

#load "entity.jai";
#load "physics/physics.jai";

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

        gubble_one : *Gubble;
    }
}

apply_inputs :: (using input: Input, using game: *Game) {
    apply_inputs(input, gubble_one);
}

initialize :: (using game: *Game) {
    // Create Entities
    {
        {
            using gubble : *Gubble = xx new_entity(.GUBBLE);
            x = 16;
            y = 16;

            initialize(*animation, "Gubble-Idle");

            array_add(*entities, xx gubble);
            array_add(*simulation.actors, *actor);

            gubble_one = gubble;
        }

        {
            using platform : *Platform = xx new_entity(.PLATFORM);
            width   = 32;
            height  = 8;
            x = 0;
            y = 8;

            initialize(*animation, "test-platform");

            array_add(*entities, xx platform);
            array_add(*simulation.solids, *solid);
        }

        {
            using platform : *Platform = xx new_entity(.PLATFORM);
            width   = 32;
            height  = 8;
            x = 64;
            y = 8;

            initialize(*animation, "test-platform");

            array_add(*entities, xx platform);
            array_add(*simulation.solids, *solid);
        }

        /*
        {
            using basic : *Basic = xx new_entity(.BASIC);
            width  = 16;
            height = 16;

            initialize(*animation, "Frog-Idle");

            array_add(*entities, xx basic);
        }
        */
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
