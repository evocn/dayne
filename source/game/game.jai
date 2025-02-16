// Dayne
// Game
// November 2024

#load "entity.jai";

#load "systems/decision.jai";

Game :: struct {
    using constants : struct {
    }

    using internals : struct {
        arena : Flat_Pool;

        simulation: Simulation;
        entities    : [..] *Entity;
    }

    using spine : struct {
    }

    using state : struct {
        camera : struct {
            position : Pair;
            zoom : int;
        }

        the_hero : *Hero;

        stage : enum {
            WALKING;
            DECISION;
        }

        // Walking-specific state

        // Decision-specific state
        decision : *Decision;
    }
}

apply_inputs :: (using game: *Game, input: Input) {
    if #complete stage == {
        case .WALKING;
            apply_inputs(input, the_hero);

        case .DECISION;
            apply_inputs(decision, input);
    }
}

simulate :: (using game: *Game, dt: float) {
    debug_print(tprint("Stage: %", stage), yellow);

    // Check for systems state.
    if #complete stage == {
        case .WALKING;

            for entity : entities {
                update(entity, dt);
            }

            debug_print(tprint("Simulated % entities", entities.count), yellow);
            debug_print(tprint("Camera: %", camera), yellow);


            for entity : entities {
                if entity.kind == .ARTIFACT {
                    artifact := cast(*Artifact)entity;
                    if artifact.decision.locked_in then continue;
                    if collision(the_hero.collider, artifact.collider) && !artifact.decision.locked_in {
                        decision = *artifact.decision;
                        stage = .DECISION;
                        break;
                    }
                }
            }

        case .DECISION;
            if decision.locked_in {
                consequence := decision.choices[decision.selected].consequence;
                if consequence {
                    consequence(game);
                }

                decision.locked_in = false;
                decision = null;
                stage = .WALKING;
            }

        for entities {
            if it.should_die then remove it;
        }
    }
}

initialize :: (using game: *Game) {
    // Create Entities
    {
        {
            using obelisk : *Artifact = xx new_entity(.ARTIFACT);

            name = "Obelisk";

            width  = 16;
            height = 128;

            x = 32;

            initialize(*animation, "Monolith");

            {
                decision.question = "Destroy the Accursed Obelisk?";

                destroy_obelisk :: (game: *Game) {
                    for game.entities {
                        if it.kind == .ARTIFACT {
                            artifact := cast(*Artifact)it;
                            if artifact.name == "Obelisk" then artifact.should_die = true;
                            play_sfx("thunder");
                            break;
                        }
                    }

                    {
                        using broken_obelisk : *Artifact = xx new_entity(.ARTIFACT);

                        name = "Broken Obelisk";

                        width  = 16;
                        height = 128;

                        x = 32;

                        decision.locked_in = true;

                        initialize(*animation, "Monolith-Broken");
                        array_add(*game.entities, xx broken_obelisk);
                    }
                }

                array_add(*decision.choices, .{text = "no"});
                array_add(*decision.choices, .{text = "yes", consequence = destroy_obelisk});
            }

            array_add(*entities, xx obelisk);
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

finalize :: (using game: *Game) {
    reset(*arena, overwrite_memory=true);
    reset(*simulation);
}
