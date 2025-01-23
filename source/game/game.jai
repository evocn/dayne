// Dayne
// Game
// November 2024

#load "entity.jai";
#load "physics/physics.jai";
#load "level-generator.jai";

Game :: struct {
    using constants : struct {
    }

    using internals : struct {
        arena : Flat_Pool;
        simulation: Simulation;

        entities    : [..] *Entity;
    }

    using data : struct {
        camera : struct {
            position : Pair;
            zoom : int;
        }

        gubble_one : *Gubble;
    }

    state : enum {
        GAMEPLAY;
        DEATH;
    }
}

apply_inputs :: (using input: Input, using game: *Game) {
    if #complete state == {
        case .GAMEPLAY;
            apply_inputs(input, gubble_one);

        case .DEATH;
            if input.a.just_pressed {
                reset(*arena);
                a: Allocator;
                a.proc = flat_pool_allocator_proc;
                a.data = *game.arena;
                initialize(game,, a);
                state = .GAMEPLAY;
            }
    }

}

initialize :: (using game: *Game) {
    // Create Entities
    {
        array_reset(*entities);
        array_reset(*simulation.actors);
        array_reset(*simulation.solids);

        {
            using gubble : *Gubble = xx new_entity(.GUBBLE);
            x = 16;
            y = 16;

            initialize(*animation, "Snork-Idle");

            array_add(*entities, xx gubble);
            array_add(*simulation.actors, *actor);

            gubble_one = gubble;
        }

        {
            using platform : *Platform = xx new_entity(.PLATFORM);
            width   = 16;
            height  = 16;
            x = 16;
            y = 0;

            initialize(*animation, "test-platform");

            array_add(*entities, xx platform);
            array_add(*simulation.solids, *solid);
        }

        // Bumpers
        {
            {
                using solid := New(Solid);
                width = 8;
                height = 100000;
                x = -8;
                y = 0;

                array_add(*simulation.solids, solid);
            }

            {
                using solid := New(Solid);
                width = 8;
                height = 100000;
                x = PIXEL_WIDTH;
                y = 0;

                array_add(*simulation.solids, solid);
            }
        }

        generate_level(*entities, *simulation);
    }

    // State
    {
        camera.position = .{0, 0};
        camera.zoom = 1;

        state = .GAMEPLAY;
    }
}

simulate :: (using game: *Game, dt: float) {
    if state == .DEATH then return;

    {
        for entity : entities {
            update(entity, dt);
        }
    }

    {
        debug_print(tprint("Simulated % entities", entities.count), yellow);
        debug_print(tprint("Camera: %", camera), yellow);
    }

    {
        for entity : entities {
            if entity.should_die then remove entity;
        }
    }

    // Determine what Gubble One can Slap.
    {
        array_reset(*gubble_one.victims);
        for entity : entities {
            if entity.kind == .BUBBLE {
                bubble := cast(*Bubble)entity;
                if collision(gubble_one.collider, bubble.collider) {
                    array_add(*gubble_one.victims, entity);
                }
            }
        }
    }

    // Death
    {
        if gubble_one.y + gubble_one.height < camera.position.y {
            gubble_one.should_die = true;
            state = .DEATH;
        }

        for entity : entities {
            if entity.kind == .ANNIE {
                annie := cast(*Annie)(entity);
                if collision(annie.collider, gubble_one.collider) {
                    gubble_one.should_die = true;
                    state = .DEATH;
                }
            }
        }

        for entity : entities {
            if entity.kind == {
                case .PLATFORM;
                    platform := cast(*Platform)(entity);
                    if platform.y + platform.height < camera.position.y {
                        platform.should_die = true;
                        array_unordered_remove_by_value(*simulation.solids, *platform.solid, stop_after_first = true);
                    }

                case .BUBBLE;
                    bubble := cast(*Bubble)(entity);
                    if bubble.y + bubble.height < camera.position.y {
                        entity.should_die = true;
                    }

                case .ANNIE;
                    annie := cast(*Annie)(entity);
                    if annie.y + annie.height < camera.position.y {
                        annie.should_die = true;
                        array_unordered_remove_by_value(*simulation.actors, *annie.actor, stop_after_first = true);
                    }
            }
        }
    }

    {
        camera.position = camera_follow_gubble(gubble_one.*, camera.position);
    }
}
