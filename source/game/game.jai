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
    }
}

apply_inputs :: (using input: Input, game: *Game) {
}

initialize :: (using game: *Game) {
    // Create Entities
    {
        {
            using basic : *Basic = xx new_entity(.BASIC);

            width  = 16;
            height = 16;

            y = PIXEL_HEIGHT - height;

            initialize(*animation, "Frog-Idle");

            array_add(*entities, xx basic);
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
