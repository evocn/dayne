// Dayne
// Game
// November 2024

#load "entity.jai";
#load "entities/basic.jai";

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
    }

    camera : struct {
        position : Pair;
        zoom : int;
    }
}

apply_inputs :: (using input: Input, game: *Game) {
}

initialize :: (using game: *Game) {
    {
        camera.position = .{};
        camera.zoom = 1;
    }

    // Create Entities
    {
        basic : *Basic = xx new_entity(.BASIC);
        {
            using basic;
            width  = 16;
            height = 16;

            initialize(*animation, "Frog-Idle");
        }
        array_add(*entities, xx basic);
    }
}

simulate :: (using game: *Game, dt: float) {
    for entity : entities {
        update(entity, dt);
    }
}
