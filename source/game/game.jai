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

            {
                idle_animation = New(Sprite_Animation);
                initialize(idle_animation, "Snork-Idle", speed = 1.0);

                slap_animation = New(Sprite_Animation);
                initialize(slap_animation, "Snork-Parry", speed = 3.0);

                animation = idle_animation;

                state = .NEUTRAL;
            }

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

        {
            using god : *God = xx new_entity(.GOD);
            z_index = -1000;

            width   = 192;
            height  = 224;
            x = 0;
            y = (floors + 1) * TILE_SIZE_IN_PIXELS * tiles_high + 32;

            initialize(*animation, "Gubble");

            initialize(*hand_animation, "Hand");
            hand_collider.width = 96;
            hand_collider.height = 32;
            hand_collider.x = 0;
            hand_collider.y = 0;
            hand_collider.y = (floors + 1) * TILE_SIZE_IN_PIXELS * tiles_high;

            array_add(*entities, xx god);
        }

        {
            using platform : *Platform = xx new_entity(.PLATFORM);
            width   = 16;
            height  = 16;
            x = 144;
            y = (floors + 1) * TILE_SIZE_IN_PIXELS * tiles_high;

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
        debug_print(tprint("Snork: % % %", gubble_one.state, gubble_one.animation.sprite_name, gubble_one.cooldown), teal);
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
                slap_hitbox := Collider.{
                    .{
                        gubble_one.x - gubble_variables.slap_hitbox_size / 4,
                        gubble_one.y - gubble_variables.slap_hitbox_size / 4
                    },
                    gubble_variables.slap_hitbox_size,
                    gubble_variables.slap_hitbox_size
                };

                if collision(slap_hitbox, bubble.collider) {
                    array_add(*gubble_one.victims, entity);
                }
            }
        }
    }

    /*
    {
        // Determine what Gubble One can Pop.
        {
            array_reset(*gubble_one.pop_victims);
            for entity : entities {
                collider : *Collider;

                if      entity.kind == .BUBBLE then collider = *(cast(*Bubble)entity).collider;
                else if entity.kind == .ANNIE  then collider = *(cast(*Annie)entity).collider;
                else continue;

                pop_hitbox := Collider.{
                    .{
                        gubble_one.x - gubble_variables.pop_hitbox_size / 2,
                        gubble_one.y - gubble_variables.pop_hitbox_size / 2
                    },
                    gubble_variables.pop_hitbox_size,
                    gubble_variables.pop_hitbox_size
                };

                if collision(pop_hitbox, collider) {
                    array_add(*gubble_one.victims, entity);
                }
            }
        }
    }
    */

    // Death
    {

        if gubble_one.y + gubble_one.height + 1 < camera.position.y {
            gubble_one.should_die = true;
            state = .DEATH;
            play_sfx("Death-fall");
        }

        for entity : entities {
            if entity.kind == .ANNIE {
                annie := cast(*Annie)(entity);
                if collision(annie.collider, gubble_one.collider) {
                    gubble_one.should_die = true;
                    state = .DEATH;
                    play_sfx("Death-annie");
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
        clamp(camera.position.y, 0, (floors + 1) * TILE_SIZE_IN_PIXELS * tiles_high);
    }
}
