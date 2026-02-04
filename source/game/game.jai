
// Game

// This set of files is where gameplay data is kept.
// There is a base "Game" primitive, which stores all the internal data for the game.
// In addition, "Entity" is next door, and under entities/, the types of the game are defined.

////////////////////////////////////////////////////////////////////////////////

#load "entity.jai";

Game :: struct {
    using constants : struct {
    }

    using internals : struct {
        arena : Flat_Pool;
        allocator : Allocator;

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
        {
            using basic : *Basic = xx new_entity(.BASIC);

            width  = 16;
            height = 16;

            y = PIXEL_HEIGHT - height;

            initialize(*animation, "Frog-Idle");

            array_add(*entities, xx basic);
        }

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
            for 0..5 {
                {
                    using tester : *Solid_Tester = xx new_entity(.SOLID_TESTER);

                    width   = 16;
                    height  = 16;

                    x = cast(int, 2.5 * it * width);
                    y = 64;

                    //solid.collidable = false;

                    initialize(*animation, "Frog-Idle");

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

finalize :: (using game: *Game) {
    reset(*arena, overwrite_memory=true);
    reset(*simulation);
}

////////////////////////////////////////////////////////////////////////////////

simulate :: (using game: *Game, dt: float) {
    for entity : entities {
        update(entity, dt);
    }

    debug_print(tprint("Simulated % entities", entities.count), yellow);
    debug_print(tprint("Camera: %", camera), yellow);

    {
        visuals := Button_Visuals_Default;
        visuals.colors.box.neutral = color_none;
        visuals.colors.outline.neutral = color_none;

        margin :: 10;
        box := Box.{PIXEL_WIDTH - 40 - margin, margin, 10, 10};
        if button(box, "<&1", visuals = visuals) {
        }
        box.x += 12;

        if button(box, ">&1", visuals = visuals) {
        }
        box.x += 12;
    }
}

////////////////////////////////////////////////////////////////////////////////

draw_game :: (game : Game) {
    z_sort :: (entities: [..] *Entity) {
        comparison :: (a: *Entity, b: *Entity) -> int { 
            if a.z_index > b.z_index        return 1;
            else if a.z_index < b.z_index   return -1;
            else return b.id - a.id;
        }
        quick_sort(entities, comparison);
    }

    // Entities
    {
        z_sort(game.entities);

        use_sprite_shader();
        for entity : game.entities {
            draw(entity);
        }
    }

    #if DEVELOPER_TOOLS {
        if program_state.show_debug_info {

            // This is dumb code, which works since most entities' "draw_debug()" just draws a dumb quad.
            // The more full-featured solution to this (and the use_sprite_shader() above) is to do actual batching of draw calls.
            // For now, we're cool.
            use_basic_shader();

            for entity : game.entities {
                draw_debug(entity);
            }
        }
    }
}
